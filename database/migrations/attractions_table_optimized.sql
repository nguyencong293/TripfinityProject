-- OPTIMIZED ATTRACTIONS TABLE
-- So sánh và chuẩn hóa với hotels table structure

CREATE TABLE `attractions` (
  `attraction_id` int NOT NULL AUTO_INCREMENT,
  `provider_id` int NOT NULL,
  `area_id` int NOT NULL,
  
  -- Basic Info (giống hotels)
  `title` varchar(255) NOT NULL,
  `service_description` text,
  `location` varchar(255) DEFAULT NULL COMMENT 'Tỉnh/thành phố (tên)',
  `address` varchar(255) DEFAULT NULL COMMENT 'Địa chỉ đầy đủ',
  
  -- Coordinates (CHUẨN HÓA: tách ra như hotels thay vì varchar)
  `latitude` decimal(10,8) DEFAULT NULL COMMENT 'Latitude coordinate',
  `longitude` decimal(11,8) DEFAULT NULL COMMENT 'Longitude coordinate',
  
  -- Date Range
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  
  -- Pricing
  `price` decimal(12,2) NOT NULL,
  `currency_code` varchar(3) NOT NULL DEFAULT 'VND',
  
  -- Capacity
  `capacity` int DEFAULT NULL COMMENT 'Số lượng khách tối đa',
  `min_participants` int DEFAULT NULL,
  `max_participants` int DEFAULT NULL,
  
  -- Media
  `thumbnail_url` varchar(512) DEFAULT NULL,
  `image_urls` json DEFAULT NULL COMMENT 'Array of image URLs (JSON)',
  
  -- Rating
  `rating_average` decimal(3,2) NOT NULL DEFAULT '0.00',
  
  -- Badges (JSON array giống hotels)
  `badges` json DEFAULT NULL COMMENT 'Array of badge strings',
  
  -- Status & Visibility (giống hotels)
  `attraction_status` enum('archived','disabled','published') NOT NULL DEFAULT 'published',
  `visibility` enum('public','private') NOT NULL DEFAULT 'public',
  `is_featured` tinyint(1) NOT NULL DEFAULT '0',
  
  -- ATTRACTION-SPECIFIC FIELDS
  `attraction_type` enum('museum','park','temple','landmark','theme_park','cultural_site','natural_attraction','entertainment','historical_site','other') DEFAULT NULL COMMENT 'Loại điểm tham quan',
  
  `average_visit_minutes` int DEFAULT NULL COMMENT 'Thời gian tham quan trung bình (phút)',
  
  `visit_types_json` json DEFAULT NULL COMMENT 'Array of visit types: ["guided_tour","self_guided","audio_guide","virtual_tour"]',
  
  `available_times_json` json DEFAULT NULL COMMENT 'Array of time slots available',
  
  `suitable_for_json` json DEFAULT NULL COMMENT 'Array: ["family","kids","elderly","couples","groups","solo","pets"]',
  
  `features_json` json DEFAULT NULL COMMENT 'Array of feature IDs from attractions_features dictionary',
  
  `opening_hours_json` json DEFAULT NULL COMMENT 'Object: {"monday":"08:00-17:00","tuesday":"08:00-17:00",...}',
  
  `highlights_json` json DEFAULT NULL COMMENT 'Array of highlight IDs (giống hotels)',
  
  `tips_text` text COMMENT 'Lời khuyên cho du khách',
  
  `policies_text` text COMMENT 'Chính sách (hủy, hoàn tiền, quy định)',
  
  -- SEO
  `slug` varchar(255) DEFAULT NULL,
  `seo_title` varchar(255) DEFAULT NULL,
  `seo_description` varchar(512) DEFAULT NULL,
  
  -- Booking Settings
  `booking_settings_json` json DEFAULT NULL COMMENT 'Cấu hình đặt chỗ',
  
  -- Timestamps
  `published_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  -- Indexes & Constraints
  PRIMARY KEY (`attraction_id`),
  UNIQUE KEY `uq_attractions_slug` (`slug`),
  KEY `fk_attractions_area` (`area_id`),
  KEY `idx_attractions_provider` (`provider_id`),
  KEY `idx_attractions_status` (`attraction_status`),
  KEY `idx_attractions_type` (`attraction_type`),
  KEY `idx_attractions_featured` (`is_featured`),
  
  CONSTRAINT `fk_attractions_area` FOREIGN KEY (`area_id`) REFERENCES `areas` (`area_id`),
  CONSTRAINT `fk_attractions_provider` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`provider_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- MIGRATION SCRIPT (nếu đã có data cũ)
-- ALTER TABLE `attractions` 
-- ADD COLUMN `latitude` decimal(10,8) DEFAULT NULL AFTER `address`,
-- ADD COLUMN `longitude` decimal(11,8) DEFAULT NULL AFTER `latitude`,
-- ADD COLUMN `attraction_type` enum('museum','park','temple','landmark','theme_park','cultural_site','natural_attraction','entertainment','historical_site','other') DEFAULT NULL AFTER `visibility`,
-- ADD COLUMN `policies_text` text AFTER `tips_text`,
-- MODIFY COLUMN `image_urls` json DEFAULT NULL COMMENT 'Array of image URLs',
-- MODIFY COLUMN `badges` json DEFAULT NULL COMMENT 'Array of badge strings',
-- DROP COLUMN `coordinates`;
