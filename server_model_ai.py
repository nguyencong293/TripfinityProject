# ======================================================
# RECOMMENDATION API SERVER
# ======================================================
from flask import Flask, request, jsonify  # type: ignore
from flask_cors import CORS  # type: ignore
import pandas as pd  # type: ignore
import numpy as np  # type: ignore
import tensorflow as tf  # type: ignore
from tensorflow import keras  # type: ignore
from sqlalchemy import create_engine  # type: ignore
import pickle
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# --- 1. CẤU HÌNH DATABASE (MySQL) ---
DB_CONFIG = {
    'user': 'root',                
    'password': 'sqlpass', 
    'host': 'localhost',           
    'database': 'tripfinity',   
    'port': 3306
}

# Tạo kết nối
db_connection_str = f"mysql+mysqlconnector://{DB_CONFIG['user']}:{DB_CONFIG['password']}@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"
try:
    db_engine = create_engine(db_connection_str)
    print("✅ Đã kết nối Database thành công.")
except Exception as e:
    print(f"❌ Lỗi kết nối DB: {e}")

# --- 2. LOAD DATA & MODEL ---
print("🔄 Đang load Model & Data...")
# ⚠️ SỬA ĐƯỜNG DẪN TỚI FOLDER CỦA BẠN TRÊN MÁY TÍNH
BASE_PATH = 'E:\\CodeWork\\TripfinityProject\\data'  # Ví dụ: D:/Project/Data
ITEMS_PATH = os.path.join(BASE_PATH, 'ai_item_tower_export_20251217_181044.csv')

# Load Items
if os.path.exists(ITEMS_PATH):
    items = pd.read_csv(ITEMS_PATH)
    items['unique_item_id'] = items['item_type'] + "_" + items['item_id'].astype(str)
    items['price'] = pd.to_numeric(items['price'], errors='coerce').fillna(items['price'].median())
    items['feature_text'] = items['normalized_features'].astype(str).str.replace(r'[\[\]"]', '', regex=True).str.replace(',', ' ')
    print(f"✅ Đã load {len(items)} items.")
else:
    print(f"❌ Không tìm thấy file csv tại: {ITEMS_PATH}")

# Load Model
try:
    with open(os.path.join(BASE_PATH, 'recsys_artifacts.pkl'), 'rb') as f:
        artifacts = pickle.load(f)
    model = keras.models.load_model(os.path.join(BASE_PATH, 'tripfinity_recsys_model.keras'))
    
    sc_lat = artifacts['scaler_lat']
    sc_lon = artifacts['scaler_lon']
    sc_price = artifacts['scaler_price']
    enc_type = artifacts['type_encoder']
    u_profiles = artifacts['user_profiles_dict']
    print("✅ Đã load Model & Artifacts.")
except Exception as e:
    print(f"❌ Lỗi load Model: {e}")

# Hàm tính khoảng cách
def haversine(lat1, lon1, lat2, lon2):
    R = 6371
    dlat = np.radians(lat2 - lat1)
    dlon = np.radians(lon2 - lon1)
    a = np.sin(dlat/2)**2 + np.cos(np.radians(lat1)) * np.cos(np.radians(lat2)) * np.sin(dlon/2)**2
    c = 2 * np.arctan2(np.sqrt(a), np.sqrt(1-a))
    return R * c

# --- 3. HÀM CHECK REAL-TIME DB ---
def get_realtime_user_profile(user_id):
    try:
        # Query SQL
        query = f"SELECT item_id, item_type, action_weight FROM user_item_interactions WHERE user_id = {user_id} ORDER BY interaction_timestamp DESC LIMIT 15"
        
        interactions = pd.read_sql(query, db_engine)
        
        if interactions.empty:
            return None # Không có data
            
        interactions['unique_key'] = interactions['item_type'] + "_" + interactions['item_id'].astype(str)
        items['unique_key'] = items['item_type'] + "_" + items['item_id'].astype(str)
        
        merged = interactions.merge(items, on='unique_key', how='inner')
        if merged.empty:
            return None

        # Tính trung bình có trọng số
        weights = merged['action_weight_x']
        total_weight = weights.sum()
        
        u_lat = (merged['latitude'] * weights).sum() / total_weight
        u_lon = (merged['longitude'] * weights).sum() / total_weight
        u_price = (np.log1p(merged['price']) * weights).sum() / total_weight
        
        top_items = merged.sort_values('action_weight_x', ascending=False).head(3)
        u_text = " ".join(top_items['feature_text'].tolist())
        
        return {
            'u_lat': u_lat, 'u_lon': u_lon, 'u_price': u_price, 
            'u_text': u_text, 'count': len(merged)
        }
    except Exception as e:
        print(f"⚠️ Lỗi SQL: {e}")
        return None

# --- 4. LOGIC GỢI Ý (CÓ SKIP NEW USER) ---
def get_smart_recommendations(user_id):
    RADIUS_KM = 15
    target_lat, target_lon = 0, 0
    is_recommendable = False
    
    # 1. Check Offline Profile
    if user_id in u_profiles:
        prof = u_profiles[user_id]
        u_lat_val, u_lon_val = prof['u_lat'], prof['u_lon']
        u_price_val = prof['u_price']
        u_text_val = str(prof['u_text'])
        
        target_lat, target_lon = u_lat_val, u_lon_val
        status = "✅ USER CŨ (Offline Model)"
        desc = "Dựa trên dữ liệu lịch sử đã train."
        is_recommendable = True
        
    else:
        # 2. Check Real-time DB
        realtime_prof = get_realtime_user_profile(user_id)
        
        if realtime_prof:
            u_lat_val = realtime_prof['u_lat']
            u_lon_val = realtime_prof['u_lon']
            u_price_val = realtime_prof['u_price']
            u_text_val = realtime_prof['u_text']
            
            target_lat, target_lon = u_lat_val, u_lon_val
            status = f"⚡ REAL-TIME ({realtime_prof['count']} hành động)"
            desc = "User chưa train, gợi ý dựa trên DB mới nhất."
            is_recommendable = True
        else:
            # 3. New User -> SKIP
            return None, "🆕 NGƯỜI DÙNG MỚI", "Chưa có dữ liệu."

    # Chạy Model nếu có dữ liệu
    if is_recommendable:
        N = len(items)
        u_lat_in = sc_lat.transform([[u_lat_val]])[0][0]
        u_lon_in = sc_lon.transform([[u_lon_val]])[0][0]
        u_price_in = sc_price.transform([[u_price_val]])[0][0]

        inputs = {
            "user_lat": np.full((N, 1), u_lat_in),
            "user_lon": np.full((N, 1), u_lon_in),
            "user_price": np.full((N, 1), u_price_in),
            "user_text": tf.constant([u_text_val] * N, dtype=tf.string),
            "item_lat": sc_lat.transform(items[['latitude']].values),
            "item_lon": sc_lon.transform(items[['longitude']].values),
            "item_price": sc_price.transform(np.log1p(items['price'].values).reshape(-1, 1)),
            "item_type": enc_type.transform(items['item_type']),
            "item_text": tf.constant(items['feature_text'].values.astype(str), dtype=tf.string)
        }

        scores = model.predict(inputs, verbose=0).flatten()
        res = items.copy()
        res['score'] = scores
        res['dist_km'] = haversine(target_lat, target_lon, res['latitude'], res['longitude'])

        in_zone = res[res['dist_km'] <= RADIUS_KM].sort_values('score', ascending=False)
        out_zone = res[res['dist_km'] > RADIUS_KM].sort_values('score', ascending=False)
        final = pd.concat([in_zone.head(10), out_zone.head(5)])
        final['price_fmt'] = final['price'].apply(lambda x: f"{int(x):,} đ")

        # Rename columns to match Flutter expectations (camelCase or keep snake_case)
        result_df = final[['item_id', 'title', 'item_type', 'price_fmt', 'dist_km', 'score']].copy()
        
        return result_df, status, desc
    
    return None, "Error", "Unknown"

# --- 5. API ENDPOINT ---
@app.route('/api/recommendations/<int:user_id>', methods=['GET'])
def get_recommendations(user_id):
    """API endpoint để lấy gợi ý cho user"""
    print(f"\n{'='*80}")
    print(f"📞 API Request - User ID: {user_id}")
    print(f"{'='*80}\n")
    
    if user_id <= 0:
        return jsonify({
            'success': False,
            'message': 'Invalid user ID',
            'data': None
        }), 400
    
    df_res, status, desc = get_smart_recommendations(user_id)
    
    if df_res is None:
        print(f"\n⚠️ {status}")
        print(f"ℹ️ {desc}")
        print(f">> BỎ QUA GỢI Ý (SKIP RECOMMENDATION)\n")
        
        return jsonify({
            'success': False,
            'message': desc,
            'status': status,
            'data': None
        }), 200
    else:
        # Convert DataFrame to dict for JSON response
        # Explicitly convert to ensure all fields are included
        recommendations = []
        for _, row in df_res.iterrows():
            recommendations.append({
                'item_id': int(row['item_id']),
                'title': str(row['title']),
                'item_type': str(row['item_type']),
                'price_fmt': str(row['price_fmt']),
                'dist_km': float(row['dist_km']),
                'score': float(row['score'])
            })
        
        print(f"\n{'='*80}")
        print(f"✅ TRẠNG THÁI: {status}")
        print(f"ℹ️ CHI TIẾT: {desc}")
        print(f"{'='*80}")
        print(f"\n📋 GỢI Ý CHO USER {user_id}:")
        print("-" * 80)
        for idx, item in enumerate(recommendations, 1):
            print(f"{idx}. {item['title']}")
            print(f"   ID: {item['item_id']} | Loại: {item['item_type']} | Giá: {item['price_fmt']} | Khoảng cách: {item['dist_km']:.1f}km | Score: {item['score']:.4f}")
        print("-" * 80 + "\n")
        
        return jsonify({
            'success': True,
            'message': 'Recommendations retrieved successfully',
            'status': status,
            'description': desc,
            'data': recommendations
        }), 200

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'message': 'Recommendation API is running'
    }), 200

# --- 6. RUN SERVER ---
if __name__ == '__main__':
    print("\n" + "="*80)
    print("🚀 STARTING RECOMMENDATION API SERVER")
    print("="*80)
    print(f"📍 Server running on: http://localhost:5000")
    print(f"🔗 API Endpoint: http://localhost:5000/api/recommendations/<user_id>")
    print(f"💚 Health Check: http://localhost:5000/health")
    print("="*80 + "\n")
    
    app.run(host='0.0.0.0', port=5000, debug=True)