-- ============================================================
-- AI RECOMMENDATION SYSTEM - TWO-TOWER MODEL
-- BẢNG DỮ LIỆU ĐỂ TRAIN AI
-- Created: 2025-12-14
-- Purpose: Lưu TẤT CẢ hành vi người dùng với đầy đủ thông tin
-- ============================================================

-- ============================================================
-- BẢNG DUY NHẤT: user_item_interactions
-- ============================================================

DROP TABLE IF EXISTS `user_item_interactions`;

CREATE TABLE `user_item_interactions` (
  -- ID
  `interaction_id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  
  -- ============================================================
  -- PHẦN 1: THÔNG TIN CƠ BẢN (Bắt buộc để train AI)
  -- ============================================================
  `user_id` INT NOT NULL COMMENT 'ID người dùng',
  `item_id` INT NOT NULL COMMENT 'ID dịch vụ (tour_id, hotel_id, attraction_id, restaurant_id)',
  `item_type` ENUM('tour', 'hotel', 'attraction', 'restaurant') NOT NULL COMMENT 'Loại dịch vụ',
  `action_type` ENUM('search', 'view', 'click', 'favorite', 'book') NOT NULL COMMENT 'Hành động: search=tìm kiếm, view=xem, click=nhấp vào, favorite=yêu thích, book=đặt',
  `action_weight` TINYINT NOT NULL COMMENT 'Trọng số: search=1, view=2, click=3, favorite=4, book=5',
  `interaction_timestamp` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời gian tương tác',
  
  -- ============================================================
  -- PHẦN 2: THÔNG TIN DỊCH VỤ (Để AI học pattern)
  -- ============================================================
  
  -- Tên dịch vụ (Để AI học pattern tên giống nhau)
  `item_title` VARCHAR(255) DEFAULT NULL COMMENT 'Tên dịch vụ (ví dụ: "Khách sạn Đà Nẵng")',
  `item_slug` VARCHAR(255) DEFAULT NULL COMMENT 'Slug dịch vụ (dùng để so sánh tên)',
  
  -- Khu vực (Để AI học pattern cùng khu vực)
  `area_id` INT DEFAULT NULL COMMENT 'ID khu vực (tỉnh/thành phố)',
  `area_name` VARCHAR(255) DEFAULT NULL COMMENT 'Tên khu vực (ví dụ: "Đà Nẵng", "Hà Nội")',
  `item_location` VARCHAR(255) DEFAULT NULL COMMENT 'Địa điểm chi tiết',
  `latitude` DECIMAL(10,8) DEFAULT NULL COMMENT 'Vĩ độ (để tính khoảng cách)',
  `longitude` DECIMAL(11,8) DEFAULT NULL COMMENT 'Kinh độ (để tính khoảng cách)',
  
  -- Giá cả (Để AI học pattern giá xêm xêm)
  `item_price` DECIMAL(12,2) DEFAULT NULL COMMENT 'Giá dịch vụ (VND)',
  `price_level` ENUM('cheap', 'moderate', 'expensive', 'luxury') DEFAULT NULL COMMENT 'Mức giá: rẻ, vừa, đắt, sang',
  
  -- Loại phụ (Để AI học pattern loại giống nhau)
  `item_subtype` VARCHAR(100) DEFAULT NULL COMMENT 'Loại phụ: tour -> tour_type, hotel -> property_type, attraction -> attraction_type',
  `address` VARCHAR(255) DEFAULT NULL COMMENT 'Địa chỉ đầy đủ (từ tours, hotels, attractions, restaurants)',
  
  -- Đặc điểm (Để AI học pattern đặc điểm giống nhau)
  `badges` VARCHAR(255) DEFAULT NULL COMMENT 'Nhãn: "Hot Deal", "Popular", "Luxury"',
  `star_rating` TINYINT DEFAULT NULL COMMENT 'Số sao (hotel: 1-5)',
  `difficulty_level` ENUM('easy', 'moderate', 'hard') DEFAULT NULL COMMENT 'Độ khó (tour)',
  
  -- Thời gian (Để AI học pattern theo mùa)
  `start_date` DATE DEFAULT NULL COMMENT 'Ngày bắt đầu dịch vụ',
  `end_date` DATE DEFAULT NULL COMMENT 'Ngày kết thúc dịch vụ',
  `duration_days` INT DEFAULT NULL COMMENT 'Số ngày (tour)',
  
  -- Sức chứa (Để AI học pattern theo nhóm)
  `capacity` INT DEFAULT NULL COMMENT 'Số người tối đa',
  `min_participants` INT DEFAULT NULL COMMENT 'Số người tối thiểu',
  `max_participants` INT DEFAULT NULL COMMENT 'Số người tối đa',
  
  -- Tags/Categories (Để AI học pattern theo sở thích)
  `categories_json` JSON DEFAULT NULL COMMENT 'Thể loại: ["adventure", "beach", "culture"]',
  `cuisines_json` JSON DEFAULT NULL COMMENT 'Món ăn (restaurant): ["vietnamese", "seafood"]',
  `amenities_json` JSON DEFAULT NULL COMMENT 'Tiện nghi (hotel): ["wifi", "pool", "parking"]',
  `features_json` JSON DEFAULT NULL COMMENT 'Tính năng (attraction): ["family_friendly", "guided_tour"]',
  
  -- ============================================================
  -- PHẦN 3: THÔNG TIN NGƯỜI DÙNG (Để AI học sở thích user)
  -- ============================================================
  `user_age_group` ENUM('18-24', '25-34', '35-44', '45-54', '55+') DEFAULT NULL COMMENT 'Nhóm tuổi user',
  `user_gender` ENUM('male', 'female', 'other') DEFAULT NULL COMMENT 'Giới tính user',
  
  -- ============================================================
  -- PHẦN 4: THÔNG TIN PHIÊN (Optional)
  -- ============================================================
  `session_id` VARCHAR(100) DEFAULT NULL COMMENT 'ID phiên làm việc',
  `search_query` VARCHAR(255) DEFAULT NULL COMMENT 'Từ khóa tìm kiếm (nếu action=search)',
  `device_type` ENUM('mobile', 'tablet', 'desktop') DEFAULT NULL COMMENT 'Loại thiết bị',
  
  -- ============================================================
  -- PHẦN 5: METADATA
  -- ============================================================
  `item_thumbnail_url` VARCHAR(512) DEFAULT NULL COMMENT 'Ảnh đại diện (để hiển thị UI)',
  `is_featured` TINYINT DEFAULT 0 COMMENT 'Dịch vụ nổi bật',
  `provider_id` INT DEFAULT NULL COMMENT 'ID nhà cung cấp',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- ============================================================
  -- INDEXES (Tối ưu query)
  -- ============================================================
  KEY `idx_user_id` (`user_id`),
  KEY `idx_item` (`item_type`, `item_id`),
  KEY `idx_action` (`action_type`, `action_weight`),
  KEY `idx_timestamp` (`interaction_timestamp` DESC),
  KEY `idx_area` (`area_id`),
  KEY `idx_price` (`item_price`),
  KEY `idx_user_time` (`user_id`, `interaction_timestamp` DESC),
  KEY `idx_train_data` (`user_id`, `item_id`, `item_type`, `action_weight`),
  
  -- ============================================================
  -- FOREIGN KEYS
  -- ============================================================
  CONSTRAINT `fk_interaction_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_interaction_area` FOREIGN KEY (`area_id`) REFERENCES `areas` (`area_id`) ON DELETE SET NULL,
  
  -- ============================================================
  -- CHECK CONSTRAINTS
  -- ============================================================
  CONSTRAINT `chk_action_weight` CHECK (`action_weight` BETWEEN 1 AND 10),
  CONSTRAINT `chk_star_rating` CHECK (`star_rating` BETWEEN 1 AND 5)
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Bảng DUY NHẤT để train AI Two-Tower. Chứa ĐẦY ĐỦ thông tin để AI học pattern: khu vực, giá, tên, loại, tags, v.v.';


-- ============================================================
-- HƯỚNG DẪN SỬ DỤNG CHO BACKEND
-- ============================================================

/*
==============================================================
1. GHI NHẬN HÀNH VI USER (Backend Java/Spring Boot)
==============================================================

// Khi user XEM dịch vụ:
INSERT INTO user_item_interactions (
  user_id, item_id, item_type, action_type, action_weight,
  item_title, area_id, area_name, item_location, item_price,
  item_thumbnail_url, interaction_timestamp
)
SELECT 
  ?, -- userId
  t.tour_id,
  'tour',
  'view',
  2,
  t.title,
  t.area_id,
  (SELECT name FROM areas WHERE area_id = t.area_id),
  t.location,
  t.price,
  t.thumbnail_url,
  NOW()
FROM tours t
WHERE t.tour_id = ?; -- tourId


// Khi user TÌM KIẾM:
INSERT INTO user_item_interactions (
  user_id, action_type, action_weight, search_query, interaction_timestamp
) VALUES (?, 'search', 1, ?, NOW());


// Khi user THÊM YÊU THÍCH:
INSERT INTO user_item_interactions (
  user_id, item_id, item_type, action_type, action_weight,
  item_title, area_id, area_name, item_location, item_price,
  item_thumbnail_url, interaction_timestamp
)
SELECT 
  ?, -- userId
  t.tour_id,
  'tour',
  'favorite',
  4,
  t.title,
  t.area_id,
  (SELECT name FROM areas WHERE area_id = t.area_id),
  t.location,
  t.price,
  t.thumbnail_url,
  NOW()
FROM tours t
WHERE t.tour_id = ?; -- tourId


// Khi user BOOK:
INSERT INTO user_item_interactions (
  user_id, item_id, item_type, action_type, action_weight,
  item_title, area_id, item_price, interaction_timestamp
)
SELECT 
  ?, h.hotel_id, 'hotel', 'book', 5,
  h.title, h.area_id, h.price, NOW()
FROM hotels h
WHERE h.hotel_id = ?;


==============================================================
2. EXPORT DỮ LIỆU ĐỂ TRAIN AI (Python)
==============================================================

# File: export_training_data.py

import pandas as pd
from sqlalchemy import create_engine

# Kết nối database
engine = create_engine('mysql://user:pass@localhost/tripfinity')

# Lấy dữ liệu để train AI
query = """
SELECT 
  user_id,
  CONCAT(item_type, '_', item_id) AS item_id,
  action_weight,
  area_id,
  item_price,
  item_title,
  interaction_timestamp
FROM user_item_interactions
WHERE action_type IN ('view', 'click', 'favorite', 'book')
ORDER BY interaction_timestamp DESC
"""

df = pd.read_sql(query, engine)
df.to_csv('training_data.csv', index=False)

print(f"Exported {len(df)} interactions for training")


==============================================================
3. KIỂM TRA DỮ LIỆU
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

-- Interactions theo khu vực:
SELECT area_name, COUNT(*) as count
FROM user_item_interactions
WHERE area_name IS NOT NULL
GROUP BY area_name
ORDER BY count DESC
LIMIT 10;


==============================================================
4. QUERY ĐỂ ĐỀ XUẤT (Backend)
==============================================================

-- Lấy lịch sử gần đây của user (20 dịch vụ):
SELECT 
  item_id, item_type, item_title, item_location,
  area_id, area_name, item_price, action_type
FROM user_item_interactions
WHERE user_id = ?
ORDER BY interaction_timestamp DESC
LIMIT 20;


-- Lấy các khu vực user thích:
SELECT DISTINCT area_id, area_name, COUNT(*) as visit_count
FROM user_item_interactions
WHERE user_id = ?
  AND area_id IS NOT NULL
GROUP BY area_id, area_name
ORDER BY visit_count DESC
LIMIT 3;


-- Lấy mức giá trung bình user thích:
SELECT 
  AVG(item_price) as avg_price,
  MIN(item_price) as min_price,
  MAX(item_price) as max_price
FROM user_item_interactions
WHERE user_id = ?
  AND action_type IN ('book', 'favorite', 'click')
  AND item_price IS NOT NULL;

*/


-- ============================================================
-- KẾT THÚC
-- ============================================================
