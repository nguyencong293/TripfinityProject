
# -*- coding: utf-8 -*-
import os
import threading
import pandas as pd
from pyngrok import ngrok
import nest_asyncio
import uvicorn
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import sys
from unidecode import unidecode
import re

nest_asyncio.apply()

os.environ["GROQ_API_KEY"] = "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"
ngrok.set_auth_token("32rp1jIGT8KGFs8QQcEN1bghzeX_2keD2P4KXZnxVUzK3RtdC")

# --- IMPORT ---
try:
    from langchain_groq import ChatGroq
    from langchain.chains import LLMChain
    from langchain.memory import ConversationBufferMemory
    from langchain.prompts import ChatPromptTemplate
    print("✅ Import OK")
except ImportError as e:
    print(f"❌ {e}")
    sys.exit(1)

# --- TUNNEL ---
try:
    for tunnel in ngrok.get_tunnels():
        ngrok.disconnect(tunnel.public_url)
    ngrok.kill()
except:
    pass

# --- LOAD DATA ---
def load_data(csv_path):
    print(f"\n📂 Loading: {csv_path}")
    if not os.path.exists(csv_path):
        print("❌ File not found!")
        return None

    df = pd.read_csv(csv_path)
    print(f"✅ Loaded {len(df)} items")

    # Chuẩn hóa location
    df['location_lower'] = df['location'].str.lower().str.strip()
    df['location_no_accent'] = df['location'].apply(lambda x: unidecode(str(x).lower().strip()))

    # Show locations
    unique_locs = df['location'].unique()
    print(f"\n📍 Có {len(unique_locs)} tỉnh thành:")
    for i, loc in enumerate(unique_locs[:20]):
        no_acc = unidecode(str(loc).lower().strip())
        print(f"  {i+1}. {loc} → {no_acc}")

    print(f"\n📊 Item types: {df['item_type'].unique()}")

    return df

# Load data
csv_path = "E:\\CodeWork\\TripfinityProject\\data\\ai_item_tower_export_20251217_181044.csv"
if not os.path.exists(csv_path):
    csv_path = "ai_item_tower_export_20251217_181044.csv"
if not os.path.exists(csv_path):
    csv_path = "data/ai_item_tower_export_20251217_181044.csv"

df_data = load_data(csv_path)


# --- DICTIONARY MAPPING CHO AMENITIES & HIGHLIGHTS ---
AMENITIES_MAP = {
    1: "WiFi miễn phí", 2: "Điều hòa", 3: "Tivi màn hình phẳng", 4: "Minibar",
    5: "Két an toàn", 6: "Máy sấy tóc", 7: "Dịch vụ phòng 24/7", 8: "Bãi đậu xe miễn phí",
    9: "Đưa đón sân bay", 10: "Cho phép thú cưng", 11: "Máy pha cà phê / Ấm đun",
    12: "Áo choàng tắm & Dép", 13: "Ban công / Sân hiên", 14: "Tầm nhìn ra biển/hồ/núi",
    15: "Góc bếp", 16: "Máy giặt", 17: "Bàn ủi", 18: "Lễ tân 24/7",
    19: "Dịch vụ Concierge", 20: "Giữ hành lý", 21: "Thang máy",
    22: "Tiện nghi cho người khuyết tật", 23: "Đổi tiền / ATM", 24: "Trạm sạc xe điện",
    25: "Phòng xông hơi / Sauna", 26: "Phòng tắm hơi ướt", 27: "Bồn tắm nóng / Jacuzzi",
    28: "Hồ bơi trẻ em", 29: "Sân chơi trẻ em", 30: "Sân tennis",
    31: "Thuê xe đạp", 32: "Dịch vụ thuê xe", 33: "Bãi biển gần",
    34: "Phòng họp / Tiệc", 35: "Ăn sáng miễn phí"
}

HIGHLIGHTS_MAP = {
    1: "View biển", 2: "View núi", 3: "Trung tâm thành phố", 4: "Gần sân bay",
    5: "Hồ bơi ngoài trời", 6: "Hồ bơi trong nhà", 7: "Spa & Massage", 8: "Phòng gym",
    9: "Nhà hàng cao cấp", 10: "Bar & Lounge", 11: "Bãi biển riêng",
    12: "Hồ bơi vô cực", 13: "Bar hồ bơi", 14: "Câu lạc bộ trẻ em (Kids Club)",
    15: "Dịch vụ trông trẻ", 16: "Sân tennis", 17: "Sân golf gần kề",
    18: "Thể thao dưới nước", 19: "Lặn biển / Snorkeling", 20: "Kayak / Chèo SUP",
    21: "Công viên nước mini", 22: "Rooftop bar", 23: "Nhà hàng buffet",
    24: "Trung tâm hội nghị", 25: "Đưa đón sân bay", 26: "Đưa đón trong khu",
    27: "Bãi đỗ xe valet", 28: "Xông hơi / Sauna", 29: "Bể sục / Jacuzzi",
    30: "Khu vui chơi trẻ em"
}

# --- TỪ KHÓA TÌM KIẾM AMENITIES (keyword -> list amenity IDs) ---
AMENITY_KEYWORDS = {
    # Hồ bơi
    'hồ bơi': [5, 6, 12, 28], 'ho boi': [5, 6, 12, 28], 'pool': [5, 6, 12, 28],
    'bể bơi': [5, 6, 12, 28], 'be boi': [5, 6, 12, 28],
    'hồ bơi vô cực': [12], 'ho boi vo cuc': [12], 'infinity pool': [12],
    'hồ bơi trẻ em': [28], 'ho boi tre em': [28],

    # Spa & Wellness
    'spa': [7, 25, 26, 27, 28, 29], 'massage': [7], 'xông hơi': [25, 28], 'xong hoi': [25, 28],
    'sauna': [25, 28], 'jacuzzi': [27, 29], 'bồn tắm nóng': [27, 29], 'bon tam nong': [27, 29],

    # Gym & Thể thao
    'gym': [8], 'phòng gym': [8], 'phong gym': [8], 'tập gym': [8], 'tap gym': [8],
    'fitness': [8], 'thể dục': [8], 'the duc': [8],
    'tennis': [16, 30], 'sân tennis': [16, 30], 'san tennis': [16, 30],
    'golf': [17], 'sân golf': [17], 'san golf': [17],

    # View & Vị trí
    'view biển': [1, 14], 'view bien': [1, 14], 'sea view': [1, 14],
    'view núi': [2, 14], 'view nui': [2, 14], 'mountain view': [2, 14],
    'gần biển': [11, 33], 'gan bien': [11, 33], 'bãi biển': [11, 33], 'bai bien': [11, 33],
    'beach': [11, 33], 'beachfront': [11, 33],
    'trung tâm': [3], 'trung tam': [3], 'city center': [3],
    'gần sân bay': [4, 9, 25], 'gan san bay': [4, 9, 25],
    'rooftop': [22], 'sân thượng': [22], 'san thuong': [22],
    'ban công': [13], 'ban cong': [13], 'balcony': [13],

    # Dịch vụ đưa đón
    'đưa đón sân bay': [9, 25], 'dua don san bay': [9, 25], 'airport transfer': [9, 25],
    'đưa đón': [9, 25, 26], 'dua don': [9, 25, 26], 'shuttle': [9, 25, 26],

    # Trẻ em & Gia đình
    'trẻ em': [14, 15, 28, 29, 30], 'tre em': [14, 15, 28, 29, 30],
    'kids': [14, 15, 28, 29, 30], 'children': [14, 15, 28, 29, 30],
    'gia đình': [14, 15, 28, 29, 30], 'gia dinh': [14, 15, 28, 29, 30], 'family': [14, 15, 28, 29, 30],
    'trông trẻ': [15], 'trong tre': [15], 'babysitting': [15],
    'kids club': [14], 'câu lạc bộ trẻ em': [14], 'cau lac bo tre em': [14],
    'sân chơi': [29, 30], 'san choi': [29, 30], 'playground': [29, 30],

    # Thú cưng
    'thú cưng': [10], 'thu cung': [10], 'pet': [10], 'chó mèo': [10], 'cho meo': [10],
    'pet friendly': [10], 'cho phép thú cưng': [10], 'cho phep thu cung': [10],

    # Ăn uống
    'ăn sáng': [35], 'an sang': [35], 'breakfast': [35], 'buffet': [23, 35],
    'nhà hàng': [9, 23], 'nha hang': [9, 23], 'restaurant': [9, 23],
    'bar': [10, 13, 22], 'lounge': [10],

    # Đỗ xe
    'đỗ xe': [8, 27], 'do xe': [8, 27], 'parking': [8, 27],
    'bãi đậu xe': [8, 27], 'bai dau xe': [8, 27],
    'valet': [27],

    # Wifi & Tiện nghi cơ bản
    'wifi': [1], 'internet': [1], 'free wifi': [1],
    'điều hòa': [2], 'dieu hoa': [2], 'air conditioning': [2], 'máy lạnh': [2], 'may lanh': [2],
    'minibar': [4], 'tủ lạnh': [4], 'tu lanh': [4],

    # Tiện nghi đặc biệt
    'lễ tân 24/7': [18], 'le tan': [18], '24/7': [7, 18],
    'concierge': [19], 'giữ hành lý': [20], 'giu hanh ly': [20],
    'thang máy': [21], 'thang may': [21], 'elevator': [21],
    'người khuyết tật': [22], 'nguoi khuyet tat': [22], 'accessible': [22], 'wheelchair': [22],
    'xe điện': [24], 'xe dien': [24], 'electric car': [24], 'ev charging': [24],
    'thuê xe đạp': [31], 'thue xe dap': [31], 'bike rental': [31],
    'thuê xe': [32], 'thue xe': [32], 'car rental': [32],
    'phòng họp': [24, 34], 'phong hop': [24, 34], 'meeting room': [24, 34],
    'hội nghị': [24, 34], 'hoi nghi': [24, 34], 'conference': [24, 34],

    # Hoạt động nước
    'lặn biển': [19], 'lan bien': [19], 'snorkeling': [19], 'diving': [19],
    'kayak': [20], 'sup': [20], 'chèo sup': [20], 'cheo sup': [20],
    'thể thao nước': [18, 19, 20], 'the thao nuoc': [18, 19, 20], 'water sports': [18, 19, 20],
    'công viên nước': [21], 'cong vien nuoc': [21], 'water park': [21],
}

# --- TỪ KHÓA CHO NORMALIZED_FEATURES (tour, restaurant, attraction) ---
FEATURE_KEYWORDS = {
    # Tour types
    'văn hóa': ['culture', 'cultural', 'historical'], 'van hoa': ['culture', 'cultural', 'historical'],
    'lịch sử': ['historical', 'history'], 'lich su': ['historical', 'history'],
    'phiêu lưu': ['adventure', 'trekking', 'hiking'], 'phieu luu': ['adventure', 'trekking', 'hiking'],
    'mạo hiểm': ['adventure', 'extreme'], 'mao hiem': ['adventure', 'extreme'],
    'thiên nhiên': ['nature', 'eco', 'wildlife'], 'thien nhien': ['nature', 'eco', 'wildlife'],
    'sinh thái': ['eco', 'nature'], 'sinh thai': ['eco', 'nature'],
    'biển': ['beach', 'sea', 'ocean', 'island'], 'bien': ['beach', 'sea', 'ocean', 'island'],
    'núi': ['mountain', 'trekking', 'hiking'], 'nui': ['mountain', 'trekking', 'hiking'],
    'thành phố': ['city', 'urban'], 'thanh pho': ['city', 'urban'],

    # Tour inclusions
    'bao gồm bữa ăn': ['meals', 'lunch', 'dinner', 'breakfast'], 'bao gom bua an': ['meals', 'lunch', 'dinner', 'breakfast'],
    'có ăn': ['meals', 'lunch', 'dinner'], 'co an': ['meals', 'lunch', 'dinner'],
    'đưa đón': ['pickup', 'transfer'], 'dua don': ['pickup', 'transfer'],
    'hướng dẫn viên': ['guide', 'guided'], 'huong dan vien': ['guide', 'guided'],
    'vé vào cửa': ['entrance_fees', 'ticket'], 've vao cua': ['entrance_fees', 'ticket'],

    # Restaurant features
    'hải sản': ['seafood'], 'hai san': ['seafood'],
    'việt nam': ['vietnamese'], 'viet nam': ['vietnamese'],
    'nhật bản': ['japanese'], 'nhat ban': ['japanese'],
    'hàn quốc': ['korean'], 'han quoc': ['korean'],
    'trung quốc': ['chinese'], 'trung quoc': ['chinese'],
    'ý': ['italian'], 'italia': ['italian'],
    'thái': ['thai'],
    'chay': ['vegetarian', 'vegan'], 'thuần chay': ['vegan'], 'thuan chay': ['vegan'],
    'halal': ['halal'],
    'không gluten': ['gluten_free'], 'khong gluten': ['gluten_free'],
    'buffet': ['buffet'],
    'lãng mạn': ['romantic'], 'lang man': ['romantic'],
    'gia đình': ['family_friendly', 'family'], 'gia dinh': ['family_friendly', 'family'],
    'sang trọng': ['formal', 'luxury'], 'sang trong': ['formal', 'luxury'],
    'bình dân': ['casual', 'budget'], 'binh dan': ['casual', 'budget'],
    'live music': ['live_music'], 'nhạc sống': ['live_music'], 'nhac song': ['live_music'],
    'outdoor': ['outdoor_seating'], 'ngoài trời': ['outdoor_seating'], 'ngoai troi': ['outdoor_seating'],
    'delivery': ['delivery'], 'giao hàng': ['delivery'], 'giao hang': ['delivery'],
    'đặt bàn': ['reservation'], 'dat ban': ['reservation'],

    # Attraction features
    'tự do': ['self_guided'], 'tu do': ['self_guided'],
    'có hướng dẫn': ['guided_tour'], 'co huong dan': ['guided_tour'],
    'cặp đôi': ['couples'], 'cap doi': ['couples'],
    'một mình': ['solo'], 'mot minh': ['solo'],
    'nhóm': ['groups'], 'nhom': ['groups'],
}

# --- TỪ KHÓA ĐẶC BIỆT CHO CÁC CÂU HỎI PHỨC TẠP ---
SPECIAL_QUERIES = {
    # Câu hỏi về thời tiết/mùa
    'mùa hè': {'season': 'summer', 'features': ['beach', 'pool', 'water']},
    'mua he': {'season': 'summer', 'features': ['beach', 'pool', 'water']},
    'mùa đông': {'season': 'winter', 'features': ['mountain', 'spa', 'indoor']},
    'mua dong': {'season': 'winter', 'features': ['mountain', 'spa', 'indoor']},

    # Câu hỏi về đối tượng
    'tuần trăng mật': {'target': 'honeymoon', 'features': ['romantic', 'couples', 'spa']},
    'tuan trang mat': {'target': 'honeymoon', 'features': ['romantic', 'couples', 'spa']},
    'honeymoon': {'target': 'honeymoon', 'features': ['romantic', 'couples', 'spa']},
    'công tác': {'target': 'business', 'features': ['business', 'meeting', 'wifi']},
    'cong tac': {'target': 'business', 'features': ['business', 'meeting', 'wifi']},
    'họp': {'target': 'business', 'features': ['meeting', 'conference']},
    'hop': {'target': 'business', 'features': ['meeting', 'conference']},

    # Câu hỏi về ngân sách
    'tiết kiệm': {'budget': 'low'}, 'tiet kiem': {'budget': 'low'},
    'budget': {'budget': 'low'}, 'giá rẻ': {'budget': 'low'}, 'gia re': {'budget': 'low'},
    'cao cấp': {'budget': 'high'}, 'cao cap': {'budget': 'high'},
    'luxury': {'budget': 'high'}, 'sang trọng': {'budget': 'high'}, 'sang trong': {'budget': 'high'},
    '5 sao': {'star_rating': 5}, '5 star': {'star_rating': 5},
    '4 sao': {'star_rating': 4}, '4 star': {'star_rating': 4},
    '3 sao': {'star_rating': 3}, '3 star': {'star_rating': 3},
}


# --- HÀM PARSE AMENITIES TỪ JSON STRING ---
def parse_amenities(amenities_str):
    """Parse amenities từ string '[1, 3, 5]' thành list labels"""
    if pd.isna(amenities_str) or amenities_str == 'nan' or not amenities_str:
        return []

    try:
        # Xử lý nhiều format khác nhau
        if isinstance(amenities_str, str):
            # Remove brackets và split
            clean = amenities_str.strip('[]').replace(' ', '')
            if not clean:
                return []
            ids = [int(x) for x in clean.split(',') if x.strip().isdigit()]
        elif isinstance(amenities_str, list):
            ids = [int(x) for x in amenities_str if isinstance(x, (int, float))]
        else:
            return []

        # Map IDs to labels
        labels = [AMENITIES_MAP.get(id, f"Tiện ích #{id}") for id in ids if id in AMENITIES_MAP]
        return labels
    except:
        return []


def parse_highlights(highlights_str):
    """Parse highlights từ string '[1, 3, 5]' thành list labels"""
    if pd.isna(highlights_str) or highlights_str == 'nan' or not highlights_str:
        return []

    try:
        if isinstance(highlights_str, str):
            clean = highlights_str.strip('[]').replace(' ', '')
            if not clean:
                return []
            ids = [int(x) for x in clean.split(',') if x.strip().isdigit()]
        elif isinstance(highlights_str, list):
            ids = [int(x) for x in highlights_str if isinstance(x, (int, float))]
        else:
            return []

        labels = [HIGHLIGHTS_MAP.get(id, f"Highlight #{id}") for id in ids if id in HIGHLIGHTS_MAP]
        return labels
    except:
        return []



def analyze_query(query, df):
    """Phân tích câu hỏi để tìm từ khóa chính - PHIÊN BẢN NÂNG CẤP"""

    query_lower = query.lower()
    query_no_accent = unidecode(query_lower)

    print(f"\n🔍 Analyzing: '{query}'")
    print(f"   No accent: '{query_no_accent}'")

    analysis = {
        'location': None,
        'item_types': [],
        'price_preference': None,
        'keywords': [],
        'required_amenities': [],      # NEW: Tiện ích yêu cầu
        'required_features': [],       # NEW: Features yêu cầu
        'star_rating': None,           # NEW: Số sao
        'target_audience': None,       # NEW: Đối tượng (gia đình, cặp đôi, etc.)
        'special_requirements': [],    # NEW: Yêu cầu đặc biệt
    }

    # 1. TÌM LOCATION (ƯU TIÊN CAO NHẤT)
    all_locations = df['location'].unique()
    for loc in all_locations:
        loc_lower = str(loc).lower().strip()
        loc_no_accent = unidecode(loc_lower)

        if (loc_no_accent in query_no_accent or
            loc_lower in query_lower or
            loc_no_accent.replace(" ", "").replace("-", "") in query_no_accent.replace(" ", "").replace("-", "")):

            analysis['location'] = loc
            print(f"✅ Location detected: {loc} (matched: {loc_no_accent})")
            break

    # 2. TÌM ITEM TYPE
    type_keywords = {
        'tour': ['tour', 'du lịch', 'du lich', 'trip', 'chuyến', 'chuyen', 'tham quan'],
        'hotel': ['khách sạn', 'khach san', 'hotel', 'lưu trú', 'luu tru', 'nghỉ', 'nghi', 'phòng', 'phong', 'resort', 'homestay'],
        'restaurant': ['nhà hàng', 'nha hang', 'restaurant', 'ăn', 'quán ăn', 'quan an', 'món ăn', 'mon an', 'ẩm thực', 'am thuc', 'quán', 'cafe', 'cà phê'],
        'attraction': ['địa điểm', 'dia diem', 'attraction', 'điểm đến', 'diem den', 'tham quan', 'vui chơi', 'vui choi', 'danh lam', 'thắng cảnh', 'thang canh', 'điểm du lịch', 'diem du lich']
    }

    for item_type, keywords in type_keywords.items():
        for kw in keywords:
            if kw in query_lower or kw in query_no_accent:
                if item_type not in analysis['item_types']:
                    analysis['item_types'].append(item_type)
                    print(f"✅ Item type detected: {item_type}")
                break

    # 3. TÌM PRICE PREFERENCE
    cheap_keywords = ['rẻ', 're', 'giá rẻ', 'gia re', 'tiết kiệm', 'tiet kiem', 'cheap', 'budget', 'bình dân', 'binh dan', 'phải chăng', 'phai chang']
    expensive_keywords = ['đắt', 'dat', 'cao cấp', 'cao cap', 'sang trọng', 'sang trong', 'luxury', 'expensive', 'vip', 'premium', 'hạng sang', 'hang sang']

    if any(kw in query_lower or kw in query_no_accent for kw in cheap_keywords):
        analysis['price_preference'] = 'cheap'
        print(f"✅ Price preference: cheap")
    elif any(kw in query_lower or kw in query_no_accent for kw in expensive_keywords):
        analysis['price_preference'] = 'expensive'
        print(f"✅ Price preference: expensive")

    # 4. TÌM AMENITIES/TIỆN ÍCH (NEW!)
    for kw, amenity_ids in AMENITY_KEYWORDS.items():
        if kw in query_lower or kw in query_no_accent:
            for aid in amenity_ids:
                if aid not in analysis['required_amenities']:
                    analysis['required_amenities'].append(aid)
            print(f"✅ Amenity keyword detected: '{kw}' → IDs: {amenity_ids}")

    # 5. TÌM FEATURES (NEW!)
    for kw, features in FEATURE_KEYWORDS.items():
        if kw in query_lower or kw in query_no_accent:
            for f in features:
                if f not in analysis['required_features']:
                    analysis['required_features'].append(f)
            print(f"✅ Feature keyword detected: '{kw}' → {features}")

    # 6. TÌM STAR RATING (NEW!)
    import re
    star_match = re.search(r'(\d)\s*sao', query_lower) or re.search(r'(\d)\s*star', query_lower)
    if star_match:
        analysis['star_rating'] = int(star_match.group(1))
        print(f"✅ Star rating: {analysis['star_rating']} sao")

    # 7. TÌM TARGET AUDIENCE (NEW!)
    audience_keywords = {
        'family': ['gia đình', 'gia dinh', 'family', 'trẻ em', 'tre em', 'con nhỏ', 'con nho', 'kids', 'children'],
        'couples': ['cặp đôi', 'cap doi', 'couple', 'lãng mạn', 'lang man', 'romantic', 'tuần trăng mật', 'tuan trang mat', 'honeymoon'],
        'solo': ['một mình', 'mot minh', 'solo', 'đi một mình', 'di mot minh'],
        'business': ['công tác', 'cong tac', 'business', 'họp', 'hop', 'hội nghị', 'hoi nghi', 'meeting'],
        'groups': ['nhóm', 'nhom', 'group', 'đoàn', 'doan', 'tập thể', 'tap the']
    }

    for audience, keywords in audience_keywords.items():
        for kw in keywords:
            if kw in query_lower or kw in query_no_accent:
                analysis['target_audience'] = audience
                print(f"✅ Target audience: {audience}")
                break
        if analysis['target_audience']:
            break

    # 8. XỬ LÝ CÂU HỎI ĐẶC BIỆT (NEW!)
    for kw, special in SPECIAL_QUERIES.items():
        if kw in query_lower or kw in query_no_accent:
            if 'star_rating' in special and not analysis['star_rating']:
                analysis['star_rating'] = special['star_rating']
                print(f"✅ Special: Star rating = {special['star_rating']}")
            if 'features' in special:
                for f in special['features']:
                    if f not in analysis['required_features']:
                        analysis['required_features'].append(f)
                print(f"✅ Special features: {special['features']}")
            if 'target' in special and not analysis['target_audience']:
                analysis['target_audience'] = special['target']
            analysis['special_requirements'].append(kw)

    # 9. TÌM KEYWORDS KHÁC
    general_keywords = ['dịch vụ', 'dich vu', 'service', 'gợi ý', 'goi y', 'suggest', 'giới thiệu', 'gioi thieu', 'recommend', 'tư vấn', 'tu van', 'tìm', 'tim', 'có gì', 'co gi']
    for kw in general_keywords:
        if kw in query_lower or kw in query_no_accent:
            analysis['keywords'].append(kw)

    return analysis


# ==========================================
# HÀM SEARCH_IN_DATA MỚI (THAY THẾ HÀM CŨ)
# ==========================================
def search_in_data(analysis, df):
    """Tìm kiếm trong CSV theo analysis - PHIÊN BẢN NÂNG CẤP"""

    if df is None or len(df) == 0:
        return []

    print(f"\n📊 Searching in CSV (Advanced)...")
    print(f"   Location: {analysis['location']}")
    print(f"   Item types: {analysis['item_types']}")
    print(f"   Price pref: {analysis['price_preference']}")
    print(f"   Required amenities: {analysis['required_amenities']}")
    print(f"   Required features: {analysis['required_features']}")
    print(f"   Star rating: {analysis['star_rating']}")
    print(f"   Target audience: {analysis['target_audience']}")

    # BẮT ĐẦU TỪ TOÀN BỘ DATA
    filtered = df.copy()

    # 1. FILTER THEO LOCATION (ƯU TIÊN CAO NHẤT)
    if analysis['location']:
        filtered = filtered[filtered['location'] == analysis['location']]
        print(f"   → Filtered by location: {len(filtered)} results")

    # 2. FILTER THEO ITEM TYPE (NẾU CÓ)
    if analysis['item_types'] and len(filtered) > 0:
        filtered = filtered[filtered['item_type'].isin(analysis['item_types'])]
        print(f"   → Filtered by item_type: {len(filtered)} results")

    # 3. FILTER THEO STAR RATING (NEW!)
    if analysis['star_rating'] and len(filtered) > 0:
        if 'star_rating' in filtered.columns:
            # Cho phép sai số 0.5 sao
            target = analysis['star_rating']
            filtered = filtered[
                (filtered['star_rating'] >= target - 0.5) &
                (filtered['star_rating'] <= target + 0.5)
            ]
            print(f"   → Filtered by star_rating (~{target}): {len(filtered)} results")

    # 4. FILTER THEO AMENITIES (NEW!)
    if analysis['required_amenities'] and len(filtered) > 0:
        def has_amenities(row):
            amenities_str = str(row.get('amenities_json', ''))
            if pd.isna(amenities_str) or amenities_str == 'nan':
                return False
            try:
                clean = amenities_str.strip('[]').replace(' ', '')
                if not clean:
                    return False
                row_ids = set(int(x) for x in clean.split(',') if x.strip().isdigit())
                # Kiểm tra xem có ít nhất 1 amenity match không
                return bool(row_ids.intersection(set(analysis['required_amenities'])))
            except:
                return False

        before_count = len(filtered)
        filtered = filtered[filtered.apply(has_amenities, axis=1)]
        if len(filtered) == 0:
            # Nếu không có kết quả, fallback về kết quả trước đó
            filtered = df.copy()
            if analysis['location']:
                filtered = filtered[filtered['location'] == analysis['location']]
            if analysis['item_types']:
                filtered = filtered[filtered['item_type'].isin(analysis['item_types'])]
            print(f"   → Amenities filter returned 0, fallback to {len(filtered)} results")
        else:
            print(f"   → Filtered by amenities: {len(filtered)} results (from {before_count})")

    # 5. FILTER THEO FEATURES (NEW!)
    if analysis['required_features'] and len(filtered) > 0:
        def has_features(row):
            features_str = str(row.get('normalized_features', ''))
            if pd.isna(features_str) or features_str == 'nan':
                return False
            features_lower = features_str.lower()
            # Kiểm tra xem có ít nhất 1 feature match không
            for f in analysis['required_features']:
                if f.lower() in features_lower:
                    return True
            return False

        before_count = len(filtered)
        temp_filtered = filtered[filtered.apply(has_features, axis=1)]
        if len(temp_filtered) > 0:
            filtered = temp_filtered
            print(f"   → Filtered by features: {len(filtered)} results (from {before_count})")
        else:
            print(f"   → Features filter returned 0, keeping {len(filtered)} results")

    # 6. FILTER THEO TARGET AUDIENCE (NEW!)
    if analysis['target_audience'] and len(filtered) > 0:
        def matches_audience(row):
            features_str = str(row.get('normalized_features', ''))
            suitable_str = str(row.get('suitable_for_json', ''))
            combined = (features_str + ' ' + suitable_str).lower()
            target = analysis['target_audience'].lower()
            return target in combined

        before_count = len(filtered)
        temp_filtered = filtered[filtered.apply(matches_audience, axis=1)]
        if len(temp_filtered) > 0:
            filtered = temp_filtered
            print(f"   → Filtered by audience '{analysis['target_audience']}': {len(filtered)} results")
        else:
            print(f"   → Audience filter returned 0, keeping {len(filtered)} results")

    # 7. SORT THEO PRICE PREFERENCE
    if len(filtered) > 0:
        if analysis['price_preference'] == 'cheap':
            filtered = filtered.sort_values('price', ascending=True)
            print(f"   → Sorted by price (cheap first)")
        elif analysis['price_preference'] == 'expensive':
            filtered = filtered.sort_values('price', ascending=False)
            print(f"   → Sorted by price (expensive first)")
        else:
            filtered = filtered.sort_values('price', ascending=True)

    # 8. LẤY TOP RESULTS
    results = filtered.head(10)

    print(f"✅ Found {len(results)} results")

    return results.to_dict('records')


# ==========================================
# HÀM CREATE_CONTEXT MỚI (THAY THẾ HÀM CŨ)
# ==========================================
def create_context(results, analysis):
    """Tạo context từ kết quả tìm kiếm - PHIÊN BẢN NÂNG CẤP"""

    location_text = analysis['location'] or 'địa điểm này'

    if not results:
        # Tạo thông báo chi tiết hơn khi không có kết quả
        no_result_msg = f"⚠️ Không tìm thấy dịch vụ phù hợp tại {location_text}"
        if analysis['required_amenities']:
            amenity_names = [AMENITIES_MAP.get(aid, f"#{aid}") for aid in analysis['required_amenities'][:3]]
            no_result_msg += f" với tiện ích: {', '.join(amenity_names)}"
        if analysis['star_rating']:
            no_result_msg += f" ({analysis['star_rating']} sao)"
        return no_result_msg

    context_parts = []

    # Group theo item_type
    grouped = {}
    for r in results:
        item_type = r['item_type']
        if item_type not in grouped:
            grouped[item_type] = []
        grouped[item_type].append(r)

    # Format theo từng loại
    for item_type, items in grouped.items():
        context_parts.append(f"\n=== {item_type.upper()} ({len(items)} kết quả) ===")

        for r in items:
            # Parse amenities thành text đẹp
            amenities_list = parse_amenities(r.get('amenities_json', ''))
            amenities_text = ', '.join(amenities_list[:5]) if amenities_list else 'Không có thông tin'

            # Parse highlights nếu có
            highlights_list = []
            # Thử parse từ normalized_features nếu là số
            features = r.get('normalized_features', '')
            if features and str(features).strip('[]').replace(' ', '').replace(',', '').isdigit():
                highlights_list = parse_highlights(features)

            # Format features text
            if highlights_list:
                features_text = ', '.join(highlights_list[:5])
            else:
                features_text = str(features) if features and str(features) != 'nan' else 'N/A'

            # Thêm star rating nếu có
            star_text = ''
            if 'star_rating' in r and r['star_rating'] and not pd.isna(r['star_rating']):
                star_text = f"\n- Xếp hạng: {r['star_rating']} sao"

            context_parts.append(
                f"\nDỊCH VỤ: {r['title']}\n"
                f"- Loại: {r['item_type']}\n"
                f"- Địa điểm: {r['location']}\n"
                f"- Giá: {r['price']} VND"
                f"{star_text}\n"
                f"- Đặc điểm: {features_text}\n"
                f"- Tiện ích: {amenities_text}"
            )

    return "\n".join(context_parts)

# --- MAIN SEARCH FUNCTION ---
def smart_search(query, df):
    """Hàm tìm kiếm chính"""

    if df is None:
        return "⚠️ Hệ thống chưa sẵn sàng"

    # Bước 1: Phân tích câu hỏi
    analysis = analyze_query(query, df)

    # Bước 2: Tìm trong CSV
    results = search_in_data(analysis, df)

    # Bước 3: Tạo context
    context = create_context(results, analysis)

    return context

# --- BOT ---
app = FastAPI()
llm = ChatGroq(model="llama-3.3-70b-versatile", temperature=0.3)

template = """Bạn là TripBOT - trợ lý ảo thông minh của nền tảng Tripfinity, chuyên gia tư vấn du lịch toàn diện.

=== QUY TẮC ƯU TIÊN DỮ LIỆU (BẮT BUỘC TUÂN THỦ) ===
🚨 **QUAN TRỌNG - ĐỌC KỸ VÀ THỰC HIỆN NGHIÊM NGẶT:**

1. **KHI CÓ DỮ LIỆU TỪ HỆ THỐNG (dưới đây):**
   - ✅ BẮT BUỘC giới thiệu TẤT CẢ các dịch vụ có trong dữ liệu
   - ✅ PHẢI format đúng như mẫu với đầy đủ emoji
   - ✅ Sắp xếp theo giá từ thấp đến cao
   - ✅ TUYỆT ĐỐI KHÔNG bỏ qua hoặc dùng kiến thức tổng quát thay thế
   - ✅ KHÔNG được nói "hệ thống chưa có dữ liệu" khi đã có dữ liệu bên dưới

2. **CHỈ KHI THỰC SỰ KHÔNG CÓ DỮ LIỆU (rỗng hoặc có cảnh báo ⚠️):**
   - Mới được dùng kiến thức tổng quát
   - Phải nói: "Hiện hệ thống chưa có dữ liệu chi tiết về [tên địa điểm/dịch vụ]..."

3. **FORMAT BẮT BUỘC khi có dữ liệu:**

Dựa trên dữ liệu hệ thống Tripfinity, tôi tìm thấy **[X] dịch vụ** phù hợp tại **[địa điểm]**:

🎯 **[Tên dịch vụ 1]**
📍 Địa điểm: [location]
💰 Giá: [price] VND (~[price/1000]K)
🏷️ Loại: [tour/hotel/restaurant/attraction]
⭐ Đặc điểm: [features chính, ngắn gọn]
🎁 Tiện ích: [nếu có, nếu không thì bỏ dòng này]

🎯 **[Tên dịch vụ 2]**
📍 Địa điểm: [location]
💰 Giá: [price] VND (~[price/1000]K)
🏷️ Loại: [tour/hotel/restaurant/attraction]
⭐ Đặc điểm: [features chính]

[Tiếp tục với TẤT CẢ dịch vụ còn lại...]

💡 **Gợi ý của tôi:**
[Lời khuyên dựa trên dữ liệu: giá tốt nhất, kết hợp dịch vụ, thời điểm đi, tips, etc.]

📞 Bạn muốn tôi tư vấn thêm chi tiết về dịch vụ nào không?

4. **XỬ LÝ CÁC TRƯỜNG HỢP ĐẶC BIỆT:**
   - Nếu người dùng hỏi chung chung (VD: "cho tôi xem dịch vụ", "có gì hay", "giới thiệu đi"...):
     → BẮT BUỘC show dịch vụ từ dữ liệu nếu có
   - Nếu người dùng hỏi về 1 địa điểm cụ thể:
     → Tìm CHÍNH XÁC địa điểm đó, KHÔNG đưa ra địa điểm khác
   - Nếu người dùng hỏi "có tour/khách sạn/nhà hàng không":
     → BẮT BUỘC show dữ liệu nếu có trong hệ thống

=== NHÂN DẠNG VÀ PHONG CÁCH ===
- Tên: TripBOT (thuộc hệ sinh thái Tripfinity)
- Vai trò: Chuyên gia tư vấn du lịch AI
- Giọng điệu: Thân thiện, chuyên nghiệp, nhiệt tình
- Đa ngôn ngữ: Tự động phát hiện và trả lời bằng ngôn ngữ người dùng

=== HỖ TRỢ ĐA NGÔN NGỮ ===
🌐 Hỗ trợ: Tiếng Việt, English, 中文, 日本語, 한국어, Français, Español, Deutsch

=== XỬ LÝ YÊU CẦU CHUYỂN NHÂN VIÊN ===
Khi người dùng muốn chat với nhân viên thực, trả lời:
"[TRANSFER_TO_STAFF] Tôi hiểu bạn muốn kết nối với nhân viên hỗ trợ. Vui lòng xác nhận bạn có muốn chuyển sang chat với nhân viên không?"

=== CHUYÊN MÔN CỐT LÕI ===
Chỉ tư vấn về du lịch:
🗺️ Kế hoạch chuyến đi | 🏨 Lưu trú | 🍜 Ẩm thực | 🎯 Điểm đến | 🚗 Tour | 💰 Ngân sách | 🌍 Văn hóa

=== QUY TẮC NGHIÊM NGẶT ===
❌ KHÔNG trả lời về: tình yêu, chính trị, tôn giáo, y tế, tài chính cá nhân, pháp lý

=== DỮ LIỆU TỪ HỆ THỐNG TRIPFINITY ===
{context}

=== VỀ TRIPFINITY ===
Nền tảng du lịch hàng đầu: Đặt khách sạn, tour, nhà hàng | Lập kế hoạch thông minh | Hỗ trợ 24/7

=== LỊCH SỬ ===
{history}

Người dùng: {input}
TripBOT:"""

prompt = ChatPromptTemplate.from_template(template)
memory = ConversationBufferMemory(memory_key="history", input_key="input")
conversation = LLMChain(llm=llm, prompt=prompt, memory=memory, verbose=True)

class Message(BaseModel):
    message: str

# ==========================================
# HÀM PHÂN LOẠI CÂU HỎI (NEW!)
# ==========================================
def classify_query(query):
    """
    Phân loại câu hỏi của người dùng:
    - 'greeting': Chào hỏi, hỏi thăm
    - 'service': Hỏi về dịch vụ du lịch (tour, hotel, restaurant, attraction)
    - 'off_topic': Hỏi ngoài lề (âm nhạc, chính trị, y tế, etc.)
    - 'general_travel': Hỏi chung về du lịch nhưng không cần items
    """
    query_lower = query.lower()
    query_no_accent = unidecode(query_lower)
    
    # 1. GREETING patterns
    greeting_patterns = [
        'xin chào', 'xin chao', 'chào', 'chao', 'hello', 'hi', 'hey',
        'bạn là ai', 'ban la ai', 'who are you',
        'bạn có thể giúp gì', 'ban co the giup gi', 'giúp gì', 'giup gi',
        'bạn làm được gì', 'ban lam duoc gi',
        'cảm ơn', 'cam on', 'thank', 'thanks',
        'tạm biệt', 'tam biet', 'bye', 'goodbye',
        'ok', 'okay', 'được', 'duoc', 'tốt', 'tot', 'good',
    ]
    
    # Check if query is ONLY greeting (short and matches pattern)
    if len(query_lower.split()) <= 10:
        for pattern in greeting_patterns:
            if pattern in query_lower or pattern in query_no_accent:
                # Make sure it's not asking for services
                service_indicators = ['tour', 'khách sạn', 'khach san', 'hotel', 'nhà hàng', 'nha hang', 
                                     'địa điểm', 'dia diem', 'dịch vụ', 'dich vu', 'tìm', 'tim', 
                                     'gợi ý', 'goi y', 'đặt', 'dat', 'book']
                if not any(si in query_lower or si in query_no_accent for si in service_indicators):
                    return 'greeting'
    
    # 2. OFF-TOPIC patterns (từ chối)
    off_topic_patterns = [
        # Âm nhạc
        'âm nhạc', 'am nhac', 'music', 'bài hát', 'bai hat', 'ca sĩ', 'ca si', 'nhạc', 'nhac',
        # Chính trị
        'chính trị', 'chinh tri', 'politic', 'bầu cử', 'bau cu', 'đảng', 'dang', 'chính phủ', 'chinh phu',
        # Y tế
        'bệnh', 'benh', 'thuốc', 'thuoc', 'điều trị', 'dieu tri', 'bác sĩ', 'bac si', 'y tế', 'y te',
        # Tài chính
        'cổ phiếu', 'co phieu', 'stock', 'bitcoin', 'crypto', 'đầu tư', 'dau tu', 'chứng khoán', 'chung khoan',
        # Tôn giáo
        'tôn giáo', 'ton giao', 'religion', 'đạo', 'dao',
        # Pháp lý
        'luật', 'luat', 'law', 'pháp lý', 'phap ly', 'kiện', 'kien',
        # Tình yêu cá nhân
        'người yêu', 'nguoi yeu', 'bạn gái', 'ban gai', 'bạn trai', 'ban trai', 'hẹn hò', 'hen ho',
        # Khác
        'code', 'lập trình', 'lap trinh', 'programming', 'hack', 'game', 'phim', 'movie',
    ]
    
    for pattern in off_topic_patterns:
        if pattern in query_lower or pattern in query_no_accent:
            return 'off_topic'
    
    # 3. SERVICE patterns (cần search items)
    service_patterns = [
        # Địa điểm cụ thể
        'ở', 'o', 'tại', 'tai', 'đến', 'den', 'đi', 'di',
        # Loại dịch vụ
        'tour', 'khách sạn', 'khach san', 'hotel', 'resort', 'homestay',
        'nhà hàng', 'nha hang', 'restaurant', 'quán ăn', 'quan an', 'ăn gì', 'an gi',
        'địa điểm', 'dia diem', 'điểm đến', 'diem den', 'attraction', 'tham quan',
        'dịch vụ', 'dich vu', 'service',
        # Hành động tìm kiếm
        'tìm', 'tim', 'find', 'search', 'kiếm', 'kiem',
        'gợi ý', 'goi y', 'suggest', 'recommend', 'đề xuất', 'de xuat',
        'giới thiệu', 'gioi thieu', 'cho tôi', 'cho toi', 'show',
        'đặt', 'dat', 'book', 'booking',
        'giá', 'gia', 'price', 'bao nhiêu', 'bao nhieu',
        # Đặc điểm dịch vụ
        'sao', 'star', 'hồ bơi', 'ho boi', 'pool', 'spa', 'gym', 'view',
        'rẻ', 're', 'cheap', 'cao cấp', 'cao cap', 'luxury',
    ]
    
    for pattern in service_patterns:
        if pattern in query_lower or pattern in query_no_accent:
            return 'service'
    
    # 4. GENERAL TRAVEL (hỏi chung về du lịch, không cần items)
    travel_patterns = [
        'du lịch', 'du lich', 'travel', 'trip', 'chuyến đi', 'chuyen di',
        'nên đi đâu', 'nen di dau', 'đi đâu', 'di dau',
        'kinh nghiệm', 'kinh nghiem', 'tips', 'mẹo', 'meo',
        'thời tiết', 'thoi tiet', 'weather', 'mùa', 'mua', 'season',
        'visa', 'hộ chiếu', 'ho chieu', 'passport',
    ]
    
    for pattern in travel_patterns:
        if pattern in query_lower or pattern in query_no_accent:
            return 'general_travel'
    
    # Default: treat as greeting/general
    return 'greeting'


# ==========================================
# HÀM EXTRACT ITEMS CHO FLUTTER (NEW!)
# ==========================================
def extract_items_for_flutter(results):
    """Trích xuất thông tin items để gửi cho Flutter app hiển thị cards"""
    items = []
    for r in results:
        item_id = r.get('item_id', 0)
        # CHỈ thêm item nếu có item_id hợp lệ
        if item_id and int(item_id) > 0:
            item = {
                'item_id': int(item_id),
                'item_type': str(r.get('item_type', '')),
                'title': str(r.get('title', '')),
                'location': str(r.get('location', '')),
                'price': float(r.get('price', 0)),
                'star_rating': float(r.get('star_rating', 0)) if r.get('star_rating') and not pd.isna(r.get('star_rating')) else 0.0,
            }
            items.append(item)
    return items


@app.post("/api/chat")
async def chat(message: Message):
    try:
        user_message = message.message
        
        # 1. PHÂN LOẠI CÂU HỎI
        query_type = classify_query(user_message)
        print(f"\n🏷️ Query type: {query_type}")
        
        # 2. XỬ LÝ THEO LOẠI
        if query_type == 'off_topic':
            # Từ chối câu hỏi ngoài lề
            return {
                "response": "Xin lỗi, tôi là TripBOT - trợ lý du lịch của Tripfinity. Tôi chỉ có thể hỗ trợ bạn các vấn đề liên quan đến du lịch như tìm khách sạn, tour, nhà hàng, điểm tham quan. Bạn cần tôi giúp gì về du lịch không? 🗺️",
                "items": [],
                "has_items": False,
                "query_type": "off_topic"
            }
        
        elif query_type == 'greeting':
            # Chào hỏi - trả lời thân thiện, KHÔNG search items
            response = conversation.predict(
                input=user_message, 
                context="[GREETING] Người dùng đang chào hỏi hoặc hỏi thăm. Hãy trả lời ngắn gọn, thân thiện và giới thiệu bản thân là TripBOT - trợ lý du lịch. KHÔNG liệt kê dịch vụ."
            )
            return {
                "response": response,
                "items": [],
                "has_items": False,
                "query_type": "greeting"
            }
        
        elif query_type == 'general_travel':
            # Hỏi chung về du lịch - trả lời tư vấn, KHÔNG search items
            response = conversation.predict(
                input=user_message, 
                context="[GENERAL_TRAVEL] Người dùng hỏi chung về du lịch. Hãy tư vấn ngắn gọn và hỏi xem họ cần tìm dịch vụ cụ thể nào không."
            )
            return {
                "response": response,
                "items": [],
                "has_items": False,
                "query_type": "general_travel"
            }
        
        else:  # query_type == 'service'
            # Hỏi về dịch vụ - SEARCH và trả về items
            analysis = analyze_query(user_message, df_data)
            results = search_in_data(analysis, df_data)
            
            # Trích xuất items (chỉ những item có ID hợp lệ)
            items = extract_items_for_flutter(results)
            
            if len(items) > 0:
                # Có items - tạo context CHI TIẾT với thông tin items thực tế
                location_text = analysis['location'] or 'theo yêu cầu của bạn'
                
                # Map item_type sang tiếng Việt
                type_map = {
                    'tour': 'Tour du lịch',
                    'hotel': 'Khách sạn',
                    'restaurant': 'Nhà hàng',
                    'attraction': 'Điểm tham quan'
                }
                
                # Tạo mô tả cho TẤT CẢ items (không giới hạn 5)
                items_summary = []
                for idx, item in enumerate(items, 1):
                    price_str = f"{int(item['price']):,}".replace(',', '.') + " VND"
                    type_vi = type_map.get(item['item_type'], item['item_type'])
                    items_summary.append(f"{idx}. {item['title']} ({type_vi}) - {price_str}")
                
                items_text = "\n".join(items_summary)
                
                context = f"""[SERVICE_FOUND] Tìm thấy {len(items)} dịch vụ tại {location_text}.

DANH SÁCH DỊCH VỤ THỰC TẾ TỪ HỆ THỐNG (PHẢI MÔ TẢ ĐẦY ĐỦ {len(items)} DỊCH VỤ):
{items_text}

QUY TẮC TRẢ LỜI BẮT BUỘC:
- MÔ TẢ ĐẦY ĐỦ TẤT CẢ {len(items)} dịch vụ trong danh sách trên
- Sử dụng ĐÚNG tên tiếng Việt cho loại dịch vụ: Tour du lịch, Khách sạn, Nhà hàng, Điểm tham quan
- CHỈ nhắc đến TÊN và GIÁ ĐÚNG như danh sách trên
- KHÔNG tự tạo dữ liệu mới hoặc thêm dịch vụ không có trong danh sách
- KHÔNG bỏ sót bất kỳ dịch vụ nào
- Có thể gợi ý 1-2 dịch vụ nổi bật cuối cùng"""

                response = conversation.predict(input=user_message, context=context)
                
                return {
                    "response": response,
                    "items": items,
                    "has_items": True,
                    "query_type": "service"
                }
            else:
                # Không tìm thấy items
                location_text = analysis['location'] or 'bạn tìm kiếm'
                response = f"Xin lỗi, dịch vụ tại **{location_text}** hiện chưa có trên hệ thống Tripfinity. Bạn có thể thử tìm ở địa điểm khác hoặc liên hệ nhân viên hỗ trợ nhé! 📞"
                
                return {
                    "response": response,
                    "items": [],
                    "has_items": False,
                    "query_type": "service_not_found"
                }
    
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))

public_url = ngrok.connect(8000)
print(f"\n🚀 Server: {public_url}\n")

def run_uvicorn():
    uvicorn.run(app, host="0.0.0.0", port=8000)

threading.Thread(target=run_uvicorn).start()

# !pip install -q gradio requests

# import gradio as gr
# import requests

# # Hàm gửi tin nhắn đến Server API của bạn
# def chat_with_bot(message, history):
#     # Kết nối đến server nội bộ (localhost) vì đang chạy cùng trên Colab
#     api_url = "http://localhost:8000/api/chat"

#     try:
#         payload = {"message": message}
#         response = requests.post(api_url, json=payload)

#         if response.status_code == 200:
#             return response.json().get("response", "Lỗi: Không nhận được phản hồi.")
#         else:
#             return f"Lỗi Server: {response.status_code} - {response.text}"

#     except Exception as e:
#         return f"Không kết nối được với Bot: {str(e)}"

# # Tạo giao diện Chat đẹp mắt
# demo = gr.ChatInterface(
#     fn=chat_with_bot,
#     title="🤖 TripBOT Test Interface",
#     description="Nhập câu hỏi về du lịch để test hệ thống RAG + Gemini.",
#     examples=[
#         "Tìm khách sạn ở Đà Nẵng giá dưới 1 triệu",
#         "Có tour nào đi Bà Nà Hills không?",
#         "Ăn gì ngon ở Huế?",
#         "Tôi muốn gặp nhân viên tư vấn"
#     ],
#     theme="soft"
# )

# # Khởi chạy giao diện
# print(">>> Đang mở giao diện chat...")
# demo.launch(share=True, debug=True)