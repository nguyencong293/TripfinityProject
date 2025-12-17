import mysql.connector
import csv
import json
from datetime import datetime

# Database connection config
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'sqlpass',  # Điền password của bạn
    'database': 'tripfinity',
    'charset': 'utf8mb4'
}

def export_ai_item_tower_to_csv():
    """
    Export toàn bộ dữ liệu từ bảng ai_item_tower ra file CSV với UTF-8 encoding
    """
    try:
        # Kết nối database
        print("Đang kết nối database...")
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor(dictionary=True)
        
        # Query toàn bộ dữ liệu
        query = """
        SELECT 
            tower_item_id,
            item_type,
            item_id,
            title,
            location,
            latitude,
            longitude,
            price,
            normalized_features,
            star_rating,
            property_type,
            difficulty_level,
            tour_type,
            attraction_type,
            amenities_json,
            categories_json,
            cuisines_json,
            diets_json,
            suitable_for_json
        FROM ai_item_tower
        ORDER BY item_type, item_id
        """
        
        print("Đang truy vấn dữ liệu...")
        cursor.execute(query)
        rows = cursor.fetchall()
        
        if not rows:
            print("❌ Không có dữ liệu trong bảng ai_item_tower!")
            return
        
        # Tạo tên file với timestamp
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        output_file = f'ai_item_tower_export_{timestamp}.csv'
        
        # Export ra CSV với UTF-8 encoding
        print(f"Đang export {len(rows)} records vào {output_file}...")
        
        with open(output_file, 'w', newline='', encoding='utf-8-sig') as csvfile:
            # Lấy tên cột
            fieldnames = rows[0].keys()
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            
            # Ghi header
            writer.writeheader()
            
            # Ghi data
            for row in rows:
                # Convert JSON columns sang string để dễ đọc trong CSV
                for key in row:
                    if row[key] is not None:
                        # Nếu là JSON object/array, convert sang string
                        if key.endswith('_json') or key == 'normalized_features':
                            if isinstance(row[key], (dict, list)):
                                row[key] = json.dumps(row[key], ensure_ascii=False)
                            elif isinstance(row[key], str):
                                # Đã là string rồi, giữ nguyên
                                pass
                    else:
                        row[key] = ''  # NULL thành empty string
                
                writer.writerow(row)
        
        print(f"✅ Export thành công!")
        print(f"📁 File: {output_file}")
        print(f"📊 Tổng số records: {len(rows)}")
        
        # Thống kê theo item_type
        stats = {}
        for row in rows:
            item_type = row['item_type']
            stats[item_type] = stats.get(item_type, 0) + 1
        
        print("\n📈 Thống kê theo loại dịch vụ:")
        for item_type, count in sorted(stats.items()):
            print(f"   - {item_type}: {count} records")
        
        cursor.close()
        conn.close()
        
    except mysql.connector.Error as err:
        print(f"❌ Lỗi database: {err}")
    except Exception as e:
        print(f"❌ Lỗi: {e}")

if __name__ == "__main__":
    print("="*60)
    print("EXPORT AI ITEM TOWER TO CSV")
    print("="*60)
    export_ai_item_tower_to_csv()
