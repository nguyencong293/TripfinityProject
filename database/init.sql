-- Ensure UTF-8 support
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET CHARACTER SET utf8mb4;
SET character_set_connection = utf8mb4;
SET character_set_database = utf8mb4;
SET character_set_results = utf8mb4;
SET character_set_server = utf8mb4;
SET collation_connection = utf8mb4_unicode_ci;
SET collation_database = utf8mb4_unicode_ci;
SET collation_server = utf8mb4_unicode_ci;

-- Create database with proper charset
CREATE DATABASE IF NOT EXISTS tripfinity 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE tripfinity;

-- Set default charset for the database
ALTER DATABASE tripfinity CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 1. Bảng users
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) DEFAULT NULL,
    avatar_url VARCHAR(512) DEFAULT NULL,
    role ENUM('tourist','provider','admin') NOT NULL,
    status ENUM('active','banned',) NOT NULL DEFAULT 'active',
    date_of_birth DATE DEFAULT NULL,
    gender ENUM('male','female','other') DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Bảng providers
CREATE TABLE IF NOT EXISTS providers (
    provider_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    tax_code VARCHAR(100) DEFAULT NULL,
    address VARCHAR(512) DEFAULT NULL,
    contact_email VARCHAR(255) DEFAULT NULL,
    contact_phone VARCHAR(20) DEFAULT NULL,
    bank_account_number VARCHAR(100) DEFAULT NULL,
    bank_name VARCHAR(255) DEFAULT NULL,
    logo_url VARCHAR(512) DEFAULT NULL,
    description TEXT DEFAULT NULL,
    rating_overall DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    status ENUM('pending','approved','rejected','suspended') NOT NULL DEFAULT 'pending',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Bảng services
CREATE TABLE IF NOT EXISTS services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_id INT NOT NULL,
    type ENUM('tour','hotel','restaurant','activity','other') NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT DEFAULT NULL,
    location VARCHAR(255) DEFAULT NULL,
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL,
    price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    capacity INT DEFAULT NULL,
    min_participants INT DEFAULT NULL,
    max_participants INT DEFAULT NULL,
    thumbnail_url VARCHAR(512) DEFAULT NULL,
    image_urls TEXT DEFAULT NULL, -- JSON array nếu muốn lưu nhiều URL
    rating_average DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    badges VARCHAR(255) DEFAULT NULL, -- lưu dạng 'flash-deal,recommended'
    status ENUM('published','archived','disabled') NOT NULL DEFAULT 'published',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (provider_id) REFERENCES providers(provider_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Bảng tours (nếu tách riêng chi tiết tour)
CREATE TABLE IF NOT EXISTS tours (
    tour_id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    itinerary_overview TEXT DEFAULT NULL,
    meeting_point VARCHAR(255) DEFAULT NULL,
    guide_language VARCHAR(100) DEFAULT NULL,
    inclusive_items TEXT DEFAULT NULL,
    exclusive_items TEXT DEFAULT NULL,
    cancellation_policy TEXT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id) REFERENCES services(service_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Bảng itineraries (chi tiết từng ngày của tour)
CREATE TABLE IF NOT EXISTS itineraries (
    itinerary_id INT AUTO_INCREMENT PRIMARY KEY,
    tour_id INT NOT NULL,
    day_number INT NOT NULL,
    date DATE DEFAULT NULL,
    time VARCHAR(50) DEFAULT NULL,
    activity_description TEXT NOT NULL,
    location VARCHAR(255) DEFAULT NULL,
    guide_id INT DEFAULT NULL, -- FK → users nếu HDV quản lý qua user
    map_coordinates VARCHAR(100) DEFAULT NULL, -- ví dụ '10.776889,106.700806'
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tour_id) REFERENCES tours(tour_id),
    FOREIGN KEY (guide_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. Bảng group_bookings (đặt nhóm & chia thanh toán)
CREATE TABLE IF NOT EXISTS group_bookings (
    group_id INT AUTO_INCREMENT PRIMARY KEY,
    leader_id INT NOT NULL,
    service_id INT NOT NULL,
    group_name VARCHAR(255) DEFAULT NULL,
    max_participants INT DEFAULT NULL,
    status ENUM('open','closed','cancelled') NOT NULL DEFAULT 'open',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (leader_id) REFERENCES users(user_id),
    FOREIGN KEY (service_id) REFERENCES services(service_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. Bảng group_members (thành viên đặt nhóm)
CREATE TABLE IF NOT EXISTS group_members (
    group_member_id INT AUTO_INCREMENT PRIMARY KEY,
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    is_leader BOOLEAN NOT NULL DEFAULT FALSE,
    share_amount DECIMAL(12,2) DEFAULT NULL,
    payment_status ENUM('pending','paid','refunded') NOT NULL DEFAULT 'pending',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (group_id) REFERENCES group_bookings(group_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. Bảng bookings (đặt dịch vụ/tour)
CREATE TABLE IF NOT EXISTS bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    service_id INT NOT NULL,
    group_id INT DEFAULT NULL,
    booking_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL,
    num_adults INT NOT NULL DEFAULT 1,
    num_children INT NOT NULL DEFAULT 0,
    total_price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    status ENUM('pending','confirmed','cancelled','completed','refunded') NOT NULL DEFAULT 'pending',
    payment_id INT DEFAULT NULL, -- không đặt FK vì Payments sẽ reference về booking_id
    e_ticket_url VARCHAR(512) DEFAULT NULL,
    qr_code_data TEXT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (service_id) REFERENCES services(service_id),
    FOREIGN KEY (group_id) REFERENCES group_bookings(group_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 9. Bảng payments (thanh toán)
CREATE TABLE IF NOT EXISTS payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT DEFAULT NULL,
    group_id INT DEFAULT NULL,
    user_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    payment_method ENUM('vnpay','momo','visa','mastercard','paypal','other') NOT NULL,
    transaction_id VARCHAR(255) NOT NULL UNIQUE,
    status ENUM('pending','success','failed','refunded') NOT NULL DEFAULT 'pending',
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    FOREIGN KEY (group_id) REFERENCES group_bookings(group_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 10. Bảng reviews (đánh giá & bình luận)
CREATE TABLE IF NOT EXISTS reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    service_id INT DEFAULT NULL,
    tour_id INT DEFAULT NULL,
    provider_id INT DEFAULT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(255) DEFAULT NULL,
    content TEXT NOT NULL,
    image_urls TEXT DEFAULT NULL, -- JSON array lưu URL ảnh nếu có
    likes_count INT NOT NULL DEFAULT 0,
    status ENUM('approved','rejected') NOT NULL DEFAULT 'approved',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (service_id) REFERENCES services(service_id),
    FOREIGN KEY (tour_id) REFERENCES tours(tour_id),
    FOREIGN KEY (provider_id) REFERENCES providers(provider_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 11. Bảng blogs (bài viết của blogger)
CREATE TABLE IF NOT EXISTS blogs (
    blog_id INT AUTO_INCREMENT PRIMARY KEY,
    blogger_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    content LONGTEXT NOT NULL,
    cover_image_url VARCHAR(512) DEFAULT NULL,
    tags VARCHAR(255) DEFAULT NULL, -- lưu 'tag1,tag2,tag3'
    views_count INT NOT NULL DEFAULT 0,
    likes_count INT NOT NULL DEFAULT 0,
    status ENUM('published','archived') NOT NULL DEFAULT 'published',
    published_at DATETIME DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (blogger_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 12. Bảng follows (theo dõi blogger)
CREATE TABLE IF NOT EXISTS follows (
    follow_id INT AUTO_INCREMENT PRIMARY KEY,
    follower_id INT NOT NULL,
    followed_blogger_id INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (follower_id) REFERENCES users(user_id),
    FOREIGN KEY (followed_blogger_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 13. Bảng itineraries_downloads (Trip Builder & xuất file)
CREATE TABLE IF NOT EXISTS itineraries_downloads (
    itinerary_build_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    content_json LONGTEXT NOT NULL,
    share_link VARCHAR(512) DEFAULT NULL,
    pdf_export_url VARCHAR(512) DEFAULT NULL,
    ics_export_url VARCHAR(512) DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 14. Bảng chat_messages (in-app chat & live chat với CSKH/provider)
CREATE TABLE IF NOT EXISTS chat_messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    booking_id INT DEFAULT NULL,
    content TEXT NOT NULL,
    message_type ENUM('text','image','file','system') NOT NULL DEFAULT 'text',
    attachment_url VARCHAR(512) DEFAULT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(user_id),
    FOREIGN KEY (receiver_id) REFERENCES users(user_id),
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 15. Bảng chatbot_logs (NLU & chatbot)
CREATE TABLE IF NOT EXISTS chatbot_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT DEFAULT NULL,
    session_id VARCHAR(255) NOT NULL,
    query_text TEXT NOT NULL,
    intent_detected VARCHAR(255) DEFAULT NULL,
    response_text TEXT NOT NULL,
    language VARCHAR(10) DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 16. Bảng e_tickets (sinh e-ticket & QR code)
CREATE TABLE IF NOT EXISTS e_tickets (
    e_ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    ticket_code VARCHAR(100) NOT NULL UNIQUE,
    qr_code_data TEXT NOT NULL,
    pdf_url VARCHAR(512) NOT NULL,
    valid_from DATE DEFAULT NULL,
    valid_until DATE DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 17. Bảng virtual_tours (xem 360° & AR preview)
CREATE TABLE IF NOT EXISTS virtual_tours (
    virtual_tour_id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    media_type ENUM('360_image','360_video','ar_model') NOT NULL,
    media_url VARCHAR(512) NOT NULL,
    thumbnail_url VARCHAR(512) DEFAULT NULL,
    metadata_json LONGTEXT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id) REFERENCES services(service_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 18. Bảng offline_maps (bản đồ & POI offline)
CREATE TABLE IF NOT EXISTS offline_maps (
    offline_map_id INT AUTO_INCREMENT PRIMARY KEY,
    region_name VARCHAR(255) NOT NULL,
    map_file_url VARCHAR(512) NOT NULL,
    poi_data_json LONGTEXT DEFAULT NULL,
    version VARCHAR(50) DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 19. Bảng price_predictions (dự báo giá & cảnh báo giá)
CREATE TABLE IF NOT EXISTS price_predictions (
    prediction_id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    predicted_date DATE NOT NULL,
    predicted_price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    model_name VARCHAR(100) DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id) REFERENCES services(service_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 20. Bảng price_alerts (cảnh báo giá)
CREATE TABLE IF NOT EXISTS price_alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    service_id INT NOT NULL,
    target_price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_notified_at DATETIME DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (service_id) REFERENCES services(service_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 21. Bảng currencies (đa tiền tệ & quy đổi)
CREATE TABLE IF NOT EXISTS currencies (
    currency_code CHAR(3) PRIMARY KEY,
    currency_name VARCHAR(100) NOT NULL,
    exchange_rate_to_base DECIMAL(18,6) NOT NULL,
    last_updated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 22. Bảng image_search_logs (tìm kiếm bằng hình ảnh)
CREATE TABLE IF NOT EXISTS image_search_logs (
    image_search_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT DEFAULT NULL,
    image_url VARCHAR(512) NOT NULL,
    result_json LONGTEXT DEFAULT NULL,
    similarity_score DECIMAL(4,2) DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 23. Bảng badges (gamification – huy hiệu)
CREATE TABLE IF NOT EXISTS badges (
    badge_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT DEFAULT NULL,
    icon_url VARCHAR(512) DEFAULT NULL,
    criteria_json LONGTEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 24. Bảng user_badges (huy hiệu đã đạt)
CREATE TABLE IF NOT EXISTS user_badges (
    user_badge_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    badge_id INT NOT NULL,
    awarded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_visible BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (badge_id) REFERENCES badges(badge_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 25. Bảng points (điểm tích lũy – XP)
CREATE TABLE IF NOT EXISTS points (
    point_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    points INT NOT NULL,
    reason VARCHAR(255) NOT NULL,
    related_id INT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 27. Bảng notifications (in-app, email, push)
CREATE TABLE IF NOT EXISTS notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    type ENUM('in_app','email','push','sms') NOT NULL,
    category ENUM('booking_confirmation','price_alert','promo','system_alert','social') NOT NULL,
    title VARCHAR(255) DEFAULT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    read_at DATETIME DEFAULT NULL,
    sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 28. Bảng admin_actions (quản trị – ghi log hành động)
CREATE TABLE IF NOT EXISTS admin_actions (
    action_id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT NOT NULL,
    action_type VARCHAR(100) NOT NULL,
    target_type ENUM('user','provider','service','blog','booking','review','other') NOT NULL,
    target_id INT DEFAULT NULL,
    description TEXT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 29. Bảng system_settings (cấu hình chung)
CREATE TABLE IF NOT EXISTS system_settings (
    setting_key VARCHAR(100) PRIMARY KEY,
    setting_value TEXT NOT NULL,
    description VARCHAR(255) DEFAULT NULL,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;