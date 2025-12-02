-- OPTIMIZED TOURS TABLE
-- Chuẩn hóa với hotels, attractions, restaurants

CREATE TABLE `tours` (
  `tour_id` int NOT NULL AUTO_INCREMENT,
  `provider_id` int NOT NULL,
  `area_id` int NOT NULL,
  
  -- Basic Info
  `title` varchar(255) NOT NULL,
  `service_description` text,
  `location` varchar(255) DEFAULT NULL COMMENT 'Tỉnh/thành phố (tên)',
  `address` varchar(255) DEFAULT NULL COMMENT 'Địa chỉ đầy đủ',
  
  -- Coordinates (CHUẨN HÓA: giống hotels, attractions, restaurants)
  `latitude` decimal(10,8) DEFAULT NULL COMMENT 'Latitude coordinate',
  `longitude` decimal(11,8) DEFAULT NULL COMMENT 'Longitude coordinate',
  
  -- Date Range
  `start_date` date DEFAULT NULL COMMENT 'Ngày bắt đầu tour',
  `end_date` date DEFAULT NULL COMMENT 'Ngày kết thúc tour',
  
  -- Pricing
  `price` decimal(12,2) NOT NULL COMMENT 'Giá tour',
  `currency_code` varchar(3) NOT NULL DEFAULT 'VND',
  
  -- Capacity
  `capacity` int DEFAULT NULL COMMENT 'Số người tối đa',
  `min_participants` int DEFAULT NULL COMMENT 'Số người tối thiểu để khởi hành',
  `max_participants` int DEFAULT NULL COMMENT 'Số người tối đa',
  
  -- Media
  `thumbnail_url` varchar(512) DEFAULT NULL,
  `image_urls` json DEFAULT NULL COMMENT 'Array of image URLs (JSON)',
  
  -- Rating
  `rating_average` decimal(3,2) NOT NULL DEFAULT '0.00',
  
  -- Badges (JSON array - CHUẨN HÓA)
  `badges` json DEFAULT NULL COMMENT 'Array: ["best_seller","eco_friendly","family_friendly","adventure"]',
  
  -- Status & Visibility (CHUẨN HÓA)
  `tour_status` enum('archived','disabled','published') NOT NULL DEFAULT 'published',
  `visibility` enum('public','private') NOT NULL DEFAULT 'public',
  `is_featured` tinyint(1) NOT NULL DEFAULT '0',
  
  -- TOUR-SPECIFIC FIELDS
  `duration_days` int DEFAULT NULL COMMENT 'Số ngày tour',
  `difficulty_level` enum('easy','moderate','hard') DEFAULT 'moderate' COMMENT 'Độ khó',
  
  `departure_location` varchar(255) DEFAULT NULL COMMENT 'Điểm xuất phát',
  `meeting_point` varchar(255) DEFAULT NULL COMMENT 'Điểm tập trung',
  
  `guide_language` varchar(100) DEFAULT NULL COMMENT 'Ngôn ngữ hướng dẫn viên (deprecated - dùng guide_languages_json)',
  `guide_languages_json` json DEFAULT NULL COMMENT 'Array: ["vietnamese","english","chinese","japanese","korean"]',
  
  -- Itinerary
  `itinerary_overview` text COMMENT 'Tổng quan lịch trình',
  `itinerary_details_json` json DEFAULT NULL COMMENT 'Chi tiết lịch trình từng ngày: [{"day":1,"title":"","activities":[]}]',
  
  -- Included/Excluded Items (CHUẨN HÓA: dùng JSON)
  `inclusive_items` text COMMENT 'Deprecated - dùng included_json',
  `exclusive_items` text COMMENT 'Deprecated - dùng excluded_json',
  `included_json` json DEFAULT NULL COMMENT 'Array: ["hotel","meals","transport","guide","insurance","entrance_fees"]',
  `excluded_json` json DEFAULT NULL COMMENT 'Array: ["flights","visa","tips","personal_expenses"]',
  
  -- Policies
  `cancellation_policy` text COMMENT 'Chính sách hủy tour',
  `policies_text` text COMMENT 'Các chính sách khác',
  
  -- Tour Types & Categories
  `tour_type` enum('group','private','custom') DEFAULT 'group' COMMENT 'Loại tour',
  `categories_json` json DEFAULT NULL COMMENT 'Array: ["culture","nature","adventure","food","beach","mountain","city","historical"]',
  
  -- Additional Services
  `services_json` json DEFAULT NULL COMMENT 'Array: ["pickup","airport_transfer","photography","bike_rental","special_meals"]',
  
  -- SEO (CHUẨN HÓA)
  `slug` varchar(255) DEFAULT NULL,
  `seo_title` varchar(255) DEFAULT NULL,
  `seo_description` varchar(512) DEFAULT NULL,
  
  -- Booking Settings
  `booking_settings_json` json DEFAULT NULL COMMENT 'Cấu hình đặt tour',
  
  -- Timestamps (CHUẨN HÓA)
  `published_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  -- Indexes & Constraints
  PRIMARY KEY (`tour_id`),
  UNIQUE KEY `uq_tours_slug` (`slug`),
  KEY `fk_tours_area` (`area_id`),
  KEY `idx_tours_provider` (`provider_id`),
  KEY `idx_tours_status` (`tour_status`),
  KEY `idx_tours_difficulty` (`difficulty_level`),
  KEY `idx_tours_featured` (`is_featured`),
  KEY `idx_tours_tour_type` (`tour_type`),
  
  CONSTRAINT `fk_tours_area` FOREIGN KEY (`area_id`) REFERENCES `areas` (`area_id`),
  CONSTRAINT `fk_tours_provider` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`provider_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- MIGRATION SCRIPT (nếu đã có data cũ)
-- ALTER TABLE `tours` 
-- ADD COLUMN `latitude` decimal(10,8) DEFAULT NULL AFTER `address`,
-- ADD COLUMN `longitude` decimal(11,8) DEFAULT NULL AFTER `latitude`,
-- ADD COLUMN `address` varchar(255) DEFAULT NULL AFTER `location`,
-- ADD COLUMN `guide_languages_json` json DEFAULT NULL AFTER `guide_language`,
-- ADD COLUMN `itinerary_details_json` json DEFAULT NULL AFTER `itinerary_overview`,
-- ADD COLUMN `policies_text` text AFTER `cancellation_policy`,
-- ADD COLUMN `tour_type` enum('group','private','custom') DEFAULT 'group' AFTER `policies_text`,
-- ADD COLUMN `categories_json` json DEFAULT NULL AFTER `tour_type`,
-- ADD COLUMN `services_json` json DEFAULT NULL AFTER `categories_json`,
-- MODIFY COLUMN `image_urls` json DEFAULT NULL,
-- MODIFY COLUMN `badges` json DEFAULT NULL;

-- NOTES:
-- 1. Đã thêm latitude/longitude giống hotels/attractions/restaurants
-- 2. Đã chuẩn hóa image_urls, badges sang JSON
-- 3. Đã thêm guide_languages_json thay cho guide_language (hỗ trợ đa ngôn ngữ)
-- 4. Đã thêm itinerary_details_json cho lịch trình chi tiết từng ngày
-- 5. Đã thêm tour_type (group/private/custom)
-- 6. Đã thêm categories_json, services_json cho filtering
-- 7. Đã thêm policies_text cho các chính sách bổ sung
