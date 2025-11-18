-- Reset sạch
DROP DATABASE IF EXISTS tripfinity;

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET CHARACTER SET utf8mb4;
SET character_set_connection = utf8mb4;
SET character_set_results   = utf8mb4;
SET character_set_server    = utf8mb4;
SET collation_connection    = utf8mb4_unicode_ci;
SET collation_server        = utf8mb4_unicode_ci;

CREATE DATABASE tripfinity
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE tripfinity;

-- 1) users
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) DEFAULT NULL,
    avatar_url VARCHAR(512) DEFAULT NULL,
    account_role ENUM('tourist','provider','admin') NOT NULL,
    account_status ENUM('active','banned') NOT NULL DEFAULT 'active',
    date_of_birth DATE DEFAULT NULL,
    gender ENUM('male','female','other') DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    otp_expiry_time DATETIME DEFAULT NULL,
    reset_otp VARCHAR(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2) areas
CREATE TABLE areas (
    area_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,           
    slug VARCHAR(255) NOT NULL UNIQUE,       
    area_type ENUM('province','city','district') NOT NULL DEFAULT 'province',
    short_description VARCHAR(255) DEFAULT NULL,
    cover_image_url VARCHAR(512) DEFAULT NULL,
    avg_rating DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    ratings_count INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3) providers
CREATE TABLE providers (
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
    provider_description TEXT DEFAULT NULL,
    rating_overall DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    provider_status ENUM('pending','approved','rejected','suspended') NOT NULL DEFAULT 'pending',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_providers_user FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4) tours
CREATE TABLE tours (
    tour_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_id INT NOT NULL,
    area_id INT NOT NULL,

    -- Trường chung
    title VARCHAR(255) NOT NULL,
    service_description TEXT DEFAULT NULL,
    location VARCHAR(255) DEFAULT NULL,
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL,
    price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    capacity INT DEFAULT NULL,
    min_participants INT DEFAULT NULL,
    max_participants INT DEFAULT NULL,
    thumbnail_url VARCHAR(512) DEFAULT NULL,
    image_urls TEXT DEFAULT NULL,
    rating_average DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    badges VARCHAR(255) DEFAULT NULL,
    tour_status ENUM('published','archived','disabled') NOT NULL DEFAULT 'published',

    -- Chi tiết tour
    itinerary_overview TEXT DEFAULT NULL,
    meeting_point VARCHAR(255) DEFAULT NULL,
    guide_language VARCHAR(100) DEFAULT NULL,
    inclusive_items TEXT DEFAULT NULL,
    exclusive_items TEXT DEFAULT NULL,
    cancellation_policy TEXT DEFAULT NULL,
    difficulty_level ENUM('easy','moderate','hard') DEFAULT NULL,
    duration_days SMALLINT DEFAULT NULL,
    departure_location VARCHAR(255) DEFAULT NULL,
    included_json JSON DEFAULT NULL,
    excluded_json JSON DEFAULT NULL,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_tours_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id),
    CONSTRAINT fk_tours_area FOREIGN KEY (area_id) REFERENCES areas(area_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5) hotels
CREATE TABLE hotels (
    hotel_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_id INT NOT NULL,
    area_id INT NOT NULL,

    -- Chung
    title VARCHAR(255) NOT NULL,
    service_description TEXT DEFAULT NULL,
    location VARCHAR(255) DEFAULT NULL,
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL,
    price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    capacity INT DEFAULT NULL,
    min_participants INT DEFAULT NULL,
    max_participants INT DEFAULT NULL,
    thumbnail_url VARCHAR(512) DEFAULT NULL,
    image_urls TEXT DEFAULT NULL,
    rating_average DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    badges VARCHAR(255) DEFAULT NULL,
    hotel_status ENUM('published','archived','disabled') NOT NULL DEFAULT 'published',

    -- SEO / Slug / Publishing
    slug VARCHAR(255) DEFAULT NULL,
    seo_title VARCHAR(255) DEFAULT NULL,
    seo_description VARCHAR(512) DEFAULT NULL,
    is_featured TINYINT(1) NOT NULL DEFAULT 0,
    booking_settings_json JSON DEFAULT NULL,
    published_at DATETIME DEFAULT NULL,

    -- Visibility (đã điều chỉnh sang public_/private_)
    visibility ENUM('public_','private_') NOT NULL DEFAULT 'public_',

    -- Chi tiết hotel
    star_rating TINYINT CHECK (star_rating BETWEEN 1 AND 5),
    property_type ENUM('hotel','resort','apartment','villa','hostel','guesthouse','homestay') DEFAULT 'hotel',
    address VARCHAR(255) DEFAULT NULL,
    checkin_time TIME DEFAULT NULL,
    checkout_time TIME DEFAULT NULL,
    highlights_json JSON DEFAULT NULL,
    amenities_json JSON DEFAULT NULL,
    policies_text TEXT DEFAULT NULL,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_hotels_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id),
    CONSTRAINT fk_hotels_area FOREIGN KEY (area_id) REFERENCES areas(area_id),

    UNIQUE KEY uq_hotels_slug (slug),
    INDEX idx_hotels_provider (provider_id),
    INDEX idx_hotels_status (hotel_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- 6) restaurants
CREATE TABLE restaurants (
    restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_id INT NOT NULL,
    area_id INT NOT NULL,

    -- Chung
    title VARCHAR(255) NOT NULL,
    service_description TEXT DEFAULT NULL,
    location VARCHAR(255) DEFAULT NULL,
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL,
    price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    capacity INT DEFAULT NULL,
    min_participants INT DEFAULT NULL,
    max_participants INT DEFAULT NULL,
    thumbnail_url VARCHAR(512) DEFAULT NULL,
    image_urls TEXT DEFAULT NULL,
    rating_average DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    badges VARCHAR(255) DEFAULT NULL,
    restaurant_status ENUM('published','archived','disabled') NOT NULL DEFAULT 'published',

    -- Chi tiết restaurant
    price_level ENUM('cheap','moderate','expensive','luxury') DEFAULT NULL,
    phone VARCHAR(20) DEFAULT NULL,
    website VARCHAR(255) DEFAULT NULL,
    address VARCHAR(255) DEFAULT NULL,
    cuisines_json JSON DEFAULT NULL,
    services_json JSON DEFAULT NULL,
    diets_json JSON DEFAULT NULL,
    opening_hours_json JSON DEFAULT NULL,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_restaurants_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id),
    CONSTRAINT fk_restaurants_area FOREIGN KEY (area_id) REFERENCES areas(area_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7) attractions
CREATE TABLE attractions (
    attraction_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_id INT NOT NULL,
    area_id INT NOT NULL,

    -- Chung
    title VARCHAR(255) NOT NULL,
    service_description TEXT DEFAULT NULL,
    location VARCHAR(255) DEFAULT NULL,
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL,
    price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    capacity INT DEFAULT NULL,
    min_participants INT DEFAULT NULL,
    max_participants INT DEFAULT NULL,
    thumbnail_url VARCHAR(512) DEFAULT NULL,
    image_urls TEXT DEFAULT NULL,
    rating_average DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    badges VARCHAR(255) DEFAULT NULL,
    attraction_status ENUM('published','archived','disabled') NOT NULL DEFAULT 'published',

    -- Chi tiết attraction
    address VARCHAR(255) DEFAULT NULL,
    coordinates VARCHAR(100) DEFAULT NULL,
    average_visit_minutes SMALLINT DEFAULT NULL,
    visit_types_json JSON DEFAULT NULL,
    available_times_json JSON DEFAULT NULL,
    suitable_for_json JSON DEFAULT NULL,
    features_json JSON DEFAULT NULL,
    opening_hours_json JSON DEFAULT NULL,
    highlights_json JSON DEFAULT NULL,
    tips_text TEXT DEFAULT NULL,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_attractions_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id),
    CONSTRAINT fk_attractions_area FOREIGN KEY (area_id) REFERENCES areas(area_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 11) bookings per type
CREATE TABLE hotel_bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    hotel_id INT NOT NULL,
    booking_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL,
    num_adults INT NOT NULL DEFAULT 1,
    total_price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    booking_status ENUM('pending','confirmed','cancelled','completed','refunded') NOT NULL DEFAULT 'pending',
    provider_confirmed TINYINT NOT NULL DEFAULT 0 COMMENT '0=pending, 1=confirmed, 2=cancelled',
    provider_confirmed_at DATETIME DEFAULT NULL,
    e_ticket_url VARCHAR(512) DEFAULT NULL,
    qr_code_data TEXT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_hotel_booking_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_hotel_booking_hotel FOREIGN KEY (hotel_id) REFERENCES hotels(hotel_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE restaurant_bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    booking_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL,
    num_adults INT NOT NULL DEFAULT 1,
    total_price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    booking_status ENUM('pending','confirmed','cancelled','completed','refunded') NOT NULL DEFAULT 'pending',
    e_ticket_url VARCHAR(512) DEFAULT NULL,
    qr_code_data TEXT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_rest_booking_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_rest_booking_rest FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE attraction_bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    attraction_id INT NOT NULL,
    booking_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL,
    num_adults INT NOT NULL DEFAULT 1,
    total_price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    booking_status ENUM('pending','confirmed','cancelled','completed','refunded') NOT NULL DEFAULT 'pending',
    e_ticket_url VARCHAR(512) DEFAULT NULL,
    qr_code_data TEXT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_attr_booking_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_attr_booking_attr FOREIGN KEY (attraction_id) REFERENCES attractions(attraction_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tour_bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    tour_id INT NOT NULL,
    booking_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL,
    num_adults INT NOT NULL DEFAULT 1,
    total_price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    booking_status ENUM('pending','confirmed','cancelled','completed','refunded') NOT NULL DEFAULT 'pending',
    e_ticket_url VARCHAR(512) DEFAULT NULL,
    qr_code_data TEXT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_tour_booking_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_tour_booking_tour FOREIGN KEY (tour_id) REFERENCES tours(tour_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 12) payments per type
CREATE TABLE hotel_payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    user_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    payment_method ENUM('vnpay','momo','visa','mastercard','paypal','other') NOT NULL,
    transaction_id VARCHAR(255) NOT NULL UNIQUE,
    payment_status ENUM('pending','success','failed','refunded') NOT NULL DEFAULT 'pending',
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_hotel_pay_booking FOREIGN KEY (booking_id) REFERENCES hotel_bookings(booking_id),
    CONSTRAINT fk_hotel_pay_user FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE restaurant_payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    user_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    payment_method ENUM('vnpay','momo','visa','mastercard','paypal','other') NOT NULL,
    transaction_id VARCHAR(255) NOT NULL UNIQUE,
    payment_status ENUM('pending','success','failed','refunded') NOT NULL DEFAULT 'pending',
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_rest_pay_booking FOREIGN KEY (booking_id) REFERENCES restaurant_bookings(booking_id),
    CONSTRAINT fk_rest_pay_user FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE attraction_payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    user_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    payment_method ENUM('vnpay','momo','visa','mastercard','paypal','other') NOT NULL,
    transaction_id VARCHAR(255) NOT NULL UNIQUE,
    payment_status ENUM('pending','success','failed','refunded') NOT NULL DEFAULT 'pending',
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_attr_pay_booking FOREIGN KEY (booking_id) REFERENCES attraction_bookings(booking_id),
    CONSTRAINT fk_attr_pay_user FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tour_payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    user_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    payment_method ENUM('vnpay','momo','visa','mastercard','paypal','other') NOT NULL,
    transaction_id VARCHAR(255) NOT NULL UNIQUE,
    payment_status ENUM('pending','success','failed','refunded') NOT NULL DEFAULT 'pending',
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_tour_pay_booking FOREIGN KEY (booking_id) REFERENCES tour_bookings(booking_id),
    CONSTRAINT fk_tour_pay_user FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- 14) chat_messages
CREATE TABLE chat_messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    hotel_booking_id INT DEFAULT NULL,
    restaurant_booking_id INT DEFAULT NULL,
    attraction_booking_id INT DEFAULT NULL,
    tour_booking_id INT DEFAULT NULL,
    content TEXT NOT NULL,
    message_type ENUM('text','image','file','system') NOT NULL DEFAULT 'text',
    attachment_url VARCHAR(512) DEFAULT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_chat_sender FOREIGN KEY (sender_id) REFERENCES users(user_id),
    CONSTRAINT fk_chat_receiver FOREIGN KEY (receiver_id) REFERENCES users(user_id),
    CONSTRAINT fk_chat_hotel_booking FOREIGN KEY (hotel_booking_id) REFERENCES hotel_bookings(booking_id) ON DELETE SET NULL,
    CONSTRAINT fk_chat_rest_booking  FOREIGN KEY (restaurant_booking_id) REFERENCES restaurant_bookings(booking_id) ON DELETE SET NULL,
    CONSTRAINT fk_chat_attr_booking  FOREIGN KEY (attraction_booking_id) REFERENCES attraction_bookings(booking_id) ON DELETE SET NULL,
    CONSTRAINT fk_chat_tour_booking  FOREIGN KEY (tour_booking_id) REFERENCES tour_bookings(booking_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 15) reviews tách theo loại
CREATE TABLE hotel_reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    hotel_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(255) DEFAULT NULL,
    content TEXT NOT NULL,
    image_urls TEXT DEFAULT NULL,
    likes_count INT NOT NULL DEFAULT 0,
    reply_count INT NOT NULL DEFAULT 0,
    review_status ENUM('approved','rejected') NOT NULL DEFAULT 'approved',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_hotel_review_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_hotel_review_hotel FOREIGN KEY (hotel_id) REFERENCES hotels(hotel_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE restaurant_reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(255) DEFAULT NULL,
    content TEXT NOT NULL,
    image_urls TEXT DEFAULT NULL,
    likes_count INT NOT NULL DEFAULT 0,
    reply_count INT NOT NULL DEFAULT 0,
    review_status ENUM('approved','rejected') NOT NULL DEFAULT 'approved',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_rest_review_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_rest_review_rest FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tour_reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    tour_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(255) DEFAULT NULL,
    content TEXT NOT NULL,
    image_urls TEXT DEFAULT NULL,
    likes_count INT NOT NULL DEFAULT 0,
    reply_count INT NOT NULL DEFAULT 0,
    review_status ENUM('approved','rejected') NOT NULL DEFAULT 'approved',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_tour_review_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_tour_review_tour FOREIGN KEY (tour_id) REFERENCES tours(tour_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE attraction_reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    attraction_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(255) DEFAULT NULL,
    content TEXT NOT NULL,
    image_urls TEXT DEFAULT NULL,
    likes_count INT NOT NULL DEFAULT 0,
    reply_count INT NOT NULL DEFAULT 0,
    review_status ENUM('approved','rejected') NOT NULL DEFAULT 'approved',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_attr_review_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_attr_review_attr FOREIGN KEY (attraction_id) REFERENCES attractions(attraction_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 16) provider reviews
CREATE TABLE provider_reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    provider_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(255) DEFAULT NULL,
    content TEXT NOT NULL,
    image_urls TEXT DEFAULT NULL,
    likes_count INT NOT NULL DEFAULT 0,
    reply_count INT NOT NULL DEFAULT 0,
    review_status ENUM('approved','rejected') NOT NULL DEFAULT 'approved',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_provider_review_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_provider_review_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 17) review aspects per loại
CREATE TABLE hotel_review_aspects (
    review_id INT PRIMARY KEY,
    cleanliness TINYINT NOT NULL CHECK (cleanliness BETWEEN 1 AND 5),
    service TINYINT NOT NULL CHECK (service BETWEEN 1 AND 5),
    value_for_money TINYINT NOT NULL CHECK (value_for_money BETWEEN 1 AND 5),
    location TINYINT NOT NULL CHECK (location BETWEEN 1 AND 5),
    facilities TINYINT NOT NULL CHECK (facilities BETWEEN 1 AND 5),
    CONSTRAINT fk_hotel_aspects_review FOREIGN KEY (review_id) REFERENCES hotel_reviews(review_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE restaurant_review_aspects (
    review_id INT PRIMARY KEY,
    quality TINYINT NOT NULL CHECK (quality BETWEEN 1 AND 5),
    service TINYINT NOT NULL CHECK (service BETWEEN 1 AND 5),
    price TINYINT NOT NULL CHECK (price BETWEEN 1 AND 5),
    location TINYINT NOT NULL CHECK (location BETWEEN 1 AND 5),
    ambience TINYINT NOT NULL CHECK (ambience BETWEEN 1 AND 5),
    CONSTRAINT fk_rest_aspects_review FOREIGN KEY (review_id) REFERENCES restaurant_reviews(review_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tour_review_aspects (
    review_id INT PRIMARY KEY,
    guide_quality TINYINT NOT NULL CHECK (guide_quality BETWEEN 1 AND 5),
    itinerary_quality TINYINT NOT NULL CHECK (itinerary_quality BETWEEN 1 AND 5),
    value_for_money TINYINT NOT NULL CHECK (value_for_money BETWEEN 1 AND 5),
    organization TINYINT NOT NULL CHECK (organization BETWEEN 1 AND 5),
    safety TINYINT NOT NULL CHECK (safety BETWEEN 1 AND 5),
    CONSTRAINT fk_tour_aspects_review FOREIGN KEY (review_id) REFERENCES tour_reviews(review_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE attraction_review_aspects (
    review_id INT PRIMARY KEY,
    beauty TINYINT NOT NULL CHECK (beauty BETWEEN 1 AND 5),
    culture TINYINT NOT NULL CHECK (culture BETWEEN 1 AND 5),
    accessibility TINYINT NOT NULL CHECK (accessibility BETWEEN 1 AND 5),
    price TINYINT NOT NULL CHECK (price BETWEEN 1 AND 5),
    facilities TINYINT NOT NULL CHECK (facilities BETWEEN 1 AND 5),
    CONSTRAINT fk_attr_aspects_review FOREIGN KEY (review_id) REFERENCES attraction_reviews(review_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 18) review replies
CREATE TABLE review_replies (
    reply_id INT AUTO_INCREMENT PRIMARY KEY,
    review_type ENUM('hotel','restaurant','tour','attraction','provider') NOT NULL,
    review_id INT NOT NULL,
    replier_id INT NOT NULL,
    content TEXT NOT NULL,
    is_public BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_reply_replier FOREIGN KEY (replier_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 19) review likes
CREATE TABLE review_likes (
    like_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    review_type ENUM('hotel','restaurant','tour','attraction','provider') NOT NULL,
    review_id INT NOT NULL,
    reply_id INT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_review_like (user_id, review_type, review_id, reply_id),
    CONSTRAINT fk_review_like_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_review_like_reply FOREIGN KEY (reply_id) REFERENCES review_replies(reply_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 20) review reports
CREATE TABLE review_reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    review_type ENUM('hotel','restaurant','tour','attraction','provider') NOT NULL,
    review_id INT NOT NULL,
    reply_id INT DEFAULT NULL,
    report_reason ENUM('spam','inappropriate','false_information','harassment','other') NOT NULL,
    report_description TEXT,
    report_status ENUM('pending','reviewed','resolved','dismissed') NOT NULL DEFAULT 'pending',
    admin_notes TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_review_report_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_review_report_reply FOREIGN KEY (reply_id) REFERENCES review_replies(reply_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 21) rating summaries per loại
CREATE TABLE restaurant_rating_summaries (
    restaurant_id INT PRIMARY KEY,
    avg_rating DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    total_reviews INT NOT NULL DEFAULT 0,
    count_1 INT NOT NULL DEFAULT 0,
    count_2 INT NOT NULL DEFAULT 0,
    count_3 INT NOT NULL DEFAULT 0,
    count_4 INT NOT NULL DEFAULT 0,
    count_5 INT NOT NULL DEFAULT 0,
    avg_quality DECIMAL(3,2),
    avg_service DECIMAL(3,2),
    avg_price DECIMAL(3,2),
    avg_location DECIMAL(3,2),
    avg_ambience DECIMAL(3,2),
    CONSTRAINT fk_rest_rating FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE hotel_rating_summaries (
    hotel_id INT PRIMARY KEY,
    avg_rating DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    total_reviews INT NOT NULL DEFAULT 0,
    count_1 INT NOT NULL DEFAULT 0,
    count_2 INT NOT NULL DEFAULT 0,
    count_3 INT NOT NULL DEFAULT 0,
    count_4 INT NOT NULL DEFAULT 0,
    count_5 INT NOT NULL DEFAULT 0,
    avg_cleanliness DECIMAL(3,2),
    avg_service DECIMAL(3,2),
    avg_value_for_money DECIMAL(3,2),
    avg_location DECIMAL(3,2),
    avg_facilities DECIMAL(3,2),
    CONSTRAINT fk_hotel_rating FOREIGN KEY (hotel_id) REFERENCES hotels(hotel_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tour_rating_summaries (
    tour_id INT PRIMARY KEY,
    avg_rating DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    total_reviews INT NOT NULL DEFAULT 0,
    count_1 INT NOT NULL DEFAULT 0,
    count_2 INT NOT NULL DEFAULT 0,
    count_3 INT NOT NULL DEFAULT 0,
    count_4 INT NOT NULL DEFAULT 0,
    count_5 INT NOT NULL DEFAULT 0,
    avg_guide_quality DECIMAL(3,2),
    avg_itinerary_quality DECIMAL(3,2),
    avg_value_for_money DECIMAL(3,2),
    avg_organization DECIMAL(3,2),
    avg_safety DECIMAL(3,2),
    CONSTRAINT fk_tour_rating FOREIGN KEY (tour_id) REFERENCES tours(tour_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE attraction_rating_summaries (
    attraction_id INT PRIMARY KEY,
    avg_rating DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    total_reviews INT NOT NULL DEFAULT 0,
    count_1 INT NOT NULL DEFAULT 0,
    count_2 INT NOT NULL DEFAULT 0,
    count_3 INT NOT NULL DEFAULT 0,
    count_4 INT NOT NULL DEFAULT 0,
    count_5 INT NOT NULL DEFAULT 0,
    avg_beauty DECIMAL(3,2),
    avg_culture DECIMAL(3,2),
    avg_accessibility DECIMAL(3,2),
    avg_price DECIMAL(3,2),
    avg_facilities DECIMAL(3,2),
    CONSTRAINT fk_attr_rating FOREIGN KEY (attraction_id) REFERENCES attractions(attraction_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 25) blogs
CREATE TABLE blogs (
    blog_id INT AUTO_INCREMENT PRIMARY KEY,
    blogger_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    content LONGTEXT NOT NULL,
    cover_image_url VARCHAR(512) DEFAULT NULL,
    tags VARCHAR(255) DEFAULT NULL,
    views_count INT NOT NULL DEFAULT 0,
    likes_count INT NOT NULL DEFAULT 0,
    blog_status ENUM('published','archived') NOT NULL DEFAULT 'published',
    published_at DATETIME DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_blog_blogger FOREIGN KEY (blogger_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 26) follow
CREATE TABLE follow (
    follow_id INT AUTO_INCREMENT PRIMARY KEY,
    follower_id INT NOT NULL,
    followed_blogger_id INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_follow_follower FOREIGN KEY (follower_id) REFERENCES users(user_id),
    CONSTRAINT fk_follow_followed FOREIGN KEY (followed_blogger_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 27) itineraries_downloads
CREATE TABLE itineraries_downloads (
    itinerary_build_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    itineraries_download_name VARCHAR(255) NOT NULL,
    content_json LONGTEXT NOT NULL,
    share_link VARCHAR(512) DEFAULT NULL,
    pdf_export_url VARCHAR(512) DEFAULT NULL,
    ics_export_url VARCHAR(512) DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_itin_download_user FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 28) chatbot_logs
CREATE TABLE chatbot_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT DEFAULT NULL,
    session_id VARCHAR(255) NOT NULL,
    query_text TEXT NOT NULL,
    intent_detected VARCHAR(255) DEFAULT NULL,
    response_text TEXT NOT NULL,
    chatbot_log_language VARCHAR(10) DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_chatbot_user FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 29) currencies
CREATE TABLE currencies (
    currency_code CHAR(3) PRIMARY KEY,
    currency_name VARCHAR(100) NOT NULL,
    exchange_rate_to_base DECIMAL(18,6) NOT NULL,
    last_updated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 30) image_search_logs
CREATE TABLE image_search_logs (
    image_search_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT DEFAULT NULL,
    image_url VARCHAR(512) NOT NULL,
    result_json LONGTEXT DEFAULT NULL,
    similarity_score DECIMAL(4,2) DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_image_search_user FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 31) badges, user_badges
CREATE TABLE badges (
    badge_id INT AUTO_INCREMENT PRIMARY KEY,
    badge_name VARCHAR(255) NOT NULL,
    badge_description TEXT DEFAULT NULL,
    icon_url VARCHAR(512) DEFAULT NULL,
    criteria_json LONGTEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE user_badges (
    user_badge_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    badge_id INT NOT NULL,
    awarded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_visible BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_user_badge_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_user_badge_badge FOREIGN KEY (badge_id) REFERENCES badges(badge_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 32) points
CREATE TABLE points (
    point_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    points INT NOT NULL,
    reason VARCHAR(255) NOT NULL,
    related_id INT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_points_user FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 33) notifications
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    notification_type ENUM('in_app','email','push','sms') NOT NULL,
    category ENUM('booking_confirmation','price_alert','promo','system_alert','social') NOT NULL,
    title VARCHAR(255) DEFAULT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    read_at DATETIME DEFAULT NULL,
    sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 34) admin_actions (target_type cập nhật)
CREATE TABLE admin_actions (
    action_id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT NOT NULL,
    action_type VARCHAR(100) NOT NULL,
    target_type ENUM('user','provider','hotel','restaurant','attraction','tour','blog','booking','review','other') NOT NULL,
    target_id INT DEFAULT NULL,
    admin_action_description TEXT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_admin_actions_admin FOREIGN KEY (admin_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ====== 1. ALTER existing listing tables: add slug, seo, publish, is_featured, booking settings, visibility ======
ALTER TABLE tours
  ADD COLUMN slug VARCHAR(255) DEFAULT NULL,
  ADD COLUMN seo_title VARCHAR(255) DEFAULT NULL,
  ADD COLUMN seo_description VARCHAR(512) DEFAULT NULL,
  ADD COLUMN is_featured TINYINT(1) NOT NULL DEFAULT 0,
  ADD COLUMN booking_settings_json JSON DEFAULT NULL,
  ADD COLUMN published_at DATETIME DEFAULT NULL,
  ADD COLUMN visibility ENUM('public','private') NOT NULL DEFAULT 'public',
  ADD UNIQUE KEY uq_tours_slug (slug),
  ADD INDEX idx_tours_provider (provider_id),
  ADD INDEX idx_tours_status (tour_status);

ALTER TABLE restaurants
  ADD COLUMN slug VARCHAR(255) DEFAULT NULL,
  ADD COLUMN seo_title VARCHAR(255) DEFAULT NULL,
  ADD COLUMN seo_description VARCHAR(512) DEFAULT NULL,
  ADD COLUMN is_featured TINYINT(1) NOT NULL DEFAULT 0,
  ADD COLUMN booking_settings_json JSON DEFAULT NULL,
  ADD COLUMN published_at DATETIME DEFAULT NULL,
  ADD COLUMN visibility ENUM('public','private') NOT NULL DEFAULT 'public',
  ADD UNIQUE KEY uq_restaurants_slug (slug),
  ADD INDEX idx_restaurants_provider (provider_id),
  ADD INDEX idx_restaurants_status (restaurant_status);

ALTER TABLE attractions
  ADD COLUMN slug VARCHAR(255) DEFAULT NULL,
  ADD COLUMN seo_title VARCHAR(255) DEFAULT NULL,
  ADD COLUMN seo_description VARCHAR(512) DEFAULT NULL,
  ADD COLUMN is_featured TINYINT(1) NOT NULL DEFAULT 0,
  ADD COLUMN booking_settings_json JSON DEFAULT NULL,
  ADD COLUMN published_at DATETIME DEFAULT NULL,
  ADD COLUMN visibility ENUM('public','private') NOT NULL DEFAULT 'public',
  ADD UNIQUE KEY uq_attractions_slug (slug),
  ADD INDEX idx_attractions_provider (provider_id),
  ADD INDEX idx_attractions_status (attraction_status);


-- ====== 2. ALTER booking tables: add provider_id, channel, hold_until, provider_seen, provider_notes ======
-- provider_id duplicated for faster queries (denormalization); set NULLABLE for existing rows and backfill after.
ALTER TABLE hotel_bookings
  ADD COLUMN provider_id INT DEFAULT NULL,
  ADD COLUMN channel VARCHAR(100) DEFAULT NULL,
  ADD COLUMN hold_until DATETIME DEFAULT NULL,
  ADD COLUMN provider_seen TINYINT(1) NOT NULL DEFAULT 0,
  ADD COLUMN provider_notes TEXT DEFAULT NULL,
  ADD INDEX idx_hotel_bookings_provider (provider_id),
  ADD INDEX idx_hotel_bookings_status (booking_status),
  ADD CONSTRAINT fk_hotel_booking_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id) ON DELETE SET NULL;

ALTER TABLE restaurant_bookings
  ADD COLUMN provider_id INT DEFAULT NULL,
  ADD COLUMN channel VARCHAR(100) DEFAULT NULL,
  ADD COLUMN hold_until DATETIME DEFAULT NULL,
  ADD COLUMN provider_seen TINYINT(1) NOT NULL DEFAULT 0,
  ADD COLUMN provider_notes TEXT DEFAULT NULL,
  ADD INDEX idx_rest_bookings_provider (provider_id),
  ADD INDEX idx_rest_bookings_status (booking_status),
  ADD CONSTRAINT fk_rest_booking_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id) ON DELETE SET NULL;

ALTER TABLE attraction_bookings
  ADD COLUMN provider_id INT DEFAULT NULL,
  ADD COLUMN channel VARCHAR(100) DEFAULT NULL,
  ADD COLUMN hold_until DATETIME DEFAULT NULL,
  ADD COLUMN provider_seen TINYINT(1) NOT NULL DEFAULT 0,
  ADD COLUMN provider_notes TEXT DEFAULT NULL,
  ADD INDEX idx_attr_bookings_provider (provider_id),
  ADD INDEX idx_attr_bookings_status (booking_status),
  ADD CONSTRAINT fk_attr_booking_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id) ON DELETE SET NULL;

ALTER TABLE tour_bookings
  ADD COLUMN provider_id INT DEFAULT NULL,
  ADD COLUMN channel VARCHAR(100) DEFAULT NULL,
  ADD COLUMN hold_until DATETIME DEFAULT NULL,
  ADD COLUMN provider_seen TINYINT(1) NOT NULL DEFAULT 0,
  ADD COLUMN provider_notes TEXT DEFAULT NULL,
  ADD INDEX idx_tour_bookings_provider (provider_id),
  ADD INDEX idx_tour_bookings_status (booking_status),
  ADD CONSTRAINT fk_tour_booking_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id) ON DELETE SET NULL;


INSERT INTO areas (area_type, cover_image_url, name, ratings_count, short_description, slug) VALUES
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'An Giang', 78, 'Tỉnh ven sông, có nhiều di tích văn hoá và lễ hội.', 'an-giang'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Bà Rịa - Vũng Tàu', 130, 'Tỉnh biển với nhiều bãi tắm và khu du lịch nghỉ dưỡng.', 'ba-ria-vung-tau'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Bắc Kạn', 52, 'Tỉnh miền núi phía Bắc, nhiều cảnh quan thiên nhiên.', 'bac-kan'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Bắc Giang', 67, 'Tỉnh phía Bắc với các khu công nghiệp và danh lam.', 'bac-giang'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Bạc Liêu', 60, 'Tỉnh đồng bằng sông Cửu Long, nổi tiếng văn hoá đờn ca tài tử.', 'bac-lieu'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Bắc Ninh', 88, 'Vùng đất Kinh Bắc với nhiều di sản văn hoá truyền thống.', 'bac-ninh'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Bến Tre', 73, 'Tỉnh sông nước miền Tây, nổi tiếng dừa và du lịch miệt vườn.', 'ben-tre'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Bình Định', 85, 'Tỉnh miền Trung có nhiều di tích võ cổ truyền và bãi biển.', 'binh-dinh'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Bình Dương', 140, 'Trung tâm công nghiệp và đô thị đang phát triển nhanh.', 'binh-duong'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Bình Phước', 58, 'Tỉnh Đông Nam Bộ, nhiều vùng trồng cây công nghiệp.', 'binh-phuoc'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Bình Thuận', 92, 'Tỉnh ven biển, nổi tiếng Mũi Né và cảnh quan ven biển.', 'binh-thuan'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Cà Mau', 66, 'Mũi Cà Mau - điểm cực Nam của đất nước, nhiều hệ sinh thái ngập mặn.', 'ca-mau'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Cần Thơ', 95, 'Trung tâm đồng bằng sông Cửu Long, nổi tiếng với chợ nổi.', 'can-tho'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Cao Bằng', 55, 'Vùng núi phía Bắc với thác Bản Giốc và nhiều di tích lịch sử.', 'cao-bang'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Đà Nẵng', 150, 'Thành phố biển miền Trung, gần nhiều điểm du lịch nổi tiếng.', 'da-nang'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Đắk Lắk', 76, 'Tỉnh Tây Nguyên, nổi tiếng cà phê và văn hoá dân tộc.', 'dak-lak'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Đắk Nông', 54, 'Tỉnh Tây Nguyên với nhiều cảnh quan thiên nhiên hoang sơ.', 'dak-nong'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Điện Biên', 61, 'Tỉnh miền núi, nổi tiếng lịch sử Điện Biên Phủ.', 'dien-bien'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Đồng Nai', 125, 'Tỉnh có nhiều khu công nghiệp và khu du lịch sinh thái.', 'dong-nai'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Đồng Tháp', 70, 'Vùng đất sen hồng, nổi tiếng phong cảnh miền Tây.', 'dong-thap'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Gia Lai', 59, 'Tỉnh Tây Nguyên với cao nguyên và văn hoá bản địa.', 'gia-lai'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Hà Giang', 99, 'Vùng cao nguyên đá nổi tiếng với đèo Mã Pì Lèng và hoa tam giác mạch.', 'ha-giang'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Hà Nam', 48, 'Tỉnh đồng bằng Bắc Bộ, gần Hà Nội với nhiều di tích lịch sử.', 'ha-nam'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Hà Nội', 240, 'Thủ đô của Việt Nam với nhiều di tích lịch sử và văn hoá.', 'ha-noi'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Hà Tĩnh', 63, 'Tỉnh miền Trung với bờ biển dài và di tích lịch sử.', 'ha-tinh'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Hải Dương', 57, 'Vùng đồng bằng Bắc Bộ, nổi tiếng nông sản và chợ hoa.', 'hai-duong'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Hải Phòng', 110, 'Thành phố cảng miền Bắc, nổi tiếng với ẩm thực hải sản.', 'hai-phong'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Hậu Giang', 46, 'Tỉnh miền Tây với nhiều kênh rạch và nông nghiệp.', 'hau-giang'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Hòa Bình', 64, 'Tỉnh miền núi phía Bắc, nhiều hồ và cảnh quan thiên nhiên.', 'hoa-binh'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Hưng Yên', 49, 'Vùng đồng bằng Bắc Bộ, nổi tiếng vải thiều và làng nghề.', 'hung-yen'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Khánh Hòa', 138, 'Tỉnh biển với Nha Trang — trung tâm du lịch biển nổi tiếng.', 'khanh-hoa'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Kiên Giang', 105, 'Tỉnh ven biển và đảo, bao gồm Phú Quốc và nhiều bãi biển đẹp.', 'kien-giang'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Kon Tum', 44, 'Tỉnh Tây Nguyên, nhiều văn hoá dân tộc và cảnh quan núi rừng.', 'kon-tum'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Lai Châu', 41, 'Tỉnh miền núi phía Bắc, cảnh quan hoang sơ và đèo dốc.', 'lai-chau'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Lâm Đồng', 132, 'Tỉnh cao nguyên Lâm Viên, nổi tiếng Đà Lạt và cảnh quan ôn đới.', 'lam-dong'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Lạng Sơn', 47, 'Tỉnh biên giới phía Bắc, nhiều danh thắng và cửa khẩu thương mại.', 'lang-son'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Lào Cai', 90, 'Tỉnh miền núi, có Sa Pa và cảnh quan núi non hùng vĩ.', 'lao-cai'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Long An', 53, 'Tỉnh đồng bằng phát triển nông nghiệp và khu công nghiệp.', 'long-an'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Nam Định', 56, 'Vùng ven biển Bắc Bộ có nhiều di tích lịch sử và lễ hội.', 'nam-dinh'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Nghệ An', 115, 'Tỉnh rộng lớn miền Trung, quê hương nhiều danh nhân lịch sử.', 'nghe-an'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Ninh Bình', 127, 'Tỉnh có quần thể Tràng An, Bái Đính và nhiều cảnh quan kì vĩ.', 'ninh-binh'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Ninh Thuận', 50, 'Tỉnh ven biển miền Trung với nhiều vùng nắng gió và di sản Cham.', 'ninh-thuan'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Phú Thọ', 68, 'Đất Tổ Hùng Vương, có nhiều di tích lịch sử và lễ hội dân gian.', 'phu-tho'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Phú Yên', 74, 'Tỉnh ven biển miền Trung, nổi tiếng với Gành Đá Dĩa và bãi biển.', 'phu-yen'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Quảng Bình', 89, 'Nổi tiếng hang Sơn Đoòng và nhiều hang động lớn.', 'quang-binh'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Quảng Nam', 123, 'Có phố cổ Hội An và nhiều di tích văn hoá, bãi biển đẹp.', 'quang-nam'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Quảng Ngãi', 62, 'Tỉnh miền Trung với nhiều bãi biển và lịch sử hào hùng.', 'quang-ngai'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Quảng Ninh', 210, 'Nổi tiếng Vịnh Hạ Long — di sản thiên nhiên thế giới.', 'quang-ninh'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Quảng Trị', 43, 'Tỉnh miền Trung giàu lịch sử với nhiều di tích chiến tranh.', 'quang-tri'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Sóc Trăng', 51, 'Tỉnh miền Tây có nền văn hoá Khmer và lễ hội đặc sắc.', 'soc-trang'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Sơn La', 59, 'Tỉnh miền núi phía Bắc, nổi tiếng chè và nông sản vùng cao.', 'son-la'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Tây Ninh', 82, 'Tỉnh gần TP.HCM, có núi Bà Đen và điểm hành hương Cao Đài.', 'tay-ninh'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Thái Bình', 46, 'Vùng đồng bằng Bắc Bộ, nổi tiếng làng nghề và nông sản.', 'thai-binh'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Thái Nguyên', 71, 'Trung tâm vùng trung du miền núi phía Bắc, nổi tiếng chè.', 'thai-nguyen'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Thanh Hóa', 160, 'Tỉnh lớn miền Bắc có bờ biển dài và nhiều thắng cảnh.', 'thanh-hoa'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Thừa Thiên - Huế', 145, 'Cố đô Huế với kiến trúc cung đình và di sản văn hoá phong phú.', 'thua-thien-hue'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Tiền Giang', 69, 'Tỉnh miền Tây, cửa ngõ sông nước và du lịch miệt vườn.', 'tien-giang'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Trà Vinh', 47, 'Tỉnh miền Tây có nhiều di sản văn hoá Khmer.', 'tra-vinh'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Tuyên Quang', 42, 'Tỉnh miền núi phía Bắc với nhiều di tích lịch sử cách mạng.', 'tuyen-quang'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Vĩnh Long', 65, 'Tỉnh miền Tây sông nước, nổi tiếng chợ nổi và miệt vườn.', 'vinh-long'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Vĩnh Phúc', 77, 'Tỉnh gần Hà Nội, có khu công nghiệp và cảnh quan núi Tam Đảo.', 'vinh-phuc'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Yên Bái', 50, 'Tỉnh miền núi với ruộng bậc thang Mù Cang Chải và bản làng.', 'yen-bai'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Hồ Chí Minh', 220, 'Trung tâm kinh tế lớn nhất cả nước, sôi động về đêm.', 'ho-chi-minh');











