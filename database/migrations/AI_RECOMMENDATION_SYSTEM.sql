-- ============================================================
-- AI RECOMMENDATION SYSTEM - TWO-TOWER MODEL
-- Created: 2025-12-17
-- Purpose: 
--   User Tower: user_item_interactions (lưu hành vi)
--   Item Tower: ai_item_tower (consolidate 4 services + features)
-- 
-- Thiết kế theo nguyên tắc:
--   1. Tiện ích (features) CỰC KỲ CẦN THIẾT - giúp AI hiểu TẠI SAO
--   2. Giải quyết Cold Start problem (content-based recommendation)
--   3. Hỗ trợ Semantic Matching cho Search behavior
--   4. Normalize features từ 4 services khác nhau
-- ============================================================

-- ============================================================
-- PART 1: USER TOWER - user_item_interactions
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
-- PART 2: ITEM TOWER - ai_item_tower
-- Purpose: Consolidate 4 services với đầy đủ features cho AI training
-- Giải quyết: Cold Start, Semantic Matching, Deal Breaker Detection
-- ============================================================

DROP TABLE IF EXISTS `ai_item_tower`;

CREATE TABLE `ai_item_tower` (
  -- ============================================================
  -- PRIMARY IDENTIFICATION
  -- ============================================================
  `tower_item_id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT 'Surrogate key cho Item Tower',
  `item_type` ENUM('tour', 'hotel', 'attraction', 'restaurant') NOT NULL COMMENT 'Loại dịch vụ',
  `item_id` INT NOT NULL COMMENT 'ID gốc từ bảng tours/hotels/attractions/restaurants',
  
  -- ============================================================
  -- BASIC INFORMATION (Content-based Features)
  -- ============================================================
  `title` VARCHAR(255) NOT NULL COMMENT 'Tên dịch vụ',
  `description` TEXT COMMENT 'Mô tả chi tiết',
  `location` VARCHAR(255) COMMENT 'Tỉnh/thành phố',
  `address` VARCHAR(255) COMMENT 'Địa chỉ đầy đủ',
  `latitude` DECIMAL(10,8) COMMENT 'Vĩ độ',
  `longitude` DECIMAL(11,8) COMMENT 'Kinh độ',
  
  -- ============================================================
  -- PRICING FEATURES (Deal Breaker Factor)
  -- ============================================================
  `price` DECIMAL(12,2) NOT NULL COMMENT 'Giá chính',
  `currency_code` VARCHAR(3) DEFAULT 'VND',
  `price_level` ENUM('budget', 'moderate', 'expensive', 'luxury') COMMENT 'Phân khúc giá (normalized từ các bảng)',
  
  -- ============================================================
  -- CAPACITY & CONSTRAINTS
  -- ============================================================
  `capacity` INT COMMENT 'Số lượng khách tối đa',
  `min_participants` INT COMMENT 'Số người tối thiểu',
  `max_participants` INT COMMENT 'Số người tối đa',
  
  -- ============================================================
  -- FEATURES VECTOR (CORE FOR AI - Deal Breakers & Preferences)
  -- Format: ["wifi", "pool", "breakfast", "parking", "gym", "spa", ...]
  -- Cross-service normalized features để AI học patterns
  -- ============================================================
  `normalized_features` JSON COMMENT 'Features chuẩn hóa cho tất cả services: amenities, services, facilities',
  
  -- ============================================================
  -- SERVICE-SPECIFIC FEATURES (Preserved from original tables)
  -- ============================================================
  -- HOTELS
  `star_rating` TINYINT COMMENT 'Hotel star rating (1-5)',
  `property_type` ENUM('hotel', 'resort', 'villa', 'apartment', 'hostel', 'guesthouse', 'homestay') COMMENT 'Loại khách sạn',
  `amenities_json` JSON COMMENT 'Hotel amenities gốc',
  `highlights_json` JSON COMMENT 'Hotel highlights',
  
  -- TOURS
  `duration_days` INT COMMENT 'Số ngày tour',
  `difficulty_level` ENUM('easy', 'moderate', 'hard') COMMENT 'Độ khó tour',
  `tour_type` ENUM('group', 'private_', 'custom') COMMENT 'Loại tour',
  `categories_json` JSON COMMENT 'Tour categories: culture, nature, adventure, food, beach',
  `services_json` JSON COMMENT 'Tour services: pickup, guide, meals',
  `included_json` JSON COMMENT 'Included in tour',
  `excluded_json` JSON COMMENT 'Excluded from tour',
  `guide_languages_json` JSON COMMENT 'Ngôn ngữ hướng dẫn viên',
  
  -- ATTRACTIONS
  `attraction_type` ENUM('cultural_site', 'entertainment', 'historical_site', 'landmark', 
                         'museum', 'natural_attraction', 'park', 'temple', 'theme_park', 'other') 
                   COMMENT 'Loại điểm tham quan',
  `average_visit_minutes` INT COMMENT 'Thời gian tham quan trung bình',
  `visit_types_json` JSON COMMENT 'guided_tour, self_guided, audio_guide, virtual_tour',
  `suitable_for_json` JSON COMMENT 'family, kids, elderly, couples, groups, solo, pets',
  `attraction_features_json` JSON COMMENT 'Attraction-specific features',
  
  -- RESTAURANTS
  `cuisines_json` JSON COMMENT 'vietnamese, chinese, japanese, italian, thai, seafood, vegetarian',
  `diets_json` JSON COMMENT 'vegetarian, vegan, halal, kosher, gluten_free, dairy_free',
  `restaurant_services_json` JSON COMMENT 'dine_in, takeaway, delivery, reservation, buffet',
  `ambiance_tags_json` JSON COMMENT 'romantic, family_friendly, business, casual, formal, cozy',
  `payment_methods_json` JSON COMMENT 'cash, credit_card, momo, zalopay, vnpay',
  
  -- ============================================================
  -- QUALITY INDICATORS (Ranking Signals)
  -- ============================================================
  `average_rating` DECIMAL(3,2) COMMENT 'Điểm đánh giá trung bình (computed)',
  `total_reviews` INT DEFAULT 0 COMMENT 'Tổng số đánh giá',
  `total_bookings` INT DEFAULT 0 COMMENT 'Tổng số lượt đặt (computed từ bookings)',
  `total_favorites` INT DEFAULT 0 COMMENT 'Tổng số lượt yêu thích (computed từ favorites)',
  `is_featured` BOOLEAN DEFAULT FALSE COMMENT 'Dịch vụ nổi bật',
  
  -- ============================================================
  -- STATUS & VISIBILITY
  -- ============================================================
  `status` ENUM('published', 'disabled', 'archived') NOT NULL DEFAULT 'published',
  `visibility` ENUM('public_', 'private_') NOT NULL DEFAULT 'public_',
  
  -- ============================================================
  -- METADATA (Sync tracking)
  -- ============================================================
  `source_updated_at` DATETIME COMMENT 'Timestamp từ bảng gốc (tours/hotels/...)',
  `thumbnail_url` VARCHAR(512) COMMENT 'Ảnh đại diện',
  `slug` VARCHAR(255) COMMENT 'SEO slug',
  `published_at` DATETIME COMMENT 'Ngày xuất bản',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  -- ============================================================
  -- INDEXES (Optimized for AI queries)
  -- ============================================================
  UNIQUE KEY `uq_item_tower` (`item_type`, `item_id`),
  INDEX `idx_item_type` (`item_type`),
  INDEX `idx_location` (`latitude`, `longitude`),
  INDEX `idx_price` (`price`),
  INDEX `idx_price_level` (`price_level`),
  INDEX `idx_rating` (`average_rating` DESC),
  INDEX `idx_featured` (`is_featured`),
  INDEX `idx_status` (`status`, `visibility`),
  INDEX `idx_bookings` (`total_bookings` DESC),
  INDEX `idx_updated` (`updated_at` DESC),
  
  -- ============================================================
  -- CONSTRAINTS
  -- ============================================================
  CONSTRAINT `chk_star_rating` CHECK (`star_rating` IS NULL OR (`star_rating` BETWEEN 1 AND 5)),
  CONSTRAINT `chk_average_rating` CHECK (`average_rating` IS NULL OR (`average_rating` BETWEEN 0 AND 5))
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Item Tower - Denormalized table consolidating 4 services với đầy đủ features cho AI Two-Tower model';


-- ============================================================
-- POPULATE DATA: Insert từ 4 bảng gốc ngay sau khi tạo bảng
-- ============================================================

-- ============================================================
-- INSERT HOTELS
-- ============================================================
INSERT INTO ai_item_tower (
  item_type, item_id, title, description, location, address, 
  latitude, longitude, price, currency_code, 
  capacity, min_participants, max_participants,
  normalized_features,
  star_rating, property_type, amenities_json, highlights_json,
  is_featured, status, visibility,
  source_updated_at, thumbnail_url, slug, published_at
)
SELECT 
  'hotel' as item_type,
  h.hotel_id as item_id,
  h.title,
  h.service_description as description,
  h.location,
  h.address,
  h.latitude,
  h.longitude,
  h.price,
  h.currency_code,
  h.capacity,
  h.min_participants,
  h.max_participants,
  
  -- Normalized features (extract từ amenities_json và highlights_json)
  h.amenities_json as normalized_features,
  
  h.star_rating,
  h.property_type,
  h.amenities_json,
  h.highlights_json,
  
  h.is_featured,
  h.hotel_status as status,
  h.visibility,
  
  h.updated_at as source_updated_at,
  h.thumbnail_url,
  h.slug,
  h.published_at
FROM hotels h
WHERE h.hotel_status = 'published';


-- ============================================================
-- INSERT TOURS
-- ============================================================
INSERT INTO ai_item_tower (
  item_type, item_id, title, description, location, address,
  latitude, longitude, price, currency_code,
  capacity, min_participants, max_participants,
  normalized_features,
  duration_days, difficulty_level, tour_type,
  categories_json, services_json, included_json, excluded_json, guide_languages_json,
  is_featured, status, visibility,
  source_updated_at, thumbnail_url, slug, published_at
)
SELECT 
  'tour' as item_type,
  t.tour_id as item_id,
  t.title,
  t.service_description as description,
  t.location,
  t.address,
  t.latitude,
  t.longitude,
  t.price,
  t.currency_code,
  t.capacity,
  t.min_participants,
  t.max_participants,
  
  -- Normalized features: merge categories + services + included
  JSON_MERGE_PRESERVE(
    IFNULL(t.categories_json, JSON_ARRAY()),
    IFNULL(t.services_json, JSON_ARRAY()),
    IFNULL(t.included_json, JSON_ARRAY())
  ) as normalized_features,
  
  t.duration_days,
  t.difficulty_level,
  t.tour_type,
  t.categories_json,
  t.services_json,
  t.included_json,
  t.excluded_json,
  t.guide_languages_json,
  
  t.is_featured,
  t.tour_status as status,
  t.visibility,
  
  t.updated_at as source_updated_at,
  t.thumbnail_url,
  t.slug,
  t.published_at
FROM tours t
WHERE t.tour_status = 'published';


-- ============================================================
-- INSERT ATTRACTIONS
-- ============================================================
INSERT INTO ai_item_tower (
  item_type, item_id, title, description, location, address,
  latitude, longitude, price, currency_code,
  capacity, min_participants, max_participants,
  normalized_features,
  attraction_type, average_visit_minutes, 
  visit_types_json, suitable_for_json, attraction_features_json,
  is_featured, status, visibility,
  source_updated_at, thumbnail_url, slug, published_at
)
SELECT 
  'attraction' as item_type,
  a.attraction_id as item_id,
  a.title,
  a.service_description as description,
  a.location,
  a.address,
  a.latitude,
  a.longitude,
  a.price,
  a.currency_code,
  a.capacity,
  a.min_participants,
  a.max_participants,
  
  -- Normalized features: merge suitable_for + visit_types + features
  JSON_MERGE_PRESERVE(
    IFNULL(a.suitable_for_json, JSON_ARRAY()),
    IFNULL(a.visit_types_json, JSON_ARRAY()),
    IFNULL(a.features_json, JSON_ARRAY())
  ) as normalized_features,
  
  a.attraction_type,
  a.average_visit_minutes,
  a.visit_types_json,
  a.suitable_for_json,
  a.features_json as attraction_features_json,
  
  a.is_featured,
  a.attraction_status as status,
  a.visibility,
  
  a.updated_at as source_updated_at,
  a.thumbnail_url,
  a.slug,
  a.published_at
FROM attractions a
WHERE a.attraction_status = 'published';


-- ============================================================
-- INSERT RESTAURANTS
-- ============================================================
INSERT INTO ai_item_tower (
  item_type, item_id, title, description, location, address,
  latitude, longitude, price, currency_code,
  capacity, min_participants, max_participants,
  normalized_features,
  price_level,
  cuisines_json, diets_json, restaurant_services_json, 
  ambiance_tags_json, payment_methods_json,
  is_featured, status, visibility,
  source_updated_at, thumbnail_url, slug, published_at
)
SELECT 
  'restaurant' as item_type,
  r.restaurant_id as item_id,
  r.title,
  r.service_description as description,
  r.location,
  r.address,
  r.latitude,
  r.longitude,
  r.price,
  r.currency_code,
  r.capacity,
  r.min_participants,
  r.max_participants,
  
  -- Normalized features: merge cuisines + diets + services + ambiance
  JSON_MERGE_PRESERVE(
    IFNULL(r.cuisines_json, JSON_ARRAY()),
    IFNULL(r.diets_json, JSON_ARRAY()),
    IFNULL(r.services_json, JSON_ARRAY()),
    IFNULL(r.ambiance_tags_json, JSON_ARRAY())
  ) as normalized_features,
  
  r.price_level,
  r.cuisines_json,
  r.diets_json,
  r.services_json as restaurant_services_json,
  r.ambiance_tags_json,
  r.payment_methods_json,
  
  r.is_featured,
  r.restaurant_status as status,
  r.visibility,
  
  r.updated_at as source_updated_at,
  r.thumbnail_url,
  r.slug,
  r.published_at
FROM restaurants r
WHERE r.restaurant_status = 'published';


-- Verify inserted data
SELECT 
  item_type, 
  COUNT(*) as total_items,
  SUM(CASE WHEN is_featured = TRUE THEN 1 ELSE 0 END) as featured_count
FROM ai_item_tower
GROUP BY item_type
ORDER BY item_type;


-- ============================================================
-- NORMALIZED FEATURES MAPPING GUIDE
-- Purpose: Chuẩn hóa tiện ích từ 4 services khác nhau
-- ============================================================
/*
NORMALIZED_FEATURES Format (JSON Array):

Cross-Service Common Features:
- "wifi", "internet" (từ hotels amenities, restaurants services)
- "parking" (hotels, attractions, restaurants)
- "family_friendly" (từ suitable_for, ambiance_tags)
- "outdoor" (từ tour categories, attraction types)
- "accessible" (wheelchair accessible - từ các bảng)
- "pet_friendly" (từ suitable_for)
- "breakfast", "meals_included" (hotels, tours)
- "guided_tour", "audio_guide" (tours, attractions)
- "reservation_required" (restaurants, attractions)

Hotel-specific → Normalized:
- "pool" → "swimming_pool", "recreation"
- "gym" → "fitness", "recreation"
- "spa" → "wellness", "spa"
- "restaurant" → "dining_on_site"
- "bar" → "entertainment", "nightlife"
- "air_conditioning" → "air_con", "comfort"

Tour-specific → Normalized:
- "adventure" → "adventure", "active"
- "culture" → "cultural", "educational"
- "nature" → "nature", "outdoor"
- "food" → "culinary", "food_experience"
- "beach" → "beach", "coastal"
- "mountain" → "mountain", "hiking"
- "city" → "urban", "city_tour"

Attraction-specific → Normalized:
- "museum" → "cultural", "educational", "indoor"
- "temple" → "religious", "cultural", "historical"
- "park" → "nature", "outdoor", "relaxation"
- "theme_park" → "entertainment", "family_friendly", "active"
- "kids" → "child_friendly", "family_friendly"
- "elderly" → "senior_friendly", "accessible"

Restaurant-specific → Normalized:
- "vegetarian" → "vegetarian", "dietary_vegetarian"
- "vegan" → "vegan", "dietary_vegan"
- "halal" → "halal", "dietary_halal"
- "gluten_free" → "gluten_free", "dietary_gluten_free"
- "buffet" → "buffet", "all_you_can_eat"
- "romantic" → "romantic", "couples_friendly"
- "business" → "business_friendly", "formal"

Example normalized_features:
{
  "features": [
    "wifi", "parking", "family_friendly", "outdoor", 
    "meals_included", "guided_tour", "cultural", "nature"
  ]
}
*/


-- ============================================================
-- STORED PROCEDURE: Sync data từ 4 bảng gốc vào Item Tower
-- ============================================================

DELIMITER //

DROP PROCEDURE IF EXISTS sync_item_tower//

CREATE PROCEDURE sync_item_tower()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  
  -- Clear existing data (hoặc có thể dùng UPSERT logic)
  TRUNCATE TABLE ai_item_tower;
  
  -- ============================================================
  -- SYNC HOTELS
  -- ============================================================
  INSERT INTO ai_item_tower (
    item_type, item_id, title, description, location, address, 
    latitude, longitude, price, currency_code, 
    capacity, min_participants, max_participants,
    normalized_features,
    star_rating, property_type, amenities_json, highlights_json,
    average_rating, is_featured, status, visibility,
    source_updated_at, thumbnail_url, slug, published_at
  )
  SELECT 
    'hotel' as item_type,
    h.hotel_id as item_id,
    h.title,
    h.service_description as description,
    h.location,
    h.address,
    h.latitude,
    h.longitude,
    h.price,
    h.currency_code,
    h.capacity,
    h.min_participants,
    h.max_participants,
    
    -- Normalized features (extract từ amenities_json và highlights_json)
    JSON_ARRAY() as normalized_features, -- TODO: Implement feature extraction
    
    h.star_rating,
    h.property_type,
    h.amenities_json,
    h.highlights_json,
    
    -- Computed metrics (TODO: Calculate từ ratings và bookings)
    NULL as average_rating,
    h.is_featured,
    h.hotel_status as status,
    h.visibility,
    
    h.updated_at as source_updated_at,
    h.thumbnail_url,
    h.slug,
    h.published_at
  FROM hotels h
  WHERE h.hotel_status = 'published';
  
  -- ============================================================
  -- SYNC TOURS
  -- ============================================================
  INSERT INTO ai_item_tower (
    item_type, item_id, title, description, location, address,
    latitude, longitude, price, currency_code,
    capacity, min_participants, max_participants,
    normalized_features,
    duration_days, difficulty_level, tour_type,
    categories_json, services_json, included_json, excluded_json, guide_languages_json,
    average_rating, is_featured, status, visibility,
    source_updated_at, thumbnail_url, slug, published_at
  )
  SELECT 
    'tour' as item_type,
    t.tour_id as item_id,
    t.title,
    t.service_description as description,
    t.location,
    t.address,
    t.latitude,
    t.longitude,
    t.price,
    t.currency_code,
    t.capacity,
    t.min_participants,
    t.max_participants,
    
    JSON_ARRAY() as normalized_features, -- TODO: Extract từ categories, services, included
    
    t.duration_days,
    t.difficulty_level,
    t.tour_type,
    t.categories_json,
    t.services_json,
    t.included_json,
    t.excluded_json,
    t.guide_languages_json,
    
    NULL as average_rating,
    t.is_featured,
    t.tour_status as status,
    t.visibility,
    
    t.updated_at as source_updated_at,
    t.thumbnail_url,
    t.slug,
    t.published_at
  FROM tours t
  WHERE t.tour_status = 'published';
  
  -- ============================================================
  -- SYNC ATTRACTIONS
  -- ============================================================
  INSERT INTO ai_item_tower (
    item_type, item_id, title, description, location, address,
    latitude, longitude, price, currency_code,
    capacity, min_participants, max_participants,
    normalized_features,
    attraction_type, average_visit_minutes, 
    visit_types_json, suitable_for_json, attraction_features_json,
    average_rating, is_featured, status, visibility,
    source_updated_at, thumbnail_url, slug, published_at
  )
  SELECT 
    'attraction' as item_type,
    a.attraction_id as item_id,
    a.title,
    a.service_description as description,
    a.location,
    a.address,
    a.latitude,
    a.longitude,
    a.price,
    a.currency_code,
    a.capacity,
    a.min_participants,
    a.max_participants,
    
    JSON_ARRAY() as normalized_features, -- TODO: Extract từ features, suitable_for, visit_types
    
    a.attraction_type,
    a.average_visit_minutes,
    a.visit_types_json,
    a.suitable_for_json,
    a.features_json as attraction_features_json,
    
    NULL as average_rating,
    a.is_featured,
    a.attraction_status as status,
    a.visibility,
    
    a.updated_at as source_updated_at,
    a.thumbnail_url,
    a.slug,
    a.published_at
  FROM attractions a
  WHERE a.attraction_status = 'published';
  
  -- ============================================================
  -- SYNC RESTAURANTS
  -- ============================================================
  INSERT INTO ai_item_tower (
    item_type, item_id, title, description, location, address,
    latitude, longitude, price, currency_code,
    capacity, min_participants, max_participants,
    normalized_features,
    price_level,
    cuisines_json, diets_json, restaurant_services_json, 
    ambiance_tags_json, payment_methods_json,
    average_rating, is_featured, status, visibility,
    source_updated_at, thumbnail_url, slug, published_at
  )
  SELECT 
    'restaurant' as item_type,
    r.restaurant_id as item_id,
    r.title,
    r.service_description as description,
    r.location,
    r.address,
    r.latitude,
    r.longitude,
    r.price,
    r.currency_code,
    r.capacity,
    r.min_participants,
    r.max_participants,
    
    JSON_ARRAY() as normalized_features, -- TODO: Extract từ cuisines, diets, services, ambiance
    
    r.price_level,
    r.cuisines_json,
    r.diets_json,
    r.services_json as restaurant_services_json,
    r.ambiance_tags_json,
    r.payment_methods_json,
    
    NULL as average_rating,
    r.is_featured,
    r.restaurant_status as status,
    r.visibility,
    
    r.updated_at as source_updated_at,
    r.thumbnail_url,
    r.slug,
    r.published_at
  FROM restaurants r
  WHERE r.restaurant_status = 'published';
  
  SELECT CONCAT('Item Tower synced: ', ROW_COUNT(), ' items') as result;
  
END//

DELIMITER ;


-- ============================================================
-- HELPER VIEWS: Query patterns cho AI Training
-- ============================================================

-- View 1: Item features với interaction statistics
DROP VIEW IF EXISTS v_item_tower_with_stats;
CREATE VIEW v_item_tower_with_stats AS
SELECT 
  it.*,
  COUNT(DISTINCT ui.user_id) as unique_users_interacted,
  COUNT(ui.interaction_id) as total_interactions,
  SUM(CASE WHEN ui.action_type = 'view' THEN 1 ELSE 0 END) as view_count,
  SUM(CASE WHEN ui.action_type = 'click' THEN 1 ELSE 0 END) as click_count,
  SUM(CASE WHEN ui.action_type = 'favorite' THEN 1 ELSE 0 END) as favorite_count,
  SUM(CASE WHEN ui.action_type = 'book' THEN 1 ELSE 0 END) as book_count,
  SUM(CASE WHEN ui.action_type = 'search' THEN 1 ELSE 0 END) as search_count,
  SUM(ui.action_weight) as total_interaction_weight
FROM ai_item_tower it
LEFT JOIN user_item_interactions ui 
  ON it.item_type = ui.item_type AND it.item_id = ui.item_id
GROUP BY it.tower_item_id;


-- View 2: Items with high engagement (popular items)
DROP VIEW IF EXISTS v_popular_items;
CREATE VIEW v_popular_items AS
SELECT 
  item_type,
  item_id,
  title,
  location,
  price,
  normalized_features,
  COUNT(DISTINCT ui.user_id) as unique_users,
  COUNT(ui.interaction_id) as total_interactions,
  SUM(ui.action_weight) as engagement_score
FROM ai_item_tower it
JOIN user_item_interactions ui 
  ON it.item_type = ui.item_type AND it.item_id = ui.item_id
GROUP BY it.tower_item_id
HAVING total_interactions >= 5
ORDER BY engagement_score DESC;


-- View 3: Cold start items (new items with few/no interactions)
DROP VIEW IF EXISTS v_cold_start_items;
CREATE VIEW v_cold_start_items AS
SELECT 
  it.item_type,
  it.item_id,
  it.title,
  it.location,
  it.price,
  it.normalized_features,
  it.created_at,
  COALESCE(COUNT(ui.interaction_id), 0) as interaction_count
FROM ai_item_tower it
LEFT JOIN user_item_interactions ui 
  ON it.item_type = ui.item_type AND it.item_id = ui.item_id
WHERE it.status = 'published'
GROUP BY it.tower_item_id
HAVING interaction_count < 5
ORDER BY it.created_at DESC;


-- ============================================================
-- SAMPLE QUERIES: Training data extraction
-- ============================================================

/*
-- Query 1: Get User-Item matrix for collaborative filtering
SELECT 
  ui.user_id,
  ui.item_type,
  ui.item_id,
  SUM(ui.action_weight) as interaction_strength
FROM user_item_interactions ui
GROUP BY ui.user_id, ui.item_type, ui.item_id;

-- Query 2: Get Item features với interaction history
SELECT 
  it.tower_item_id,
  it.item_type,
  it.title,
  it.price,
  it.normalized_features,
  it.categories_json,
  it.amenities_json,
  vis.unique_users_interacted,
  vis.total_interactions,
  vis.total_interaction_weight
FROM v_item_tower_with_stats vis
JOIN ai_item_tower it ON vis.tower_item_id = it.tower_item_id
WHERE vis.total_interactions > 0;

-- Query 3: Find similar items based on features (Content-based)
-- (Cần implement feature similarity calculation)

-- Query 4: Get training data cho Two-Tower model
SELECT 
  ui.user_id,
  ui.item_type,
  ui.item_id,
  it.normalized_features,
  it.price,
  it.location,
  it.star_rating,
  it.property_type,
  it.cuisines_json,
  it.categories_json,
  ui.action_type,
  ui.action_weight,
  ui.interaction_timestamp
FROM user_item_interactions ui
JOIN ai_item_tower it 
  ON ui.item_type = it.item_type AND ui.item_id = it.item_id
WHERE it.status = 'published'
ORDER BY ui.interaction_timestamp DESC;

*/


-- ============================================================
-- MAINTENANCE: Call procedure để sync data
-- ============================================================
-- CALL sync_item_tower();

-- Verify results:
-- SELECT item_type, COUNT(*) as count FROM ai_item_tower GROUP BY item_type;



-- ============================================================
-- KẾT THÚC
-- ============================================================
