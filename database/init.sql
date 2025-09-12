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

-- 2) providers
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

-- 3) tours (gộp trường chung + chi tiết tour)
CREATE TABLE tours (
    tour_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_id INT NOT NULL,

    -- Trường chung (từ services)
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

    CONSTRAINT fk_tours_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4) hotels
CREATE TABLE hotels (
    hotel_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_id INT NOT NULL,

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

    CONSTRAINT fk_hotels_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5) restaurants
CREATE TABLE restaurants (
    restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_id INT NOT NULL,

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

    CONSTRAINT fk_restaurants_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6) attractions
CREATE TABLE attractions (
    attraction_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_id INT NOT NULL,

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

    CONSTRAINT fk_attractions_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7) price options per type
CREATE TABLE tour_price_options (
    option_id INT AUTO_INCREMENT PRIMARY KEY,
    tour_id INT NOT NULL,
    option_name VARCHAR(100) NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    per_person BOOLEAN NOT NULL DEFAULT TRUE,
    min_age SMALLINT DEFAULT NULL,
    max_age SMALLINT DEFAULT NULL,
    description VARCHAR(255) DEFAULT NULL,
    includes_json JSON DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_tour_option (tour_id, option_name),
    CONSTRAINT fk_tour_option_tour FOREIGN KEY (tour_id) REFERENCES tours(tour_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE hotel_price_options (
    option_id INT AUTO_INCREMENT PRIMARY KEY,
    hotel_id INT NOT NULL,
    option_name VARCHAR(100) NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    per_person BOOLEAN NOT NULL DEFAULT TRUE,
    min_age SMALLINT DEFAULT NULL,
    max_age SMALLINT DEFAULT NULL,
    description VARCHAR(255) DEFAULT NULL,
    includes_json JSON DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_hotel_option (hotel_id, option_name),
    CONSTRAINT fk_hotel_option_hotel FOREIGN KEY (hotel_id) REFERENCES hotels(hotel_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE restaurant_price_options (
    option_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT NOT NULL,
    option_name VARCHAR(100) NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    per_person BOOLEAN NOT NULL DEFAULT TRUE,
    min_age SMALLINT DEFAULT NULL,
    max_age SMALLINT DEFAULT NULL,
    description VARCHAR(255) DEFAULT NULL,
    includes_json JSON DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_restaurant_option (restaurant_id, option_name),
    CONSTRAINT fk_restaurant_option_rest FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE attraction_price_options (
    option_id INT AUTO_INCREMENT PRIMARY KEY,
    attraction_id INT NOT NULL,
    option_name VARCHAR(100) NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    per_person BOOLEAN NOT NULL DEFAULT TRUE,
    min_age SMALLINT DEFAULT NULL,
    max_age SMALLINT DEFAULT NULL,
    description VARCHAR(255) DEFAULT NULL,
    includes_json JSON DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_attraction_option (attraction_id, option_name),
    CONSTRAINT fk_attraction_option_attr FOREIGN KEY (attraction_id) REFERENCES attractions(attraction_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8) itineraries (tour only)
CREATE TABLE itineraries (
    itinerary_id INT AUTO_INCREMENT PRIMARY KEY,
    tour_id INT NOT NULL,
    day_number INT NOT NULL,
    itinerarie_date DATE DEFAULT NULL,
    itinerarie_time VARCHAR(50) DEFAULT NULL,
    activity_description TEXT NOT NULL,
    location VARCHAR(255) DEFAULT NULL,
    guide_id INT DEFAULT NULL,
    map_coordinates VARCHAR(100) DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_itin_tour FOREIGN KEY (tour_id) REFERENCES tours(tour_id),
    CONSTRAINT fk_itin_guide FOREIGN KEY (guide_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 9) group bookings (tour only) + members
CREATE TABLE tour_group_bookings (
    group_id INT AUTO_INCREMENT PRIMARY KEY,
    leader_id INT NOT NULL,
    tour_id INT NOT NULL,
    group_name VARCHAR(255) DEFAULT NULL,
    max_participants INT DEFAULT NULL,
    group_booking_status ENUM('open','closed','cancelled') NOT NULL DEFAULT 'open',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_tour_group_leader FOREIGN KEY (leader_id) REFERENCES users(user_id),
    CONSTRAINT fk_tour_group_tour FOREIGN KEY (tour_id) REFERENCES tours(tour_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE group_members (
    group_member_id INT AUTO_INCREMENT PRIMARY KEY,
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    is_leader BOOLEAN NOT NULL DEFAULT FALSE,
    share_amount DECIMAL(12,2) DEFAULT NULL,
    payment_status ENUM('pending','paid','refunded') NOT NULL DEFAULT 'pending',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_group_member_group FOREIGN KEY (group_id) REFERENCES tour_group_bookings(group_id),
    CONSTRAINT fk_group_member_user FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 10) bookings per type
CREATE TABLE hotel_bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    hotel_id INT NOT NULL,
    booking_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL,
    num_adults INT NOT NULL DEFAULT 1,
    num_children INT NOT NULL DEFAULT 0,
    total_price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    booking_status ENUM('pending','confirmed','cancelled','completed','refunded') NOT NULL DEFAULT 'pending',
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
    num_children INT NOT NULL DEFAULT 0,
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
    num_children INT NOT NULL DEFAULT 0,
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
    group_id INT DEFAULT NULL,
    booking_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL,
    num_adults INT NOT NULL DEFAULT 1,
    num_children INT NOT NULL DEFAULT 0,
    total_price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    booking_status ENUM('pending','confirmed','cancelled','completed','refunded') NOT NULL DEFAULT 'pending',
    e_ticket_url VARCHAR(512) DEFAULT NULL,
    qr_code_data TEXT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_tour_booking_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_tour_booking_tour FOREIGN KEY (tour_id) REFERENCES tours(tour_id),
    CONSTRAINT fk_tour_booking_group FOREIGN KEY (group_id) REFERENCES tour_group_bookings(group_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 11) payments per type (tránh CHECK + đa FK)
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

-- 12) e_tickets per type
CREATE TABLE hotel_e_tickets (
    e_ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    ticket_code VARCHAR(100) NOT NULL UNIQUE,
    qr_code_data TEXT NOT NULL,
    pdf_url VARCHAR(512) NOT NULL,
    valid_from DATE DEFAULT NULL,
    valid_until DATE DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_hotel_ticket_booking FOREIGN KEY (booking_id) REFERENCES hotel_bookings(booking_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE restaurant_e_tickets (
    e_ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    ticket_code VARCHAR(100) NOT NULL UNIQUE,
    qr_code_data TEXT NOT NULL,
    pdf_url VARCHAR(512) NOT NULL,
    valid_from DATE DEFAULT NULL,
    valid_until DATE DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rest_ticket_booking FOREIGN KEY (booking_id) REFERENCES restaurant_bookings(booking_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE attraction_e_tickets (
    e_ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    ticket_code VARCHAR(100) NOT NULL UNIQUE,
    qr_code_data TEXT NOT NULL,
    pdf_url VARCHAR(512) NOT NULL,
    valid_from DATE DEFAULT NULL,
    valid_until DATE DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_attr_ticket_booking FOREIGN KEY (booking_id) REFERENCES attraction_bookings(booking_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tour_e_tickets (
    e_ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    ticket_code VARCHAR(100) NOT NULL UNIQUE,
    qr_code_data TEXT NOT NULL,
    pdf_url VARCHAR(512) NOT NULL,
    valid_from DATE DEFAULT NULL,
    valid_until DATE DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tour_ticket_booking FOREIGN KEY (booking_id) REFERENCES tour_bookings(booking_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 13) chat_messages (optional liên kết booking theo loại, KHÔNG dùng CHECK)
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

-- 14) reviews tách theo loại
CREATE TABLE hotel_reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    hotel_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(255) DEFAULT NULL,
    content TEXT NOT NULL,
    image_urls TEXT DEFAULT NULL,
    likes_count INT NOT NULL DEFAULT 0,
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
    review_status ENUM('approved','rejected') NOT NULL DEFAULT 'approved',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_attr_review_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_attr_review_attr FOREIGN KEY (attraction_id) REFERENCES attractions(attraction_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 15) review aspects per loại (CASCADE)
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

-- 16) provider reviews (bổ sung từ schema cũ có provider_id)
CREATE TABLE provider_reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    provider_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(255) DEFAULT NULL,
    content TEXT NOT NULL,
    image_urls TEXT DEFAULT NULL,
    likes_count INT NOT NULL DEFAULT 0,
    review_status ENUM('approved','rejected') NOT NULL DEFAULT 'approved',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_provider_review_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_provider_review_provider FOREIGN KEY (provider_id) REFERENCES providers(provider_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE provider_rating_summaries (
    provider_id INT PRIMARY KEY,
    avg_rating DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    total_reviews INT NOT NULL DEFAULT 0,
    count_1 INT NOT NULL DEFAULT 0,
    count_2 INT NOT NULL DEFAULT 0,
    count_3 INT NOT NULL DEFAULT 0,
    count_4 INT NOT NULL DEFAULT 0,
    count_5 INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_provider_rating FOREIGN KEY (provider_id) REFERENCES providers(provider_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 17) rating summaries per loại
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

-- 18) virtual tours per type
CREATE TABLE hotel_virtual_tours (
    virtual_tour_id INT AUTO_INCREMENT PRIMARY KEY,
    hotel_id INT NOT NULL,
    media_type ENUM('360_image','360_video','ar_model') NOT NULL,
    media_url VARCHAR(512) NOT NULL,
    thumbnail_url VARCHAR(512) DEFAULT NULL,
    metadata_json LONGTEXT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_hotel_virtual FOREIGN KEY (hotel_id) REFERENCES hotels(hotel_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE restaurant_virtual_tours (
    virtual_tour_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT NOT NULL,
    media_type ENUM('360_image','360_video','ar_model') NOT NULL,
    media_url VARCHAR(512) NOT NULL,
    thumbnail_url VARCHAR(512) DEFAULT NULL,
    metadata_json LONGTEXT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_rest_virtual FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE attraction_virtual_tours (
    virtual_tour_id INT AUTO_INCREMENT PRIMARY KEY,
    attraction_id INT NOT NULL,
    media_type ENUM('360_image','360_video','ar_model') NOT NULL,
    media_url VARCHAR(512) NOT NULL,
    thumbnail_url VARCHAR(512) DEFAULT NULL,
    metadata_json LONGTEXT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_attr_virtual FOREIGN KEY (attraction_id) REFERENCES attractions(attraction_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tour_virtual_tours (
    virtual_tour_id INT AUTO_INCREMENT PRIMARY KEY,
    tour_id INT NOT NULL,
    media_type ENUM('360_image','360_video','ar_model') NOT NULL,
    media_url VARCHAR(512) NOT NULL,
    thumbnail_url VARCHAR(512) DEFAULT NULL,
    metadata_json LONGTEXT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_tour_virtual FOREIGN KEY (tour_id) REFERENCES tours(tour_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 19) price predictions per type
CREATE TABLE hotel_price_predictions (
    prediction_id INT AUTO_INCREMENT PRIMARY KEY,
    hotel_id INT NOT NULL,
    predicted_date DATE NOT NULL,
    predicted_price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    model_name VARCHAR(100) DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_hotel_pred FOREIGN KEY (hotel_id) REFERENCES hotels(hotel_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE restaurant_price_predictions (
    prediction_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT NOT NULL,
    predicted_date DATE NOT NULL,
    predicted_price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    model_name VARCHAR(100) DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rest_pred FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE attraction_price_predictions (
    prediction_id INT AUTO_INCREMENT PRIMARY KEY,
    attraction_id INT NOT NULL,
    predicted_date DATE NOT NULL,
    predicted_price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    model_name VARCHAR(100) DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_attr_pred FOREIGN KEY (attraction_id) REFERENCES attractions(attraction_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tour_price_predictions (
    prediction_id INT AUTO_INCREMENT PRIMARY KEY,
    tour_id INT NOT NULL,
    predicted_date DATE NOT NULL,
    predicted_price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    model_name VARCHAR(100) DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tour_pred FOREIGN KEY (tour_id) REFERENCES tours(tour_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 20) price alerts per type
CREATE TABLE hotel_price_alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    hotel_id INT NOT NULL,
    target_price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_notified_at DATETIME DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_hotel_alert_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_hotel_alert_hotel FOREIGN KEY (hotel_id) REFERENCES hotels(hotel_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE restaurant_price_alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    target_price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_notified_at DATETIME DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_rest_alert_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_rest_alert_rest FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE attraction_price_alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    attraction_id INT NOT NULL,
    target_price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_notified_at DATETIME DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_attr_alert_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_attr_alert_attr FOREIGN KEY (attraction_id) REFERENCES attractions(attraction_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tour_price_alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    tour_id INT NOT NULL,
    target_price DECIMAL(12,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_notified_at DATETIME DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_tour_alert_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_tour_alert_tour FOREIGN KEY (tour_id) REFERENCES tours(tour_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 21) blogs
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

-- 22) follow
CREATE TABLE follow (
    follow_id INT AUTO_INCREMENT PRIMARY KEY,
    follower_id INT NOT NULL,
    followed_blogger_id INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_follow_follower FOREIGN KEY (follower_id) REFERENCES users(user_id),
    CONSTRAINT fk_follow_followed FOREIGN KEY (followed_blogger_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 23) itineraries_downloads
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

-- 24) chatbot_logs
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

-- 25) currencies
CREATE TABLE currencies (
    currency_code CHAR(3) PRIMARY KEY,
    currency_name VARCHAR(100) NOT NULL,
    exchange_rate_to_base DECIMAL(18,6) NOT NULL,
    last_updated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 26) image_search_logs
CREATE TABLE image_search_logs (
    image_search_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT DEFAULT NULL,
    image_url VARCHAR(512) NOT NULL,
    result_json LONGTEXT DEFAULT NULL,
    similarity_score DECIMAL(4,2) DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_image_search_user FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 27) badges, user_badges
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

-- 28) points
CREATE TABLE points (
    point_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    points INT NOT NULL,
    reason VARCHAR(255) NOT NULL,
    related_id INT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_points_user FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 29) notifications
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

-- 30) admin_actions (target_type cập nhật)
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