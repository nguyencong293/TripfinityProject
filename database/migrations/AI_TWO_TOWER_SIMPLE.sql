-- ============================================================
-- AI TWO-TOWER RECOMMENDATION SYSTEM
-- Created: 2025-12-17
-- Purpose: 2 bảng chính cho AI recommendation
--   1. user_item_interactions (User Tower - hành vi)
--   2. ai_item_tower (Item Tower - dữ liệu 4 services)
-- ============================================================

USE tripfinity;

-- ============================================================
-- BẢNG 1: USER TOWER - user_item_interactions
-- ============================================================

DROP TABLE IF EXISTS `user_item_interactions`;

CREATE TABLE `user_item_interactions` (
  `interaction_id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL COMMENT 'ID người dùng',
  `item_id` INT NOT NULL COMMENT 'ID dịch vụ',
  `item_type` ENUM('tour', 'hotel', 'attraction', 'restaurant') NOT NULL,
  `action_type` ENUM('search', 'view', 'click', 'favorite', 'book') NOT NULL,
  `action_weight` TINYINT NOT NULL COMMENT 'search=1, view=2, click=3, favorite=4, book=5',
  `interaction_timestamp` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Indexes
  KEY `idx_user_id` (`user_id`),
  KEY `idx_item` (`item_type`, `item_id`),
  KEY `idx_action` (`action_type`, `action_weight`),
  KEY `idx_timestamp` (`interaction_timestamp` DESC),
  KEY `idx_train_data` (`user_id`, `item_id`, `item_type`, `action_weight`),
  
  -- Foreign Key
  CONSTRAINT `fk_interaction_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_action_weight` CHECK (`action_weight` BETWEEN 1 AND 10)
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='User Tower - Lưu hành vi người dùng';


-- ============================================================
-- BẢNG 2: ITEM TOWER - ai_item_tower
-- ============================================================

DROP TABLE IF EXISTS `ai_item_tower`;

CREATE TABLE `ai_item_tower` (
  -- Identification
  `tower_item_id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `item_type` ENUM('tour', 'hotel', 'attraction', 'restaurant') NOT NULL,
  `item_id` INT NOT NULL,
  
  -- Basic Info cho AI
  `title` VARCHAR(255) NOT NULL,
  `location` VARCHAR(255),
  `latitude` DECIMAL(10,8),
  `longitude` DECIMAL(11,8),
  `price` DECIMAL(12,2) NOT NULL,
  
  -- CORE: Normalized Features Vector
  `normalized_features` JSON COMMENT 'Features hợp nhất - CORE cho AI',
  
  -- Categorical Features
  `star_rating` TINYINT,
  `property_type` ENUM('hotel', 'resort', 'villa', 'apartment', 'hostel', 'guesthouse', 'homestay'),
  `difficulty_level` ENUM('easy', 'moderate', 'hard'),
  `tour_type` ENUM('group', 'private_', 'custom'),
  `attraction_type` ENUM('cultural_site', 'entertainment', 'historical_site', 'landmark', 
                         'museum', 'natural_attraction', 'park', 'temple', 'theme_park', 'other'),
  
  -- Service Features JSON (chỉ features, không metadata)
  `amenities_json` JSON,
  `categories_json` JSON,
  `cuisines_json` JSON,
  `diets_json` JSON,
  `suitable_for_json` JSON,
  
  -- Indexes
  UNIQUE KEY `uq_item_tower` (`item_type`, `item_id`),
  INDEX `idx_item_type` (`item_type`),
  INDEX `idx_location` (`latitude`, `longitude`),
  INDEX `idx_price` (`price`),
  
  -- Constraints
  CONSTRAINT `chk_star_rating` CHECK (`star_rating` IS NULL OR (`star_rating` BETWEEN 1 AND 5))
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Item Tower - CHỈ LƯU FEATURES CẦN THIẾT CHO AI';


-- ============================================================
-- POPULATE DATA: Insert từ 4 bảng gốc
-- ============================================================

-- INSERT HOTELS
INSERT INTO ai_item_tower (
  item_type, item_id, title, location,
  latitude, longitude, price,
  normalized_features,
  star_rating, property_type, amenities_json
)
SELECT 
  'hotel',
  h.hotel_id,
  h.title,
  h.location,
  h.latitude,
  h.longitude,
  h.price,
  h.amenities_json,
  h.star_rating,
  h.property_type,
  h.amenities_json
FROM hotels h
WHERE h.hotel_status = 'published';


-- INSERT TOURS
INSERT INTO ai_item_tower (
  item_type, item_id, title, location,
  latitude, longitude, price,
  normalized_features,
  difficulty_level, tour_type, categories_json
)
SELECT 
  'tour',
  t.tour_id,
  t.title,
  t.location,
  t.latitude,
  t.longitude,
  t.price,
  JSON_MERGE_PRESERVE(
    IFNULL(t.categories_json, JSON_ARRAY()),
    IFNULL(t.services_json, JSON_ARRAY()),
    IFNULL(t.included_json, JSON_ARRAY())
  ),
  t.difficulty_level,
  t.tour_type,
  t.categories_json
FROM tours t
WHERE t.tour_status = 'published';


-- INSERT ATTRACTIONS
INSERT INTO ai_item_tower (
  item_type, item_id, title, location,
  latitude, longitude, price,
  normalized_features,
  attraction_type, suitable_for_json
)
SELECT 
  'attraction',
  a.attraction_id,
  a.title,
  a.location,
  a.latitude,
  a.longitude,
  a.price,
  JSON_MERGE_PRESERVE(
    IFNULL(a.suitable_for_json, JSON_ARRAY()),
    IFNULL(a.visit_types_json, JSON_ARRAY()),
    IFNULL(a.features_json, JSON_ARRAY())
  ),
  a.attraction_type,
  a.suitable_for_json
FROM attractions a
WHERE a.attraction_status = 'published';


-- INSERT RESTAURANTS
INSERT INTO ai_item_tower (
  item_type, item_id, title, location,
  latitude, longitude, price,
  normalized_features,
  cuisines_json, diets_json
)
SELECT 
  'restaurant',
  r.restaurant_id,
  r.title,
  r.location,
  r.latitude,
  r.longitude,
  r.price,
  JSON_MERGE_PRESERVE(
    IFNULL(r.cuisines_json, JSON_ARRAY()),
    IFNULL(r.diets_json, JSON_ARRAY()),
    IFNULL(r.services_json, JSON_ARRAY()),
    IFNULL(r.ambiance_tags_json, JSON_ARRAY())
  ),
  r.cuisines_json,
  r.diets_json
FROM restaurants r
WHERE r.restaurant_status = 'published';


-- ============================================================
-- VERIFY DATA
-- ============================================================

-- Kiểm tra số lượng items đã insert
SELECT 
  item_type, 
  COUNT(*) as total_items,
  MIN(price) as min_price,
  MAX(price) as max_price,
  AVG(price) as avg_price
FROM ai_item_tower
GROUP BY item_type
ORDER BY item_type;

-- Kiểm tra sample data
SELECT 
  tower_item_id,
  item_type,
  item_id,
  title,
  location,
  price,
  star_rating,
  property_type,
  attraction_type
FROM ai_item_tower
LIMIT 10;

-- ============================================================
-- KẾT THÚC
-- ============================================================
