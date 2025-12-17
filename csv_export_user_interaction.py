import mysql.connector
import csv
from datetime import datetime

# Database connection config
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'sqlpass',
    'database': 'tripfinity',
    'charset': 'utf8mb4'
}

def export_user_interactions_to_csv():
    """
    Export toàn bộ dữ liệu từ bảng user_item_interactions ra file CSV với UTF-8 encoding
    """
    try:
        # Kết nối database
        print("Đang kết nối database...")
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor(dictionary=True)
        
        # Query toàn bộ dữ liệu
        query = """
        SELECT 
            interaction_id,
            user_id,
            item_id,
            item_type,
            action_type,
            action_weight,
            interaction_timestamp,
            created_at
        FROM user_item_interactions
        ORDER BY interaction_timestamp DESC
        """
        
        print("Đang truy vấn dữ liệu...")
        cursor.execute(query)
        rows = cursor.fetchall()
        
        if not rows:
            print("❌ Không có dữ liệu trong bảng user_item_interactions!")
            return
        
        # Tạo tên file với timestamp
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        output_file = f'user_item_interactions_export_{timestamp}.csv'
        
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
                # Convert datetime sang string format
                for key in row:
                    if row[key] is not None:
                        if isinstance(row[key], datetime):
                            row[key] = row[key].strftime('%Y-%m-%d %H:%M:%S')
                    else:
                        row[key] = ''
                
                writer.writerow(row)
        
        print(f"✅ Export thành công!")
        print(f"📁 File: {output_file}")
        print(f"📊 Tổng số interactions: {len(rows)}")
        
        # Thống kê theo action_type
        action_stats = {}
        for row in rows:
            action_type = row['action_type']
            action_stats[action_type] = action_stats.get(action_type, 0) + 1
        
        print("\n📈 Thống kê theo action_type:")
        for action_type, count in sorted(action_stats.items()):
            print(f"   - {action_type}: {count} records")
        
        # Thống kê theo item_type
        item_stats = {}
        for row in rows:
            item_type = row['item_type']
            item_stats[item_type] = item_stats.get(item_type, 0) + 1
        
        print("\n📈 Thống kê theo item_type:")
        for item_type, count in sorted(item_stats.items()):
            print(f"   - {item_type}: {count} records")
        
        # Thống kê user
        unique_users = set(row['user_id'] for row in rows)
        print(f"\n👥 Tổng số user có tương tác: {len(unique_users)}")
        
        cursor.close()
        conn.close()
        
    except mysql.connector.Error as err:
        print(f"❌ Lỗi database: {err}")
    except Exception as e:
        print(f"❌ Lỗi: {e}")

if __name__ == "__main__":
    print("="*60)
    print("EXPORT USER ITEM INTERACTIONS TO CSV")
    print("="*60)
    export_user_interactions_to_csv()
