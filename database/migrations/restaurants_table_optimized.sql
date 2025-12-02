-- OPTIMIZED RESTAURANTS TABLE
-- So sánh và chuẩn hóa với hotels & attractions

CREATE TABLE `restaurants` (
  `restaurant_id` int NOT NULL AUTO_INCREMENT,
  `provider_id` int NOT NULL,
  `area_id` int NOT NULL,
  
  -- Basic Info
  `title` varchar(255) NOT NULL,
  `service_description` text,
  `location` varchar(255) DEFAULT NULL COMMENT 'Tỉnh/thành phố (tên)',
  `address` varchar(255) DEFAULT NULL COMMENT 'Địa chỉ đầy đủ',
  
  -- Coordinates (CHUẨN HÓA: giống hotels & attractions)
  `latitude` decimal(10,8) DEFAULT NULL COMMENT 'Latitude coordinate',
  `longitude` decimal(11,8) DEFAULT NULL COMMENT 'Longitude coordinate',
  
  -- Contact Info
  `phone` varchar(20) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  
  -- Date Range (optional for seasonal restaurants)
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  
  -- Pricing
  `price` decimal(12,2) NOT NULL COMMENT 'Giá trung bình 1 người',
  `currency_code` varchar(3) NOT NULL DEFAULT 'VND',
  `price_level` enum('cheap','moderate','expensive','luxury') DEFAULT 'moderate' COMMENT 'Mức giá',
  
  -- Capacity
  `capacity` int DEFAULT NULL COMMENT 'Số chỗ ngồi tối đa',
  `min_participants` int DEFAULT NULL COMMENT 'Số người tối thiểu (group booking)',
  `max_participants` int DEFAULT NULL COMMENT 'Số người tối đa (group booking)',
  
  -- Media
  `thumbnail_url` varchar(512) DEFAULT NULL,
  `image_urls` json DEFAULT NULL COMMENT 'Array of image URLs (JSON)',
  
  -- Rating
  `rating_average` decimal(3,2) NOT NULL DEFAULT '0.00',
  
  -- Badges (JSON array)
  `badges` json DEFAULT NULL COMMENT 'Array: ["michelin_star","recommended","halal_certified"]',
  
  -- Status & Visibility
  `restaurant_status` enum('archived','disabled','published') NOT NULL DEFAULT 'published',
  `visibility` enum('public','private') NOT NULL DEFAULT 'public',
  `is_featured` tinyint(1) NOT NULL DEFAULT '0',
  
  -- RESTAURANT-SPECIFIC FIELDS
  `cuisines_json` json DEFAULT NULL COMMENT 'Array of cuisine types: ["vietnamese","chinese","japanese","korean","italian","french","thai","indian","american","mexican","seafood","vegetarian","fusion","bbq","hotpot"]',
  
  `services_json` json DEFAULT NULL COMMENT 'Array: ["dine_in","takeaway","delivery","reservation","private_room","buffet","outdoor_seating","live_music","wifi","parking"]',
  
  `diets_json` json DEFAULT NULL COMMENT 'Array: ["vegetarian","vegan","halal","kosher","gluten_free","dairy_free","nut_free","low_carb","keto"]',
  
  `opening_hours_json` json DEFAULT NULL COMMENT 'Object: {"monday":"10:00-22:00","tuesday":"10:00-22:00",...}',
  
  `menu_highlights_json` json DEFAULT NULL COMMENT 'Array of signature dishes',
  
  `ambiance_tags_json` json DEFAULT NULL COMMENT 'Array: ["romantic","family_friendly","business","casual","formal","cozy","modern","traditional","rooftop","beachfront"]',
  
  `payment_methods_json` json DEFAULT NULL COMMENT 'Array: ["cash","credit_card","debit_card","momo","zalopay","vnpay"]',
  
  `policies_text` text COMMENT 'Chính sách: dress code, reservation, cancellation',
  
  -- SEO
  `slug` varchar(255) DEFAULT NULL,
  `seo_title` varchar(255) DEFAULT NULL,
  `seo_description` varchar(512) DEFAULT NULL,
  
  -- Booking Settings
  `booking_settings_json` json DEFAULT NULL COMMENT 'Cấu hình đặt bàn',
  
  -- Timestamps
  `published_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  -- Indexes & Constraints
  PRIMARY KEY (`restaurant_id`),
  UNIQUE KEY `uq_restaurants_slug` (`slug`),
  KEY `fk_restaurants_area` (`area_id`),
  KEY `idx_restaurants_provider` (`provider_id`),
  KEY `idx_restaurants_status` (`restaurant_status`),
  KEY `idx_restaurants_price_level` (`price_level`),
  KEY `idx_restaurants_featured` (`is_featured`),
  
  CONSTRAINT `fk_restaurants_area` FOREIGN KEY (`area_id`) REFERENCES `areas` (`area_id`),
  CONSTRAINT `fk_restaurants_provider` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`provider_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- MIGRATION SCRIPT (nếu đã có data cũ)
-- ALTER TABLE `restaurants` 
-- ADD COLUMN `latitude` decimal(10,8) DEFAULT NULL AFTER `address`,
-- ADD COLUMN `longitude` decimal(11,8) DEFAULT NULL AFTER `latitude`,
-- ADD COLUMN `menu_highlights_json` json DEFAULT NULL AFTER `opening_hours_json`,
-- ADD COLUMN `ambiance_tags_json` json DEFAULT NULL AFTER `menu_highlights_json`,
-- ADD COLUMN `payment_methods_json` json DEFAULT NULL AFTER `ambiance_tags_json`,
-- ADD COLUMN `policies_text` text AFTER `payment_methods_json`,
-- MODIFY COLUMN `image_urls` json DEFAULT NULL COMMENT 'Array of image URLs',
-- MODIFY COLUMN `badges` json DEFAULT NULL COMMENT 'Array of badge strings',
-- MODIFY COLUMN `price_level` enum('cheap','moderate','expensive','luxury') DEFAULT 'moderate';
