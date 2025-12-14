-- Migration: Add user_favorites table
-- Date: 2025-12-14
-- Purpose: Cho phép user lưu danh sách các dịch vụ yêu thích (hotels, restaurants, attractions, tours)

-- Create user_favorites table
CREATE TABLE IF NOT EXISTS `user_favorites` (
  `favorite_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `service_type` ENUM('hotel', 'restaurant', 'attraction', 'tour') NOT NULL,
  `service_id` INT NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`favorite_id`),
  UNIQUE KEY `unique_user_service_favorite` (`user_id`, `service_type`, `service_id`),
  KEY `idx_user_favorites_user_id` (`user_id`),
  KEY `idx_user_favorites_service` (`service_type`, `service_id`),
  KEY `idx_user_favorites_created_at` (`created_at`),
  CONSTRAINT `fk_user_favorites_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Notes:
-- 1. UNIQUE constraint đảm bảo một user không thể favorite cùng một service nhiều lần
-- 2. service_type: hotel, restaurant, attraction, tour
-- 3. service_id: ID của dịch vụ tương ứng (hotel_id, restaurant_id, attraction_id, tour_id)
-- 4. ON DELETE CASCADE: Xóa user thì xóa luôn favorites của user đó
-- 5. Indexes được tạo để tối ưu query: get favorites by user, check favorite status, count favorites
