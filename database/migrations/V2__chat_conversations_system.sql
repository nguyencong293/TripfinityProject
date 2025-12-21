-- =====================================================
-- TRIPFINITY CHAT SYSTEM - COMPLETE SQL MIGRATION
-- Author: TripFinity Development Team  
-- Date: 2024-12-21
-- Description: Complete chat system between Users and Providers
-- Supports: Text messages, Image attachments (Cloudinary), File attachments
-- =====================================================

-- =====================================================
-- 1. TABLE: conversations
-- Quản lý các cuộc hội thoại giữa User và Provider
-- Mỗi cặp user-provider chỉ có 1 conversation duy nhất
-- =====================================================
CREATE TABLE IF NOT EXISTS `conversations` (
  `conversation_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL COMMENT 'ID của khách hàng (tourist)',
  `provider_id` INT NOT NULL COMMENT 'ID của nhà cung cấp dịch vụ',
  `subject` VARCHAR(255) DEFAULT NULL COMMENT 'Chủ đề cuộc hội thoại (tùy chọn)',
  `conversation_status` ENUM('active', 'closed', 'archived') NOT NULL DEFAULT 'active' COMMENT 'Trạng thái: active=đang hoạt động, closed=đã đóng, archived=lưu trữ',
  `last_message_at` DATETIME DEFAULT NULL COMMENT 'Thời gian tin nhắn cuối cùng',
  `last_message_preview` VARCHAR(255) DEFAULT NULL COMMENT 'Nội dung preview tin nhắn cuối',
  `user_unread_count` INT NOT NULL DEFAULT 0 COMMENT 'Số tin nhắn chưa đọc của user',
  `provider_unread_count` INT NOT NULL DEFAULT 0 COMMENT 'Số tin nhắn chưa đọc của provider',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`conversation_id`),
  UNIQUE KEY `uk_user_provider_conversation` (`user_id`, `provider_id`),
  KEY `idx_conversations_user` (`user_id`),
  KEY `idx_conversations_provider` (`provider_id`),
  KEY `idx_conversations_status` (`conversation_status`),
  KEY `idx_conversations_last_message` (`last_message_at` DESC),
  CONSTRAINT `fk_conversations_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_conversations_provider` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`provider_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng quản lý cuộc hội thoại giữa User và Provider';

-- =====================================================
-- 2. TABLE: conversation_messages
-- Lưu trữ từng tin nhắn trong cuộc hội thoại
-- Hỗ trợ: text, image (Cloudinary), file, system message
-- =====================================================
CREATE TABLE IF NOT EXISTS `conversation_messages` (
  `message_id` INT NOT NULL AUTO_INCREMENT,
  `conversation_id` INT NOT NULL COMMENT 'ID cuộc hội thoại',
  `sender_type` ENUM('user', 'provider') NOT NULL COMMENT 'Loại người gửi: user hoặc provider',
  `sender_id` INT NOT NULL COMMENT 'ID người gửi (user_id nếu user, provider_id nếu provider)',
  `content` TEXT DEFAULT NULL COMMENT 'Nội dung tin nhắn văn bản',
  `message_type` ENUM('text', 'image', 'file', 'system') NOT NULL DEFAULT 'text' COMMENT 'Loại tin nhắn',
  `image_url` VARCHAR(512) DEFAULT NULL COMMENT 'URL hình ảnh từ Cloudinary',
  `file_url` VARCHAR(512) DEFAULT NULL COMMENT 'URL file đính kèm',
  `file_name` VARCHAR(255) DEFAULT NULL COMMENT 'Tên file gốc',
  `file_size` INT DEFAULT NULL COMMENT 'Kích thước file (bytes)',
  `is_read` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '0=chưa đọc, 1=đã đọc',
  `read_at` DATETIME DEFAULT NULL COMMENT 'Thời gian đọc tin nhắn',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_id`),
  KEY `idx_messages_conversation` (`conversation_id`),
  KEY `idx_messages_sender` (`sender_type`, `sender_id`),
  KEY `idx_messages_created` (`created_at` DESC),
  KEY `idx_messages_unread` (`conversation_id`, `is_read`, `sender_type`),
  CONSTRAINT `fk_messages_conversation` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`conversation_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng lưu trữ tin nhắn trong cuộc hội thoại';

-- =====================================================
-- 3. STORED PROCEDURES cho Chat System
-- =====================================================

-- Procedure: Tạo hoặc lấy conversation giữa user và provider
DROP PROCEDURE IF EXISTS `sp_get_or_create_conversation`;
DELIMITER //
CREATE PROCEDURE `sp_get_or_create_conversation`(
  IN p_user_id INT,
  IN p_provider_id INT,
  IN p_subject VARCHAR(255)
)
BEGIN
  DECLARE v_conversation_id INT;
  
  -- Kiểm tra conversation đã tồn tại chưa
  SELECT conversation_id INTO v_conversation_id
  FROM conversations
  WHERE user_id = p_user_id AND provider_id = p_provider_id
  LIMIT 1;
  
  -- Nếu chưa có thì tạo mới
  IF v_conversation_id IS NULL THEN
    INSERT INTO conversations (user_id, provider_id, subject, conversation_status)
    VALUES (p_user_id, p_provider_id, p_subject, 'active');
    
    SET v_conversation_id = LAST_INSERT_ID();
  END IF;
  
  -- Trả về conversation
  SELECT c.*, 
         u.full_name AS user_name, 
         u.avatar_url AS user_avatar,
         p.company_name AS provider_name,
         p.logo_url AS provider_logo
  FROM conversations c
  JOIN users u ON c.user_id = u.user_id
  JOIN providers p ON c.provider_id = p.provider_id
  WHERE c.conversation_id = v_conversation_id;
END//
DELIMITER ;

-- Procedure: Gửi tin nhắn mới
DROP PROCEDURE IF EXISTS `sp_send_message`;
DELIMITER //
CREATE PROCEDURE `sp_send_message`(
  IN p_conversation_id INT,
  IN p_sender_type ENUM('user', 'provider'),
  IN p_sender_id INT,
  IN p_content TEXT,
  IN p_message_type ENUM('text', 'image', 'file', 'system'),
  IN p_image_url VARCHAR(512),
  IN p_file_url VARCHAR(512),
  IN p_file_name VARCHAR(255),
  IN p_file_size INT
)
BEGIN
  DECLARE v_message_preview VARCHAR(255);
  
  -- Tạo message preview
  SET v_message_preview = CASE 
    WHEN p_message_type = 'image' THEN '[Hình ảnh]'
    WHEN p_message_type = 'file' THEN CONCAT('[Tệp: ', IFNULL(p_file_name, 'file'), ']')
    WHEN p_message_type = 'system' THEN '[Thông báo hệ thống]'
    ELSE LEFT(p_content, 100)
  END;
  
  -- Insert tin nhắn mới
  INSERT INTO conversation_messages (
    conversation_id, sender_type, sender_id, content, message_type,
    image_url, file_url, file_name, file_size
  ) VALUES (
    p_conversation_id, p_sender_type, p_sender_id, p_content, p_message_type,
    p_image_url, p_file_url, p_file_name, p_file_size
  );
  
  -- Cập nhật conversation
  UPDATE conversations
  SET 
    last_message_at = NOW(),
    last_message_preview = v_message_preview,
    user_unread_count = CASE WHEN p_sender_type = 'provider' THEN user_unread_count + 1 ELSE user_unread_count END,
    provider_unread_count = CASE WHEN p_sender_type = 'user' THEN provider_unread_count + 1 ELSE provider_unread_count END
  WHERE conversation_id = p_conversation_id;
  
  -- Trả về tin nhắn vừa tạo
  SELECT * FROM conversation_messages WHERE message_id = LAST_INSERT_ID();
END//
DELIMITER ;

-- Procedure: Đánh dấu đã đọc tin nhắn
DROP PROCEDURE IF EXISTS `sp_mark_messages_as_read`;
DELIMITER //
CREATE PROCEDURE `sp_mark_messages_as_read`(
  IN p_conversation_id INT,
  IN p_reader_type ENUM('user', 'provider')
)
BEGIN
  -- Đánh dấu tất cả tin nhắn từ đối phương là đã đọc
  UPDATE conversation_messages
  SET is_read = 1, read_at = NOW()
  WHERE conversation_id = p_conversation_id
    AND sender_type != p_reader_type
    AND is_read = 0;
  
  -- Reset unread count
  IF p_reader_type = 'user' THEN
    UPDATE conversations SET user_unread_count = 0 WHERE conversation_id = p_conversation_id;
  ELSE
    UPDATE conversations SET provider_unread_count = 0 WHERE conversation_id = p_conversation_id;
  END IF;
  
  SELECT ROW_COUNT() AS messages_marked_read;
END//
DELIMITER ;

-- =====================================================
-- 4. VIEWS cho dễ query
-- =====================================================

-- View: Danh sách conversations với thông tin đầy đủ
CREATE OR REPLACE VIEW `v_conversations_full` AS
SELECT 
  c.conversation_id,
  c.user_id,
  c.provider_id,
  c.subject,
  c.conversation_status,
  c.last_message_at,
  c.last_message_preview,
  c.user_unread_count,
  c.provider_unread_count,
  c.created_at,
  c.updated_at,
  u.full_name AS user_name,
  u.avatar_url AS user_avatar,
  u.email AS user_email,
  p.company_name AS provider_name,
  p.logo_url AS provider_logo,
  p.contact_email AS provider_email
FROM conversations c
JOIN users u ON c.user_id = u.user_id
JOIN providers p ON c.provider_id = p.provider_id;

-- View: Tin nhắn với thông tin sender
CREATE OR REPLACE VIEW `v_messages_with_sender` AS
SELECT 
  m.message_id,
  m.conversation_id,
  m.sender_type,
  m.sender_id,
  m.content,
  m.message_type,
  m.image_url,
  m.file_url,
  m.file_name,
  m.file_size,
  m.is_read,
  m.read_at,
  m.created_at,
  CASE 
    WHEN m.sender_type = 'user' THEN u.full_name
    ELSE p.company_name
  END AS sender_name,
  CASE 
    WHEN m.sender_type = 'user' THEN u.avatar_url
    ELSE p.logo_url
  END AS sender_avatar
FROM conversation_messages m
JOIN conversations c ON m.conversation_id = c.conversation_id
JOIN users u ON c.user_id = u.user_id
JOIN providers p ON c.provider_id = p.provider_id;

-- =====================================================
-- 5. SAMPLE DATA cho Testing (Comment out khi deploy production)
-- =====================================================
-- Uncomment để test:

-- INSERT INTO `conversations` (`user_id`, `provider_id`, `subject`, `conversation_status`, `last_message_at`, `last_message_preview`) 
-- VALUES 
--   (1, 1, 'Hỏi về đặt khách sạn Việt Nam', 'active', NOW(), 'Cảm ơn bạn đã liên hệ!'),
--   (1, 1, NULL, 'active', NULL, NULL);

-- INSERT INTO `conversation_messages` (`conversation_id`, `sender_type`, `sender_id`, `content`, `message_type`) 
-- VALUES 
--   (1, 'user', 1, 'Xin chào, tôi muốn hỏi về phòng trống cho ngày 25/12', 'text'),
--   (1, 'provider', 1, 'Chào bạn! Chúng tôi vẫn còn phòng. Bạn cần loại phòng nào ạ?', 'text'),
--   (1, 'user', 1, 'Tôi cần phòng đôi cho 2 người, có view biển được không?', 'text'),
--   (1, 'provider', 1, 'Dạ có ạ! Giá phòng view biển là 1,500,000 VND/đêm. Bạn muốn đặt mấy đêm?', 'text');

-- =====================================================
-- END OF MIGRATION
-- =====================================================
