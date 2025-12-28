# ======================================================
# TRIPFINITY TWO-TOWER SERVER (ENHANCED MULTI-FACTOR)
# Logic: 5 Items (Latest Context) + 5 Items (History Context)
# Architecture: Enhanced Two-Tower with Content-Based Filtering
# Features: Geo-Location + Price Similarity + Amenities Matching + Category/Type Matching
# ======================================================
from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
from sqlalchemy import create_engine
import traceback
import json

app = Flask(__name__)
CORS(app)

# --- 1. CONFIG DATABASE ---
DB_CONFIG = {
    'user': 'root', 'password': 'sqlpass', 
    'host': 'localhost', 'database': 'tripfinity', 'port': 3306
}
db_connection_str = f"mysql+mysqlconnector://{DB_CONFIG['user']}:{DB_CONFIG['password']}@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"

try:
    db_engine = create_engine(db_connection_str)
    print("✅ Database Connected (Enhanced Multi-Factor Mode).")
except Exception as e:
    print(f"❌ DB Connection Error: {e}")
    exit()

# ======================================================
# SCORING WEIGHTS CONFIGURATION (Có thể điều chỉnh)
# ======================================================
SCORING_WEIGHTS = {
    'geo_proximity': 0.40,      # Khoảng cách địa lý (Ưu tiên cao nhất)
    'price_similarity': 0.25,   # Độ tương đồng giá cả
    'feature_match': 0.35       # Khớp đặc trưng (amenities + category + type-specific)
}
# Lưu ý: star_rating chỉ áp dụng cho HOTEL (cấp sao khách sạn), không phải đánh giá user

# ======================================================
# SERVICE-SPECIFIC FEATURES CONFIGURATION
# Định nghĩa đặc trưng riêng cho từng loại dịch vụ
# ======================================================
SERVICE_FEATURES = {
    'hotel': {
        'primary_features': ['amenities_json', 'property_type', 'star_rating'],
        'description': 'Khách sạn/Lưu trú',
        'matching_fields': {
            'amenities_json': 'Tiện ích (WiFi, Hồ bơi, Spa...)',
            'property_type': 'Loại hình (Hotel, Resort, Villa, Homestay...)',
            'star_rating': 'Cấp sao khách sạn (1-5 sao)'
        }
    },
    'tour': {
        'primary_features': ['categories_json', 'tour_type', 'difficulty_level'],
        'description': 'Tour du lịch',
        'matching_fields': {
            'categories_json': 'Thể loại tour (Adventure, Cultural, Nature...)',
            'tour_type': 'Kiểu tour (Group, Private, Custom)',
            'difficulty_level': 'Độ khó (Easy, Moderate, Hard)'
        }
    },
    'restaurant': {
        'primary_features': ['cuisines_json', 'diets_json', 'categories_json'],
        'description': 'Nhà hàng/Ẩm thực',
        'matching_fields': {
            'cuisines_json': 'Ẩm thực (Vietnamese, Japanese, Italian...)',
            'diets_json': 'Chế độ ăn (Vegetarian, Vegan, Halal...)',
            'categories_json': 'Loại hình (Fine Dining, Street Food, Cafe...)'
        }
    },
    'attraction': {
        'primary_features': ['attraction_type', 'suitable_for_json', 'categories_json'],
        'description': 'Điểm tham quan',
        'matching_fields': {
            'attraction_type': 'Loại điểm đến (Museum, Temple, Park, Beach...)',
            'suitable_for_json': 'Phù hợp với (Family, Couples, Solo...)',
            'categories_json': 'Danh mục (Cultural, Nature, Entertainment...)'
        }
    }
}

# ======================================================
# CORE MODEL: ENHANCED TWO TOWER CLASS
# ======================================================

class TripfinityTwoTowerModel:
    def __init__(self, engine):
        self.engine = engine
        self.EARTH_RADIUS = 6371
        self.weights = SCORING_WEIGHTS

    # --------------------------------------------------
    # TOWER A: USER TOWER (Xử lý đặc trưng người dùng)
    # Output: User Profile Vector với preferences đa chiều
    # --------------------------------------------------
    def user_tower_layer(self, user_id):
        query = f"""
            SELECT 
                ui.item_id, ui.item_type, ui.interaction_timestamp,
                it.title, it.latitude, it.longitude, it.price,
                it.star_rating, it.property_type, it.difficulty_level,
                it.tour_type, it.attraction_type,
                it.amenities_json, it.categories_json, 
                it.cuisines_json, it.diets_json, it.suitable_for_json
            FROM user_item_interactions ui
            JOIN ai_item_tower it ON ui.item_id = it.item_id AND ui.item_type = it.item_type
            WHERE ui.user_id = {user_id}
            ORDER BY ui.interaction_timestamp DESC 
            LIMIT 10
        """
        try:
            df = pd.read_sql(query, self.engine)
            if df.empty: return None
            
            # --- Phân tích User Preferences (Content-Based) ---
            user_preferences = self._extract_user_preferences(df)
            
            # --- VECTOR 1: LATEST (Mới nhất - Index 0) ---
            latest_row = df.iloc[0]
            latest_vec = {
                'lat': float(latest_row['latitude']),
                'lon': float(latest_row['longitude']),
                'item_id': latest_row['item_id'],
                'item_type': latest_row['item_type'],
                'title': latest_row['title'],
                'price': float(latest_row['price']) if pd.notna(latest_row['price']) else 0,
                'amenities': self._safe_json_parse(latest_row.get('amenities_json')),
                'categories': self._safe_json_parse(latest_row.get('categories_json')),
                'cuisines': self._safe_json_parse(latest_row.get('cuisines_json')),
                'property_type': latest_row.get('property_type'),
                'tour_type': latest_row.get('tour_type'),
                'attraction_type': latest_row.get('attraction_type')
            }

            # --- VECTOR 2: HISTORY (Lịch sử - Index 1 đến 9) ---
            history_vec = None
            if len(df) > 1:
                df_history = df.iloc[1:].copy()
                
                # Tính trọng số Time-Decay cho lịch sử
                weights = [max(1.0 - (i * 0.1), 0.2) for i in range(len(df_history))]
                df_history['weight'] = weights
                
                # Ép kiểu float
                df_history['latitude'] = df_history['latitude'].astype(float)
                df_history['longitude'] = df_history['longitude'].astype(float)
                df_history['price'] = pd.to_numeric(df_history['price'], errors='coerce').fillna(0)
                
                # Tính trung bình toạ độ lịch sử
                total_w = df_history['weight'].sum()
                avg_lat = (df_history['latitude'] * df_history['weight']).sum() / total_w
                avg_lon = (df_history['longitude'] * df_history['weight']).sum() / total_w
                avg_price = (df_history['price'] * df_history['weight']).sum() / total_w
                
                history_vec = {
                    'lat': avg_lat,
                    'lon': avg_lon,
                    'avg_price': avg_price,
                    'count': len(df_history)
                }

            # Danh sách item đã xem (để loại trừ)
            viewed_list = list(zip(df['item_id'], df['item_type']))

            return {
                'latest': latest_vec,
                'history': history_vec,
                'viewed_list': viewed_list,
                'preferences': user_preferences  # NEW: User preferences
            }

        except Exception:
            print(traceback.format_exc())
            return None

    # --------------------------------------------------
    # USER PREFERENCE EXTRACTION (Content-Based Analysis)
    # Phân tích sở thích người dùng từ lịch sử tương tác
    # Xử lý đặc trưng riêng của từng loại dịch vụ
    # --------------------------------------------------
    def _extract_user_preferences(self, df):
        """Trích xuất user preferences từ lịch sử tương tác - chi tiết theo từng loại dịch vụ"""
        preferences = {
            'price_range': {'min': 0, 'max': 0, 'avg': 0, 'std': 0},
            'preferred_item_types': {},      # hotel, tour, restaurant, attraction
            # --- HOTEL PREFERENCES ---
            'hotel': {
                'amenities': {},             # Tiện ích yêu thích
                'property_types': {},        # Loại hình lưu trú yêu thích
                'star_classes': {}           # Cấp sao khách sạn yêu thích (1-5 sao)
            },
            # --- TOUR PREFERENCES ---
            'tour': {
                'categories': {},            # Thể loại tour
                'tour_types': {},            # Group/Private/Custom
                'difficulty_levels': {}      # Easy/Moderate/Hard
            },
            # --- RESTAURANT PREFERENCES ---
            'restaurant': {
                'cuisines': {},              # Ẩm thực yêu thích
                'diets': {},                 # Chế độ ăn
                'categories': {}             # Loại nhà hàng
            },
            # --- ATTRACTION PREFERENCES ---
            'attraction': {
                'attraction_types': {},      # Loại điểm tham quan
                'suitable_for': {},          # Phù hợp với ai
                'categories': {}             # Danh mục
            },
            # --- NORMALIZED FEATURES (Chung cho tất cả) ---
            'normalized_features': {}        # Features từ trường normalized_features
        }
        
        try:
            # === 1. PRICE PREFERENCE (Chung) ===
            prices = pd.to_numeric(df['price'], errors='coerce').dropna()
            if not prices.empty:
                preferences['price_range'] = {
                    'min': float(prices.min()),
                    'max': float(prices.max()),
                    'avg': float(prices.mean()),
                    'std': float(prices.std()) if len(prices) > 1 else float(prices.mean() * 0.3)
                }
            
            # === 2. ITEM TYPE PREFERENCE ===
            for _, row in df.iterrows():
                item_type = row.get('item_type')
                if item_type:
                    preferences['preferred_item_types'][item_type] = \
                        preferences['preferred_item_types'].get(item_type, 0) + 1
            
            # === 4. SERVICE-SPECIFIC PREFERENCES ===
            for _, row in df.iterrows():
                item_type = row.get('item_type')
                
                # --- HOTEL ---
                if item_type == 'hotel':
                    # Amenities
                    amenities = self._safe_json_parse(row.get('amenities_json'))
                    for a in amenities:
                        preferences['hotel']['amenities'][a] = \
                            preferences['hotel']['amenities'].get(a, 0) + 1
                    # Property type
                    prop_type = row.get('property_type')
                    if pd.notna(prop_type) and prop_type:
                        preferences['hotel']['property_types'][prop_type] = \
                            preferences['hotel']['property_types'].get(prop_type, 0) + 1
                    # Star class (Cấp sao khách sạn)
                    star_class = row.get('star_rating')
                    if pd.notna(star_class) and star_class:
                        star_key = f"{int(star_class)}_star"
                        preferences['hotel']['star_classes'][star_key] = \
                            preferences['hotel']['star_classes'].get(star_key, 0) + 1
                
                # --- TOUR ---
                elif item_type == 'tour':
                    # Categories
                    categories = self._safe_json_parse(row.get('categories_json'))
                    for c in categories:
                        preferences['tour']['categories'][c] = \
                            preferences['tour']['categories'].get(c, 0) + 1
                    # Tour type
                    tour_type = row.get('tour_type')
                    if pd.notna(tour_type) and tour_type:
                        preferences['tour']['tour_types'][tour_type] = \
                            preferences['tour']['tour_types'].get(tour_type, 0) + 1
                    # Difficulty
                    difficulty = row.get('difficulty_level')
                    if pd.notna(difficulty) and difficulty:
                        preferences['tour']['difficulty_levels'][difficulty] = \
                            preferences['tour']['difficulty_levels'].get(difficulty, 0) + 1
                
                # --- RESTAURANT ---
                elif item_type == 'restaurant':
                    # Cuisines
                    cuisines = self._safe_json_parse(row.get('cuisines_json'))
                    for c in cuisines:
                        preferences['restaurant']['cuisines'][c] = \
                            preferences['restaurant']['cuisines'].get(c, 0) + 1
                    # Diets
                    diets = self._safe_json_parse(row.get('diets_json'))
                    for d in diets:
                        preferences['restaurant']['diets'][d] = \
                            preferences['restaurant']['diets'].get(d, 0) + 1
                    # Categories
                    categories = self._safe_json_parse(row.get('categories_json'))
                    for c in categories:
                        preferences['restaurant']['categories'][c] = \
                            preferences['restaurant']['categories'].get(c, 0) + 1
                
                # --- ATTRACTION ---
                elif item_type == 'attraction':
                    # Attraction type
                    attr_type = row.get('attraction_type')
                    if pd.notna(attr_type) and attr_type:
                        preferences['attraction']['attraction_types'][attr_type] = \
                            preferences['attraction']['attraction_types'].get(attr_type, 0) + 1
                    # Suitable for
                    suitable = self._safe_json_parse(row.get('suitable_for_json'))
                    for s in suitable:
                        preferences['attraction']['suitable_for'][s] = \
                            preferences['attraction']['suitable_for'].get(s, 0) + 1
                    # Categories
                    categories = self._safe_json_parse(row.get('categories_json'))
                    for c in categories:
                        preferences['attraction']['categories'][c] = \
                            preferences['attraction']['categories'].get(c, 0) + 1
                
                # === 5. NORMALIZED FEATURES (Chung - từ trường normalized_features) ===
                norm_features = self._safe_json_parse(row.get('normalized_features'))
                for f in norm_features:
                    preferences['normalized_features'][f] = \
                        preferences['normalized_features'].get(f, 0) + 1
                
        except Exception as e:
            print(f"⚠️ Preference extraction warning: {e}")
            traceback.print_exc()
            
        return preferences

    # --------------------------------------------------
    # HELPER: Safe JSON Parse
    # --------------------------------------------------
    def _safe_json_parse(self, json_str):
        """An toàn parse JSON string thành list"""
        if pd.isna(json_str) or not json_str:
            return []
        try:
            if isinstance(json_str, list):
                return json_str
            return json.loads(json_str) if isinstance(json_str, str) else []
        except:
            return []

    # --------------------------------------------------
    # TOWER B: ITEM TOWER (Xử lý đặc trưng sản phẩm)
    # Load đầy đủ attributes để tính Multi-Factor Score
    # --------------------------------------------------
    def item_tower_layer(self):
        query = """
            SELECT tower_item_id, item_type, item_id, title, location,
                   latitude, longitude, price, normalized_features, star_rating,
                   property_type, difficulty_level, tour_type, attraction_type,
                   amenities_json, categories_json, cuisines_json, 
                   diets_json, suitable_for_json
            FROM ai_item_tower
            WHERE latitude IS NOT NULL AND longitude IS NOT NULL
        """
        df = pd.read_sql(query, self.engine)
        # Ép kiểu dữ liệu an toàn
        df['latitude'] = df['latitude'].astype(float)
        df['longitude'] = df['longitude'].astype(float)
        df['price'] = pd.to_numeric(df['price'], errors='coerce').fillna(0)
        df['star_rating'] = pd.to_numeric(df['star_rating'], errors='coerce').fillna(0)
        return df

    # --------------------------------------------------
    # MULTI-FACTOR SIMILARITY ENGINE 
    # Tính điểm dựa trên: Geo + Price + Service-Specific Features + Rating
    # --------------------------------------------------
    def find_nearby_enhanced(self, target_lat, target_lon, item_matrix, exclude_tuples, 
                              limit, radius_km, user_prefs=None, context_item=None):
        """
        Enhanced similarity với multi-factor scoring
        - target_lat, target_lon: Tọa độ tâm tìm kiếm
        - user_prefs: User preferences từ User Tower
        - context_item: Item context (latest hoặc None cho history)
        """
        if item_matrix.empty: return pd.DataFrame()

        # 1. Filter Logic (Loại trừ items đã xem hoặc đã chọn)
        candidates = item_matrix.copy()
        exclude_keys = set([f"{t}_{i}" for i, t in exclude_tuples])
        candidates['unique_key'] = candidates['item_type'] + "_" + candidates['item_id'].astype(str)
        candidates = candidates[~candidates['unique_key'].isin(exclude_keys)]
        
        if candidates.empty: return pd.DataFrame()

        # 2. Haversine Distance (Vectorized) - GEO SCORE
        lat1, lon1 = np.radians(target_lat), np.radians(target_lon)
        lat2, lon2 = np.radians(candidates['latitude']), np.radians(candidates['longitude'])
        
        dlat = lat2 - lat1
        dlon = lon2 - lon1
        a = np.sin(dlat/2)**2 + np.cos(lat1) * np.cos(lat2) * np.sin(dlon/2)**2
        c = 2 * np.arctan2(np.sqrt(a), np.sqrt(1-a))
        candidates['dist_km'] = self.EARTH_RADIUS * c

        # 3. Geo-Filter (Ưu tiên khu vực - Giữ nguyên logic gốc)
        nearby = candidates[candidates['dist_km'] <= radius_km].copy()
        
        # Nếu không có kết quả trong radius, mở rộng tìm kiếm
        if nearby.empty:
            nearby = candidates.nsmallest(limit * 2, 'dist_km').copy()

        # =====================================================
        # MULTI-FACTOR SCORING
        # =====================================================
        
        # --- SCORE 1: Geo Proximity (0-1) ---
        max_dist = nearby['dist_km'].max() if nearby['dist_km'].max() > 0 else 1
        nearby['geo_score'] = 1 - (nearby['dist_km'] / (max_dist + 1))
        
        # --- SCORE 2: Price Similarity (0-1) ---
        nearby['price_score'] = self._calculate_price_score(nearby, user_prefs, context_item)
        
        # --- SCORE 3: Service-Specific Feature Match (0-1) ---
        # Xử lý đặc trưng riêng cho từng loại dịch vụ
        # Lưu ý: star_rating được tính trong feature_score của HOTEL (cấp sao khách sạn)
        nearby['feature_score'] = nearby.apply(
            lambda row: self._calculate_service_specific_score(row, user_prefs, context_item), axis=1
        )
        
        # =====================================================
        # WEIGHTED FINAL SCORE (Không có rating_quality vì không có đánh giá user)
        # =====================================================
        nearby['final_score'] = (
            nearby['geo_score'] * self.weights['geo_proximity'] +
            nearby['price_score'] * self.weights['price_similarity'] +
            nearby['feature_score'] * self.weights['feature_match']
        )
        
        # Tạo recommendation reason chi tiết
        nearby['score_breakdown'] = nearby.apply(
            lambda row: self._generate_score_breakdown(row), axis=1
        )
        
        # Tạo feature match detail
        nearby['feature_match_detail'] = nearby.apply(
            lambda row: self._get_feature_match_detail(row, user_prefs, context_item), axis=1
        )
        
        return nearby.sort_values('final_score', ascending=False).head(limit)

    # --------------------------------------------------
    # PRICE SIMILARITY SCORING (Chung cho tất cả dịch vụ)
    # --------------------------------------------------
    def _calculate_price_score(self, df, user_prefs, context_item):
        """Tính điểm tương đồng giá cả - áp dụng cho tất cả loại dịch vụ"""
        scores = []
        
        # Xác định giá target từ user preferences
        target_price = 0
        price_std = 0
        
        if user_prefs and user_prefs.get('price_range', {}).get('avg', 0) > 0:
            target_price = user_prefs['price_range']['avg']
            price_std = user_prefs['price_range'].get('std', target_price * 0.3)
        elif context_item and context_item.get('price', 0) > 0:
            target_price = context_item['price']
            price_std = target_price * 0.3
            
        if target_price == 0:
            return pd.Series([0.5] * len(df), index=df.index)
        
        for _, row in df.iterrows():
            item_price = float(row['price']) if row['price'] > 0 else 0
            
            if item_price == 0:
                scores.append(0.5)
            else:
                # Gaussian similarity
                diff = abs(item_price - target_price)
                sigma = max(price_std, target_price * 0.2)
                score = np.exp(-(diff ** 2) / (2 * sigma ** 2))
                scores.append(score)
        
        return pd.Series(scores, index=df.index)

    # --------------------------------------------------
    # SERVICE-SPECIFIC FEATURE SCORING
    # Xử lý đặc trưng riêng cho từng loại dịch vụ
    # --------------------------------------------------
    def _calculate_service_specific_score(self, row, user_prefs, context_item):
        """
        Tính điểm khớp đặc trưng dựa trên loại dịch vụ cụ thể
        - Hotel: amenities, property_type
        - Tour: categories, tour_type, difficulty_level
        - Restaurant: cuisines, diets, categories
        - Attraction: attraction_type, suitable_for, categories
        """
        item_type = row.get('item_type', '')
        
        if item_type == 'hotel':
            return self._score_hotel(row, user_prefs, context_item)
        elif item_type == 'tour':
            return self._score_tour(row, user_prefs, context_item)
        elif item_type == 'restaurant':
            return self._score_restaurant(row, user_prefs, context_item)
        elif item_type == 'attraction':
            return self._score_attraction(row, user_prefs, context_item)
        else:
            return 0.5  # Default score cho unknown type

    # --------------------------------------------------
    # HOTEL SCORING
    # --------------------------------------------------
    def _score_hotel(self, row, user_prefs, context_item):
        """Tính điểm cho Hotel dựa trên amenities, property_type và star_rating (cấp sao)"""
        scores = []
        
        # 1. Amenities Match (Jaccard Similarity)
        item_amenities = set(self._safe_json_parse(row.get('amenities_json')))
        user_amenities = set()
        
        if user_prefs and user_prefs.get('hotel', {}).get('amenities'):
            # Lấy top 10 amenities từ preference
            top_amenities = sorted(
                user_prefs['hotel']['amenities'].items(),
                key=lambda x: x[1], reverse=True
            )[:10]
            user_amenities = set([a[0] for a in top_amenities])
        
        # Thêm amenities từ context item nếu có
        if context_item and context_item.get('amenities'):
            user_amenities.update(context_item['amenities'])
        
        if item_amenities and user_amenities:
            intersection = len(item_amenities & user_amenities)
            union = len(item_amenities | user_amenities)
            scores.append(intersection / union if union > 0 else 0.5)
        else:
            scores.append(0.5)
        
        # 2. Property Type Match
        item_prop_type = row.get('property_type')
        if user_prefs and user_prefs.get('hotel', {}).get('property_types') and item_prop_type:
            if item_prop_type in user_prefs['hotel']['property_types']:
                scores.append(1.0)
            else:
                scores.append(0.3)
        else:
            scores.append(0.5)
        
        # Context item property type match
        if context_item and context_item.get('property_type') == item_prop_type:
            scores.append(1.0)
        
        # 3. Star Class Match (Cấp sao khách sạn - 1 đến 5 sao)
        item_star = row.get('star_rating')
        if user_prefs and user_prefs.get('hotel', {}).get('star_classes') and pd.notna(item_star):
            item_star_key = f"{int(item_star)}_star"
            user_star_prefs = user_prefs['hotel']['star_classes']
            
            if item_star_key in user_star_prefs:
                # Exact match với cấp sao user hay chọn
                scores.append(1.0)
            else:
                # Tính điểm dựa trên khoảng cách cấp sao
                # User hay chọn 5 sao → khách sạn 4 sao vẫn được điểm khá
                user_avg_star = 0
                total_weight = 0
                for star_key, count in user_star_prefs.items():
                    star_num = int(star_key.split('_')[0])
                    user_avg_star += star_num * count
                    total_weight += count
                if total_weight > 0:
                    user_avg_star = user_avg_star / total_weight
                    star_diff = abs(int(item_star) - user_avg_star)
                    # Mỗi sao chênh lệch giảm 0.2 điểm
                    scores.append(max(1.0 - (star_diff * 0.2), 0.3))
                else:
                    scores.append(0.5)
        else:
            scores.append(0.5)
        
        return np.mean(scores) if scores else 0.5

    # --------------------------------------------------
    # TOUR SCORING
    # --------------------------------------------------
    def _score_tour(self, row, user_prefs, context_item):
        """Tính điểm cho Tour dựa trên categories, tour_type, difficulty"""
        scores = []
        
        # 1. Categories Match (Jaccard Similarity)
        item_categories = set(self._safe_json_parse(row.get('categories_json')))
        user_categories = set()
        
        if user_prefs and user_prefs.get('tour', {}).get('categories'):
            top_cats = sorted(
                user_prefs['tour']['categories'].items(),
                key=lambda x: x[1], reverse=True
            )[:5]
            user_categories = set([c[0] for c in top_cats])
        
        if context_item and context_item.get('categories'):
            user_categories.update(context_item['categories'])
        
        if item_categories and user_categories:
            intersection = len(item_categories & user_categories)
            union = len(item_categories | user_categories)
            scores.append(intersection / union if union > 0 else 0.5)
        else:
            scores.append(0.5)
        
        # 2. Tour Type Match (Group/Private/Custom)
        item_tour_type = row.get('tour_type')
        if user_prefs and user_prefs.get('tour', {}).get('tour_types') and item_tour_type:
            if item_tour_type in user_prefs['tour']['tour_types']:
                scores.append(1.0)
            else:
                scores.append(0.4)
        else:
            scores.append(0.5)
        
        # 3. Difficulty Level Match
        item_difficulty = row.get('difficulty_level')
        if user_prefs and user_prefs.get('tour', {}).get('difficulty_levels') and item_difficulty:
            if item_difficulty in user_prefs['tour']['difficulty_levels']:
                scores.append(1.0)
            else:
                # Partial match: adjacent difficulty levels
                difficulty_order = ['easy', 'moderate', 'hard']
                user_diffs = list(user_prefs['tour']['difficulty_levels'].keys())
                if user_diffs:
                    try:
                        user_idx = difficulty_order.index(user_diffs[0])
                        item_idx = difficulty_order.index(item_difficulty)
                        if abs(user_idx - item_idx) == 1:
                            scores.append(0.6)  # Adjacent level
                        else:
                            scores.append(0.3)
                    except ValueError:
                        scores.append(0.5)
                else:
                    scores.append(0.5)
        else:
            scores.append(0.5)
        
        return np.mean(scores) if scores else 0.5

    # --------------------------------------------------
    # RESTAURANT SCORING
    # --------------------------------------------------
    def _score_restaurant(self, row, user_prefs, context_item):
        """Tính điểm cho Restaurant dựa trên cuisines, diets, categories"""
        scores = []
        
        # 1. Cuisines Match (Jaccard Similarity)
        item_cuisines = set(self._safe_json_parse(row.get('cuisines_json')))
        user_cuisines = set()
        
        if user_prefs and user_prefs.get('restaurant', {}).get('cuisines'):
            top_cuisines = sorted(
                user_prefs['restaurant']['cuisines'].items(),
                key=lambda x: x[1], reverse=True
            )[:5]
            user_cuisines = set([c[0] for c in top_cuisines])
        
        if context_item and context_item.get('cuisines'):
            user_cuisines.update(context_item['cuisines'])
        
        if item_cuisines and user_cuisines:
            intersection = len(item_cuisines & user_cuisines)
            union = len(item_cuisines | user_cuisines)
            scores.append(intersection / union if union > 0 else 0.5)
        else:
            scores.append(0.5)
        
        # 2. Diets Match (Important for dietary restrictions)
        item_diets = set(self._safe_json_parse(row.get('diets_json')))
        user_diets = set()
        
        if user_prefs and user_prefs.get('restaurant', {}).get('diets'):
            user_diets = set(user_prefs['restaurant']['diets'].keys())
        
        if item_diets and user_diets:
            # Nếu user có dietary restrictions, ưu tiên cao
            intersection = len(item_diets & user_diets)
            if intersection > 0:
                scores.append(1.0)  # Có match dietary = điểm cao
            else:
                scores.append(0.3)  # Không match = điểm thấp
        else:
            scores.append(0.5)
        
        # 3. Categories Match (Fine Dining, Casual, etc.)
        item_categories = set(self._safe_json_parse(row.get('categories_json')))
        user_categories = set()
        
        if user_prefs and user_prefs.get('restaurant', {}).get('categories'):
            user_categories = set(user_prefs['restaurant']['categories'].keys())
        
        if item_categories and user_categories:
            intersection = len(item_categories & user_categories)
            union = len(item_categories | user_categories)
            scores.append(intersection / union if union > 0 else 0.5)
        else:
            scores.append(0.5)
        
        return np.mean(scores) if scores else 0.5

    # --------------------------------------------------
    # ATTRACTION SCORING
    # --------------------------------------------------
    def _score_attraction(self, row, user_prefs, context_item):
        """Tính điểm cho Attraction dựa trên attraction_type, suitable_for, categories"""
        scores = []
        
        # 1. Attraction Type Match
        item_attr_type = row.get('attraction_type')
        if user_prefs and user_prefs.get('attraction', {}).get('attraction_types') and item_attr_type:
            if item_attr_type in user_prefs['attraction']['attraction_types']:
                scores.append(1.0)
            else:
                scores.append(0.4)
        else:
            scores.append(0.5)
        
        # 2. Suitable For Match (Family, Couples, Solo, etc.)
        item_suitable = set(self._safe_json_parse(row.get('suitable_for_json')))
        user_suitable = set()
        
        if user_prefs and user_prefs.get('attraction', {}).get('suitable_for'):
            user_suitable = set(user_prefs['attraction']['suitable_for'].keys())
        
        if item_suitable and user_suitable:
            intersection = len(item_suitable & user_suitable)
            union = len(item_suitable | user_suitable)
            scores.append(intersection / union if union > 0 else 0.5)
        else:
            scores.append(0.5)
        
        # 3. Categories Match
        item_categories = set(self._safe_json_parse(row.get('categories_json')))
        user_categories = set()
        
        if user_prefs and user_prefs.get('attraction', {}).get('categories'):
            user_categories = set(user_prefs['attraction']['categories'].keys())
        
        if item_categories and user_categories:
            intersection = len(item_categories & user_categories)
            union = len(item_categories | user_categories)
            scores.append(intersection / union if union > 0 else 0.5)
        else:
            scores.append(0.5)
        
        return np.mean(scores) if scores else 0.5

    # --------------------------------------------------
    # GET FEATURE MATCH DETAIL (Cho API response)
    # --------------------------------------------------
    def _get_feature_match_detail(self, row, user_prefs, context_item):
        """Trả về chi tiết các features đã match - dùng cho thuyết trình"""
        item_type = row.get('item_type', '')
        detail = {'item_type': item_type, 'matched_features': []}
        
        if item_type == 'hotel':
            # Check amenities match
            item_amenities = set(self._safe_json_parse(row.get('amenities_json')))
            if user_prefs and user_prefs.get('hotel', {}).get('amenities'):
                user_amenities = set(user_prefs['hotel']['amenities'].keys())
                matched = item_amenities & user_amenities
                if matched:
                    detail['matched_features'].append({
                        'type': 'amenities',
                        'matched': list(matched)[:5]
                    })
            # Check property type
            if row.get('property_type'):
                detail['property_type'] = row['property_type']
                
        elif item_type == 'tour':
            item_categories = set(self._safe_json_parse(row.get('categories_json')))
            if user_prefs and user_prefs.get('tour', {}).get('categories'):
                user_cats = set(user_prefs['tour']['categories'].keys())
                matched = item_categories & user_cats
                if matched:
                    detail['matched_features'].append({
                        'type': 'categories',
                        'matched': list(matched)[:5]
                    })
            if row.get('tour_type'):
                detail['tour_type'] = row['tour_type']
            if row.get('difficulty_level'):
                detail['difficulty_level'] = row['difficulty_level']
                
        elif item_type == 'restaurant':
            item_cuisines = set(self._safe_json_parse(row.get('cuisines_json')))
            if user_prefs and user_prefs.get('restaurant', {}).get('cuisines'):
                user_cuisines = set(user_prefs['restaurant']['cuisines'].keys())
                matched = item_cuisines & user_cuisines
                if matched:
                    detail['matched_features'].append({
                        'type': 'cuisines',
                        'matched': list(matched)[:5]
                    })
            item_diets = set(self._safe_json_parse(row.get('diets_json')))
            if item_diets:
                detail['diets'] = list(item_diets)[:3]
                
        elif item_type == 'attraction':
            if row.get('attraction_type'):
                detail['attraction_type'] = row['attraction_type']
            item_suitable = set(self._safe_json_parse(row.get('suitable_for_json')))
            if item_suitable:
                detail['suitable_for'] = list(item_suitable)[:3]
        
        return detail

    # --------------------------------------------------
    # GENERATE SCORE BREAKDOWN (Cho debug/thuyết trình)
    # --------------------------------------------------
    def _generate_score_breakdown(self, row):
        """Tạo breakdown chi tiết về scoring"""
        breakdown = {
            'geo': round(row['geo_score'], 3),
            'price': round(row['price_score'], 3),
            'feature': round(row['feature_score'], 3),
            'final': round(row['final_score'], 3)
        }
        # Thêm star_class cho hotel (cấp sao khách sạn, không phải đánh giá)
        if row.get('item_type') == 'hotel' and pd.notna(row.get('star_rating')):
            breakdown['hotel_star_class'] = int(row['star_rating'])
        return breakdown

    # --------------------------------------------------
    # LEGACY: find_nearby (Giữ lại cho backward compatibility)
    # --------------------------------------------------
    def find_nearby(self, target_lat, target_lon, item_matrix, exclude_tuples, limit, radius_km):
        """Legacy method - redirect to enhanced version"""
        return self.find_nearby_enhanced(
            target_lat, target_lon, item_matrix, exclude_tuples, 
            limit, radius_km, user_prefs=None, context_item=None
        )

    # --------------------------------------------------
    # PREDICT (Logic phân bổ 5 - 5 với Multi-Factor Scoring)
    # GIỮ NGUYÊN CẤU TRÚC: Ưu tiên khu vực + 10 interactions
    # --------------------------------------------------
    def predict(self, user_id):
        # Bước 1: User Tower - Lấy user vectors & preferences (10 interactions gần nhất)
        u_vectors = self.user_tower_layer(user_id)
        # Bước 2: Item Tower - Lấy item matrix
        i_matrix = self.item_tower_layer()

        # Case: Cold Start (User mới)
        if not u_vectors:
            # Fallback: Lấy đa dạng các loại dịch vụ, ưu tiên hotel có star cao
            top_items = i_matrix.copy()
            # Sắp xếp theo price (giá trung bình) để có sự đa dạng
            top_items = top_items.sort_values('price', ascending=False).head(10)
            top_items['reason'] = "Gợi ý phổ biến (User mới)"
            top_items['final_score'] = 0.5  # Score mặc định
            top_items['dist_km'] = 0
            top_items['geo_score'] = 0
            top_items['price_score'] = 0.5
            top_items['feature_score'] = 0.5
            top_items['score_breakdown'] = top_items.apply(
                lambda r: {'geo': 0, 'price': 0.5, 'feature': 0.5, 'final': 0.5}, 
                axis=1
            )
            top_items['feature_match_detail'] = top_items.apply(
                lambda r: {'item_type': r['item_type'], 'matched_features': []}, axis=1
            )
            return top_items, "Cold Start"

        results = []
        user_prefs = u_vectors.get('preferences', {})
        
        # Danh sách loại trừ (bắt đầu bằng những cái đã xem)
        current_excludes = u_vectors['viewed_list'].copy()

        # --- PHASE 1: LẤY ĐÚNG 5 ITEMS CHO LATEST CONTEXT (Ưu tiên khu vực 30km) ---
        latest = u_vectors['latest']
        df_latest = self.find_nearby_enhanced(
            target_lat=latest['lat'],
            target_lon=latest['lon'],
            item_matrix=i_matrix,
            exclude_tuples=current_excludes,
            limit=5,
            radius_km=30,  # Ưu tiên trong 30km
            user_prefs=user_prefs,
            context_item=latest
        )
        if not df_latest.empty:
            df_latest['reason'] = df_latest.apply(
                lambda row: self._generate_reason(row, latest['title'], 'latest'), axis=1
            )
            results.append(df_latest)
            current_excludes.extend(list(zip(df_latest['item_id'], df_latest['item_type'])))

        # --- PHASE 2: LẤY ĐÚNG 5 ITEMS CHO HISTORY CONTEXT (Ưu tiên khu vực 50km) ---
        history = u_vectors['history']
        if history:
            df_history = self.find_nearby_enhanced(
                target_lat=history['lat'],
                target_lon=history['lon'],
                item_matrix=i_matrix,
                exclude_tuples=current_excludes,
                limit=5,
                radius_km=50,  # Mở rộng 50km cho history
                user_prefs=user_prefs,
                context_item=None
            )
            if not df_history.empty:
                df_history['reason'] = df_history.apply(
                    lambda row: self._generate_reason(row, None, 'history'), axis=1
                )
                results.append(df_history)

        # Merge Results
        if not results:
            fallback = i_matrix.sort_values('star_rating', ascending=False).head(10)
            fallback['reason'] = "Fallback (Không tìm thấy lân cận)"
            fallback['final_score'] = fallback['star_rating'] / 5.0
            fallback['dist_km'] = 0
            return fallback, "Fallback"

        final_df = pd.concat(results)
        return final_df, "Success (5 Latest + 5 History) - Service-Specific"

    # --------------------------------------------------
    # GENERATE RECOMMENDATION REASON
    # --------------------------------------------------
    def _generate_reason(self, row, context_title, context_type):
        """Tạo lý do khuyến nghị chi tiết theo từng loại dịch vụ"""
        reasons = []
        item_type = row.get('item_type', '')
        
        # Geo reason (Chung)
        dist = row.get('dist_km', 0)
        if dist <= 5:
            reasons.append(f"Rất gần ({dist:.1f}km)")
        elif dist <= 15:
            reasons.append(f"Gần ({dist:.1f}km)")
        else:
            reasons.append(f"Trong khu vực ({dist:.1f}km)")
        
        # Price reason (Chung)
        if row.get('price_score', 0) >= 0.7:
            reasons.append("Giá phù hợp")
        
        # Feature reason (Theo từng loại dịch vụ)
        feature_score = row.get('feature_score', 0)
        if feature_score >= 0.6:
            if item_type == 'hotel':
                reasons.append("Tiện ích phù hợp")
            elif item_type == 'tour':
                reasons.append("Loại tour yêu thích")
            elif item_type == 'restaurant':
                reasons.append("Ẩm thực phù hợp")
            elif item_type == 'attraction':
                reasons.append("Điểm đến phù hợp")
        
        # Service-specific details
        if item_type == 'hotel':
            # Cấp sao khách sạn (không phải đánh giá user)
            star_class = row.get('star_rating', 0)
            if pd.notna(star_class) and star_class > 0:
                reasons.append(f"{int(star_class)} sao")
            if row.get('property_type'):
                reasons.append(f"{row['property_type'].title()}")
        elif item_type == 'tour' and row.get('difficulty_level'):
            reasons.append(f"Độ khó: {row['difficulty_level'].title()}")
        elif item_type == 'restaurant':
            cuisines = self._safe_json_parse(row.get('cuisines_json'))
            if cuisines:
                reasons.append(f"{cuisines[0]}")
        elif item_type == 'attraction' and row.get('attraction_type'):
            reasons.append(f"{row['attraction_type'].replace('_', ' ').title()}")
        
        # Context
        if context_type == 'latest' and context_title:
            base = f"Gần '{context_title}'"
        else:
            base = "Dựa trên lịch sử"
        
        detail = " | ".join(reasons) if reasons else ""
        return f"{base} • {detail}" if detail else base

# Init Model
rec_model = TripfinityTwoTowerModel(db_engine)

# --- API ENDPOINT ---
@app.route('/api/recommendations/<int:user_id>', methods=['GET'])
def get_recommendations(user_id):
    print(f"\n⚡ REQUEST: User {user_id}...")
    try:
        df_res, status = rec_model.predict(user_id)
        
        data = []
        if not df_res.empty:
            df_res['price_fmt'] = df_res['price'].apply(lambda x: f"{int(x):,} đ")
            for _, row in df_res.iterrows():
                # Score breakdown
                score_info = row.get('score_breakdown', {})
                score_detail = score_info if isinstance(score_info, dict) else {}
                
                # Feature match detail
                feature_info = row.get('feature_match_detail', {})
                feature_detail = feature_info if isinstance(feature_info, dict) else {}
                
                item_data = {
                    'item_id': int(row['item_id']),
                    'title': str(row['title']),
                    'item_type': str(row['item_type']),
                    'price': str(row['price_fmt']),
                    'location': str(row.get('location', '')),
                    'dist_km': round(float(row['dist_km']), 2) if 'dist_km' in row else 0.0,
                    'reason': str(row['reason']),
                    'final_score': round(float(row.get('final_score', 0)), 3),
                    'score_breakdown': score_detail,
                    'feature_match_detail': feature_detail
                }
                
                # Chỉ thêm star_rating cho hotel (cấp sao khách sạn)
                if row['item_type'] == 'hotel' and pd.notna(row.get('star_rating')):
                    item_data['hotel_star_class'] = int(row['star_rating'])
                
                data.append(item_data)
        
        print(f"ℹ️ Status: {status} | Total Items: {len(data)}")
        return jsonify({
            'success': True,
            'status': status,
            'model_info': {
                'name': 'TripfinityTwoTower-ServiceSpecific',
                'version': '2.2',
                'factors': ['geo_proximity', 'price_similarity', 'service_specific_features'],
                'weights': SCORING_WEIGHTS,
                'service_features': SERVICE_FEATURES,
                'note': 'star_rating chỉ áp dụng cho Hotel (cấp sao khách sạn 1-5), không có đánh giá user'
            },
            'data': data
        })

    except Exception as e:
        print(f"❌ SERVER ERROR: {traceback.format_exc()}")
        return jsonify({'success': False, 'message': str(e)}), 500

# --- API ENDPOINT: Model Info (Cho thuyết trình) ---
@app.route('/api/model-info', methods=['GET'])
def get_model_info():
    """API để lấy thông tin model - hữu ích cho thuyết trình"""
    return jsonify({
        'model_name': 'Tripfinity Two-Tower Recommendation System',
        'version': '2.2 - Service-Specific Features (No User Rating)',
        'note': 'Bảng ai_item_tower KHÔNG có đánh giá user. star_rating chỉ dành cho Hotel (cấp sao khách sạn 1-5)',
        'architecture': {
            'user_tower': {
                'description': 'Phân tích đặc trưng người dùng từ 10 tương tác gần nhất',
                'outputs': ['latest_context_vector', 'history_context_vector', 'service_specific_preferences'],
                'preferences_extracted': {
                    'common': ['price_range', 'item_type_preference'],
                    'hotel': ['amenities', 'property_type', 'star_class (cấp sao khách sạn)'],
                    'tour': ['categories', 'tour_type', 'difficulty_level'],
                    'restaurant': ['cuisines', 'diets', 'categories'],
                    'attraction': ['attraction_type', 'suitable_for', 'categories']
                }
            },
            'item_tower': {
                'description': 'Xử lý đặc trưng sản phẩm/dịch vụ với features riêng theo loại',
                'common_features': ['location', 'price', 'normalized_features'],
                'hotel_only': 'star_rating (cấp sao khách sạn 1-5, KHÔNG phải đánh giá user)',
                'service_specific_features': SERVICE_FEATURES
            },
            'similarity_engine': {
                'description': 'Multi-Factor Scoring Engine với Service-Specific Processing',
                'scoring_formula': 'final_score = geo×0.40 + price×0.25 + feature×0.35',
                'factors': {
                    'geo_proximity': f"{SCORING_WEIGHTS['geo_proximity']*100}% - Khoảng cách địa lý (Haversine Distance)",
                    'price_similarity': f"{SCORING_WEIGHTS['price_similarity']*100}% - Gaussian Price Similarity",
                    'feature_match': f"{SCORING_WEIGHTS['feature_match']*100}% - Service-Specific Feature Matching (Jaccard Similarity)"
                },
                'no_user_rating': 'KHÔNG có tiêu chí đánh giá user vì bảng ai_item_tower không lưu rating từ user'
            }
        },
        'recommendation_logic': {
            'split': '5-5 (5 Latest Context + 5 History Context)',
            'latest_radius': '30km (Ưu tiên khu vực)',
            'history_radius': '50km (Mở rộng cho lịch sử)',
            'time_decay': 'weight = max(1.0 - (i × 0.1), 0.2)',
            'fallback': 'Top items theo price khi không tìm thấy trong khu vực'
        },
        'service_specific_scoring': {
            'hotel': {
                'factors': ['amenities_match (Jaccard)', 'property_type_match', 'star_class_match (cấp sao)'],
                'note': 'star_rating = cấp sao khách sạn (1-5 sao), KHÔNG phải đánh giá user',
                'example': 'User hay chọn Resort 5 sao có Pool → Ưu tiên Resort/Villa 4-5 sao có Pool, Spa'
            },
            'tour': {
                'factors': ['categories_match (Jaccard)', 'tour_type_match', 'difficulty_match'],
                'example': 'User hay chọn Adventure Tour dễ → Ưu tiên tour Adventure/Nature độ khó Easy/Moderate'
            },
            'restaurant': {
                'factors': ['cuisines_match (Jaccard)', 'diets_match (Priority)', 'categories_match'],
                'example': 'User hay ăn Vietnamese Vegetarian → Ưu tiên nhà hàng Việt có menu Vegetarian'
            },
            'attraction': {
                'factors': ['attraction_type_match', 'suitable_for_match (Jaccard)', 'categories_match'],
                'example': 'User hay đi Museum phù hợp Family → Ưu tiên Museum/Cultural phù hợp Family'
            }
        },
        'cold_start_handling': 'Diversity-Based: Top 10 items đa dạng loại hình'
    })


if __name__ == '__main__':
    print("\n" + "="*70)
    print("🚀 TRIPFINITY TWO-TOWER RECOMMENDATION SERVER v2.2")
    print("   Service-Specific Feature Matching (No User Rating)")
    print("="*70)
    print("\n📊 Scoring Weights:")
    for factor, weight in SCORING_WEIGHTS.items():
        print(f"   • {factor}: {weight*100}%")
    print("\n⚠️  Lưu ý: star_rating chỉ dành cho HOTEL (cấp sao khách sạn)")
    print("\n🏨 Service-Specific Features:")
    for service, config in SERVICE_FEATURES.items():
        print(f"   • {service.upper()}: {config['primary_features']}")
    print("="*70 + "\n")
    app.run(host='0.0.0.0', port=5000, debug=True)