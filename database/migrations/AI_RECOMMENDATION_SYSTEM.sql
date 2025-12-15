-- ============================================================
-- AI RECOMMENDATION SYSTEM - TWO-TOWER MODEL
-- BẢNG USER INTERACTION (USER TOWER)
-- Created: 2025-12-15
-- Purpose: Chỉ lưu HÀNH VI người dùng. Item data lấy từ 4 bảng gốc!
-- ============================================================

-- ============================================================
-- BẢNG USER TOWER: user_item_interactions
-- Item Tower: Lấy trực tiếp từ tours, hotels, attractions, restaurants
-- ============================================================

DROP TABLE IF EXISTS `user_item_interactions`;

CREATE TABLE `user_item_interactions` (
  -- ID
  `interaction_id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  
  -- ============================================================
  -- CORE: Thông tin tương tác (BẮT BUỘC)
  -- ============================================================
  `user_id` INT NOT NULL COMMENT 'ID người dùng',
  `item_id` INT NOT NULL COMMENT 'ID dịch vụ (tour_id, hotel_id, attraction_id, restaurant_id)',
  `item_type` ENUM('tour', 'hotel', 'attraction', 'restaurant') NOT NULL COMMENT 'Loại dịch vụ',
  `action_type` ENUM('search', 'view', 'click', 'favorite', 'book') NOT NULL COMMENT 'Hành động người dùng',
  `action_weight` TINYINT NOT NULL COMMENT 'Trọng số: search=1, view=2, click=3, favorite=4, book=5',
  `interaction_timestamp` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời gian tương tác',
  
  
  -- ============================================================
  -- METADATA
  -- ============================================================
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- ============================================================
  -- INDEXES
  -- ============================================================
  KEY `idx_user_id` (`user_id`),
  KEY `idx_item` (`item_type`, `item_id`),
  KEY `idx_action` (`action_type`, `action_weight`),
  KEY `idx_timestamp` (`interaction_timestamp` DESC),
  KEY `idx_user_time` (`user_id`, `interaction_timestamp` DESC),
  KEY `idx_train_data` (`user_id`, `item_id`, `item_type`, `action_weight`),
  
  -- ============================================================
  -- FOREIGN KEYS
  -- ============================================================
  CONSTRAINT `fk_interaction_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  
  -- ============================================================
  -- CHECK CONSTRAINTS
  -- ============================================================
  CONSTRAINT `chk_action_weight` CHECK (`action_weight` BETWEEN 1 AND 10)
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Bảng User Tower - Chỉ lưu hành vi người dùng. Item data lấy từ tours/hotels/attractions/restaurants';


-- ============================================================
-- HƯỚNG DẪN SỬ DỤNG
-- ============================================================

/*
==============================================================
1. GHI NHẬN HÀNH VI USER (Backend Java/Spring Boot)
==============================================================

// Khi user XEM dịch vụ:
INSERT INTO user_item_interactions (
  user_id, item_id, item_type, action_type, action_weight
) VALUES (?, ?, 'tour', 'view', 2);


// Khi user TÌM KIẾM:
INSERT INTO user_item_interactions (
  user_id, item_id, item_type, action_type, action_weight, search_query
) VALUES (?, 0, 'tour', 'search', 1, ?);


// Khi user CLICK vào dịch vụ:
INSERT INTO user_item_interactions (
  user_id, item_id, item_type, action_type, action_weight
) VALUES (?, ?, 'hotel', 'click', 3);


// Khi user THÊM YÊU THÍCH:
INSERT INTO user_item_interactions (
  user_id, item_id, item_type, action_type, action_weight
) VALUES (?, ?, 'attraction', 'favorite', 4);


// Khi user BOOK:
INSERT INTO user_item_interactions (
  user_id, item_id, item_type, action_type, action_weight
) VALUES (?, ?, 'restaurant', 'book', 5);


==============================================================
2. EXPORT DỮ LIỆU ĐỂ TRAIN AI (Python)
==============================================================

# File: export_training_data.py

import pandas as pd
from sqlalchemy import create_engine

engine = create_engine('mysql://user:pass@localhost/tripfinity')

# ============================================================
# STEP 1: Export ITEM TOWER (4 bảng gộp lại)
# ============================================================

# Export tours
tours = pd.read_sql("""
    SELECT 
        CONCAT('tour_', tour_id) as item_id,
        'tour' as item_type,
        title, area_id, location, price, tour_type,
        star_rating, badges, categories_json, thumbnail_url
    FROM tours
    WHERE status = 'active'
""", engine)

# Export hotels
hotels = pd.read_sql("""
    SELECT 
        CONCAT('hotel_', hotel_id) as item_id,
        'hotel' as item_type,
        title, area_id, location, price, property_type,
        star_rating, badges, amenities_json, thumbnail_url
    FROM hotels
    WHERE status = 'active'
""", engine)

# Export attractions
attractions = pd.read_sql("""
    SELECT 
        CONCAT('attraction_', attraction_id) as item_id,
        'attraction' as item_type,
        title, area_id, location, price, attraction_type,
        NULL as star_rating, badges, features_json, thumbnail_url
    FROM attractions
    WHERE status = 'active'
""", engine)

# Export restaurants
restaurants = pd.read_sql("""
    SELECT 
        CONCAT('restaurant_', restaurant_id) as item_id,
        'restaurant' as item_type,
        title, area_id, location, price, price_level as property_type,
        NULL as star_rating, badges, cuisines_json as features_json, thumbnail_url
    FROM restaurants
    WHERE status = 'active'
""", engine)

# Gộp 4 bảng
items = pd.concat([tours, hotels, attractions, restaurants], ignore_index=True)
items.to_csv('items.csv', index=False)
print(f"✅ Exported {len(items)} items")


# ============================================================
# STEP 2: Export USER TOWER (Bảng interactions)
# ============================================================

interactions = pd.read_sql("""
    SELECT 
        user_id,
        CONCAT(item_type, '_', item_id) as item_id,
        item_type,
        action_type,
        action_weight,
        interaction_timestamp
    FROM user_item_interactions
    WHERE action_type IN ('view', 'click', 'favorite', 'book')
    ORDER BY interaction_timestamp DESC
""", engine)

interactions.to_csv('interactions.csv', index=False)
print(f"✅ Exported {len(interactions)} interactions")


==============================================================
3. TRAIN TWO-TOWER MODEL (Python)
==============================================================

# File: train_two_tower.py

import pandas as pd
import tensorflow as tf

# Load data
items = pd.read_csv('items.csv')
interactions = pd.read_csv('interactions.csv')

print(f"Items: {len(items)}")
print(f"Interactions: {len(interactions)}")

# Split train/test
from sklearn.model_selection import train_test_split
train, test = train_test_split(interactions, test_size=0.2, random_state=42)

# Build Two-Tower Model
user_tower = build_user_tower()
item_tower = build_item_tower()

model = TwoTowerModel(user_tower, item_tower)
model.fit(train, items)

# Evaluate
metrics = model.evaluate(test, items)
print(f"Precision@10: {metrics['precision']:.2%}")
print(f"Recall@10: {metrics['recall']:.2%}")
print(f"NDCG@10: {metrics['ndcg']:.3f}")


==============================================================
4. KIỂM TRA DỮ LIỆU
==============================================================

-- Tổng số interactions:
SELECT COUNT(*) as total FROM user_item_interactions;

-- Phân bố theo action_type:
SELECT action_type, COUNT(*) as count
FROM user_item_interactions
GROUP BY action_type;

-- Phân bố theo item_type:
SELECT item_type, COUNT(*) as count
FROM user_item_interactions
GROUP BY item_type;

-- Top users tương tác nhiều nhất:
SELECT user_id, COUNT(*) as total_interactions
FROM user_item_interactions
GROUP BY user_id
ORDER BY total_interactions DESC
LIMIT 10;

*/


-- ============================================================
-- KẾT THÚC
-- ============================================================
