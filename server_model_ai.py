# ======================================================
# TRIPFINITY TWO-TOWER SERVER (STABLE 5-5 SPLIT)
# Logic: 5 Items (Latest Context) + 5 Items (History Context)
# Architecture: Single Class Two-Tower
# ======================================================
from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
from sqlalchemy import create_engine
import traceback

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
    print("✅ Database Connected (5-5 Split Mode).")
except Exception as e:
    print(f"❌ DB Connection Error: {e}")
    exit()

# ======================================================
# CORE MODEL: TWO TOWER CLASS
# ======================================================

class TripfinityTwoTowerModel:
    def __init__(self, engine):
        self.engine = engine
        self.EARTH_RADIUS = 6371

    # --------------------------------------------------
    # TOWER A: USER TOWER (Xử lý đặc trưng người dùng)
    # Output: Trả về 2 vectors riêng biệt (Latest & History)
    # --------------------------------------------------
    def user_tower_layer(self, user_id):
        query = f"""
            SELECT 
                ui.item_id, ui.item_type, ui.interaction_timestamp,
                it.title, it.latitude, it.longitude
            FROM user_item_interactions ui
            JOIN ai_item_tower it ON ui.item_id = it.item_id AND ui.item_type = it.item_type
            WHERE ui.user_id = {user_id}
            ORDER BY ui.interaction_timestamp DESC 
            LIMIT 10
        """
        try:
            df = pd.read_sql(query, self.engine)
            if df.empty: return None
            
            # --- VECTOR 1: LATEST (Mới nhất - Index 0) ---
            latest_row = df.iloc[0]
            latest_vec = {
                'lat': float(latest_row['latitude']),
                'lon': float(latest_row['longitude']),
                'item_id': latest_row['item_id'],
                'item_type': latest_row['item_type'],
                'title': latest_row['title']
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
                
                # Tính trung bình toạ độ lịch sử
                total_w = df_history['weight'].sum()
                avg_lat = (df_history['latitude'] * df_history['weight']).sum() / total_w
                avg_lon = (df_history['longitude'] * df_history['weight']).sum() / total_w
                
                history_vec = {
                    'lat': avg_lat,
                    'lon': avg_lon,
                    'count': len(df_history)
                }

            # Danh sách item đã xem (để loại trừ)
            viewed_list = list(zip(df['item_id'], df['item_type']))

            return {
                'latest': latest_vec,
                'history': history_vec,
                'viewed_list': viewed_list
            }

        except Exception:
            print(traceback.format_exc())
            return None

    # --------------------------------------------------
    # TOWER B: ITEM TOWER (Xử lý đặc trưng sản phẩm)
    # --------------------------------------------------
    def item_tower_layer(self):
        query = """
            SELECT tower_item_id, item_type, item_id, title, 
                   latitude, longitude, price, star_rating
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
    # SIMILARITY ENGINE (Tính toán khoảng cách)
    # --------------------------------------------------
    def find_nearby(self, target_lat, target_lon, item_matrix, exclude_tuples, limit, radius_km):
        if item_matrix.empty: return pd.DataFrame()

        # 1. Filter Logic (Loại trừ items đã xem hoặc đã chọn)
        candidates = item_matrix.copy()
        exclude_keys = set([f"{t}_{i}" for i, t in exclude_tuples])
        candidates['unique_key'] = candidates['item_type'] + "_" + candidates['item_id'].astype(str)
        candidates = candidates[~candidates['unique_key'].isin(exclude_keys)]
        
        if candidates.empty: return pd.DataFrame()

        # 2. Haversine Distance (Vectorized)
        lat1, lon1 = np.radians(target_lat), np.radians(target_lon)
        lat2, lon2 = np.radians(candidates['latitude']), np.radians(candidates['longitude'])
        
        dlat = lat2 - lat1
        dlon = lon2 - lon1
        a = np.sin(dlat/2)**2 + np.cos(lat1) * np.cos(lat2) * np.sin(dlon/2)**2
        c = 2 * np.arctan2(np.sqrt(a), np.sqrt(1-a))
        candidates['dist_km'] = self.EARTH_RADIUS * c

        # 3. Geo-Filter & Ranking
        nearby = candidates[candidates['dist_km'] <= radius_km].copy()
        
        # Scoring: Gần (70%) + Rating (30%)
        nearby['score'] = (1 / (nearby['dist_km'] + 0.5)) * 0.7 + (nearby['star_rating'] / 5) * 0.3
        
        return nearby.sort_values('score', ascending=False).head(limit)

    # --------------------------------------------------
    # PREDICT (Logic phân bổ 5 - 5)
    # --------------------------------------------------
    def predict(self, user_id):
        # Bước 1: User Tower
        u_vectors = self.user_tower_layer(user_id)
        # Bước 2: Item Tower
        i_matrix = self.item_tower_layer()

        # Case: Cold Start (User mới)
        if not u_vectors:
            top_rated = i_matrix.sort_values('star_rating', ascending=False).head(10)
            top_rated['reason'] = "Gợi ý phổ biến (User mới)"
            return top_rated, "Cold Start"

        results = []
        # Danh sách loại trừ (bắt đầu bằng những cái đã xem)
        current_excludes = u_vectors['viewed_list'].copy()

        # --- PHASE 1: LẤY ĐÚNG 5 ITEMS CHO LATEST CONTEXT ---
        latest = u_vectors['latest']
        df_latest = self.find_nearby(
            target_lat=latest['lat'],
            target_lon=latest['lon'],
            item_matrix=i_matrix,
            exclude_tuples=current_excludes,
            limit=5,             # <--- ĐÚNG YÊU CẦU: LẤY 5
            radius_km=30
        )
        if not df_latest.empty:
            df_latest['reason'] = f"Gần '{latest['title']}' (Mới xem)"
            results.append(df_latest)
            # Add kết quả vào exclude để Phase 2 không lấy trùng
            current_excludes.extend(list(zip(df_latest['item_id'], df_latest['item_type'])))

        # --- PHASE 2: LẤY ĐÚNG 5 ITEMS CHO HISTORY CONTEXT ---
        history = u_vectors['history']
        if history:
            df_history = self.find_nearby(
                target_lat=history['lat'],
                target_lon=history['lon'],
                item_matrix=i_matrix,
                exclude_tuples=current_excludes,
                limit=5,         # <--- ĐÚNG YÊU CẦU: LẤY 5 CÒN LẠI
                radius_km=50
            )
            if not df_history.empty:
                df_history['reason'] = "Dựa trên lịch sử cũ"
                results.append(df_history)

        # Merge Results
        if not results:
            fallback = i_matrix.sort_values('star_rating', ascending=False).head(10)
            fallback['reason'] = "Fallback (Không tìm thấy lân cận)"
            return fallback, "Fallback"

        final_df = pd.concat(results)
        return final_df, "Success (5 Latest + 5 History)"

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
                data.append({
                    'item_id': int(row['item_id']),
                    'title': str(row['title']),
                    'item_type': str(row['item_type']),
                    'price': str(row['price_fmt']),
                    'dist_km': round(float(row['dist_km']), 2) if 'dist_km' in row else 0.0,
                    'reason': str(row['reason'])
                })
        
        print(f"ℹ️ Status: {status} | Total Items: {len(data)}")
        return jsonify({
            'success': True,
            'status': status,
            'data': data
        })

    except Exception as e:
        print(f"❌ SERVER ERROR: {traceback.format_exc()}")
        return jsonify({'success': False, 'message': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)