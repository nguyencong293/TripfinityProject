-- Create user_badges table
CREATE TABLE IF NOT EXISTS `user_badges` (
  `user_badge_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `badge_id` INT NOT NULL,
  `unlocked_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_badge_id`),
  KEY `fk_user_badges_user` (`user_id`),
  KEY `fk_user_badges_badge` (`badge_id`),
  UNIQUE KEY `uk_user_badge` (`user_id`, `badge_id`),
  CONSTRAINT `fk_user_badges_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_user_badges_badge` FOREIGN KEY (`badge_id`) REFERENCES `badges` (`badge_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert default badges with criteria
INSERT INTO `badges` (`badge_name`, `badge_description`, `icon_url`, `criteria_json`, `created_at`, `updated_at`) VALUES
('Đồng', 'Du khách mới - Bắt đầu hành trình khám phá', '🥉', '{"requiredPoints":200}', NOW(), NOW()),
('Bạc', 'Nhà thám hiểm - Đã có nhiều trải nghiệm', '🥈', '{"requiredPoints":500}', NOW(), NOW()),
('Vàng', 'Du lịch chuyên nghiệp - Người đi nhiều nơi', '🥇', '{"requiredPoints":1000}', NOW(), NOW()),
('Kim cương', 'Huyền thoại du lịch - Bậc thầy khám phá', '💎', '{"requiredPoints":2000}', NOW(), NOW()),
('Huyền thoại', 'Bậc thầy du lịch - Đỉnh cao của du lịch', '👑', '{"requiredPoints":5000}', NOW(), NOW());
