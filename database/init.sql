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
    CONSTRAINT fk_hotels_area FOREIGN KEY (area_id) REFERENCES areas(area_id)
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

-- 8) price options per type
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

-- 9) itineraries (tour only)
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

-- 10) group bookings (tour only) + members
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

-- 11) bookings per type
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

-- 13) e_tickets per type
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

-- 22) virtual tours per type
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

-- 23) price predictions per type
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

-- 24) price alerts per type
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

INSERT INTO users (email, password_hash, full_name, phone_number, avatar_url, account_role, account_status, date_of_birth, gender, reset_otp, otp_expiry_time) VALUES 
('congnt.21kit.fpt.vku@gmail.com', 'cong12', 'cong nguyen', NULL, NULL, 'provider', 'active', NULL, NULL, NULL, NULL);


INSERT INTO providers (user_id, company_name, tax_code, address, contact_email, contact_phone, bank_account_number, bank_name, logo_url, provider_description, rating_overall, provider_status) VALUES 
(1, 'Cong Travel Co., Ltd', '0123456789', '123 Nguyen Trai, Da Nang', 'biz@congtravel.vn', '0912345678', '1234567890', 'Vietcombank', 'https://example.com/logo.png', 'Nhà cung cấp tour chuyên nghiệp', 0.0, 'pending');


INSERT INTO areas (area_type, cover_image_url, name, ratings_count, short_description, slug) VALUES
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Hà Nội', 240, 'Thủ đô của Việt Nam với nhiều di tích lịch sử và văn hoá.', 'ha-noi'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Hồ Chí Minh', 220, 'Trung tâm kinh tế lớn nhất cả nước, sôi động về đêm.', 'ho-chi-minh'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Hải Phòng', 110, 'Thành phố cảng miền Bắc, nổi tiếng với ẩm thực hải sản.', 'hai-phong'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Đà Nẵng', 150, 'Thành phố biển miền Trung, gần nhiều điểm du lịch nổi tiếng.', 'da-nang'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Cần Thơ', 95, 'Trung tâm đồng bằng sông Cửu Long, nổi tiếng với chợ nổi.', 'can-tho'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'An Giang', 78, 'Tỉnh ven sông, có nhiều di tích văn hoá và lễ hội.', 'an-giang'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Bà Rịa - Vũng Tàu', 130, 'Tỉnh biển với nhiều bãi tắm và khu du lịch nghỉ dưỡng.', 'ba-ria-vung-tau'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Bắc Giang', 67, 'Tỉnh phía Bắc với các khu công nghiệp và danh lam.', 'bac-giang'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Bắc Kạn', 52, 'Tỉnh miền núi phía Bắc, nhiều cảnh quan thiên nhiên.', 'bac-kan'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Bạc Liêu', 60, 'Tỉnh đồng bằng sông Cửu Long, nổi tiếng văn hoá đờn ca tài tử.', 'bac-lieu'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Bắc Ninh', 88, 'Vùng đất Kinh Bắc với nhiều di sản văn hoá truyền thống.', 'bac-ninh'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Bến Tre', 73, 'Tỉnh sông nước miền Tây, nổi tiếng dừa và du lịch miệt vườn.', 'ben-tre'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Bình Định', 85, 'Tỉnh miền Trung có nhiều di tích võ cổ truyền và bãi biển.', 'binh-dinh'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Bình Dương', 140, 'Trung tâm công nghiệp và đô thị đang phát triển nhanh.', 'binh-duong'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Bình Phước', 58, 'Tỉnh Đông Nam Bộ, nhiều vùng trồng cây công nghiệp.', 'binh-phuoc'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Bình Thuận', 92, 'Tỉnh ven biển, nổi tiếng Mũi Né và cảnh quan sa mạc ven biển.', 'binh-thuan'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Cà Mau', 66, 'Mũi Cà Mau - điểm cực Nam của đất nước, nhiều hệ sinh thái ngập mặn.', 'ca-mau'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Cao Bằng', 55, 'Vùng núi phía Bắc với thác Bản Giốc và nhiều di tích lịch sử.', 'cao-bang'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Đắk Lắk', 76, 'Tỉnh Tây Nguyên, nổi tiếng cà phê và văn hoá dân tộc.', 'dak-lak'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Đắk Nông', 54, 'Tỉnh Tây Nguyên với nhiều cảnh quan thiên nhiên hoang sơ.', 'dak-nong'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Điện Biên', 61, 'Tỉnh miền núi, nổi tiếng lịch sử Điện Biên Phủ.', 'dien-bien'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Đồng Nai', 125, 'Tỉnh có nhiều khu công nghiệp và khu du lịch sinh thái.', 'dong-nai'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Đồng Tháp', 70, 'Vùng đất sen hồng, nổi tiếng phong cảnh miền Tây.', 'dong-thap'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Gia Lai', 59, 'Tỉnh Tây Nguyên với cao nguyên, cà phê và văn hoá bản địa.', 'gia-lai'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Hà Giang', 99, 'Vùng cao nguyên đá nổi tiếng với đèo Mã Pì Lèng và hoa tam giác mạch.', 'ha-giang'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Hà Nam', 48, 'Tỉnh đồng bằng Bắc Bộ, gần Hà Nội với nhiều di tích lịch sử.', 'ha-nam'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Hà Tĩnh', 63, 'Tỉnh miền Trung với bờ biển dài và di tích lịch sử.', 'ha-tinh'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Hải Dương', 57, 'Vùng đồng bằng Bắc Bộ, nổi tiếng nông sản và chợ hoa.', 'hai-duong'),
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
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Long An', 53, 'Tỉnh đồng bằng sông Cửu Long mở rộng, phát triển nông nghiệp.', 'long-an'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Nam Định', 56, 'Vùng ven biển Bắc Bộ, có nhiều di tích lịch sử và lễ hội.', 'nam-dinh'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Nghệ An', 115, 'Tỉnh rộng lớn miền Trung, quê hương nhiều danh nhân lịch sử.', 'nghe-an'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Ninh Bình', 127, 'Tỉnh có quần thể Tràng An, Bái Đính và nhiều cảnh quan kì vĩ.', 'ninh-binh'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Ninh Thuận', 50, 'Tỉnh ven biển miền Trung với nhiều vùng nắng gió và di sản Cham.', 'ninh-thuan'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Phú Thọ', 68, 'Đất Tổ Hùng Vương, có nhiều di tích lịch sử và lễ hội dân gian.', 'phu-tho'),
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Phú Yên', 74, 'Tỉnh ven biển miền Trung, nổi tiếng với bãi Rạn Yến và Gành Đá Dĩa.', 'phu-yen'),
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
('province', 'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg', 'Yên Bái', 50, 'Tỉnh miền núi với ruộng bậc thang Mù Cang Chải và bản làng.', 'yen-bai');

INSERT INTO restaurants (provider_id,area_id,title,service_description,location,start_date,end_date,price,currency_code,capacity,min_participants,max_participants,thumbnail_url,image_urls,rating_average,badges,restaurant_status,price_level,phone,website,address,cuisines_json,services_json,diets_json,opening_hours_json) VALUES
(1,1,'Nhà hàng Đặc sản Hà Nội','Ẩm thực truyền thống Hà Nội, không gian ấm cúng.','Hà Nội, Việt Nam','2025-09-15','2025-12-31',220000.00,'VND',80,1,50,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/ha-noi-1.jpg","https://cdn.example.com/restaurants/ha-noi-2.jpg"]',4.4,'["local-favorite"]','published','moderate','+84-24-123-0001','https://hannong.example.com','123 Hàng Bạc, Hoàn Kiếm, Hà Nội','["Vietnamese"]','["dine_in","takeaway","wifi"]','["vegan","gluten_free"]','{"mon":[{"open":"09:00","close":"21:00"}],"tue":[{"open":"09:00","close":"21:00"}],"wed":[{"open":"09:00","close":"21:00"}],"thu":[{"open":"09:00","close":"21:00"}],"fri":[{"open":"09:00","close":"22:00"}],"sat":[{"open":"09:00","close":"22:00"}],"sun":[{"open":"09:00","close":"21:00"}]}'),
(1,2,'Nhà hàng Đặc sản Hồ Chí Minh','Ẩm thực Sài Gòn phong phú, phục vụ chuyên nghiệp.','Hồ Chí Minh, Việt Nam','2025-09-15','2025-12-31',230000.00,'VND',100,1,60,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/ho-chi-minh-1.jpg"]',4.5,'["local-favorite"]','published','moderate','+84-28-123-0002','https://hcm.example.com','123 Nguyễn Huệ, Quận 1, TP. HCM','["Vietnamese","Asian"]','["dine_in","delivery","wifi"]','["vegan"]','{"mon":[{"open":"09:00","close":"22:00"}],"tue":[{"open":"09:00","close":"22:00"}],"wed":[{"open":"09:00","close":"22:00"}],"thu":[{"open":"09:00","close":"22:00"}],"fri":[{"open":"09:00","close":"23:00"}],"sat":[{"open":"09:00","close":"23:00"}],"sun":[{"open":"09:00","close":"21:00"}]}'),
(1,3,'Nhà hàng Đặc sản Hải Phòng','Hải sản tươi, món ngon địa phương.','Hải Phòng, Việt Nam','2025-09-15','2025-12-31',210000.00,'VND',80,1,50,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/hai-phong-1.jpg"]',4.3,'["sea-view"]','published','moderate','+84-225-123-0003','https://haiphong.example.com','123 Lạch Tray, Hải Phòng','["Seafood","Vietnamese"]','["dine_in","takeaway"]','["gluten_free"]','{"mon":[{"open":"09:00","close":"21:00"}],"tue":[{"open":"09:00","close":"21:00"}],"wed":[{"open":"09:00","close":"21:00"}],"thu":[{"open":"09:00","close":"21:00"}],"fri":[{"open":"09:00","close":"22:00"}],"sat":[{"open":"09:00","close":"22:00"}],"sun":[{"open":"09:00","close":"21:00"}]}'),
(1,4,'Nhà hàng Biển Xanh Xanh 222','Hải sản tươi sống, view biển, phục vụ chuyên nghiệp.','Đà Nẵng, Việt Nam','2025-09-15','2025-12-31',350000.00,'VND',120,1,20,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/blue-sea-1.jpg","https://cdn.example.com/restaurants/blue-sea-2.jpg"]',4.5,'["family-friendly","sea-view"]','published','moderate','+84-236-123-4567','https://bluesea.example.com','123 Võ Nguyên Giáp, Sơn Trà, Đà Nẵng','["Vietnamese","Seafood"]','["delivery","takeaway","parking","wifi"]','["vegan","gluten_free"]','{"mon":[{"open":"09:00","close":"21:00"}],"tue":[{"open":"09:00","close":"21:00"}],"wed":[{"open":"09:00","close":"21:00"}],"thu":[{"open":"09:00","close":"21:00"}],"fri":[{"open":"09:00","close":"22:00"}],"sat":[{"open":"09:00","close":"22:00"}],"sun":[{"open":"09:00","close":"21:00"}]}'),
(1,5,'Nhà hàng Đặc sản Cần Thơ','Ẩm thực miền Tây, tươi ngon và đậm đà.','Cần Thơ, Việt Nam','2025-09-15','2025-12-31',190000.00,'VND',90,1,50,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/can-tho-1.jpg"]',4.2,'["local-favorite"]','published','moderate','+84-292-123-0005','https://cantho.example.com','123 Lê Lợi, Ninh Kiều, Cần Thơ','["Vietnamese","Seafood"]','["dine_in","delivery"]','["vegan"]','{"mon":[{"open":"09:00","close":"21:00"}],"tue":[{"open":"09:00","close":"21:00"}],"wed":[{"open":"09:00","close":"21:00"}],"thu":[{"open":"09:00","close":"21:00"}],"fri":[{"open":"09:00","close":"22:00"}],"sat":[{"open":"09:00","close":"22:00"}],"sun":[{"open":"09:00","close":"21:00"}]}'),
(1,6,'Nhà hàng Đặc sản An Giang','Ẩm thực đồng bằng, món đặc trưng vùng sông nước.','An Giang, Việt Nam','2025-09-15','2025-12-31',170000.00,'VND',70,1,40,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/an-giang-1.jpg"]',4.1,'["local-favorite"]','published','moderate','+84-296-123-0006','https://angiang.example.com','123 Cách Mạng, Châu Đốc, An Giang','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"20:00"}],"tue":[{"open":"09:00","close":"20:00"}],"wed":[{"open":"09:00","close":"20:00"}],"thu":[{"open":"09:00","close":"20:00"}],"fri":[{"open":"09:00","close":"21:00"}],"sat":[{"open":"09:00","close":"21:00"}],"sun":[{"open":"09:00","close":"20:00"}]}'),
(1,7,'Nhà hàng Đặc sản Bà Rịa - Vũng Tàu','Hải sản và đặc sản biển, view biển đẹp.','Bà Rịa - Vũng Tàu, Việt Nam','2025-09-15','2025-12-31',240000.00,'VND',90,1,50,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/ba-ria-vung-tau-1.jpg"]',4.4,'["sea-view"]','published','moderate','+84-254-123-0007','https://vungtau.example.com','123 Trần Phú, Vũng Tàu','["Seafood","Vietnamese"]','["dine_in","parking"]','["gluten_free"]','{"mon":[{"open":"09:00","close":"21:00"}],"tue":[{"open":"09:00","close":"21:00"}],"wed":[{"open":"09:00","close":"21:00"}],"thu":[{"open":"09:00","close":"21:00"}],"fri":[{"open":"09:00","close":"22:00"}],"sat":[{"open":"09:00","close":"22:00"}],"sun":[{"open":"09:00","close":"21:00"}]}'),
(1,8,'Nhà hàng Đặc sản Bắc Giang','Ẩm thực địa phương Bắc Giang, phục vụ gia đình.','Bắc Giang, Việt Nam','2025-09-15','2025-12-31',160000.00,'VND',70,1,40,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/bac-giang-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-240-123-0008','https://bacgiang.example.com','123 Nguyễn Văn Cừ, Bắc Giang','["Vietnamese"]','["dine_in","takeaway"]','["vegan"]','{"mon":[{"open":"09:00","close":"20:00"}],"tue":[{"open":"09:00","close":"20:00"}],"wed":[{"open":"09:00","close":"20:00"}],"thu":[{"open":"09:00","close":"20:00"}],"fri":[{"open":"09:00","close":"21:00"}],"sat":[{"open":"09:00","close":"21:00"}],"sun":[{"open":"09:00","close":"20:00"}]}'),
(1,9,'Nhà hàng Đặc sản Bắc Kạn','Ẩm thực núi rừng, phong cách dân tộc.','Bắc Kạn, Việt Nam','2025-09-15','2025-12-31',150000.00,'VND',60,1,30,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/bac-kan-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-209-123-0009','https://backan.example.com','123 Trung Tâm, Bắc Kạn','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"19:00"}],"tue":[{"open":"09:00","close":"19:00"}],"wed":[{"open":"09:00","close":"19:00"}],"thu":[{"open":"09:00","close":"19:00"}],"fri":[{"open":"09:00","close":"20:00"}],"sat":[{"open":"09:00","close":"20:00"}],"sun":[{"open":"09:00","close":"19:00"}]}'),
(1,10,'Nhà hàng Đặc sản Bạc Liêu','Ẩm thực miền Tây, hải sản và đờn ca tài tử.','Bạc Liêu, Việt Nam','2025-09-15','2025-12-31',170000.00,'VND',70,1,40,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/bac-lieu-1.jpg"]',4.1,'["local-favorite"]','published','moderate','+84-291-123-0010','https://baclieu.example.com','123 Điện Biên Phủ, Bạc Liêu','["Vietnamese","Seafood"]','["dine_in","takeaway"]','["vegan"]','{"mon":[{"open":"09:00","close":"21:00"}],"tue":[{"open":"09:00","close":"21:00"}],"wed":[{"open":"09:00","close":"21:00"}],"thu":[{"open":"09:00","close":"21:00"}],"fri":[{"open":"09:00","close":"22:00"}],"sat":[{"open":"09:00","close":"22:00"}],"sun":[{"open":"09:00","close":"21:00"}]}'),
(1,11,'Nhà hàng Đặc sản Bắc Ninh','Ẩm thực Kinh Bắc truyền thống.','Bắc Ninh, Việt Nam','2025-09-15','2025-12-31',180000.00,'VND',75,1,45,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/bac-ninh-1.jpg"]',4.2,'["local-favorite"]','published','moderate','+84-222-123-0011','https://bacninh.example.com','123 Lý Thái Tổ, Bắc Ninh','["Vietnamese"]','["dine_in","takeaway"]','["vegan"]','{"mon":[{"open":"09:00","close":"20:00"}],"tue":[{"open":"09:00","close":"20:00"}],"wed":[{"open":"09:00","close":"20:00"}],"thu":[{"open":"09:00","close":"20:00"}],"fri":[{"open":"09:00","close":"21:00"}],"sat":[{"open":"09:00","close":"21:00"}],"sun":[{"open":"09:00","close":"20:00"}]}'),
(1,12,'Nhà hàng Đặc sản Bến Tre','Ẩm thực miền Tây, đặc sản dừa.','Bến Tre, Việt Nam','2025-09-15','2025-12-31',160000.00,'VND',70,1,40,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/ben-tre-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-275-123-0012','https://bentre.example.com','123 Nguyễn Đình Chiểu, Bến Tre','["Vietnamese"]','["dine_in","delivery"]','["vegan"]','{"mon":[{"open":"09:00","close":"20:00"}],"tue":[{"open":"09:00","close":"20:00"}],"wed":[{"open":"09:00","close":"20:00"}],"thu":[{"open":"09:00","close":"20:00"}],"fri":[{"open":"09:00","close":"21:00"}],"sat":[{"open":"09:00","close":"21:00"}],"sun":[{"open":"09:00","close":"20:00"}]}'),
(1,13,'Nhà hàng Đặc sản Bình Định','Ẩm thực miền Trung, bánh hỏi, nem chợ Huyện.','Bình Định, Việt Nam','2025-09-15','2025-12-31',200000.00,'VND',80,1,50,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/binh-dinh-1.jpg"]',4.3,'["local-favorite"]','published','moderate','+84-256-123-0013','https://binhdinh.example.com','123 Trần Hưng Đạo, Quy Nhơn','["Vietnamese","Seafood"]','["dine_in","takeaway"]','["gluten_free"]','{"mon":[{"open":"09:00","close":"21:00"}],"tue":[{"open":"09:00","close":"21:00"}],"wed":[{"open":"09:00","close":"21:00"}],"thu":[{"open":"09:00","close":"21:00"}],"fri":[{"open":"09:00","close":"22:00"}],"sat":[{"open":"09:00","close":"22:00"}],"sun":[{"open":"09:00","close":"21:00"}]}'),
(1,14,'Nhà hàng Đặc sản Bình Dương','Ẩm thực công nghiệp, phục vụ nhanh.','Bình Dương, Việt Nam','2025-09-15','2025-12-31',180000.00,'VND',90,1,50,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/binh-duong-1.jpg"]',4.1,'["local-favorite"]','published','moderate','+84-274-123-0014','https://binhduong.example.com','123 Đại lộ Bình Dương, Thủ Dầu Một','["Vietnamese"]','["dine_in","delivery"]','["vegan"]','{"mon":[{"open":"09:00","close":"21:00"}],"tue":[{"open":"09:00","close":"21:00"}],"wed":[{"open":"09:00","close":"21:00"}],"thu":[{"open":"09:00","close":"21:00"}],"fri":[{"open":"09:00","close":"22:00"}],"sat":[{"open":"09:00","close":"22:00"}],"sun":[{"open":"09:00","close":"21:00"}]}'),
(1,15,'Nhà hàng Đặc sản Bình Phước','Ẩm thực Đông Nam Bộ, món ăn địa phương.','Bình Phước, Việt Nam','2025-09-15','2025-12-31',150000.00,'VND',60,1,40,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/binh-phuoc-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-271-123-0015','https://binhphuoc.example.com','123 Nguyễn Huệ, Bình Phước','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"19:00"}],"tue":[{"open":"09:00","close":"19:00"}],"wed":[{"open":"09:00","close":"19:00"}],"thu":[{"open":"09:00","close":"19:00"}],"fri":[{"open":"09:00","close":"20:00"}],"sat":[{"open":"09:00","close":"20:00"}],"sun":[{"open":"09:00","close":"19:00"}]}'),
(1,16,'Nhà hàng Đặc sản Bình Thuận','Hải sản Mũi Né, phong cách resort.','Bình Thuận, Việt Nam','2025-09-15','2025-12-31',210000.00,'VND',80,1,50,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/binh-thuan-1.jpg"]',4.2,'["sea-view"]','published','moderate','+84-252-123-0016','https://binhthuan.example.com','123 Võ Thị Sáu, Phan Thiết','["Seafood","Vietnamese"]','["dine_in","parking"]','["gluten_free"]','{"mon":[{"open":"09:00","close":"21:00"}],"tue":[{"open":"09:00","close":"21:00"}],"wed":[{"open":"09:00","close":"21:00"}],"thu":[{"open":"09:00","close":"21:00"}],"fri":[{"open":"09:00","close":"22:00"}],"sat":[{"open":"09:00","close":"22:00"}],"sun":[{"open":"09:00","close":"21:00"}]}'),
(1,17,'Nhà hàng Đặc sản Cà Mau','Hải sản miền Tây cực nam, tươi ngon.','Cà Mau, Việt Nam','2025-09-15','2025-12-31',170000.00,'VND',70,1,40,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/ca-mau-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-291-123-0017','https://camau.example.com','123 Quản Trọng Linh, Cà Mau','["Seafood","Vietnamese"]','["dine_in","takeaway"]','["vegan"]','{"mon":[{"open":"09:00","close":"20:00"}],"tue":[{"open":"09:00","close":"20:00"}],"wed":[{"open":"09:00","close":"20:00"}],"thu":[{"open":"09:00","close":"20:00"}],"fri":[{"open":"09:00","close":"21:00"}],"sat":[{"open":"09:00","close":"21:00"}],"sun":[{"open":"09:00","close":"20:00"}]}'),
(1,18,'Nhà hàng Đặc sản Cao Bằng','Ẩm thực núi đá, đặc sản vùng cao.','Cao Bằng, Việt Nam','2025-09-15','2025-12-31',160000.00,'VND',60,1,40,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/cao-bang-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-206-123-0018','https://caobang.example.com','123 Hoàng Hoa Thám, Cao Bằng','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"19:00"}],"tue":[{"open":"09:00","close":"19:00"}],"wed":[{"open":"09:00","close":"19:00"}],"thu":[{"open":"09:00","close":"19:00"}],"fri":[{"open":"09:00","close":"20:00"}],"sat":[{"open":"09:00","close":"20:00"}],"sun":[{"open":"09:00","close":"19:00"}]}'),
(1,19,'Nhà hàng Đặc sản Đắk Lắk','Ẩm thực Tây Nguyên, cà phê và món đặc trưng.','Đắk Lắk, Việt Nam','2025-09-15','2025-12-31',180000.00,'VND',80,1,50,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/dak-lak-1.jpg"]',4.1,'["local-favorite"]','published','moderate','+84-262-123-0019','https://daklak.example.com','123 Lê Duẩn, Buôn Ma Thuột','["Vietnamese","Coffee"]','["dine_in","takeaway"]','["vegan"]','{"mon":[{"open":"09:00","close":"21:00"}],"tue":[{"open":"09:00","close":"21:00"}],"wed":[{"open":"09:00","close":"21:00"}],"thu":[{"open":"09:00","close":"21:00"}],"fri":[{"open":"09:00","close":"22:00"}],"sat":[{"open":"09:00","close":"22:00"}],"sun":[{"open":"09:00","close":"21:00"}]}'),
(1,20,'Nhà hàng Đặc sản Đắk Nông','Ẩm thực núi rừng, phong vị Tây Nguyên.','Đắk Nông, Việt Nam','2025-09-15','2025-12-31',160000.00,'VND',60,1,40,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/dak-nong-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-261-123-0020','https://daknong.example.com','123 Trần Hưng Đạo, Gia Nghĩa','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"19:00"}],"tue":[{"open":"09:00","close":"19:00"}],"wed":[{"open":"09:00","close":"19:00"}],"thu":[{"open":"09:00","close":"19:00"}],"fri":[{"open":"09:00","close":"20:00"}],"sat":[{"open":"09:00","close":"20:00"}],"sun":[{"open":"09:00","close":"19:00"}]}'),
(1,21,'Nhà hàng Đặc sản Điện Biên','Ẩm thực địa phương, món núi rừng.','Điện Biên, Việt Nam','2025-09-15','2025-12-31',150000.00,'VND',60,1,40,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/dien-bien-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-215-123-0021','https://dienbien.example.com','123 Điện Biên Phủ, Điện Biên','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"19:00"}],"tue":[{"open":"09:00","close":"19:00"}],"wed":[{"open":"09:00","close":"19:00"}],"thu":[{"open":"09:00","close":"19:00"}],"fri":[{"open":"09:00","close":"20:00"}],"sat":[{"open":"09:00","close":"20:00"}],"sun":[{"open":"09:00","close":"19:00"}]}'),
(1,22,'Nhà hàng Đặc sản Đồng Nai','Ẩm thực đô thị, phục vụ đa dạng.','Đồng Nai, Việt Nam','2025-09-15','2025-12-31',190000.00,'VND',90,1,50,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/dong-nai-1.jpg"]',4.2,'["local-favorite"]','published','moderate','+84-251-123-0022','https://dongnai.example.com','123 Đồng Khởi, Biên Hòa','["Vietnamese"]','["dine_in","delivery"]','["vegan"]','{"mon":[{"open":"09:00","close":"21:00"}],"tue":[{"open":"09:00","close":"21:00"}],"wed":[{"open":"09:00","close":"21:00"}],"thu":[{"open":"09:00","close":"21:00"}],"fri":[{"open":"09:00","close":"22:00"}],"sat":[{"open":"09:00","close":"22:00"}],"sun":[{"open":"09:00","close":"21:00"}]}'),
(1,23,'Nhà hàng Đặc sản Đồng Tháp','Ẩm thực miền Tây, sen và đặc sản cồn.','Đồng Tháp, Việt Nam','2025-09-15','2025-12-31',160000.00,'VND',70,1,40,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/dong-thap-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-277-123-0023','https://dongthap.example.com','123 Nguyễn Huệ, Sa Đéc','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"20:00"}],"tue":[{"open":"09:00","close":"20:00"}],"wed":[{"open":"09:00","close":"20:00"}],"thu":[{"open":"09:00","close":"20:00"}],"fri":[{"open":"09:00","close":"21:00"}],"sat":[{"open":"09:00","close":"21:00"}],"sun":[{"open":"09:00","close":"20:00"}]}'),
(1,24,'Nhà hàng Đặc sản Gia Lai','Ẩm thực Tây Nguyên, phong vị cà phê.','Gia Lai, Việt Nam','2025-09-15','2025-12-31',170000.00,'VND',70,1,40,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/gia-lai-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-260-123-0024','https://gialai.example.com','123 Trần Phú, Pleiku','["Vietnamese","Coffee"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"20:00"}],"tue":[{"open":"09:00","close":"20:00"}],"wed":[{"open":"09:00","close":"20:00"}],"thu":[{"open":"09:00","close":"20:00"}],"fri":[{"open":"09:00","close":"21:00"}],"sat":[{"open":"09:00","close":"21:00"}],"sun":[{"open":"09:00","close":"20:00"}]}'),
(1,25,'Nhà hàng Đặc sản Hà Giang','Ẩm thực cao nguyên đá, đặc sản vùng cao.','Hà Giang, Việt Nam','2025-09-15','2025-12-31',160000.00,'VND',60,1,40,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/ha-giang-1.jpg"]',4.1,'["local-favorite"]','published','moderate','+84-219-123-0025','https://hagiang.example.com','123 Phố Núi, Hà Giang','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"19:00"}],"tue":[{"open":"09:00","close":"19:00"}],"wed":[{"open":"09:00","close":"19:00"}],"thu":[{"open":"09:00","close":"19:00"}],"fri":[{"open":"09:00","close":"20:00"}],"sat":[{"open":"09:00","close":"20:00"}],"sun":[{"open":"09:00","close":"19:00"}]}'),
(1,26,'Nhà hàng Đặc sản Hà Nam','Ẩm thực Bắc Bộ, món quê truyền thống.','Hà Nam, Việt Nam','2025-09-15','2025-12-31',150000.00,'VND',60,1,40,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/ha-nam-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-226-123-0026','https://hanam.example.com','123 Tây Tiến, Hà Nam','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"19:00"}],"tue":[{"open":"09:00","close":"19:00"}],"wed":[{"open":"09:00","close":"19:00"}],"thu":[{"open":"09:00","close":"19:00"}],"fri":[{"open":"09:00","close":"20:00"}],"sat":[{"open":"09:00","close":"20:00"}],"sun":[{"open":"09:00","close":"19:00"}]}'),
(1,27,'Nhà hàng Đặc sản Hà Tĩnh','Ẩm thực miền Trung, đặc sản biển và quê.','Hà Tĩnh, Việt Nam','2025-09-15','2025-12-31',150000.00,'VND',60,1,40,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/ha-tinh-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-239-123-0027','https://hatinh.example.com','123 Nguyễn Huệ, Hà Tĩnh','["Vietnamese","Seafood"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"20:00"}],"tue":[{"open":"09:00","close":"20:00"}],"wed":[{"open":"09:00","close":"20:00"}],"thu":[{"open":"09:00","close":"20:00"}],"fri":[{"open":"09:00","close":"21:00"}],"sat":[{"open":"09:00","close":"21:00"}],"sun":[{"open":"09:00","close":"20:00"}]}'),
(1,28,'Nhà hàng Đặc sản Hải Dương','Ăẩm thực Bắc Bộ, hải sản và nông sản địa phương.','Hải Dương, Việt Nam','2025-09-15','2025-12-31',150000.00,'VND',60,1,40,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/hai-duong-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-320-123-0028','https://haiduong.example.com','123 Hoàng Hoa Thám, Hải Dương','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"19:00"}],"tue":[{"open":"09:00","close":"19:00"}],"wed":[{"open":"09:00","close":"19:00"}],"thu":[{"open":"09:00","close":"19:00"}],"fri":[{"open":"09:00","close":"20:00"}],"sat":[{"open":"09:00","close":"20:00"}],"sun":[{"open":"09:00","close":"19:00"}]}'),
(1,29,'Nhà hàng Đặc sản Hậu Giang','Ẩm thực miền Tây, lẩu mắm và đặc sản địa phương.','Hậu Giang, Việt Nam','2025-09-15','2025-12-31',140000.00,'VND',60,1,40,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/hau-giang-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-293-123-0029','https://haugiang.example.com','123 Lê Lợi, Vị Thanh','["Vietnamese","Seafood"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"20:00"}],"tue":[{"open":"09:00","close":"20:00"}],"wed":[{"open":"09:00","close":"20:00"}],"thu":[{"open":"09:00","close":"20:00"}],"fri":[{"open":"09:00","close":"21:00"}],"sat":[{"open":"09:00","close":"21:00"}],"sun":[{"open":"09:00","close":"20:00"}]}'),
(1,30,'Nhà hàng Đặc sản Hòa Bình','Ẩm thực miền núi, món đặc sản dân tộc.','Hòa Bình, Việt Nam','2025-09-15','2025-12-31',150000.00,'VND',60,1,40,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/hoa-binh-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-218-123-0030','https://hoabinh.example.com','123 Đinh Tiên Hoàng, Hòa Bình','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"19:00"}],"tue":[{"open":"09:00","close":"19:00"}],"wed":[{"open":"09:00","close":"19:00"}],"thu":[{"open":"09:00","close":"19:00"}],"fri":[{"open":"09:00","close":"20:00"}],"sat":[{"open":"09:00","close":"20:00"}],"sun":[{"open":"09:00","close":"19:00"}]}'),
(1,31,'Nhà hàng Đặc sản Hưng Yên','Ẩm thực đồng bằng, đặc sản vải thiều mùa vụ.','Hưng Yên, Việt Nam','2025-09-15','2025-12-31',140000.00,'VND',60,1,40,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/hung-yen-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-221-123-0031','https://hungyen.example.com','123 Lê Lợi, Hưng Yên','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"20:00"}],"tue":[{"open":"09:00","close":"20:00"}],"wed":[{"open":"09:00","close":"20:00"}],"thu":[{"open":"09:00","close":"20:00"}],"fri":[{"open":"09:00","close":"21:00"}],"sat":[{"open":"09:00","close":"21:00"}],"sun":[{"open":"09:00","close":"20:00"}]}'),
(1,32,'Nhà hàng Đặc sản Khánh Hòa','Ẩm thực Nha Trang, hải sản tươi sống.','Khánh Hòa, Việt Nam','2025-09-15','2025-12-31',260000.00,'VND',100,1,60,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/khanh-hoa-1.jpg"]',4.5,'["sea-view","family-friendly"]','published','moderate','+84-258-123-0032','https://khanhhoa.example.com','123 Trần Phú, Nha Trang','["Seafood","Vietnamese"]','["dine_in","parking","wifi"]','["gluten_free"]','{"mon":[{"open":"09:00","close":"21:00"}],"tue":[{"open":"09:00","close":"21:00"}],"wed":[{"open":"09:00","close":"21:00"}],"thu":[{"open":"09:00","close":"21:00"}],"fri":[{"open":"09:00","close":"22:00"}],"sat":[{"open":"09:00","close":"22:00"}],"sun":[{"open":"09:00","close":"21:00"}]}'),
(1,33,'Nhà hàng Đặc sản Kiên Giang','Ẩm thực đảo, hải sản Phú Quốc.','Kiên Giang, Việt Nam','2025-09-15','2025-12-31',250000.00,'VND',90,1,50,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/kien-giang-1.jpg"]',4.4,'["sea-view"]','published','moderate','+84-297-123-0033','https://kiengiang.example.com','123 Trần Hưng Đạo, Rạch Giá','["Seafood","Vietnamese"]','["dine_in","takeaway"]','["gluten_free"]','{"mon":[{"open":"09:00","close":"21:00"}],"tue":[{"open":"09:00","close":"21:00"}],"wed":[{"open":"09:00","close":"21:00"}],"thu":[{"open":"09:00","close":"21:00"}],"fri":[{"open":"09:00","close":"22:00"}],"sat":[{"open":"09:00","close":"22:00"}],"sun":[{"open":"09:00","close":"21:00"}]}'),
(1,34,'Nhà hàng Đặc sản Kon Tum','Ẩm thực vùng cao, văn hoá dân tộc.','Kon Tum, Việt Nam','2025-09-15','2025-12-31',150000.00,'VND',60,1,40,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/kon-tum-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-260-123-0034','https://kontum.example.com','123 Nguyễn Huệ, Kon Tum','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"19:00"}],"tue":[{"open":"09:00","close":"19:00"}],"wed":[{"open":"09:00","close":"19:00"}],"thu":[{"open":"09:00","close":"19:00"}],"fri":[{"open":"09:00","close":"20:00"}],"sat":[{"open":"09:00","close":"20:00"}],"sun":[{"open":"09:00","close":"19:00"}]}'),
(1,35,'Nhà hàng Đặc sản Lai Châu','Ẩm thực miền núi, món bản địa.','Lai Châu, Việt Nam','2025-09-15','2025-12-31',140000.00,'VND',50,1,30,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/lai-chau-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-213-123-0035','https://laichau.example.com','123 Trung Tâm, Lai Châu','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"19:00"}],"tue":[{"open":"09:00","close":"19:00"}],"wed":[{"open":"09:00","close":"19:00"}],"thu":[{"open":"09:00","close":"19:00"}],"fri":[{"open":"09:00","close":"20:00"}],"sat":[{"open":"09:00","close":"20:00"}],"sun":[{"open":"09:00","close":"19:00"}]}'),
(1,36,'Nhà hàng Đặc sản Lâm Đồng','Ẩm thực Đà Lạt, cà phê và món ôn đới.','Lâm Đồng, Việt Nam','2025-09-15','2025-12-31',240000.00,'VND',90,1,50,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/lam-dong-1.jpg"]',4.5,'["family-friendly"]','published','moderate','+84-263-123-0036','https://lamdong.example.com','123 Trần Phú, Đà Lạt','["Vietnamese","Coffee"]','["dine_in","wifi"]','["vegan","gluten_free"]','{"mon":[{"open":"08:00","close":"22:00"}],"tue":[{"open":"08:00","close":"22:00"}],"wed":[{"open":"08:00","close":"22:00"}],"thu":[{"open":"08:00","close":"22:00"}],"fri":[{"open":"08:00","close":"23:00"}],"sat":[{"open":"08:00","close":"23:00"}],"sun":[{"open":"08:00","close":"22:00"}]}'),
(1,37,'Nhà hàng Đặc sản Lạng Sơn','Ẩm thực biên giới, đặc sản nướng.','Lạng Sơn, Việt Nam','2025-09-15','2025-12-31',150000.00,'VND',60,1,40,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/lang-son-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-205-123-0037','https://langson.example.com','123 Hữu Nghị, Lạng Sơn','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"19:00"}],"tue":[{"open":"09:00","close":"19:00"}],"wed":[{"open":"09:00","close":"19:00"}],"thu":[{"open":"09:00","close":"19:00"}],"fri":[{"open":"09:00","close":"20:00"}],"sat":[{"open":"09:00","close":"20:00"}],"sun":[{"open":"09:00","close":"19:00"}]}'),
(1,38,'Nhà hàng Đặc sản Lào Cai','Ẩm thực Sa Pa, rượu táo mèo và đặc sản núi.','Lào Cai, Việt Nam','2025-09-15','2025-12-31',220000.00,'VND',80,1,50,'https://res.cloudinary.com/dmuiou1m9/image/upload/v1758605094/du-lich-hue-mua-he-banner_mn6ds5.jpg','["https://cdn.example.com/restaurants/lao-cai-1.jpg"]',4.4,'["family-friendly"]','published','moderate','+84-214-123-0038','https://laocai.example.com','123 Fansipan, Sa Pa','["Vietnamese","Local"]','["dine_in","coffee"]','["vegan"]','{"mon":[{"open":"08:00","close":"21:00"}],"tue":[{"open":"08:00","close":"21:00"}],"wed":[{"open":"08:00","close":"21:00"}],"thu":[{"open":"08:00","close":"21:00"}],"fri":[{"open":"08:00","close":"22:00"}],"sat":[{"open":"08:00","close":"22:00"}],"sun":[{"open":"08:00","close":"21:00"}]}'),
(1,39,'Nhà hàng Đặc sản Long An','Ẩm thực đồng bằng, món dân dã.','Long An, Việt Nam','2025-09-15','2025-12-31',150000.00,'VND',60,1,40,'https://cdn.example.com/restaurants/long-an-thumb.jpg','["https://cdn.example.com/restaurants/long-an-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-272-123-0039','https://longan.example.com','123 Nguyễn Văn Linh, Long An','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"19:00"}],"tue":[{"open":"09:00","close":"19:00"}],"wed":[{"open":"09:00","close":"19:00"}],"thu":[{"open":"09:00","close":"19:00"}],"fri":[{"open":"09:00","close":"20:00"}],"sat":[{"open":"09:00","close":"20:00"}],"sun":[{"open":"09:00","close":"19:00"}]}'),
(1,40,'Nhà hàng Đặc sản Nam Định','Ẩm thực ven biển Bắc Bộ, nem và hải sản.','Nam Định, Việt Nam','2025-09-15','2025-12-31',150000.00,'VND',60,1,40,'https://cdn.example.com/restaurants/nam-dinh-thumb.jpg','["https://cdn.example.com/restaurants/nam-dinh-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-228-123-0040','https://namdinh.example.com','123 Trần Hưng Đạo, Nam Định','["Vietnamese","Seafood"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"20:00"}],"tue":[{"open":"09:00","close":"20:00"}],"wed":[{"open":"09:00","close":"20:00"}],"thu":[{"open":"09:00","close":"20:00"}],"fri":[{"open":"09:00","close":"21:00"}],"sat":[{"open":"09:00","close":"21:00"}],"sun":[{"open":"09:00","close":"20:00"}]}'),
(1,41,'Nhà hàng Đặc sản Nghệ An','Ẩm thực Trung Bộ, món quê và hải sản.','Nghệ An, Việt Nam','2025-09-15','2025-12-31',170000.00,'VND',80,1,50,'https://cdn.example.com/restaurants/nghe-an-thumb.jpg','["https://cdn.example.com/restaurants/nghe-an-1.jpg"]',4.1,'["local-favorite"]','published','moderate','+84-238-123-0041','https://nghean.example.com','123 Quang Trung, Vinh','["Vietnamese"]','["dine_in","takeaway"]','["vegan"]','{"mon":[{"open":"09:00","close":"21:00"}],"tue":[{"open":"09:00","close":"21:00"}],"wed":[{"open":"09:00","close":"21:00"}],"thu":[{"open":"09:00","close":"21:00"}],"fri":[{"open":"09:00","close":"22:00"}],"sat":[{"open":"09:00","close":"22:00"}],"sun":[{"open":"09:00","close":"21:00"}]}'),
(1,42,'Nhà hàng Đặc sản Ninh Bình','Ẩm thực cố đô, món đặc trưng vùng Hoa Lư.','Ninh Bình, Việt Nam','2025-09-15','2025-12-31',200000.00,'VND',80,1,50,'https://cdn.example.com/restaurants/ninh-binh-thumb.jpg','["https://cdn.example.com/restaurants/ninh-binh-1.jpg"]',4.4,'["local-favorite"]','published','moderate','+84-229-123-0042','https://ninhbinh.example.com','123 Tràng An, Ninh Bình','["Vietnamese"]','["dine_in","parking"]','["gluten_free"]','{"mon":[{"open":"09:00","close":"21:00"}],"tue":[{"open":"09:00","close":"21:00"}],"wed":[{"open":"09:00","close":"21:00"}],"thu":[{"open":"09:00","close":"21:00"}],"fri":[{"open":"09:00","close":"22:00"}],"sat":[{"open":"09:00","close":"22:00"}],"sun":[{"open":"09:00","close":"21:00"}]}'),
(1,43,'Nhà hàng Đặc sản Ninh Thuận','Ẩm thực ven biển, đặc sản Cham.','Ninh Thuận, Việt Nam','2025-09-15','2025-12-31',160000.00,'VND',70,1,40,'https://cdn.example.com/restaurants/ninh-thuan-thumb.jpg','["https://cdn.example.com/restaurants/ninh-thuan-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-259-123-0043','https://ninhthuan.example.com','123 Trần Phú, Phan Rang','["Vietnamese","Seafood"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"20:00"}],"tue":[{"open":"09:00","close":"20:00"}],"wed":[{"open":"09:00","close":"20:00"}],"thu":[{"open":"09:00","close":"20:00"}],"fri":[{"open":"09:00","close":"21:00"}],"sat":[{"open":"09:00","close":"21:00"}],"sun":[{"open":"09:00","close":"20:00"}]}'),
(1,44,'Nhà hàng Đặc sản Phú Thọ','Ẩm thực đất Tổ, món truyền thống.','Phú Thọ, Việt Nam','2025-09-15','2025-12-31',150000.00,'VND',60,1,40,'https://cdn.example.com/restaurants/phu-tho-thumb.jpg','["https://cdn.example.com/restaurants/phu-tho-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-210-123-0044','https://phutho.example.com','123 Hùng Vương, Việt Trì','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"19:00"}],"tue":[{"open":"09:00","close":"19:00"}],"wed":[{"open":"09:00","close":"19:00"}],"thu":[{"open":"09:00","close":"19:00"}],"fri":[{"open":"09:00","close":"20:00"}],"sat":[{"open":"09:00","close":"20:00"}],"sun":[{"open":"09:00","close":"19:00"}]}'),
(1,45,'Nhà hàng Đặc sản Phú Yên','Hải sản miền Trung, biển và đặc sản địa phương.','Phú Yên, Việt Nam','2025-09-15','2025-12-31',170000.00,'VND',70,1,40,'https://cdn.example.com/restaurants/phu-yen-thumb.jpg','["https://cdn.example.com/restaurants/phu-yen-1.jpg"]',4.1,'["local-favorite","sea-view"]','published','moderate','+84-257-123-0045','https://phuyen.example.com','123 Trần Phú, Tuy Hòa','["Seafood","Vietnamese"]','["dine_in","takeaway"]','["vegan"]','{"mon":[{"open":"09:00","close":"21:00"}],"tue":[{"open":"09:00","close":"21:00"}],"wed":[{"open":"09:00","close":"21:00"}],"thu":[{"open":"09:00","close":"21:00"}],"fri":[{"open":"09:00","close":"22:00"}],"sat":[{"open":"09:00","close":"22:00"}],"sun":[{"open":"09:00","close":"21:00"}]}'),
(1,46,'Nhà hàng Đặc sản Quảng Bình','Ẩm thực hang động, ẩm thực miền Trung.','Quảng Bình, Việt Nam','2025-09-15','2025-12-31',170000.00,'VND',70,1,40,'https://cdn.example.com/restaurants/quang-binh-thumb.jpg','["https://cdn.example.com/restaurants/quang-binh-1.jpg"]',4.2,'["local-favorite"]','published','moderate','+84-52-123-0046','https://quangbinh.example.com','123 Trần Hưng Đạo, Đồng Hới','["Vietnamese","Seafood"]','["dine_in"]','["gluten_free"]','{"mon":[{"open":"09:00","close":"21:00"}],"tue":[{"open":"09:00","close":"21:00"}],"wed":[{"open":"09:00","close":"21:00"}],"thu":[{"open":"09:00","close":"21:00"}],"fri":[{"open":"09:00","close":"22:00"}],"sat":[{"open":"09:00","close":"22:00"}],"sun":[{"open":"09:00","close":"21:00"}]}'),
(1,47,'Nhà hàng Đặc sản Quảng Nam','Ẩm thực Hội An, ẩm thực miền Trung.','Quảng Nam, Việt Nam','2025-09-15','2025-12-31',220000.00,'VND',80,1,50,'https://cdn.example.com/restaurant s/quang-nam-thumb.jpg','["https://cdn.example.com/restaurants/quang-nam-1.jpg"]',4.4,'["family-friendly"]','published','moderate','+84-235-123-0047','https://quangnam.example.com','123 Nguyễn Phúc, Hội An','["Vietnamese","Local"]','["dine_in","parking"]','["gluten_free"]','{"mon":[{"open":"09:00","close":"21:00"}],"tue":[{"open":"09:00","close":"21:00"}],"wed":[{"open":"09:00","close":"21:00"}],"thu":[{"open":"09:00","close":"21:00"}],"fri":[{"open":"09:00","close":"22:00"}],"sat":[{"open":"09:00","close":"22:00"}],"sun":[{"open":"09:00","close":"21:00"}]}'),
(1,48,'Nhà hàng Đặc sản Quảng Ngãi','Ẩm thực miền Trung, đặc sản địa phương.','Quảng Ngãi, Việt Nam','2025-09-15','2025-12-31',160000.00,'VND',70,1,40,'https://cdn.example.com/restaurants/quang-ngai-thumb.jpg','["https://cdn.example.com/restaurants/quang-ngai-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-255-123-0048','https://quangngai.example.com','123 Trần Phú, Quảng Ngãi','["Vietnamese","Seafood"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"20:00"}],"tue":[{"open":"09:00","close":"20:00"}],"wed":[{"open":"09:00","close":"20:00"}],"thu":[{"open":"09:00","close":"20:00"}],"fri":[{"open":"09:00","close":"21:00"}],"sat":[{"open":"09:00","close":"21:00"}],"sun":[{"open":"09:00","close":"20:00"}]}'),
(1,49,'Nhà hàng Đặc sản Quảng Ninh','Ẩm thực Hạ Long, hải sản nổi tiếng.','Quảng Ninh, Việt Nam','2025-09-15','2025-12-31',300000.00,'VND',100,1,60,'https://cdn.example.com/restaurants/quang-ninh-thumb.jpg','["https://cdn.example.com/restaurants/quang-ninh-1.jpg"]',4.6,'["sea-view","family-friendly"]','published','moderate','+84-203-123-0049','https://quangninh.example.com','123 Hạ Long, Quảng Ninh','["Seafood","Vietnamese"]','["dine_in","parking"]','["gluten_free"]','{"mon":[{"open":"09:00","close":"22:00"}],"tue":[{"open":"09:00","close":"22:00"}],"wed":[{"open":"09:00","close":"22:00"}],"thu":[{"open":"09:00","close":"22:00"}],"fri":[{"open":"09:00","close":"23:00"}],"sat":[{"open":"09:00","close":"23:00"}],"sun":[{"open":"09:00","close":"22:00"}]}'),
(1,50,'Nhà hàng Đặc sản Quảng Trị','Ẩm thực miền Trung, món truyền thống.','Quảng Trị, Việt Nam','2025-09-15','2025-12-31',150000.00,'VND',60,1,40,'https://cdn.example.com/restaurants/quang-tri-thumb.jpg','["https://cdn.example.com/restaurants/quang-tri-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-233-123-0050','https://quangtri.example.com','123 Điện Biên, Quảng Trị','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"19:00"}],"tue":[{"open":"09:00","close":"19:00"}],"wed":[{"open":"09:00","close":"19:00"}],"thu":[{"open":"09:00","close":"19:00"}],"fri":[{"open":"09:00","close":"20:00"}],"sat":[{"open":"09:00","close":"20:00"}],"sun":[{"open":"09:00","close":"19:00"}]}'),
(1,51,'Nhà hàng Đặc sản Sóc Trăng','Ẩm thực Khmer, món đặc trưng vùng Đồng bằng.','Sóc Trăng, Việt Nam','2025-09-15','2025-12-31',140000.00,'VND',60,1,40,'https://cdn.example.com/restaurants/soc-trang-thumb.jpg','["https://cdn.example.com/restaurants/soc-trang-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-292-123-0051','https://soctrang.example.com','123 Võ Văn Kiệt, Sóc Trăng','["Vietnamese","Local"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"20:00"}],"tue":[{"open":"09:00","close":"20:00"}],"wed":[{"open":"09:00","close":"20:00"}],"thu":[{"open":"09:00","close":"20:00"}],"fri":[{"open":"09:00","close":"21:00"}],"sat":[{"open":"09:00","close":"21:00"}],"sun":[{"open":"09:00","close":"20:00"}]}'),
(1,52,'Nhà hàng Đặc sản Sơn La','Ẩm thực Tây Bắc, chè và đặc sản vùng cao.','Sơn La, Việt Nam','2025-09-15','2025-12-31',140000.00,'VND',60,1,40,'https://cdn.example.com/restaurants/son-la-thumb.jpg','["https://cdn.example.com/restaurants/son-la-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-212-123-0052','https://sonla.example.com','123 Trung Tâm, Sơn La','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"19:00"}],"tue":[{"open":"09:00","close":"19:00"}],"wed":[{"open":"09:00","close":"19:00"}],"thu":[{"open":"09:00","close":"19:00"}],"fri":[{"open":"09:00","close":"20:00"}],"sat":[{"open":"09:00","close":"20:00"}],"sun":[{"open":"09:00","close":"19:00"}]}'),
(1,53,'Nhà hàng Đặc sản Tây Ninh','Ẩm thực miền Nam, đặc sản núi Bà Đen.','Tây Ninh, Việt Nam','2025-09-15','2025-12-31',150000.00,'VND',60,1,40,'https://cdn.example.com/restaurants/tay-ninh-thumb.jpg','["https://cdn.example.com/restaurants/tay-ninh-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-276-123-0053','https://tayninh.example.com','123 Trần Hưng Đạo, Tây Ninh','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"19:00"}],"tue":[{"open":"09:00","close":"19:00"}],"wed":[{"open":"09:00","close":"19:00"}],"thu":[{"open":"09:00","close":"19:00"}],"fri":[{"open":"09:00","close":"20:00"}],"sat":[{"open":"09:00","close":"20:00"}],"sun":[{"open":"09:00","close":"19:00"}]}'),
(1,54,'Nhà hàng Đặc sản Thái Bình','Ẩm thực đồng bằng Bắc Bộ, hải sản địa phương.','Thái Bình, Việt Nam','2025-09-15','2025-12-31',140000.00,'VND',60,1,40,'https://cdn.example.com/restaurants/thai-binh-thumb.jpg','["https://cdn.example.com/restaurants/thai-binh-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-227-123-0054','https://thaibinh.example.com','123 Lê Lợi, Thái Bình','["Vietnamese","Seafood"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"20:00"}],"tue":[{"open":"09:00","close":"20:00"}],"wed":[{"open":"09:00","close":"20:00"}],"thu":[{"open":"09:00","close":"20:00"}],"fri":[{"open":"09:00","close":"21:00"}],"sat":[{"open":"09:00","close":"21:00"}],"sun":[{"open":"09:00","close":"20:00"}]}'),
(1,55,'Nhà hàng Đặc sản Thái Nguyên','Ẩm thực vùng chè, đặc sản trà.','Thái Nguyên, Việt Nam','2025-09-15','2025-12-31',150000.00,'VND',60,1,40,'https://cdn.example.com/restaurants/thai-nguyen-thumb.jpg','["https://cdn.example.com/restaurants/thai-nguyen-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-208-123-0055','https://thainguyen.example.com','123 Võ Thị Sáu, Thái Nguyên','["Vietnamese","Tea"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"19:00"}],"tue":[{"open":"09:00","close":"19:00"}],"wed":[{"open":"09:00","close":"19:00"}],"thu":[{"open":"09:00","close":"19:00"}],"fri":[{"open":"09:00","close":"20:00"}],"sat":[{"open":"09:00","close":"20:00"}],"sun":[{"open":"09:00","close":"19:00"}]}'),
(1,56,'Nhà hàng Đặc sản Thanh Hóa','Ẩm thực miền Bắc - Trung, phong phú và truyền thống.','Thanh Hóa, Việt Nam','2025-09-15','2025-12-31',200000.00,'VND',90,1,50,'https://cdn.example.com/restaurants/thanh-hoa-thumb.jpg','["https://cdn.example.com/restaurants/thanh-hoa-1.jpg"]',4.2,'["local-favorite"]','published','moderate','+84-237-123-0056','https://thanhhoa.example.com','123 Lê Lợi, Thanh Hóa','["Vietnamese"]','["dine_in","parking"]','["gluten_free"]','{"mon":[{"open":"09:00","close":"21:00"}],"tue":[{"open":"09:00","close":"21:00"}],"wed":[{"open":"09:00","close":"21:00"}],"thu":[{"open":"09:00","close":"21:00"}],"fri":[{"open":"09:00","close":"22:00"}],"sat":[{"open":"09:00","close":"22:00"}],"sun":[{"open":"09:00","close":"21:00"}]}'),
(1,57,'Nhà hàng Đặc sản Thừa Thiên - Huế','Ẩm thực cung đình Huế, phong vị cổ truyền.','Thừa Thiên - Huế, Việt Nam','2025-09-15','2025-12-31',230000.00,'VND',90,1,50,'https://cdn.example.com/restaurants/thua-thien-hue-thumb.jpg','["https://cdn.example.com/restaurants/thua-thien-hue-1.jpg"]',4.5,'["local-favorite"]','published','moderate','+84-234-123-0057','https://hue.example.com','123 Đường Lê Lợi, Huế','["Vietnamese","Royal"]','["dine_in","parking"]','["gluten_free"]','{"mon":[{"open":"09:00","close":"21:00"}],"tue":[{"open":"09:00","close":"21:00"}],"wed":[{"open":"09:00","close":"21:00"}],"thu":[{"open":"09:00","close":"21:00"}],"fri":[{"open":"09:00","close":"22:00"}],"sat":[{"open":"09:00","close":"22:00"}],"sun":[{"open":"09:00","close":"21:00"}]}'),
(1,58,'Nhà hàng Đặc sản Tiền Giang','Ẩm thực miền Tây, miệt vườn và trái cây.','Tiền Giang, Việt Nam','2025-09-15','2025-12-31',150000.00,'VND',70,1,40,'https://cdn.example.com/restaurants/tien-giang-thumb.jpg','["https://cdn.example.com/restaurants/tien-giang-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-273-123-0058','https://tiengiang.example.com','123 Nguyễn Trãi, Mỹ Tho','["Vietnamese","Fruit"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"20:00"}],"tue":[{"open":"09:00","close":"20:00"}],"wed":[{"open":"09:00","close":"20:00"}],"thu":[{"open":"09:00","close":"20:00"}],"fri":[{"open":"09:00","close":"21:00"}],"sat":[{"open":"09:00","close":"21:00"}],"sun":[{"open":"09:00","close":"20:00"}]}'),
(1,59,'Nhà hàng Đặc sản Trà Vinh','Ẩm thực Khmer độc đáo, món địa phương.','Trà Vinh, Việt Nam','2025-09-15','2025-12-31',140000.00,'VND',60,1,40,'https://cdn.example.com/restaurants/tra-vinh-thumb.jpg','["https://cdn.example.com/restaurants/tra-vinh-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-294-123-0059','https://travinh.example.com','123 Nguyễn Huệ, Trà Vinh','["Vietnamese","Khmer"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"20:00"}],"tue":[{"open":"09:00","close":"20:00"}],"wed":[{"open":"09:00","close":"20:00"}],"thu":[{"open":"09:00","close":"20:00"}],"fri":[{"open":"09:00","close":"21:00"}],"sat":[{"open":"09:00","close":"21:00"}],"sun":[{"open":"09:00","close":"20:00"}]}'),
(1,60,'Nhà hàng Đặc sản Tuyên Quang','Ẩm thực núi rừng, món đặc sản địa phương.','Tuyên Quang, Việt Nam','2025-09-15','2025-12-31',140000.00,'VND',60,1,40,'https://cdn.example.com/restaurants/tuyen-quang-thumb.jpg','["https://cdn.example.com/restaurants/tuyen-quang-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-207-123-0060','https://tuyenquang.example.com','123 Hùng Vương, Tuyên Quang','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"19:00"}],"tue":[{"open":"09:00","close":"19:00"}],"wed":[{"open":"09:00","close":"19:00"}],"thu":[{"open":"09:00","close":"19:00"}],"fri":[{"open":"09:00","close":"20:00"}],"sat":[{"open":"09:00","close":"20:00"}],"sun":[{"open":"09:00","close":"19:00"}]}'),
(1,61,'Nhà hàng Đặc sản Vĩnh Long','Ẩm thực miệt vườn, chợ nổi và đặc sản miền Tây.','Vĩnh Long, Việt Nam','2025-09-15','2025-12-31',150000.00,'VND',70,1,40,'https://cdn.example.com/restaurants/vinh-long-thumb.jpg','["https://cdn.example.com/restaurants/vinh-long-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-270-123-0061','https://vinhlong.example.com','123 Nguyễn Văn Cừ, Vĩnh Long','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"20:00"}],"tue":[{"open":"09:00","close":"20:00"}],"wed":[{"open":"09:00","close":"20:00"}],"thu":[{"open":"09:00","close":"20:00"}],"fri":[{"open":"09:00","close":"21:00"}],"sat":[{"open":"09:00","close":"21:00"}],"sun":[{"open":"09:00","close":"20:00"}]}'),
(1,62,'Nhà hàng Đặc sản Vĩnh Phúc','Ẩm thực ven đô, phục vụ gia đình.','Vĩnh Phúc, Việt Nam','2025-09-15','2025-12-31',160000.00,'VND',70,1,40,'https://cdn.example.com/restaurants/vinh-phuc-thumb.jpg','["https://cdn.example.com/restaurants/vinh-phuc-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-211-123-0062','https://vinhphuc.example.com','123 Tam Đảo, Vĩnh Phúc','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"20:00"}],"tue":[{"open":"09:00","close":"20:00"}],"wed":[{"open":"09:00","close":"20:00"}],"thu":[{"open":"09:00","close":"20:00"}],"fri":[{"open":"09:00","close":"21:00"}],"sat":[{"open":"09:00","close":"21:00"}],"sun":[{"open":"09:00","close":"20:00"}]}'),
(1,63,'Nhà hàng Đặc sản Yên Bái','Ẩm thực vùng cao, ruộng bậc thang và món dân tộc.','Yên Bái, Việt Nam','2025-09-15','2025-12-31',150000.00,'VND',60,1,40,'https://cdn.example.com/restaurants/yen-bai-thumb.jpg','["https://cdn.example.com/restaurants/yen-bai-1.jpg"]',4.0,'["local-favorite"]','published','moderate','+84-216-123-0063','https://yenbai.example.com','123 Mù Cang Chải, Yên Bái','["Vietnamese"]','["dine_in"]','["vegan"]','{"mon":[{"open":"09:00","close":"19:00"}],"tue":[{"open":"09:00","close":"19:00"}],"wed":[{"open":"09:00","close":"19:00"}],"thu":[{"open":"09:00","close":"19:00"}],"fri":[{"open":"09:00","close":"20:00"}],"sat":[{"open":"09:00","close":"20:00"}],"sun":[{"open":"09:00","close":"19:00"}]}');

INSERT INTO hotels (provider_id, area_id, title, service_description, location, start_date, end_date, price, currency_code, capacity, min_participants, max_participants, thumbnail_url, image_urls, rating_average, badges, hotel_status, star_rating, property_type, address, checkin_time, checkout_time, highlights_json, amenities_json, policies_text) VALUES
(1,1,'Khách sạn Đặc sản Hà Nội','Khách sạn 3 sao trung tâm, phòng tiện nghi, gần khu di tích.','Hà Nội, Việt Nam','2025-09-15','2025-12-31',900000.00,'VND',80,1,4,'https://cdn.example.com/hotels/ha-noi/thumb.jpg','[\"https://cdn.example.com/hotels/ha-noi/room1.jpg\",\"https://cdn.example.com/hotels/ha-noi/lobby.jpg\"]',4.2,'family-friendly','published',3,'hotel','123 Hàng Bạc, Hoàn Kiếm, Hà Nội','14:00:00','12:00:00','[\"Gần Hồ Hoàn Kiếm\",\"Buffet sáng\",\"Wi-fi miễn phí\"]','[\"wifi miễn phí\",\"máy lạnh\",\"dịch vụ phòng\"]','Nhận phòng từ 14:00, trả phòng trước 12:00. Không hút thuốc trong phòng.'),
(1,2,'Khách sạn Đặc sản Hồ Chí Minh','Khách sạn 4 sao ở Quận 1, tiện nghi quốc tế.','Hồ Chí Minh, Việt Nam','2025-09-15','2025-12-31',1100000.00,'VND',120,1,4,'https://cdn.example.com/hotels/ho-chi-minh/thumb.jpg','[\"https://cdn.example.com/hotels/ho-chi-minh/room1.jpg\",\"https://cdn.example.com/hotels/ho-chi-minh/lobby.jpg\"]',4.4,'family-friendly','published',4,'hotel','123 Nguyễn Huệ, Quận 1, TP. HCM','14:00:00','12:00:00','[\"Gần Bến Nghé\",\"Hồ bơi trên tầng thượng\",\"Spa\"]','[\"wifi miễn phí\",\"hồ bơi\",\"spa\",\"đỗ xe\"]','Nhận phòng từ 14:00, trả phòng trước 12:00. Hủy phòng theo chính sách.'),
(1,3,'Khách sạn Đặc sản Hải Phòng','Khách sạn 3 sao gần cảng, hải sản tươi.','Hải Phòng, Việt Nam','2025-09-15','2025-12-31',800000.00,'VND',70,1,3,'https://cdn.example.com/hotels/hai-phong/thumb.jpg','[\"https://cdn.example.com/hotels/hai-phong/room1.jpg\"]',4.1,'sea-view','published',3,'hotel','123 Lạch Tray, Hải Phòng','14:00:00','12:00:00','[\"Gần bến cảng\",\"Ăn sáng miễn phí\"]','[\"wifi miễn phí\",\"máy lạnh\",\"hồ bơi\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,4,'Khách sạn Biển Vàng Vàng','Khách sạn 3 sao gần biển, phòng hiện đại, tiện nghi đầy đủ.','Đà Nẵng, Việt Nam','2025-09-15','2025-12-31',1200000.00,'VND',80,1,4,'https://cdn.example.com/hotels/gold-sea/thumb.jpg','[\"https://cdn.example.com/hotels/gold-sea/room1.jpg\",\"https://cdn.example.com/hotels/gold-sea/room2.jpg\",\"https://cdn.example.com/hotels/gold-sea/lobby.jpg\"]',4.3,'family-friendly,sea-view','published',3,'hotel','123 Võ Nguyên Giáp, Sơn Trà, Đà Nẵng','14:00:00','12:00:00','[\"Gần biển Mỹ Khê\",\"Buffet sáng miễn phí\",\"Hồ bơi ngoài trời\"]','[\"wifi miễn phí\",\"máy lạnh\",\"dịch vụ phòng\",\"chỗ đậu xe\"]','Nhận phòng từ 14:00, trả phòng trước 12:00. Không hút thuốc trong phòng.'),
(1,5,'Khách sạn Đặc sản Cần Thơ','Khách sạn 3 sao ven sông, phong cách miền Tây.','Cần Thơ, Việt Nam','2025-09-15','2025-12-31',700000.00,'VND',60,1,3,'https://cdn.example.com/hotels/can-tho/thumb.jpg','[\"https://cdn.example.com/hotels/can-tho/room1.jpg\"]',4.0,'family-friendly','published',3,'hotel','123 Lê Lợi, Ninh Kiều, Cần Thơ','14:00:00','12:00:00','[\"View sông\",\"Ăn sáng miễn phí\"]','[\"wifi miễn phí\",\"máy lạnh\",\"đỗ xe\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,6,'Khách sạn Đặc sản An Giang','Khách sạn 2-3 sao, phù hợp gia đình.','An Giang, Việt Nam','2025-09-15','2025-12-31',600000.00,'VND',50,1,3,'https://cdn.example.com/hotels/an-giang/thumb.jpg','[\"https://cdn.example.com/hotels/an-giang/room1.jpg\"]',3.9,'local-favorite','published',3,'hotel','123 Cách Mạng, Châu Đốc, An Giang','14:00:00','12:00:00','[\"Gần chợ nổi\",\"Ăn sáng nhẹ\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,7,'Khách sạn Đặc sản Bà Rịa - Vũng Tàu','Khách sạn ven biển, phòng có ban công.','Bà Rịa - Vũng Tàu, Việt Nam','2025-09-15','2025-12-31',900000.00,'VND',70,1,3,'https://cdn.example.com/hotels/ba-ria-vung-tau/thumb.jpg','[\"https://cdn.example.com/hotels/ba-ria-vung-tau/room1.jpg\"]',4.2,'sea-view','published',3,'hotel','123 Trần Phú, Vũng Tàu','14:00:00','12:00:00','[\"View biển\",\"Gần bãi tắm\"]','[\"wifi miễn phí\",\"máy lạnh\",\"đỗ xe\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,8,'Khách sạn Đặc sản Bắc Giang','Khách sạn 3 sao tiện nghi, phù hợp công tác.','Bắc Giang, Việt Nam','2025-09-15','2025-12-31',600000.00,'VND',60,1,3,'https://cdn.example.com/hotels/bac-giang/thumb.jpg','[\"https://cdn.example.com/hotels/bac-giang/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Nguyễn Văn Cừ, Bắc Giang','14:00:00','12:00:00','[\"Gần trung tâm\",\"Ăn sáng miễn phí\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,9,'Khách sạn Đặc sản Bắc Kạn','Khách sạn nhỏ, phong cách dân tộc.','Bắc Kạn, Việt Nam','2025-09-15','2025-12-31',550000.00,'VND',40,1,2,'https://cdn.example.com/hotels/bac-kan/thumb.jpg','[\"https://cdn.example.com/hotels/bac-kan/room1.jpg\"]',4.0,'local-favorite','published',2,'hotel','123 Trung Tâm, Bắc Kạn','14:00:00','12:00:00','[\"Phong cách dân tộc\",\"Bữa sáng địa phương\"]','[\"wifi miễn phí\",\"sưởi ấm\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,10,'Khách sạn Đặc sản Bạc Liêu','Khách sạn 2-3 sao, gần trung tâm.','Bạc Liêu, Việt Nam','2025-09-15','2025-12-31',600000.00,'VND',60,1,3,'https://cdn.example.com/hotels/bac-lieu/thumb.jpg','[\"https://cdn.example.com/hotels/bac-lieu/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Điện Biên Phủ, Bạc Liêu','14:00:00','12:00:00','[\"Gần trung tâm\",\"Ăn sáng phục vụ địa phương\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,11,'Khách sạn Đặc sản Bắc Ninh','Khách sạn 3 sao, gần các làng nghề.','Bắc Ninh, Việt Nam','2025-09-15','2025-12-31',700000.00,'VND',65,1,3,'https://cdn.example.com/hotels/bac-ninh/thumb.jpg','[\"https://cdn.example.com/hotels/bac-ninh/room1.jpg\"]',4.1,'local-favorite','published',3,'hotel','123 Lý Thái Tổ, Bắc Ninh','14:00:00','12:00:00','[\"Gần di tích truyền thống\",\"Bữa sáng buffet\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,12,'Khách sạn Đặc sản Bến Tre','Khách sạn nhỏ ven sông, phong cách miệt vườn.','Bến Tre, Việt Nam','2025-09-15','2025-12-31',650000.00,'VND',55,1,3,'https://cdn.example.com/hotels/ben-tre/thumb.jpg','[\"https://cdn.example.com/hotels/ben-tre/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Nguyễn Đình Chiểu, Bến Tre','14:00:00','12:00:00','[\"View sông\",\"Ăn sáng miệt vườn\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,13,'Khách sạn Đặc sản Bình Định','Khách sạn 3 sao gần biển, phục vụ hải sản địa phương.','Bình Định, Việt Nam','2025-09-15','2025-12-31',750000.00,'VND',70,1,3,'https://cdn.example.com/hotels/binh-dinh/thumb.jpg','[\"https://cdn.example.com/hotels/binh-dinh/room1.jpg\"]',4.1,'local-favorite','published',3,'hotel','123 Trần Hưng Đạo, Quy Nhơn','14:00:00','12:00:00','[\"Gần biển\",\"Ăn sáng miễn phí\"]','[\"wifi miễn phí\",\"máy lạnh\",\"đỗ xe\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,14,'Khách sạn Đặc sản Bình Dương','Khách sạn 3 sao tiện lợi cho doanh nhân.','Bình Dương, Việt Nam','2025-09-15','2025-12-31',700000.00,'VND',80,1,3,'https://cdn.example.com/hotels/binh-duong/thumb.jpg','[\"https://cdn.example.com/hotels/binh-duong/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Đại lộ Bình Dương, Thủ Dầu Một','14:00:00','12:00:00','[\"Gần khu công nghiệp\",\"Ăn sáng buffet\"]','[\"wifi miễn phí\",\"máy lạnh\",\"đỗ xe\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,15,'Khách sạn Đặc sản Bình Phước','Khách sạn nhỏ, phù hợp công tác và gia đình.','Bình Phước, Việt Nam','2025-09-15','2025-12-31',600000.00,'VND',50,1,3,'https://cdn.example.com/hotels/binh-phuoc/thumb.jpg','[\"https://cdn.example.com/hotels/binh-phuoc/room1.jpg\"]',3.9,'local-favorite','published',3,'hotel','123 Nguyễn Huệ, Bình Phước','14:00:00','12:00:00','[\"Gần trung tâm\",\"Ăn sáng phục vụ địa phương\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,16,'Khách sạn Đặc sản Bình Thuận','Khách sạn 3 sao gần Mũi Né, phòng có ban công.','Bình Thuận, Việt Nam','2025-09-15','2025-12-31',850000.00,'VND',75,1,3,'https://cdn.example.com/hotels/binh-thuan/thumb.jpg','[\"https://cdn.example.com/hotels/binh-thuan/room1.jpg\"]',4.1,'sea-view','published',3,'hotel','123 Võ Thị Sáu, Phan Thiết','14:00:00','12:00:00','[\"Gần biển\",\"Buffet sáng\"]','[\"wifi miễn phí\",\"máy lạnh\",\"hồ bơi\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,17,'Khách sạn Đặc sản Cà Mau','Khách sạn 2-3 sao, trải nghiệm ẩm thực địa phương.','Cà Mau, Việt Nam','2025-09-15','2025-12-31',650000.00,'VND',60,1,3,'https://cdn.example.com/hotels/ca-mau/thumb.jpg','[\"https://cdn.example.com/hotels/ca-mau/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Quản Trọng Linh, Cà Mau','14:00:00','12:00:00','[\"Gần mũi Cà Mau\",\"Ăn sáng địa phương\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,18,'Khách sạn Đặc sản Cao Bằng','Khách sạn nhỏ vùng cao, phong cảnh núi.','Cao Bằng, Việt Nam','2025-09-15','2025-12-31',600000.00,'VND',50,1,2,'https://cdn.example.com/hotels/cao-bang/thumb.jpg','[\"https://cdn.example.com/hotels/cao-bang/room1.jpg\"]',3.9,'local-favorite','published',2,'hotel','123 Hoàng Hoa Thám, Cao Bằng','14:00:00','12:00:00','[\"View núi\",\"Ẩm thực địa phương\"]','[\"wifi miễn phí\",\"sưởi ấm\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,19,'Khách sạn Đặc sản Đắk Lắk','Khách sạn cao nguyên, quán cà phê trong khuôn viên.','Đắk Lắk, Việt Nam','2025-09-15','2025-12-31',750000.00,'VND',70,1,3,'https://cdn.example.com/hotels/dak-lak/thumb.jpg','[\"https://cdn.example.com/hotels/dak-lak/room1.jpg\"]',4.0,'family-friendly','published',3,'hotel','123 Lê Duẩn, Buôn Ma Thuột','14:00:00','12:00:00','[\"Quán cà phê trong khách sạn\",\"Gần cao nguyên\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,20,'Khách sạn Đặc sản Đắk Nông','Khách sạn 2-3 sao, phong cách tự nhiên.','Đắk Nông, Việt Nam','2025-09-15','2025-12-31',600000.00,'VND',50,1,3,'https://cdn.example.com/hotels/dak-nong/thumb.jpg','[\"https://cdn.example.com/hotels/dak-nong/room1.jpg\"]',3.9,'local-favorite','published',3,'hotel','123 Trần Hưng Đạo, Gia Nghĩa','14:00:00','12:00:00','[\"Gần rừng\",\"Ăn sáng địa phương\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,21,'Khách sạn Đặc sản Điện Biên','Khách sạn nhỏ, phù hợp du lịch lịch sử.','Điện Biên, Việt Nam','2025-09-15','2025-12-31',550000.00,'VND',50,1,2,'https://cdn.example.com/hotels/dien-bien/thumb.jpg','[\"https://cdn.example.com/hotels/dien-bien/room1.jpg\"]',3.9,'local-favorite','published',2,'hotel','123 Điện Biên Phủ, Điện Biên','14:00:00','12:00:00','[\"Gần di tích lịch sử\",\"Ăn sáng địa phương\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,22,'Khách sạn Đặc sản Đồng Nai','Khách sạn 3 sao, phù hợp công tác và du lịch.','Đồng Nai, Việt Nam','2025-09-15','2025-12-31',750000.00,'VND',80,1,3,'https://cdn.example.com/hotels/dong-nai/thumb.jpg','[\"https://cdn.example.com/hotels/dong-nai/room1.jpg\"]',4.1,'local-favorite','published',3,'hotel','123 Đồng Khởi, Biên Hòa','14:00:00','12:00:00','[\"Gần khu công nghiệp\",\"Ăn sáng buffet\"]','[\"wifi miễn phí\",\"máy lạnh\",\"đỗ xe\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,23,'Khách sạn Đặc sản Đồng Tháp','Khách sạn ven sông, trải nghiệm miệt vườn.','Đồng Tháp, Việt Nam','2025-09-15','2025-12-31',650000.00,'VND',60,1,3,'https://cdn.example.com/hotels/dong-thap/thumb.jpg','[\"https://cdn.example.com/hotels/dong-thap/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Nguyễn Huệ, Sa Đéc','14:00:00','12:00:00','[\"Gần miệt vườn\",\"Ăn sáng địa phương\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,24,'Khách sạn Đặc sản Gia Lai','Khách sạn cao nguyên, phong cách Tây Nguyên.','Gia Lai, Việt Nam','2025-09-15','2025-12-31',700000.00,'VND',60,1,3,'https://cdn.example.com/hotels/gia-lai/thumb.jpg','[\"https://cdn.example.com/hotels/gia-lai/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Trần Phú, Pleiku','14:00:00','12:00:00','[\"Gần cao nguyên\",\"Quán cà phê\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,25,'Khách sạn Đặc sản Hà Giang','Khách sạn nhỏ vùng cao, view ruộng bậc thang.','Hà Giang, Việt Nam','2025-09-15','2025-12-31',600000.00,'VND',45,1,2,'https://cdn.example.com/hotels/ha-giang/thumb.jpg','[\"https://cdn.example.com/hotels/ha-giang/room1.jpg\"]',4.0,'local-favorite','published',2,'hotel','123 Phố Núi, Hà Giang','14:00:00','12:00:00','[\"View núi\",\"Ăn sáng địa phương\"]','[\"wifi miễn phí\",\"sưởi ấm\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,26,'Khách sạn Đặc sản Hà Nam','Khách sạn 3 sao, gần Hà Nội, phù hợp công tác.','Hà Nam, Việt Nam','2025-09-15','2025-12-31',650000.00,'VND',60,1,3,'https://cdn.example.com/hotels/ha-nam/thumb.jpg','[\"https://cdn.example.com/hotels/ha-nam/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Tây Tiến, Hà Nam','14:00:00','12:00:00','[\"Gần nhà ga\",\"Ăn sáng miễn phí\"]','[\"wifi miễn phí\",\"máy lạnh\",\"đỗ xe\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,27,'Khách sạn Đặc sản Hà Tĩnh','Khách sạn 3 sao gần biển, phục vụ hải sản.','Hà Tĩnh, Việt Nam','2025-09-15','2025-12-31',650000.00,'VND',60,1,3,'https://cdn.example.com/hotels/ha-tinh/thumb.jpg','[\"https://cdn.example.com/hotels/ha-tinh/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Nguyễn Huệ, Hà Tĩnh','14:00:00','12:00:00','[\"Gần biển\",\"Ăn sáng miễn phí\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,28,'Khách sạn Đặc sản Hải Dương','Khách sạn trung tâm, thuận tiện đi lại.','Hải Dương, Việt Nam','2025-09-15','2025-12-31',600000.00,'VND',60,1,3,'https://cdn.example.com/hotels/hai-duong/thumb.jpg','[\"https://cdn.example.com/hotels/hai-duong/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Hoàng Hoa Thám, Hải Dương','14:00:00','12:00:00','[\"Gần chợ\",\"Ăn sáng buffet\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,29,'Khách sạn Đặc sản Hậu Giang','Khách sạn 2-3 sao, trải nghiệm miệt vườn.','Hậu Giang, Việt Nam','2025-09-15','2025-12-31',600000.00,'VND',50,1,3,'https://cdn.example.com/hotels/hau-giang/thumb.jpg','[\"https://cdn.example.com/hotels/hau-giang/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Lê Lợi, Vị Thanh','14:00:00','12:00:00','[\"Gần chợ địa phương\",\"Ăn sáng địa phương\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,30,'Khách sạn Đặc sản Hòa Bình','Khách sạn miền núi, phong cách lịch lãm.','Hòa Bình, Việt Nam','2025-09-15','2025-12-31',650000.00,'VND',60,1,3,'https://cdn.example.com/hotels/hoa-binh/thumb.jpg','[\"https://cdn.example.com/hotels/hoa-binh/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Đinh Tiên Hoàng, Hòa Bình','14:00:00','12:00:00','[\"Gần hồ, cảnh quan\",\"Bữa sáng phục vụ địa phương\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,31,'Khách sạn Đặc sản Hưng Yên','Khách sạn 2-3 sao, gần chợ và làng nghề.','Hưng Yên, Việt Nam','2025-09-15','2025-12-31',600000.00,'VND',55,1,3,'https://cdn.example.com/hotels/hung-yen/thumb.jpg','[\"https://cdn.example.com/hotels/hung-yen/room1.jpg\"]',3.9,'local-favorite','published',3,'hotel','123 Lê Lợi, Hưng Yên','14:00:00','12:00:00','[\"Gần làng nghề\",\"Ăn sáng phục vụ địa phương\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,32,'Khách sạn Đặc sản Khánh Hòa','Khách sạn ven biển Nha Trang, phòng nhìn biển.','Khánh Hòa, Việt Nam','2025-09-15','2025-12-31',1400000.00,'VND',110,1,4,'https://cdn.example.com/hotels/khanh-hoa/thumb.jpg','[\"https://cdn.example.com/hotels/khanh-hoa/room1.jpg\"]',4.4,'sea-view,family-friendly','published',4,'hotel','123 Trần Phú, Nha Trang','14:00:00','12:00:00','[\"View biển\",\"Hồ bơi\",\"Buffet sáng\"]','[\"wifi miễn phí\",\"hồ bơi\",\"spa\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,33,'Khách sạn Đặc sản Kiên Giang','Khách sạn đảo, phục vụ du khách Phú Quốc.','Kiên Giang, Việt Nam','2025-09-15','2025-12-31',1300000.00,'VND',90,1,4,'https://cdn.example.com/hotels/kien-giang/thumb.jpg','[\"https://cdn.example.com/hotels/kien-giang/room1.jpg\"]',4.3,'sea-view','published',4,'hotel','123 Trần Hưng Đạo, Rạch Giá','14:00:00','12:00:00','[\"Gần đảo Phú Quốc\",\"Hồ bơi\",\"Dịch vụ tàu tham quan\"]','[\"wifi miễn phí\",\"hồ bơi\",\"đỗ xe\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,34,'Khách sạn Đặc sản Kon Tum','Khách sạn ven rừng, yên tĩnh.','Kon Tum, Việt Nam','2025-09-15','2025-12-31',600000.00,'VND',50,1,3,'https://cdn.example.com/hotels/kon-tum/thumb.jpg','[\"https://cdn.example.com/hotels/kon-tum/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Nguyễn Huệ, Kon Tum','14:00:00','12:00:00','[\"Gần rừng quốc gia\",\"Ăn sáng địa phương\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,35,'Khách sạn Đặc sản Lai Châu','Khách sạn miền núi, phù hợp khách du lịch mạo hiểm.','Lai Châu, Việt Nam','2025-09-15','2025-12-31',550000.00,'VND',45,1,2,'https://cdn.example.com/hotels/lai-chau/thumb.jpg','[\"https://cdn.example.com/hotels/lai-chau/room1.jpg\"]',4.0,'local-favorite','published',2,'hotel','123 Trung Tâm, Lai Châu','14:00:00','12:00:00','[\"Gần đèo, bản làng\",\"Ăn sáng cơ bản\"]','[\"wifi miễn phí\",\"sưởi ấm\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,36,'Khách sạn Đặc sản Lâm Đồng','Khách sạn Đà Lạt, phong cách ôn đới, quán cà phê.','Lâm Đồng, Việt Nam','2025-09-15','2025-12-31',1100000.00,'VND',90,1,4,'https://cdn.example.com/hotels/lam-dong/thumb.jpg','[\"https://cdn.example.com/hotels/lam-dong/room1.jpg\"]',4.4,'family-friendly','published',4,'hotel','123 Trần Phú, Đà Lạt','14:00:00','12:00:00','[\"Vườn hoa\",\"Quán cà phê trong khách sạn\"]','[\"wifi miễn phí\",\"máy lạnh\",\"đỗ xe\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,37,'Khách sạn Đặc sản Lạng Sơn','Khách sạn biên giới, phòng ấm áp.','Lạng Sơn, Việt Nam','2025-09-15','2025-12-31',600000.00,'VND',55,1,3,'https://cdn.example.com/hotels/lang-son/thumb.jpg','[\"https://cdn.example.com/hotels/lang-son/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Hữu Nghị, Lạng Sơn','14:00:00','12:00:00','[\"Gần cửa khẩu\",\"Ăn sáng địa phương\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,38,'Khách sạn Đặc sản Lào Cai','Khách sạn Sa Pa, view núi Fansipan.','Lào Cai, Việt Nam','2025-09-15','2025-12-31',1000000.00,'VND',80,1,4,'https://cdn.example.com/hotels/lao-cai/thumb.jpg','[\"https://cdn.example.com/hotels/lao-cai/room1.jpg\"]',4.3,'family-friendly','published',4,'hotel','123 Fansipan, Sa Pa','14:00:00','12:00:00','[\"View Fansipan\",\"Quán cà phê ấm áp\"]','[\"wifi miễn phí\",\"máy sưởi\",\"đỗ xe\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,39,'Khách sạn Đặc sản Long An','Khách sạn 2-3 sao, thuận tiện đi lại.','Long An, Việt Nam','2025-09-15','2025-12-31',600000.00,'VND',60,1,3,'https://cdn.example.com/hotels/long-an/thumb.jpg','[\"https://cdn.example.com/hotels/long-an/room1.jpg\"]',3.9,'local-favorite','published',3,'hotel','123 Nguyễn Văn Linh, Long An','14:00:00','12:00:00','[\"Gần trung tâm\",\"Ăn sáng nhẹ\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,40,'Khách sạn Đặc sản Nam Định','Khách sạn ven biển, ấm cúng và thoải mái.','Nam Định, Việt Nam','2025-09-15','2025-12-31',650000.00,'VND',60,1,3,'https://cdn.example.com/hotels/nam-dinh/thumb.jpg','[\"https://cdn.example.com/hotels/nam-dinh/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Trần Hưng Đạo, Nam Định','14:00:00','12:00:00','[\"Gần biển\",\"Ăn sáng buffet\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,41,'Khách sạn Đặc sản Nghệ An','Khách sạn 3 sao, thuận tiện cho du lịch.','Nghệ An, Việt Nam','2025-09-15','2025-12-31',700000.00,'VND',80,1,4,'https://cdn.example.com/hotels/nghe-an/thumb.jpg','[\"https://cdn.example.com/hotels/nghe-an/room1.jpg\"]',4.1,'local-favorite','published',3,'hotel','123 Quang Trung, Vinh','14:00:00','12:00:00','[\"Gần biển và phố cổ\",\"Bữa sáng tự chọn\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,42,'Khách sạn Đặc sản Ninh Bình','Khách sạn gần Tràng An, phù hợp tham quan.','Ninh Bình, Việt Nam','2025-09-15','2025-12-31',900000.00,'VND',80,1,4,'https://cdn.example.com/hotels/ninh-binh/thumb.jpg','[\"https://cdn.example.com/hotels/ninh-binh/room1.jpg\"]',4.3,'family-friendly','published',4,'hotel','123 Tràng An, Ninh Bình','14:00:00','12:00:00','[\"Gần Tràng An\",\"Tour tham quan hỗ trợ\"]','[\"wifi miễn phí\",\"hướng dẫn viên\",\"bếp nhỏ\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,43,'Khách sạn Đặc sản Ninh Thuận','Khách sạn ven biển, thiết kế hiện đại.','Ninh Thuận, Việt Nam','2025-09-15','2025-12-31',700000.00,'VND',60,1,3,'https://cdn.example.com/hotels/ninh-thuan/thumb.jpg','[\"https://cdn.example.com/hotels/ninh-thuan/room1.jpg\"]',4.0,'sea-view','published',3,'hotel','123 Trần Phú, Phan Rang','14:00:00','12:00:00','[\"Gần biển\",\"Ăn sáng phục vụ địa phương\"]','[\"wifi miễn phí\",\"máy lạnh\",\"đỗ xe\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,44,'Khách sạn Đặc sản Phú Thọ','Khách sạn truyền thống, gần di tích Hùng Vương.','Phú Thọ, Việt Nam','2025-09-15','2025-12-31',650000.00,'VND',60,1,3,'https://cdn.example.com/hotels/phu-tho/thumb.jpg','[\"https://cdn.example.com/hotels/phu-tho/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Hùng Vương, Việt Trì','14:00:00','12:00:00','[\"Gần đền thờ\",\"Ăn sáng địa phương\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,45,'Khách sạn Đặc sản Phú Yên','Khách sạn ven biển, view Gành Đá Dĩa.','Phú Yên, Việt Nam','2025-09-15','2025-12-31',750000.00,'VND',65,1,3,'https://cdn.example.com/hotels/phu-yen/thumb.jpg','[\"https://cdn.example.com/hotels/phu-yen/room1.jpg\"]',4.1,'sea-view','published',3,'hotel','123 Trần Phú, Tuy Hòa','14:00:00','12:00:00','[\"Gần Gành Đá Dĩa\",\"Ăn sáng miễn phí\"]','[\"wifi miễn phí\",\"máy lạnh\",\"đỗ xe\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,46,'Khách sạn Đặc sản Quảng Bình','Khách sạn gần Phong Nha, phục vụ tour hang động.','Quảng Bình, Việt Nam','2025-09-15','2025-12-31',800000.00,'VND',70,1,3,'https://cdn.example.com/hotels/quang-binh/thumb.jpg','[\"https://cdn.example.com/hotels/quang-binh/room1.jpg\"]',4.1,'local-favorite','published',3,'hotel','123 Trần Hưng Đạo, Đồng Hới','14:00:00','12:00:00','[\"Gần Phong Nha\",\"Tour hang động hỗ trợ\"]','[\"wifi miễn phí\",\"máy lạnh\",\"đỗ xe\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,47,'Khách sạn Đặc sản Quảng Nam','Khách sạn cổ điển gần Hội An, phong cách truyền thống.','Quảng Nam, Việt Nam','2025-09-15','2025-12-31',950000.00,'VND',80,1,4,'https://cdn.example.com/hotels/quang-nam/thumb.jpg','[\"https://cdn.example.com/hotels/quang-nam/room1.jpg\"]',4.3,'family-friendly','published',4,'hotel','123 Nguyễn Phúc, Hội An','14:00:00','12:00:00','[\"Gần phố cổ Hội An\",\"Buffet sáng truyền thống\"]','[\"wifi miễn phí\",\"hướng dẫn viên\",\"đỗ xe\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,48,'Khách sạn Đặc sản Quảng Ngãi','Khách sạn 3 sao, phục vụ hải sản địa phương.','Quảng Ngãi, Việt Nam','2025-09-15','2025-12-31',650000.00,'VND',60,1,3,'https://cdn.example.com/hotels/quang-ngai/thumb.jpg','[\"https://cdn.example.com/hotels/quang-ngai/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Trần Phú, Quảng Ngãi','14:00:00','12:00:00','[\"Gần biển\",\"Ăn sáng địa phương\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,49,'Khách sạn Đặc sản Quảng Ninh','Khách sạn Hạ Long, view vịnh, phòng cao cấp.','Quảng Ninh, Việt Nam','2025-09-15','2025-12-31',1600000.00,'VND',120,1,5,'https://cdn.example.com/hotels/quang-ninh/thumb.jpg','[\"https://cdn.example.com/hotels/quang-ninh/room1.jpg\"]',4.6,'sea-view,family-friendly','published',5,'hotel','123 Hạ Long, Quảng Ninh','14:00:00','12:00:00','[\"View Vịnh Hạ Long\",\"Hồ bơi\",\"Nhà hàng hải sản\"]','[\"wifi miễn phí\",\"hồ bơi\",\"spa\",\"đỗ xe\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,50,'Khách sạn Đặc sản Quảng Trị','Khách sạn lịch sử, yên tĩnh và trang nhã.','Quảng Trị, Việt Nam','2025-09-15','2025-12-31',600000.00,'VND',50,1,3,'https://cdn.example.com/hotels/quang-tri/thumb.jpg','[\"https://cdn.example.com/hotels/quang-tri/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Điện Biên, Quảng Trị','14:00:00','12:00:00','[\"Gần di tích lịch sử\",\"Bữa sáng phục vụ địa phương\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,51,'Khách sạn Đặc sản Sóc Trăng','Khách sạn miền Tây, gần chợ và ẩm thực Khmer.','Sóc Trăng, Việt Nam','2025-09-15','2025-12-31',600000.00,'VND',55,1,3,'https://cdn.example.com/hotels/soc-trang/thumb.jpg','[\"https://cdn.example.com/hotels/soc-trang/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Võ Văn Kiệt, Sóc Trăng','14:00:00','12:00:00','[\"Gần chợ địa phương\",\"Ẩm thực Khmer\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,52,'Khách sạn Đặc sản Sơn La','Khách sạn vùng cao, phù hợp trekking.','Sơn La, Việt Nam','2025-09-15','2025-12-31',550000.00,'VND',50,1,2,'https://cdn.example.com/hotels/son-la/thumb.jpg','[\"https://cdn.example.com/hotels/son-la/room1.jpg\"]',3.9,'local-favorite','published',2,'hotel','123 Trung Tâm, Sơn La','14:00:00','12:00:00','[\"Gần cao nguyên\",\"Ăn sáng nhẹ\"]','[\"wifi miễn phí\",\"sưởi ấm\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,53,'Khách sạn Đặc sản Tây Ninh','Khách sạn gần núi Bà Đen, tiện nghi cơ bản.','Tây Ninh, Việt Nam','2025-09-15','2025-12-31',600000.00,'VND',55,1,3,'https://cdn.example.com/hotels/tay-ninh/thumb.jpg','[\"https://cdn.example.com/hotels/tay-ninh/room1.jpg\"]',3.9,'local-favorite','published',3,'hotel','123 Trần Hưng Đạo, Tây Ninh','14:00:00','12:00:00','[\"Gần núi Bà Đen\",\"Ăn sáng cơ bản\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,54,'Khách sạn Đặc sản Thái Bình','Khách sạn ven biển, phù hợp gia đình.','Thái Bình, Việt Nam','2025-09-15','2025-12-31',600000.00,'VND',60,1,3,'https://cdn.example.com/hotels/thai-binh/thumb.jpg','[\"https://cdn.example.com/hotels/thai-binh/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Lê Lợi, Thái Bình','14:00:00','12:00:00','[\"Gần bãi biển\",\"Ăn sáng phục vụ địa phương\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,55,'Khách sạn Đặc sản Thái Nguyên','Khách sạn gần vùng chè, phù hợp nghỉ dưỡng ngắn ngày.','Thái Nguyên, Việt Nam','2025-09-15','2025-12-31',650000.00,'VND',60,1,3,'https://cdn.example.com/hotels/thai-nguyen/thumb.jpg','[\"https://cdn.example.com/hotels/thai-nguyen/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Võ Thị Sáu, Thái Nguyên','14:00:00','12:00:00','[\"Gần vườn chè\",\"Ăn sáng địa phương\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,56,'Khách sạn Đặc sản Thanh Hóa','Khách sạn 4 sao, gần bãi tắm Sầm Sơn.','Thanh Hóa, Việt Nam','2025-09-15','2025-12-31',950000.00,'VND',100,1,4,'https://cdn.example.com/hotels/thanh-hoa/thumb.jpg','[\"https://cdn.example.com/hotels/thanh-hoa/room1.jpg\"]',4.2,'family-friendly','published',4,'hotel','123 Lê Lợi, Thanh Hóa','14:00:00','12:00:00','[\"Gần bãi tắm\",\"Hồ bơi\",\"Nhà hàng\"]','[\"wifi miễn phí\",\"hồ bơi\",\"spa\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,57,'Khách sạn Đặc sản Thừa Thiên - Huế','Khách sạn mang đậm phong cách cung đình Huế.','Thừa Thiên - Huế, Việt Nam','2025-09-15','2025-12-31',1100000.00,'VND',90,1,4,'https://cdn.example.com/hotels/thua-thien-hue/thumb.jpg','[\"https://cdn.example.com/hotels/thua-thien-hue/room1.jpg\"]',4.4,'local-favorite','published',4,'hotel','123 Đường Lê Lợi, Huế','14:00:00','12:00:00','[\"Phong cách cung đình\",\"Ẩm thực Huế\"]','[\"wifi miễn phí\",\"nhà hàng\",\"đỗ xe\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,58,'Khách sạn Đặc sản Tiền Giang','Khách sạn miệt vườn, gần sông.','Tiền Giang, Việt Nam','2025-09-15','2025-12-31',600000.00,'VND',60,1,3,'https://cdn.example.com/hotels/tien-giang/thumb.jpg','[\"https://cdn.example.com/hotels/tien-giang/room1.jpg\"]',3.9,'local-favorite','published',3,'hotel','123 Nguyễn Trãi, Mỹ Tho','14:00:00','12:00:00','[\"Gần miệt vườn\",\"Ăn sáng trái cây\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,59,'Khách sạn Đặc sản Trà Vinh','Khách sạn truyền thống, trải nghiệm ẩm thực Khmer.','Trà Vinh, Việt Nam','2025-09-15','2025-12-31',600000.00,'VND',55,1,3,'https://cdn.example.com/hotels/tra-vinh/thumb.jpg','[\"https://cdn.example.com/hotels/tra-vinh/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Nguyễn Huệ, Trà Vinh','14:00:00','12:00:00','[\"Ẩm thực Khmer\",\"Gần các đền chùa\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,60,'Khách sạn Đặc sản Tuyên Quang','Khách sạn miền núi, phù hợp tham quan lịch sử.','Tuyên Quang, Việt Nam','2025-09-15','2025-12-31',550000.00,'VND',50,1,2,'https://cdn.example.com/hotels/tuyen-quang/thumb.jpg','[\"https://cdn.example.com/hotels/tuyen-quang/room1.jpg\"]',3.9,'local-favorite','published',2,'hotel','123 Hùng Vương, Tuyên Quang','14:00:00','12:00:00','[\"Gần đền chùa\",\"Phong cảnh núi\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,61,'Khách sạn Đặc sản Vĩnh Long','Khách sạn miệt vườn, gần chợ nổi.','Vĩnh Long, Việt Nam','2025-09-15','2025-12-31',650000.00,'VND',65,1,3,'https://cdn.example.com/hotels/vinh-long/thumb.jpg','[\"https://cdn.example.com/hotels/vinh-long/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Nguyễn Văn Cừ, Vĩnh Long','14:00:00','12:00:00','[\"Gần chợ nổi\",\"Ăn sáng miệt vườn\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,62,'Khách sạn Đặc sản Vĩnh Phúc','Khách sạn ven Tam Đảo, nghỉ dưỡng cuối tuần.','Vĩnh Phúc, Việt Nam','2025-09-15','2025-12-31',700000.00,'VND',70,1,3,'https://cdn.example.com/hotels/vinh-phuc/thumb.jpg','[\"https://cdn.example.com/hotels/vinh-phuc/room1.jpg\"]',4.0,'family-friendly','published',3,'hotel','123 Tam Đảo, Vĩnh Phúc','14:00:00','12:00:00','[\"View Tam Đảo\",\"Spa nhỏ\"]','[\"wifi miễn phí\",\"máy lạnh\",\"đỗ xe\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.'),
(1,63,'Khách sạn Đặc sản Yên Bái','Khách sạn vùng cao, gần ruộng bậc thang.','Yên Bái, Việt Nam','2025-09-15','2025-12-31',600000.00,'VND',55,1,3,'https://cdn.example.com/hotels/yen-bai/thumb.jpg','[\"https://cdn.example.com/hotels/yen-bai/room1.jpg\"]',4.0,'local-favorite','published',3,'hotel','123 Mù Cang Chải, Yên Bái','14:00:00','12:00:00','[\"View ruộng bậc thang\",\"Ăn sáng đậm đà\"]','[\"wifi miễn phí\",\"máy lạnh\"]','Nhận phòng từ 14:00, trả phòng trước 12:00.');

INSERT INTO tours (provider_id, area_id, title, service_description, location, start_date, end_date, price, currency_code, capacity, min_participants, max_participants, thumbnail_url, image_urls, rating_average, badges, tour_status, itinerary_overview, meeting_point, guide_language, inclusive_items, exclusive_items, cancellation_policy, difficulty_level, duration_days, departure_location, included_json, excluded_json) VALUES
(1,1,'Tour Khám phá Hà Nội 3N2Đ','Khám phá Hoàn Kiếm, Văn Miếu, Lăng Bác.','Hà Nội, Việt Nam','2025-10-01','2025-10-03',3500000.00,'VND',30,2,30,'https://cdn.example.com/tours/ha-noi/thumb.jpg','[\"https://cdn.example.com/tours/ha-noi/1.jpg\",\"https://cdn.example.com/tours/ha-noi/2.jpg\"]',4.7,'family-friendly,best-seller','published','Ngày 1: Hoàn Kiếm; Ngày 2: Văn Miếu; Ngày 3: Lăng Bác.','Trung tâm Hà Nội','Vietnamese,English','Xe đưa đón,Vé tham quan chính,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',3,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 3 sao\",\"Bữa sáng hàng ngày\",\"Vé tham quan\"]','[\"Vé máy bay khứ hồi\",\"Bữa trưa và tối\",\"Chi phí cá nhân\"]'),
(1,2,'Tour Khám phá Hồ Chí Minh 3N2Đ','Nhà thờ Đức Bà, Bến Thành, Củ Chi.','Hồ Chí Minh, Việt Nam','2025-10-01','2025-10-03',3500000.00,'VND',30,2,30,'https://cdn.example.com/tours/ho-chi-minh/thumb.jpg','[\"https://cdn.example.com/tours/ho-chi-minh/1.jpg\",\"https://cdn.example.com/tours/ho-chi-minh/2.jpg\"]',4.7,'family-friendly,best-seller','published','Ngày 1: Nhà thờ Đức Bà; Ngày 2: Củ Chi; Ngày 3: Bến Thành.','Trung tâm Hồ Chí Minh','Vietnamese,English','Xe đưa đón,Vé tham quan chính,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',3,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 3 sao\",\"Bữa sáng hàng ngày\",\"Vé tham quan\"]','[\"Vé máy bay khứ hồi\",\"Bữa trưa và tối\",\"Chi phí cá nhân\"]'),
(1,3,'Tour Khám phá Hải Phòng 3N2Đ','Đảo Cát Bà, vịnh Lan Hạ, ẩm thực hải sản.','Hải Phòng, Việt Nam','2025-10-01','2025-10-03',3200000.00,'VND',25,2,25,'https://cdn.example.com/tours/hai-phong/thumb.jpg','[\"https://cdn.example.com/tours/hai-phong/1.jpg\",\"https://cdn.example.com/tours/hai-phong/2.jpg\"]',4.6,'family-friendly','published','Ngày 1: Cát Bà; Ngày 2: Vịnh Lan Hạ; Ngày 3: ẩm thực.','Trung tâm Hải Phòng','Vietnamese,English','Xe đưa đón,Vé tàu,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',3,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 3 sao\",\"Bữa sáng hàng ngày\",\"Vé tàu\"]','[\"Vé máy bay khứ hồi\",\"Bữa trưa và tối\",\"Chi phí cá nhân\"]'),
(1,4,'Tour Khám phá Đà Nẵng 3N2Đ','Bà Nà Hills, Hội An, Ngũ Hành Sơn.','Đà Nẵng, Việt Nam','2025-10-01','2025-10-03',3500000.00,'VND',30,2,30,'https://cdn.example.com/tours/da-nang/thumb.jpg','[\"https://cdn.example.com/tours/da-nang/1.jpg\",\"https://cdn.example.com/tours/da-nang/2.jpg\"]',4.7,'family-friendly,best-seller','published','Ngày 1: Bà Nà Hills; Ngày 2: Hội An; Ngày 3: Ngũ Hành Sơn.','Sân bay Đà Nẵng (cổng đến)','Vietnamese,English','Xe đưa đón,Vé tham quan chính,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',3,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 3 sao\",\"Bữa sáng hàng ngày\",\"Vé cáp treo Bà Nà\"]','[\"Vé máy bay khứ hồi\",\"Bữa trưa và tối\",\"Chi phí cá nhân\"]'),
(1,5,'Tour Khám phá Cần Thơ 3N2Đ','Chợ nổi, miệt vườn, ẩm thực miền Tây.','Cần Thơ, Việt Nam','2025-10-01','2025-10-03',1900000.00,'VND',25,2,25,'https://cdn.example.com/tours/can-tho/thumb.jpg','[\"https://cdn.example.com/tours/can-tho/1.jpg\",\"https://cdn.example.com/tours/can-tho/2.jpg\"]',4.4,'local-favorite','published','Ngày 1: Chợ nổi; Ngày 2: miệt vườn; Ngày 3: ẩm thực.','Trung tâm Cần Thơ','Vietnamese,English','Xe đưa đón,Vé tham quan,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',3,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 3 sao\",\"Bữa sáng hàng ngày\"]','[\"Vé máy bay khứ hồi\",\"Bữa trưa và tối\"]'),
(1,6,'Tour Khám phá An Giang 2N1Đ','Chợ nổi, miếu cổ, ẩm thực sông nước.','An Giang, Việt Nam','2025-10-01','2025-10-02',1200000.00,'VND',20,2,20,'https://cdn.example.com/tours/an-giang/thumb.jpg','[\"https://cdn.example.com/tours/an-giang/1.jpg\"]',4.2,'local-favorite','published','Ngày 1: Chợ nổi và miếu; Ngày 2: trải nghiệm miệt vườn.','Trung tâm An Giang','Vietnamese,English','Xe đưa đón,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 2-3 sao\",\"Bữa sáng\"]','[\"Vé máy bay khứ hồi\",\"Chi phí cá nhân\"]'),
(1,7,'Tour Khám phá Bà Rịa - Vũng Tàu 2N1Đ','Bãi tắm, ẩm thực hải sản, ngắm biển.','Bà Rịa - Vũng Tàu, Việt Nam','2025-10-01','2025-10-02',1300000.00,'VND',25,2,25,'https://cdn.example.com/tours/ba-ria-vung-tau/thumb.jpg','[\"https://cdn.example.com/tours/ba-ria-vung-tau/1.jpg\"]',4.5,'sea-view','published','Ngày 1: Bãi tắm; Ngày 2: ẩm thực hải sản.','Trung tâm Bà Rịa - Vũng Tàu','Vietnamese,English','Xe đưa đón,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 3 sao\",\"Bữa sáng\"]','[\"Vé máy bay khứ hồi\",\"Chi phí cá nhân\"]'),
(1,8,'Tour Khám phá Bắc Giang 2N1Đ','Khám phá làng nghề, cảnh quan nông thôn.','Bắc Giang, Việt Nam','2025-10-01','2025-10-02',1100000.00,'VND',20,2,20,'https://cdn.example.com/tours/bac-giang/thumb.jpg','[\"https://cdn.example.com/tours/bac-giang/1.jpg\"]',4.0,'local-favorite','published','Ngày 1: Làng nghề và chợ; Ngày 2: trải nghiệm nông thôn.','Trung tâm Bắc Giang','Vietnamese,English','Xe đưa đón,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 2-3 sao\",\"Bữa sáng\"]','[\"Vé máy bay khứ hồi\",\"Chi phí cá nhân\"]'),
(1,9,'Tour Khám phá Bắc Kạn 2N1Đ','Khám phá rừng, thác nước và văn hoá dân tộc.','Bắc Kạn, Việt Nam','2025-10-01','2025-10-02',1150000.00,'VND',18,2,18,'https://cdn.example.com/tours/bac-kan/thumb.jpg','[\"https://cdn.example.com/tours/bac-kan/1.jpg\"]',4.1,'local-favorite','published','Khám phá rừng và bản làng.','Trung tâm Bắc Kạn','Vietnamese,English','Xe đưa đón,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 2 sao\",\"Bữa sáng\"]','[\"Vé máy bay khứ hồi\",\"Chi phí cá nhân\"]'),
(1,10,'Tour Khám phá Bạc Liêu 2N1Đ','Âm nhạc đờn ca tài tử, ẩm thực miền Tây.','Bạc Liêu, Việt Nam','2025-10-01','2025-10-02',1100000.00,'VND',20,2,20,'https://cdn.example.com/tours/bac-lieu/thumb.jpg','[\"https://cdn.example.com/tours/bac-lieu/1.jpg\"]',4.0,'local-favorite','published','Trải nghiệm đờn ca tài tử và hải sản.','Trung tâm Bạc Liêu','Vietnamese,English','Xe đưa đón,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 2-3 sao\",\"Bữa sáng\"]','[\"Vé máy bay khứ hồi\",\"Chi phí cá nhân\"]'),
(1,11,'Tour Khám phá Bắc Ninh 1N','Thăm các di tích Kinh Bắc và làng nghề.','Bắc Ninh, Việt Nam','2025-10-05','2025-10-05',800000.00,'VND',20,2,20,'https://cdn.example.com/tours/bac-ninh/thumb.jpg','[\"https://cdn.example.com/tours/bac-ninh/1.jpg\"]',4.2,'local-favorite','published','Tour 1 ngày thăm Làng nghề và đền miếu.','Trung tâm Bắc Ninh','Vietnamese,English','Xe đưa đón,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn sáng\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,12,'Tour Khám phá Bến Tre 1N','Tour miệt vườn, xe đạp và dừa.','Bến Tre, Việt Nam','2025-10-05','2025-10-05',750000.00,'VND',18,2,18,'https://cdn.example.com/tours/ben-tre/thumb.jpg','[\"https://cdn.example.com/tours/ben-tre/1.jpg\"]',4.1,'local-favorite','published','Tour 1 ngày trải nghiệm miệt vườn.','Trung tâm Bến Tre','Vietnamese,English','Xe đạp,Ăn trưa địa phương','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,13,'Tour Khám phá Bình Định 2N1Đ','Khám phá Quy Nhơn, bãi biển, ẩm thực võ cổ truyền.','Bình Định, Việt Nam','2025-10-01','2025-10-02',1400000.00,'VND',22,2,22,'https://cdn.example.com/tours/binh-dinh/thumb.jpg','[\"https://cdn.example.com/tours/binh-dinh/1.jpg\",\"https://cdn.example.com/tours/binh-dinh/2.jpg\"]',4.3,'local-favorite','published','Ngày 1: Thành phố; Ngày 2: bãi biển và ẩm thực.','Trung tâm Bình Định','Vietnamese,English','Xe đưa đón,Vé tham quan,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 3 sao\",\"Bữa sáng\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,14,'Tour Khám phá Bình Dương 1N','Tour công nghiệp & ẩm thực đô thị.','Bình Dương, Việt Nam','2025-10-05','2025-10-05',900000.00,'VND',20,2,20,'https://cdn.example.com/tours/binh-duong/thumb.jpg','[\"https://cdn.example.com/tours/binh-duong/1.jpg\"]',4.0,'local-favorite','published','Tour 1 ngày tham quan khu đô thị và ẩm thực.','Trung tâm Bình Dương','Vietnamese,English','Xe đưa đón,Ăn trưa','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,15,'Tour Khám phá Bình Phước 1N','Trải nghiệm nông nghiệp và vườn cây công nghiệp.','Bình Phước, Việt Nam','2025-10-05','2025-10-05',850000.00,'VND',18,2,18,'https://cdn.example.com/tours/binh-phuoc/thumb.jpg','[\"https://cdn.example.com/tours/binh-phuoc/1.jpg\"]',3.9,'local-favorite','published','Tour 1 ngày vườn cây và trải nghiệm địa phương.','Trung tâm Bình Phước','Vietnamese,English','Xe đưa đón,Ăn sáng','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn sáng\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,16,'Tour Khám phá Bình Thuận 2N1Đ','Mũi Né, cồn cát, hải sản và lặn.','Bình Thuận, Việt Nam','2025-10-01','2025-10-02',1450000.00,'VND',24,2,24,'https://cdn.example.com/tours/binh-thuan/thumb.jpg','[\"https://cdn.example.com/tours/binh-thuan/1.jpg\"]',4.2,'sea-view','published','Ngày 1: Mũi Né; Ngày 2: cồn cát và hải sản.','Trung tâm Bình Thuận','Vietnamese,English','Xe đưa đón,Vé tham quan,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 3 sao\",\"Bữa sáng\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,17,'Tour Khám phá Cà Mau 2N1Đ','Mũi Cà Mau, rừng ngập mặn, ẩm thực biển.','Cà Mau, Việt Nam','2025-10-01','2025-10-02',1200000.00,'VND',20,2,20,'https://cdn.example.com/tours/ca-mau/thumb.jpg','[\"https://cdn.example.com/tours/ca-mau/1.jpg\"]',4.0,'local-favorite','published','Ngày 1: Mũi Cà Mau; Ngày 2: rừng ngập mặn.','Trung tâm Cà Mau','Vietnamese,English','Xe đưa đón,Vé tham quan,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 2-3 sao\",\"Bữa sáng\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,18,'Tour Khám phá Cao Bằng 2N1Đ','Thác Bản Giốc, hang động và lịch sử.','Cao Bằng, Việt Nam','2025-10-01','2025-10-02',1250000.00,'VND',18,2,18,'https://cdn.example.com/tours/cao-bang/thumb.jpg','[\"https://cdn.example.com/tours/cao-bang/1.jpg\"]',4.1,'local-favorite','published','Ngày 1: Thác Bản Giốc; Ngày 2: thăm hang động.','Trung tâm Cao Bằng','Vietnamese,English','Xe đưa đón,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 2 sao\",\"Bữa sáng\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,19,'Tour Khám phá Đắk Lắk 2N1Đ','Buôn Ma Thuột, văn hóa Tây Nguyên, cà phê.','Đắk Lắk, Việt Nam','2025-10-01','2025-10-02',1300000.00,'VND',22,2,22,'https://cdn.example.com/tours/dak-lak/thumb.jpg','[\"https://cdn.example.com/tours/dak-lak/1.jpg\"]',4.2,'local-favorite','published','Ngày 1: Buôn Ma Thuột; Ngày 2: trải nghiệm cà phê.','Trung tâm Đắk Lắk','Vietnamese,English','Xe đưa đón,Vé tham quan,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 3 sao\",\"Bữa sáng\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,20,'Tour Khám phá Đắk Nông 2N1Đ','Rừng, thác và văn hóa bản địa.','Đắk Nông, Việt Nam','2025-10-01','2025-10-02',1150000.00,'VND',18,2,18,'https://cdn.example.com/tours/dak-nong/thumb.jpg','[\"https://cdn.example.com/tours/dak-nong/1.jpg\"]',4.0,'local-favorite','published','Ngày 1: rừng và thác; Ngày 2: văn hoá bản địa.','Trung tâm Đắk Nông','Vietnamese,English','Xe đưa đón,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 2 sao\",\"Bữa sáng\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,21,'Tour Khám phá Điện Biên 2N1Đ','Lịch sử Điện Biên Phủ, di tích và danh thắng.','Điện Biên, Việt Nam','2025-10-01','2025-10-02',1250000.00,'VND',18,2,18,'https://cdn.example.com/tours/dien-bien/thumb.jpg','[\"https://cdn.example.com/tours/dien-bien/1.jpg\"]',4.2,'local-favorite','published','Ngày 1: Di tích; Ngày 2: khung cảnh núi.','Trung tâm Điện Biên','Vietnamese,English','Xe đưa đón,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 2 sao\",\"Bữa sáng\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,22,'Tour Khám phá Đồng Nai 1N','Khu du lịch, vườn trái cây và ẩm thực.','Đồng Nai, Việt Nam','2025-10-05','2025-10-05',900000.00,'VND',20,2,20,'https://cdn.example.com/tours/dong-nai/thumb.jpg','[\"https://cdn.example.com/tours/dong-nai/1.jpg\"]',4.1,'local-favorite','published','Tour 1 ngày vườn trái cây và du lịch sinh thái.','Trung tâm Đồng Nai','Vietnamese,English','Xe đưa đón,Ăn trưa','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,23,'Tour Khám phá Đồng Tháp 1N','Miệt vườn, chợ nổi và sinh thái.','Đồng Tháp, Việt Nam','2025-10-05','2025-10-05',850000.00,'VND',18,2,18,'https://cdn.example.com/tours/dong-thap/thumb.jpg','[\"https://cdn.example.com/tours/dong-thap/1.jpg\"]',4.0,'local-favorite','published','Tour 1 ngày trải nghiệm miệt vườn.','Trung tâm Đồng Tháp','Vietnamese,English','Xe đưa đón,Ăn trưa','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,24,'Tour Khám phá Gia Lai 2N1Đ','Cao nguyên, cà phê và văn hoá dân tộc.','Gia Lai, Việt Nam','2025-10-01','2025-10-02',1250000.00,'VND',20,2,20,'https://cdn.example.com/tours/gia-lai/thumb.jpg','[\"https://cdn.example.com/tours/gia-lai/1.jpg\"]',4.0,'local-favorite','published','Ngày 1: Pleiku; Ngày 2: văn hóa Tây Nguyên.','Trung tâm Gia Lai','Vietnamese,English','Xe đưa đón,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 2-3 sao\",\"Bữa sáng\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,25,'Tour Khám phá Hà Giang 3N2Đ','Cao nguyên đá, đèo Mã Pí Lèng, ruộng bậc thang.','Hà Giang, Việt Nam','2025-10-01','2025-10-03',2800000.00,'VND',18,2,18,'https://cdn.example.com/tours/ha-giang/thumb.jpg','[\"https://cdn.example.com/tours/ha-giang/1.jpg\",\"https://cdn.example.com/tours/ha-giang/2.jpg\"]',4.6,'local-favorite','published','Ngày 1: Đồng Văn; Ngày 2: Mã Pí Lèng; Ngày 3: Yên Minh.','Trung tâm Hà Giang','Vietnamese,English','Xe đưa đón,Vé tham quan,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','moderate',3,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 2-3 sao\",\"Bữa sáng hàng ngày\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,26,'Tour Khám phá Hà Nam 1N','Di tích lịch sử, quê truyền thống.','Hà Nam, Việt Nam','2025-10-05','2025-10-05',800000.00,'VND',20,2,20,'https://cdn.example.com/tours/ha-nam/thumb.jpg','[\"https://cdn.example.com/tours/ha-nam/1.jpg\"]',4.0,'local-favorite','published','Tour 1 ngày thăm di tích và làng quê.','Trung tâm Hà Nam','Vietnamese,English','Xe đưa đón,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn sáng\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,27,'Tour Khám phá Hà Tĩnh 2N1Đ','Bờ biển, di tích lịch sử và ẩm thực.','Hà Tĩnh, Việt Nam','2025-10-01','2025-10-02',1200000.00,'VND',20,2,20,'https://cdn.example.com/tours/ha-tinh/thumb.jpg','[\"https://cdn.example.com/tours/ha-tinh/1.jpg\"]',4.0,'local-favorite','published','Ngày 1: bãi biển; Ngày 2: di tích.','Trung tâm Hà Tĩnh','Vietnamese,English','Xe đưa đón,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 2-3 sao\",\"Bữa sáng\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,28,'Tour Khám phá Hải Dương 1N','Làng nghề, ẩm thực và trải nghiệm nông thôn.','Hải Dương, Việt Nam','2025-10-05','2025-10-05',850000.00,'VND',18,2,18,'https://cdn.example.com/tours/hai-duong/thumb.jpg','[\"https://cdn.example.com/tours/hai-duong/1.jpg\"]',4.0,'local-favorite','published','Tour 1 ngày làng nghề và ẩm thực.','Trung tâm Hải Dương','Vietnamese,English','Xe đưa đón,Ăn trưa','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,29,'Tour Khám phá Hậu Giang 1N','Miệt vườn, ẩm thực và trải nghiệm chợ nổi.','Hậu Giang, Việt Nam','2025-10-05','2025-10-05',800000.00,'VND',18,2,18,'https://cdn.example.com/tours/hau-giang/thumb.jpg','[\"https://cdn.example.com/tours/hau-giang/1.jpg\"]',4.0,'local-favorite','published','Tour 1 ngày miệt vườn.','Trung tâm Hậu Giang','Vietnamese,English','Xe đưa đón,Ăn trưa','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,30,'Tour Khám phá Hòa Bình 1N','Hồ, hang động và trải nghiệm dân tộc.','Hòa Bình, Việt Nam','2025-10-05','2025-10-05',900000.00,'VND',20,2,20,'https://cdn.example.com/tours/hoa-binh/thumb.jpg','[\"https://cdn.example.com/tours/hoa-binh/1.jpg\"]',4.1,'local-favorite','published','Tour 1 ngày hồ và bản làng.','Trung tâm Hòa Bình','Vietnamese,English','Xe đưa đón,Ăn trưa','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,31,'Tour Khám phá Hưng Yên 1N','Làng nghề, chùa chiền và ẩm thực địa phương.','Hưng Yên, Việt Nam','2025-10-05','2025-10-05',800000.00,'VND',18,2,18,'https://cdn.example.com/tours/hung-yen/thumb.jpg','[\"https://cdn.example.com/tours/hung-yen/1.jpg\"]',4.0,'local-favorite','published','Tour 1 ngày làng nghề và chùa chiền.','Trung tâm Hưng Yên','Vietnamese,English','Xe đưa đón,Ăn trưa','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,32,'Tour Khám phá Khánh Hòa 3N2Đ','Nha Trang, lặn biển, đảo và ẩm thực hải sản.','Khánh Hòa, Việt Nam','2025-10-01','2025-10-03',3600000.00,'VND',30,2,30,'https://cdn.example.com/tours/khanh-hoa/thumb.jpg','[\"https://cdn.example.com/tours/khanh-hoa/1.jpg\",\"https://cdn.example.com/tours/khanh-hoa/2.jpg\"]',4.7,'sea-view,family-friendly','published','Ngày 1: Nha Trang; Ngày 2: lặn biển; Ngày 3: đảo.','Sân bay Cam Ranh (cổng đến)','Vietnamese,English','Xe đưa đón,Vé tham quan chính,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',3,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 3 sao\",\"Bữa sáng hàng ngày\",\"Tour lặn biển\"]','[\"Vé máy bay\",\"Bữa trưa và tối\",\"Chi phí cá nhân\"]'),
(1,33,'Tour Khám phá Kiên Giang 3N2Đ','Phú Quốc, đảo, biển và hải sản.','Kiên Giang, Việt Nam','2025-10-01','2025-10-03',3800000.00,'VND',30,2,30,'https://cdn.example.com/tours/kien-giang/thumb.jpg','[\"https://cdn.example.com/tours/kien-giang/1.jpg\",\"https://cdn.example.com/tours/kien-giang/2.jpg\"]',4.8,'sea-view,best-seller','published','Ngày 1: Phú Quốc; Ngày 2: đảo; Ngày 3: thư giãn.','Sân bay Phú Quốc (cổng đến)','Vietnamese,English','Xe đưa đón,Vé tham quan,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',3,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 4 sao\",\"Bữa sáng hàng ngày\",\"Tour đảo\"]','[\"Vé máy bay\",\"Bữa trưa và tối\",\"Chi phí cá nhân\"]'),
(1,34,'Tour Khám phá Kon Tum 2N1Đ','Văn hóa dân tộc, rừng và bản làng.','Kon Tum, Việt Nam','2025-10-01','2025-10-02',1250000.00,'VND',18,2,18,'https://cdn.example.com/tours/kon-tum/thumb.jpg','[\"https://cdn.example.com/tours/kon-tum/1.jpg\"]',4.1,'local-favorite','published','Ngày 1: bản làng; Ngày 2: rừng.','Trung tâm Kon Tum','Vietnamese,English','Xe đưa đón,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 2-3 sao\",\"Bữa sáng\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,35,'Tour Khám phá Lai Châu 2N1Đ','Đèo, bản làng, ruộng bậc thang.','Lai Châu, Việt Nam','2025-10-01','2025-10-02',1300000.00,'VND',18,2,18,'https://cdn.example.com/tours/lai-chau/thumb.jpg','[\"https://cdn.example.com/tours/lai-chau/1.jpg\"]',4.2,'local-favorite','published','Ngày 1: đèo và bản làng; Ngày 2: ruộng bậc thang.','Trung tâm Lai Châu','Vietnamese,English','Xe đưa đón,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','moderate',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 2 sao\",\"Bữa sáng\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,36,'Tour Khám phá Lâm Đồng 3N2Đ','Đà Lạt, vườn hoa, hồ và quán cà phê.','Lâm Đồng, Việt Nam','2025-10-01','2025-10-03',3000000.00,'VND',28,2,28,'https://cdn.example.com/tours/lam-dong/thumb.jpg','[\"https://cdn.example.com/tours/lam-dong/1.jpg\",\"https://cdn.example.com/tours/lam-dong/2.jpg\"]',4.6,'family-friendly','published','Ngày 1: Đà Lạt; Ngày 2: vườn hoa; Ngày 3: hồ và cà phê.','Trung tâm Đà Lạt','Vietnamese,English','Xe đưa đón,Vé tham quan,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',3,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 3 sao\",\"Bữa sáng hàng ngày\",\"Vé tham quan\"]','[\"Vé máy bay\",\"Bữa trưa và tối\",\"Chi phí cá nhân\"]'),
(1,37,'Tour Khám phá Lạng Sơn 1N','Chợ cửa khẩu, núi đá và ẩm thực.','Lạng Sơn, Việt Nam','2025-10-05','2025-10-05',900000.00,'VND',20,2,20,'https://cdn.example.com/tours/lang-son/thumb.jpg','[\"https://cdn.example.com/tours/lang-son/1.jpg\"]',4.0,'local-favorite','published','Tour 1 ngày cửa khẩu và núi.','Trung tâm Lạng Sơn','Vietnamese,English','Xe đưa đón,Ăn trưa','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,38,'Tour Khám phá Lào Cai 2N1Đ','Sa Pa, Fansipan, ruộng bậc thang.','Lào Cai, Việt Nam','2025-10-01','2025-10-02',1800000.00,'VND',24,2,24,'https://cdn.example.com/tours/lao-cai/thumb.jpg','[\"https://cdn.example.com/tours/lao-cai/1.jpg\"]',4.5,'family-friendly','published','Ngày 1: Sa Pa; Ngày 2: Fansipan.','Trung tâm Lào Cai','Vietnamese,English','Xe đưa đón,Vé cáp treo,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','moderate',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 3 sao\",\"Bữa sáng\",\"Vé cáp treo\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,39,'Tour Khám phá Long An 1N','Nông nghiệp, làng nghề và ẩm thực.','Long An, Việt Nam','2025-10-05','2025-10-05',800000.00,'VND',18,2,18,'https://cdn.example.com/tours/long-an/thumb.jpg','[\"https://cdn.example.com/tours/long-an/1.jpg\"]',4.0,'local-favorite','published','Tour 1 ngày trải nghiệm làng nghề.','Trung tâm Long An','Vietnamese,English','Xe đưa đón,Ăn trưa','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,40,'Tour Khám phá Nam Định 1N','Đền chùa, làng nghề và ẩm thực truyền thống.','Nam Định, Việt Nam','2025-10-05','2025-10-05',850000.00,'VND',18,2,18,'https://cdn.example.com/tours/nam-dinh/thumb.jpg','[\"https://cdn.example.com/tours/nam-dinh/1.jpg\"]',4.0,'local-favorite','published','Tour 1 ngày đền chùa và làng nghề.','Trung tâm Nam Định','Vietnamese,English','Xe đưa đón,Ăn trưa','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,41,'Tour Khám phá Nghệ An 2N1Đ','Vinh, biển Cửa Lò, di tích lịch sử.','Nghệ An, Việt Nam','2025-10-01','2025-10-02',1300000.00,'VND',22,2,22,'https://cdn.example.com/tours/nghe-an/thumb.jpg','[\"https://cdn.example.com/tours/nghe-an/1.jpg\"]',4.1,'local-favorite','published','Ngày 1: Vinh; Ngày 2: Cửa Lò.','Trung tâm Nghệ An','Vietnamese,English','Xe đưa đón,Ăn sáng','Đồ dùng cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 3 sao\",\"Bữa sáng\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,42,'Tour Khám phá Ninh Bình 2N1Đ','Tràng An, Bái Đính, Tam Cốc.','Ninh Bình, Việt Nam','2025-10-01','2025-10-02',1400000.00,'VND',26,2,26,'https://cdn.example.com/tours/ninh-binh/thumb.jpg','[\"https://cdn.example.com/tours/ninh-binh/1.jpg\",\"https://cdn.example.com/tours/ninh-binh/2.jpg\"]',4.4,'family-friendly','published','Ngày 1: Tràng An; Ngày 2: Bái Đính và Tam Cốc.','Trung tâm Ninh Bình','Vietnamese,English','Xe đưa đón,Vé thuyền,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 3 sao\",\"Bữa sáng\",\"Vé thuyền\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,43,'Tour Khám phá Ninh Thuận 2N1Đ','Phong cảnh nắng gió, di sản Cham.','Ninh Thuận, Việt Nam','2025-10-01','2025-10-02',1200000.00,'VND',20,2,20,'https://cdn.example.com/tours/ninh-thuan/thumb.jpg','[\"https://cdn.example.com/tours/ninh-thuan/1.jpg\"]',4.0,'local-favorite','published','Ngày 1: biển và di tích Cham; Ngày 2: trải nghiệm nắng gió.','Trung tâm Ninh Thuận','Vietnamese,English','Xe đưa đón,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 2-3 sao\",\"Bữa sáng\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,44,'Tour Khám phá Phú Thọ 1N','Đền Hùng, suối nước nóng và ẩm thực dân gian.','Phú Thọ, Việt Nam','2025-10-05','2025-10-05',900000.00,'VND',20,2,20,'https://cdn.example.com/tours/phu-tho/thumb.jpg','[\"https://cdn.example.com/tours/phu-tho/1.jpg\"]',4.0,'local-favorite','published','Tour 1 ngày tham quan Đền Hùng và suối.','Trung tâm Phú Thọ','Vietnamese,English','Xe đưa đón,Ăn trưa','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,45,'Tour Khám phá Phú Yên 2N1Đ','Gành Đá Dĩa, biển và ẩm thực.','Phú Yên, Việt Nam','2025-10-01','2025-10-02',1250000.00,'VND',20,2,20,'https://cdn.example.com/tours/phu-yen/thumb.jpg','[\"https://cdn.example.com/tours/phu-yen/1.jpg\"]',4.1,'sea-view','published','Ngày 1: Gành Đá Dĩa; Ngày 2: biển và ẩm thực.','Trung tâm Phú Yên','Vietnamese,English','Xe đưa đón,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 2-3 sao\",\"Bữa sáng\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,46,'Tour Khám phá Quảng Bình 2N1Đ','Phong Nha - hang động và khám phá thiên nhiên.','Quảng Bình, Việt Nam','2025-10-01','2025-10-02',1500000.00,'VND',22,2,22,'https://cdn.example.com/tours/quang-binh/thumb.jpg','[\"https://cdn.example.com/tours/quang-binh/1.jpg\"]',4.3,'local-favorite','published','Ngày 1: Phong Nha; Ngày 2: hang động và khám phá.','Trung tâm Quảng Bình','Vietnamese,English','Xe đưa đón,Vé tham quan,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','moderate',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 3 sao\",\"Bữa sáng\",\"Vé tham quan\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,47,'Tour Khám phá Quảng Nam 2N1Đ','Hội An, Mỹ Sơn và ẩm thực miền Trung.','Quảng Nam, Việt Nam','2025-10-01','2025-10-02',1700000.00,'VND',26,2,26,'https://cdn.example.com/tours/quang-nam/thumb.jpg','[\"https://cdn.example.com/tours/quang-nam/1.jpg\"]',4.5,'family-friendly','published','Ngày 1: Hội An; Ngày 2: Mỹ Sơn.','Trung tâm Quảng Nam','Vietnamese,English','Xe đưa đón,Vé tham quan,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 3 sao\",\"Bữa sáng\",\"Vé tham quan\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,48,'Tour Khám phá Quảng Ngãi 1N','Bãi biển, đảo nhỏ và ẩm thực địa phương.','Quảng Ngãi, Việt Nam','2025-10-05','2025-10-05',950000.00,'VND',18,2,18,'https://cdn.example.com/tours/quang-ngai/thumb.jpg','[\"https://cdn.example.com/tours/quang-ngai/1.jpg\"]',4.0,'local-favorite','published','Tour 1 ngày bãi biển và đảo nhỏ.','Trung tâm Quảng Ngãi','Vietnamese,English','Xe đưa đón,Ăn trưa','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,49,'Tour Khám phá Quảng Ninh 2N1Đ','Vịnh Hạ Long, thuyền ngủ đêm và hang động.','Quảng Ninh, Việt Nam','2025-10-01','2025-10-02',4200000.00,'VND',28,2,28,'https://cdn.example.com/tours/quang-ninh/thumb.jpg','[\"https://cdn.example.com/tours/quang-ninh/1.jpg\",\"https://cdn.example.com/tours/quang-ninh/2.jpg\"]',4.8,'sea-view,best-seller','published','Ngày 1: Hạ Long; Ngày 2: hang động và câu mực đêm.','Bến tàu Hạ Long','Vietnamese,English','Xe đưa đón,Vé thuyền,Ăn sáng','Vé máy bay,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','moderate',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Ngủ đêm trên thuyền\",\"Bữa sáng\",\"Vé tham quan\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,50,'Tour Khám phá Quảng Trị 1N','Di tích lịch sử, biển và ẩm thực.','Quảng Trị, Việt Nam','2025-10-05','2025-10-05',1000000.00,'VND',18,2,18,'https://cdn.example.com/tours/quang-tri/thumb.jpg','[\"https://cdn.example.com/tours/quang-tri/1.jpg\"]',4.0,'local-favorite','published','Tour 1 ngày di tích lịch sử và biển.','Trung tâm Quảng Trị','Vietnamese,English','Xe đưa đón,Ăn trưa','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,51,'Tour Khám phá Sóc Trăng 1N','Ẩm thực Khmer, chùa chiền và lễ hội.','Sóc Trăng, Việt Nam','2025-10-05','2025-10-05',900000.00,'VND',18,2,18,'https://cdn.example.com/tours/soc-trang/thumb.jpg','[\"https://cdn.example.com/tours/soc-trang/1.jpg\"]',4.0,'local-favorite','published','Tour 1 ngày khám phá ẩm thực Khmer.','Trung tâm Sóc Trăng','Vietnamese,English','Xe đưa đón,Ăn trưa','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,52,'Tour Khám phá Sơn La 1N','Ruộng bậc thang, chè và đặc sản vùng cao.','Sơn La, Việt Nam','2025-10-05','2025-10-05',950000.00,'VND',18,2,18,'https://cdn.example.com/tours/son-la/thumb.jpg','[\"https://cdn.example.com/tours/son-la/1.jpg\"]',4.0,'local-favorite','published','Tour 1 ngày ruộng bậc thang và chè.','Trung tâm Sơn La','Vietnamese,English','Xe đưa đón,Ăn trưa','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,53,'Tour Khám phá Tây Ninh 1N','Núi Bà Đen, hành hương và thiên nhiên.','Tây Ninh, Việt Nam','2025-10-05','2025-10-05',900000.00,'VND',18,2,18,'https://cdn.example.com/tours/tay-ninh/thumb.jpg','[\"https://cdn.example.com/tours/tay-ninh/1.jpg\"]',4.0,'local-favorite','published','Tour 1 ngày lên núi Bà Đen và viếng chùa.','Trung tâm Tây Ninh','Vietnamese,English','Xe đưa đón,Ăn trưa','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','moderate',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,54,'Tour Khám phá Thái Bình 1N','Biển, chùa và làng nghề.','Thái Bình, Việt Nam','2025-10-05','2025-10-05',850000.00,'VND',18,2,18,'https://cdn.example.com/tours/thai-binh/thumb.jpg','[\"https://cdn.example.com/tours/thai-binh/1.jpg\"]',4.0,'local-favorite','published','Tour 1 ngày bãi biển và làng nghề.','Trung tâm Thái Bình','Vietnamese,English','Xe đưa đón,Ăn trưa','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,55,'Tour Khám phá Thái Nguyên 1N','Vùng chè, thăm vườn chè và thưởng trà.','Thái Nguyên, Việt Nam','2025-10-05','2025-10-05',900000.00,'VND',18,2,18,'https://cdn.example.com/tours/thai-nguyen/thumb.jpg','[\"https://cdn.example.com/tours/thai-nguyen/1.jpg\"]',4.0,'local-favorite','published','Tour 1 ngày thăm vườn chè và thưởng trà.','Trung tâm Thái Nguyên','Vietnamese,English','Xe đưa đón,Ăn trưa','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,56,'Tour Khám phá Thanh Hóa 3N2Đ','Sầm Sơn, Pù Luông, di tích và ẩm thực.','Thanh Hóa, Việt Nam','2025-10-01','2025-10-03',2900000.00,'VND',28,2,28,'https://cdn.example.com/tours/thanh-hoa/thumb.jpg','[\"https://cdn.example.com/tours/thanh-hoa/1.jpg\",\"https://cdn.example.com/tours/thanh-hoa/2.jpg\"]',4.5,'family-friendly','published','Ngày 1: Sầm Sơn; Ngày 2: Pù Luông; Ngày 3: di tích.','Trung tâm Thanh Hóa','Vietnamese,English','Xe đưa đón,Vé tham quan,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',3,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 3 sao\",\"Bữa sáng\",\"Vé tham quan\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,57,'Tour Khám phá Thừa Thiên - Huế 2N1Đ','Cố đô Huế, lăng tẩm, ẩm thực cung đình.','Thừa Thiên - Huế, Việt Nam','2025-10-01','2025-10-02',1500000.00,'VND',24,2,24,'https://cdn.example.com/tours/thua-thien-hue/thumb.jpg','[\"https://cdn.example.com/tours/thua-thien-hue/1.jpg\"]',4.5,'local-favorite','published','Ngày 1: Kinh thành; Ngày 2: lăng tẩm và ẩm thực.','Trung tâm Huế','Vietnamese,English','Xe đưa đón,Vé tham quan,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 3 sao\",\"Bữa sáng\",\"Vé tham quan\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,58,'Tour Khám phá Tiền Giang 1N','Miệt vườn, chợ nổi và ẩm thực trái cây.','Tiền Giang, Việt Nam','2025-10-05','2025-10-05',850000.00,'VND',18,2,18,'https://cdn.example.com/tours/tien-giang/thumb.jpg','[\"https://cdn.example.com/tours/tien-giang/1.jpg\"]',4.0,'local-favorite','published','Tour 1 ngày miệt vườn và chợ nổi.','Trung tâm Tiền Giang','Vietnamese,English','Xe đưa đón,Ăn trưa','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,59,'Tour Khám phá Trà Vinh 1N','Ẩm thực Khmer, di tích và văn hoá.','Trà Vinh, Việt Nam','2025-10-05','2025-10-05',800000.00,'VND',18,2,18,'https://cdn.example.com/tours/tra-vinh/thumb.jpg','[\"https://cdn.example.com/tours/tra-vinh/1.jpg\"]',4.0,'local-favorite','published','Tour 1 ngày khám phá văn hoá Khmer.','Trung tâm Trà Vinh','Vietnamese,English','Xe đưa đón,Ăn trưa','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,60,'Tour Khám phá Tuyên Quang 1N','Di tích cách mạng, bản làng và thiên nhiên.','Tuyên Quang, Việt Nam','2025-10-05','2025-10-05',900000.00,'VND',18,2,18,'https://cdn.example.com/tours/tuyen-quang/thumb.jpg','[\"https://cdn.example.com/tours/tuyen-quang/1.jpg\"]',4.0,'local-favorite','published','Tour 1 ngày lịch sử và bản làng.','Trung tâm Tuyên Quang','Vietnamese,English','Xe đưa đón,Ăn trưa','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,61,'Tour Khám phá Vĩnh Long 1N','Chợ nổi, miệt vườn và ẩm thực miền Tây.','Vĩnh Long, Việt Nam','2025-10-05','2025-10-05',850000.00,'VND',18,2,18,'https://cdn.example.com/tours/vinh-long/thumb.jpg','[\"https://cdn.example.com/tours/vinh-long/1.jpg\"]',4.0,'local-favorite','published','Tour 1 ngày chợ nổi và miệt vườn.','Trung tâm Vĩnh Long','Vietnamese,English','Xe đưa đón,Ăn trưa','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,62,'Tour Khám phá Vĩnh Phúc 1N','Tam Đảo, nghỉ dưỡng cuối tuần và leo núi nhẹ.','Vĩnh Phúc, Việt Nam','2025-10-05','2025-10-05',950000.00,'VND',20,2,20,'https://cdn.example.com/tours/vinh-phuc/thumb.jpg','[\"https://cdn.example.com/tours/vinh-phuc/1.jpg\"]',4.0,'family-friendly','published','Tour 1 ngày Tam Đảo, nghỉ dưỡng.','Trung tâm Vĩnh Phúc','Vietnamese,English','Xe đưa đón,Ăn trưa','Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','easy',1,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Hướng dẫn viên\",\"Ăn trưa\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]'),
(1,63,'Tour Khám phá Yên Bái 2N1Đ','Mù Cang Chải, ruộng bậc thang và bản làng.','Yên Bái, Việt Nam','2025-10-01','2025-10-02',1350000.00,'VND',20,2,20,'https://cdn.example.com/tours/yen-bai/thumb.jpg','[\"https://cdn.example.com/tours/yen-bai/1.jpg\"]',4.3,'local-favorite','published','Ngày 1: Mù Cang Chải; Ngày 2: bản làng và ruộng bậc thang.','Trung tâm Yên Bái','Vietnamese,English','Xe đưa đón,Vé tham quan,Ăn sáng','Chi phí cá nhân,Đồ uống,Tip HDV','Hoàn 80% trước 7 ngày, 50% trước 3 ngày, không hoàn trong 48h.','moderate',2,'Hà Nội/TP.HCM (tuỳ chọn)','[\"Khách sạn 2-3 sao\",\"Bữa sáng hàng ngày\",\"Hướng dẫn viên\"]','[\"Vé máy bay\",\"Chi phí cá nhân\"]');

INSERT INTO attractions (provider_id, area_id, title, service_description, location, address, coordinates, start_date, end_date, price, currency_code, capacity, min_participants, max_participants, thumbnail_url, image_urls, rating_average, badges, attraction_status, average_visit_minutes, highlights_json, features_json, tips_text, suitable_for_json, opening_hours_json, available_times_json, visit_types_json) VALUES
(1,1,'Điểm tham quan tiêu biểu - Hà Nội','Điểm tham quan nổi bật tại Hà Nội, phù hợp cho du khách muốn khám phá văn hoá và thiên nhiên địa phương.','Hà Nội, Việt Nam','Trung tâm Hà Nội','0.0000,0.0000','2025-10-01','2025-12-31',50000.00,'VND',150,1,200,'https://cdn.example.com/attractions/ha-noi/thumb.jpg','["https://cdn.example.com/attractions/ha-noi/1.jpg","https://cdn.example.com/attractions/ha-noi/2.jpg"]',4.5,'cultural,nature','published',90,'["Di tích A tại Hà Nội","Phố cổ","Công viên lớn"]','["hướng dẫn viên","bãi đỗ xe","wifi miễn phí"]','Mang nước và đồ dùng cá nhân. Kiểm tra thời tiết trước khi đi.','["family","friends","couple"]','{"mon":[{"open":"07:00","close":"17:30"}],"tue":[{"open":"07:00","close":"17:30"}],"wed":[{"open":"07:00","close":"17:30"}],"thu":[{"open":"07:00","close":"17:30"}],"fri":[{"open":"07:00","close":"17:30"}],"sat":[{"open":"07:00","close":"18:00"}],"sun":[{"open":"07:00","close":"18:00"}]}','["08:00","10:00","14:00"]','["tự túc","theo tour","tham quan nhóm"]'),
(1,2,'Điểm tham quan tiêu biểu - Hồ Chí Minh','Điểm tham quan nổi bật tại Hồ Chí Minh, phù hợp cho du khách muốn khám phá văn hoá và thiên nhiên địa phương.','Hồ Chí Minh, Việt Nam','Trung tâm Hồ Chí Minh','0.0000,0.0000','2025-10-01','2025-12-31',50000.00,'VND',150,1,200,'https://cdn.example.com/attractions/ho-chi-minh/thumb.jpg','["https://cdn.example.com/attractions/ho-chi-minh/1.jpg","https://cdn.example.com/attractions/ho-chi-minh/2.jpg"]',4.5,'cultural,nature','published',90,'["Địa danh A tại HCM","Chợ nổi tiếng","Bảo tàng"]','["hướng dẫn viên","bãi đỗ xe","wifi miễn phí"]','Mang nước và đồ dùng cá nhân. Kiểm tra thời tiết trước khi đi.','["family","friends","couple"]','{"mon":[{"open":"07:00","close":"17:30"}],"tue":[{"open":"07:00","close":"17:30"}],"wed":[{"open":"07:00","close":"17:30"}],"thu":[{"open":"07:00","close":"17:30"}],"fri":[{"open":"07:00","close":"17:30"}],"sat":[{"open":"07:00","close":"18:00"}],"sun":[{"open":"07:00","close":"18:00"}]}','["08:00","10:00","14:00"]','["tự túc","theo tour","tham quan nhóm"]'),
(1,3,'Điểm tham quan tiêu biểu - Hải Phòng','Điểm tham quan nổi bật tại Hải Phòng, phù hợp cho du khách muốn khám phá văn hoá và thiên nhiên địa phương.','Hải Phòng, Việt Nam','Trung tâm Hải Phòng','0.0000,0.0000','2025-10-01','2025-12-31',50000.00,'VND',150,1,200,'https://cdn.example.com/attractions/hai-phong/thumb.jpg','["https://cdn.example.com/attractions/hai-phong/1.jpg","https://cdn.example.com/attractions/hai-phong/2.jpg"]',4.5,'cultural,nature','published',90,'["Bến cảng","Đền chùa","Ẩm thực hải sản"]','["hướng dẫn viên","bãi đỗ xe","wifi miễn phí"]','Mang nước và đồ dùng cá nhân. Kiểm tra thời tiết trước khi đi.','["family","friends","couple"]','{"mon":[{"open":"07:00","close":"17:30"}],"tue":[{"open":"07:00","close":"17:30"}],"wed":[{"open":"07:00","close":"17:30"}],"thu":[{"open":"07:00","close":"17:30"}],"fri":[{"open":"07:00","close":"17:30"}],"sat":[{"open":"07:00","close":"18:00"}],"sun":[{"open":"07:00","close":"18:00"}]}','["08:00","10:00","14:00"]','["tự túc","theo tour","tham quan nhóm"]'),
(1,4,'Điểm tham quan tiêu biểu - Đà Nẵng','Điểm tham quan nổi bật tại Đà Nẵng, phù hợp cho du khách muốn khám phá văn hoá và thiên nhiên địa phương.','Đà Nẵng, Việt Nam','Trung tâm Đà Nẵng','0.0000,0.0000','2025-10-01','2025-12-31',50000.00,'VND',150,1,200,'https://cdn.example.com/attractions/da-nang/thumb.jpg','["https://cdn.example.com/attractions/da-nang/1.jpg","https://cdn.example.com/attractions/da-nang/2.jpg"]',4.5,'cultural,nature','published',90,'["Bãi biển đẹp","Cầu Rồng","Đỉnh núi nhìn toàn cảnh"]','["hướng dẫn viên","bãi đỗ xe","wifi miễn phí"]','Mang nước và đồ dùng cá nhân. Kiểm tra thời tiết trước khi đi.','["family","friends","couple"]','{"mon":[{"open":"07:00","close":"17:30"}],"tue":[{"open":"07:00","close":"17:30"}],"wed":[{"open":"07:00","close":"17:30"}],"thu":[{"open":"07:00","close":"17:30"}],"fri":[{"open":"07:00","close":"17:30"}],"sat":[{"open":"07:00","close":"18:00"}],"sun":[{"open":"07:00","close":"18:00"}]}','["08:00","10:00","14:00"]','["tự túc","theo tour","tham quan nhóm"]'),
(1,5,'Điểm tham quan tiêu biểu - Cần Thơ','Điểm tham quan nổi bật tại Cần Thơ, phù hợp cho du khách muốn khám phá văn hoá và thiên nhiên địa phương.','Cần Thơ, Việt Nam','Trung tâm Cần Thơ','0.0000,0.0000','2025-10-01','2025-12-31',45000.00,'VND',120,1,150,'https://cdn.example.com/attractions/can-tho/thumb.jpg','["https://cdn.example.com/attractions/can-tho/1.jpg","https://cdn.example.com/attractions/can-tho/2.jpg"]',4.4,'nature,food','published',80,'["Chợ nổi","Vườn trái cây","Làng nghề địa phương"]','["thuyền","hướng dẫn viên","wifi miễn phí"]','Mang kem chống nắng, nước uống.','["family","friends"]','{"mon":[{"open":"06:30","close":"17:00"}],"tue":[{"open":"06:30","close":"17:00"}],"wed":[{"open":"06:30","close":"17:00"}],"thu":[{"open":"06:30","close":"17:00"}],"fri":[{"open":"06:30","close":"17:00"}],"sat":[{"open":"06:30","close":"18:00"}],"sun":[{"open":"06:30","close":"18:00"}]}','["07:00","09:00","15:00"]','["tự túc","theo tour"]'),
(1,6,'Điểm tham quan tiêu biểu - An Giang','Điểm tham quan nổi bật tại An Giang, phù hợp cho du khách muốn khám phá văn hoá và thiên nhiên địa phương.','An Giang, Việt Nam','Trung tâm An Giang','0.0000,0.0000','2025-10-01','2025-12-31',40000.00,'VND',100,1,120,'https://cdn.example.com/attractions/an-giang/thumb.jpg','["https://cdn.example.com/attractions/an-giang/1.jpg","https://cdn.example.com/attractions/an-giang/2.jpg"]',4.2,'nature,cultural','published',70,'["Đền thờ","Chùa cổ","Danh thắng ven sông"]','["hướng dẫn viên","bãi đỗ xe"]','Chuẩn bị giày bám đường, nước.','["family","friends"]','{"mon":[{"open":"07:00","close":"17:00"}],"tue":[{"open":"07:00","close":"17:00"}],"wed":[{"open":"07:00","close":"17:00"}],"thu":[{"open":"07:00","close":"17:00"}],"fri":[{"open":"07:00","close":"17:00"}],"sat":[{"open":"07:00","close":"17:30"}],"sun":[{"open":"07:00","close":"17:30"}]}','["08:00","13:00"]','["tự túc","tham quan nhóm"]'),
(1,7,'Điểm tham quan tiêu biểu - Bà Rịa - Vũng Tàu','Điểm tham quan nổi bật tại Bà Rịa - Vũng Tàu, phù hợp cho du khách muốn khám phá biển và nghỉ dưỡng.','Bà Rịa - Vũng Tàu, Việt Nam','Trung tâm Bà Rịa - Vũng Tàu','0.0000,0.0000','2025-10-01','2025-12-31',60000.00,'VND',180,1,250,'https://cdn.example.com/attractions/ba-ria-vung-tau/thumb.jpg','["https://cdn.example.com/attractions/ba-ria-vung-tau/1.jpg","https://cdn.example.com/attractions/ba-ria-vung-tau/2.jpg"]',4.6,'beach,resort','published',120,'["Bãi biển A","Mũi cảnh đẹp","Công viên biển"]','["bãi đỗ xe","hướng dẫn viên","nhà hàng"]','Mang đồ tắm, kem chống nắng.','["family","couple"]','{"mon":[{"open":"06:00","close":"18:00"}],"tue":[{"open":"06:00","close":"18:00"}],"wed":[{"open":"06:00","close":"18:00"}],"thu":[{"open":"06:00","close":"18:00"}],"fri":[{"open":"06:00","close":"18:00"}],"sat":[{"open":"06:00","close":"19:00"}],"sun":[{"open":"06:00","close":"19:00"}]}','["08:00","11:00","16:00"]','["tự túc","theo tour"]'),
(1,8,'Điểm tham quan tiêu biểu - Bắc Giang','Điểm tham quan nổi bật tại Bắc Giang, phù hợp cho du khách muốn khám phá văn hoá và thiên nhiên địa phương.','Bắc Giang, Việt Nam','Trung tâm Bắc Giang','0.0000,0.0000','2025-10-01','2025-12-31',35000.00,'VND',90,1,100,'https://cdn.example.com/attractions/bac-giang/thumb.jpg','["https://cdn.example.com/attractions/bac-giang/1.jpg","https://cdn.example.com/attractions/bac-giang/2.jpg"]',4.1,'nature,cultural','published',75,'["Đền thờ","Vườn hoa","Khu di tích"]','["hướng dẫn viên","bãi đỗ xe"]','Mang giày đi bộ.','["friends","family"]','{"mon":[{"open":"07:00","close":"17:00"}],"tue":[{"open":"07:00","close":"17:00"}],"wed":[{"open":"07:00","close":"17:00"}],"thu":[{"open":"07:00","close":"17:00"}],"fri":[{"open":"07:00","close":"17:00"}],"sat":[{"open":"07:00","close":"17:30"}],"sun":[{"open":"07:00","close":"17:30"}]}','["09:00","14:00"]','["tự túc","tham quan nhóm"]'),
(1,9,'Điểm tham quan tiêu biểu - Bắc Kạn','Điểm tham quan nổi bật tại Bắc Kạn, phù hợp cho du khách muốn khám phá thiên nhiên núi rừng.','Bắc Kạn, Việt Nam','Trung tâm Bắc Kạn','0.0000,0.0000','2025-10-01','2025-12-31',32000.00,'VND',80,1,90,'https://cdn.example.com/attractions/bac-kan/thumb.jpg','["https://cdn.example.com/attractions/bac-kan/1.jpg","https://cdn.example.com/attractions/bac-kan/2.jpg"]',4.0,'nature','published',110,'["Hồ nước","Đồi núi","Làng bản"]','["hướng dẫn viên","đi bộ đường dài"]','Chuẩn bị đồ ấm nếu đi buổi sáng.','["adventure","friends"]','{"mon":[{"open":"07:30","close":"17:00"}],"tue":[{"open":"07:30","close":"17:00"}],"wed":[{"open":"07:30","close":"17:00"}],"thu":[{"open":"07:30","close":"17:00"}],"fri":[{"open":"07:30","close":"17:00"}],"sat":[{"open":"07:30","close":"17:30"}],"sun":[{"open":"07:30","close":"17:30"}]}','["08:30","13:30"]','["tự túc","tham quan nhóm"]'),
(1,10,'Điểm tham quan tiêu biểu - Bạc Liêu','Điểm tham quan nổi bật tại Bạc Liêu, phù hợp cho du khách muốn khám phá văn hoá đờn ca tài tử và phong cảnh đồng bằng.','Bạc Liêu, Việt Nam','Trung tâm Bạc Liêu','0.0000,0.0000','2025-10-01','2025-12-31',33000.00,'VND',85,1,100,'https://cdn.example.com/attractions/bac-lieu/thumb.jpg','["https://cdn.example.com/attractions/bac-lieu/1.jpg","https://cdn.example.com/attractions/bac-lieu/2.jpg"]',4.1,'culture,music','published',80,'["Nhà công tử","Sân khấu đờn ca","Khu di tích"]','["hướng dẫn viên","nhà hàng"]','Tôn trọng sinh hoạt địa phương.','["family","culture"]','{"mon":[{"open":"07:00","close":"17:00"}],"tue":[{"open":"07:00","close":"17:00"}],"wed":[{"open":"07:00","close":"17:00"}],"thu":[{"open":"07:00","close":"17:00"}],"fri":[{"open":"07:00","close":"17:00"}],"sat":[{"open":"07:00","close":"17:30"}],"sun":[{"open":"07:00","close":"17:30"}]}','["09:00","15:00"]','["tự túc","theo tour"]'),
(1,11,'Điểm tham quan tiêu biểu - Bắc Ninh','Điểm tham quan nổi bật tại Bắc Ninh, phù hợp cho du khách muốn khám phá di sản văn hoá truyền thống.','Bắc Ninh, Việt Nam','Trung tâm Bắc Ninh','0.0000,0.0000','2025-10-01','2025-12-31',36000.00,'VND',95,1,120,'https://cdn.example.com/attractions/bac-ninh/thumb.jpg','["https://cdn.example.com/attractions/bac-ninh/1.jpg","https://cdn.example.com/attractions/bac-ninh/2.jpg"]',4.3,'culture,heritage','published',85,'["Đền cổ","Làng nghề","Lễ hội truyền thống"]','["hướng dẫn viên","bãi đỗ xe"]','Tôn trọng lễ nghi khi tham quan đền chùa.','["culture","family"]','{"mon":[{"open":"07:00","close":"17:30"}],"tue":[{"open":"07:00","close":"17:30"}],"wed":[{"open":"07:00","close":"17:30"}],"thu":[{"open":"07:00","close":"17:30"}],"fri":[{"open":"07:00","close":"17:30"}],"sat":[{"open":"07:00","close":"18:00"}],"sun":[{"open":"07:00","close":"18:00"}]}','["08:30","10:30","14:30"]','["tự túc","theo tour"]'),
(1,12,'Điểm tham quan tiêu biểu - Bến Tre','Điểm tham quan nổi bật tại Bến Tre, phù hợp cho du khách muốn khám phá miệt vườn và sông nước.','Bến Tre, Việt Nam','Trung tâm Bến Tre','0.0000,0.0000','2025-10-01','2025-12-31',38000.00,'VND',110,1,130,'https://cdn.example.com/attractions/ben-tre/thumb.jpg','["https://cdn.example.com/attractions/ben-tre/1.jpg","https://cdn.example.com/attractions/ben-tre/2.jpg"]',4.2,'river,village','published',100,'["Miệt vườn","Chợ nổi nhỏ","Trang trại dừa"]','["thuyền","hướng dẫn viên"]','Chuẩn bị mũ, kem chống nắng.','["family","friends"]','{"mon":[{"open":"06:30","close":"17:30"}],"tue":[{"open":"06:30","close":"17:30"}],"wed":[{"open":"06:30","close":"17:30"}],"thu":[{"open":"06:30","close":"17:30"}],"fri":[{"open":"06:30","close":"17:30"}],"sat":[{"open":"06:30","close":"18:00"}],"sun":[{"open":"06:30","close":"18:00"}]}','["07:30","10:30","15:00"]','["tự túc","theo tour"]'),
(1,13,'Điểm tham quan tiêu biểu - Bình Định','Điểm tham quan nổi bật tại Bình Định, phù hợp cho du khách muốn khám phá bãi biển và di tích võ cổ truyền.','Bình Định, Việt Nam','Trung tâm Bình Định','0.0000,0.0000','2025-10-01','2025-12-31',42000.00,'VND',130,1,150,'https://cdn.example.com/attractions/binh-dinh/thumb.jpg','["https://cdn.example.com/attractions/binh-dinh/1.jpg","https://cdn.example.com/attractions/binh-dinh/2.jpg"]',4.3,'beach,heritage','published',95,'["Bãi biển","Đền võ","Làng nghề"]','["hướng dẫn viên","bãi đỗ xe","nhà hàng"]','Mang đồ bơi, mũ.','["family","adventure"]','{"mon":[{"open":"07:00","close":"17:30"}],"tue":[{"open":"07:00","close":"17:30"}],"wed":[{"open":"07:00","close":"17:30"}],"thu":[{"open":"07:00","close":"17:30"}],"fri":[{"open":"07:00","close":"17:30"}],"sat":[{"open":"07:00","close":"18:00"}],"sun":[{"open":"07:00","close":"18:00"}]}','["08:00","12:00","15:00"]','["tự túc","theo tour"]'),
(1,14,'Điểm tham quan tiêu biểu - Bình Dương','Điểm tham quan nổi bật tại Bình Dương, phù hợp cho du khách muốn khám phá khu công nghiệp và đô thị mới.','Bình Dương, Việt Nam','Trung tâm Bình Dương','0.0000,0.0000','2025-10-01','2025-12-31',34000.00,'VND',140,1,180,'https://cdn.example.com/attractions/binh-duong/thumb.jpg','["https://cdn.example.com/attractions/binh-duong/1.jpg","https://cdn.example.com/attractions/binh-duong/2.jpg"]',4.0,'urban,park','published',70,'["Công viên","Trung tâm thương mại","Khu triển lãm"]','["bãi đỗ xe","wifi miễn phí"]','Thích hợp cho dịp cuối tuần.','["friends","family"]','{"mon":[{"open":"08:00","close":"18:00"}],"tue":[{"open":"08:00","close":"18:00"}],"wed":[{"open":"08:00","close":"18:00"}],"thu":[{"open":"08:00","close":"18:00"}],"fri":[{"open":"08:00","close":"18:00"}],"sat":[{"open":"08:00","close":"19:00"}],"sun":[{"open":"08:00","close":"19:00"}]}','["09:00","14:00"]','["tự túc","tham quan nhóm"]'),
(1,15,'Điểm tham quan tiêu biểu - Bình Phước','Điểm tham quan nổi bật tại Bình Phước, phù hợp cho du khách muốn khám phá vùng trồng cây công nghiệp và rừng.','Bình Phước, Việt Nam','Trung tâm Bình Phước','0.0000,0.0000','2025-10-01','2025-12-31',30000.00,'VND',80,1,90,'https://cdn.example.com/attractions/binh-phuoc/thumb.jpg','["https://cdn.example.com/attractions/binh-phuoc/1.jpg","https://cdn.example.com/attractions/binh-phuoc/2.jpg"]',3.9,'nature,agri','published',100,'["Vườn cây","Khu rừng","Trại nuôi"]','["hướng dẫn viên","đi bộ"]','Mang đồ bảo hộ khi cần.','["adventure","friends"]','{"mon":[{"open":"07:30","close":"17:00"}],"tue":[{"open":"07:30","close":"17:00"}],"wed":[{"open":"07:30","close":"17:00"}],"thu":[{"open":"07:30","close":"17:00"}],"fri":[{"open":"07:30","close":"17:00"}],"sat":[{"open":"07:30","close":"17:30"}],"sun":[{"open":"07:30","close":"17:30"}]}','["08:30","13:00"]','["tự túc","tham quan nhóm"]'),
(1,16,'Điểm tham quan tiêu biểu - Bình Thuận','Điểm tham quan nổi bật tại Bình Thuận, phù hợp cho du khách muốn khám phá Mũi Né và cảnh quan sa mạc ven biển.','Bình Thuận, Việt Nam','Trung tâm Bình Thuận','0.0000,0.0000','2025-10-01','2025-12-31',55000.00,'VND',160,1,220,'https://cdn.example.com/attractions/binh-thuan/thumb.jpg','["https://cdn.example.com/attractions/binh-thuan/1.jpg","https://cdn.example.com/attractions/binh-thuan/2.jpg"]',4.4,'beach,desert','published',110,'["Đồi cát","Bãi biển","Khu resort"]','["hướng dẫn viên","nhà hàng","bãi đỗ xe"]','Mang đồ tắm, kính mát.','["family","couple"]','{"mon":[{"open":"06:00","close":"18:00"}],"tue":[{"open":"06:00","close":"18:00"}],"wed":[{"open":"06:00","close":"18:00"}],"thu":[{"open":"06:00","close":"18:00"}],"fri":[{"open":"06:00","close":"18:00"}],"sat":[{"open":"06:00","close":"19:00"}],"sun":[{"open":"06:00","close":"19:00"}]}','["07:30","10:30","16:00"]','["tự túc","theo tour"]'),
(1,17,'Điểm tham quan tiêu biểu - Cà Mau','Điểm tham quan nổi bật tại Cà Mau, phù hợp cho du khách muốn khám phá hệ sinh thái ngập mặn và mũi cực Nam.','Cà Mau, Việt Nam','Trung tâm Cà Mau','0.0000,0.0000','2025-10-01','2025-12-31',38000.00,'VND',100,1,120,'https://cdn.example.com/attractions/ca-mau/thumb.jpg','["https://cdn.example.com/attractions/ca-mau/1.jpg","https://cdn.example.com/attractions/ca-mau/2.jpg"]',4.0,'nature,wetland','published',130,'["Rừng ngập mặn","Mũi Cà Mau","Khu bảo tồn"]','["thuyền","hướng dẫn viên"]','Mang thuốc muỗi và đồ chống nắng.','["adventure","nature"]','{"mon":[{"open":"06:00","close":"17:30"}],"tue":[{"open":"06:00","close":"17:30"}],"wed":[{"open":"06:00","close":"17:30"}],"thu":[{"open":"06:00","close":"17:30"}],"fri":[{"open":"06:00","close":"17:30"}],"sat":[{"open":"06:00","close":"18:00"}],"sun":[{"open":"06:00","close":"18:00"}]}','["07:00","12:00"]','["tự túc","tham quan nhóm"]'),
(1,18,'Điểm tham quan tiêu biểu - Cao Bằng','Điểm tham quan nổi bật tại Cao Bằng, phù hợp cho du khách muốn khám phá thác Bản Giốc và núi non.','Cao Bằng, Việt Nam','Trung tâm Cao Bằng','0.0000,0.0000','2025-10-01','2025-12-31',44000.00,'VND',90,1,110,'https://cdn.example.com/attractions/cao-bang/thumb.jpg','["https://cdn.example.com/attractions/cao-bang/1.jpg","https://cdn.example.com/attractions/cao-bang/2.jpg"]',4.3,'nature,waterfall','published',140,'["Thác Bản Giốc","Hang động","Đèo núi"]','["hướng dẫn viên","đi bộ"]','Chuẩn bị giày leo núi, áo ấm.','["adventure","friends"]','{"mon":[{"open":"07:00","close":"17:00"}],"tue":[{"open":"07:00","close":"17:00"}],"wed":[{"open":"07:00","close":"17:00"}],"thu":[{"open":"07:00","close":"17:00"}],"fri":[{"open":"07:00","close":"17:00"}],"sat":[{"open":"07:00","close":"17:30"}],"sun":[{"open":"07:00","close":"17:30"}]}','["09:00","13:00"]','["tự túc","tham quan nhóm"]'),
(1,19,'Điểm tham quan tiêu biểu - Đắk Lắk','Điểm tham quan nổi bật tại Đắk Lắk, phù hợp cho du khách muốn khám phá cao nguyên cà phê và văn hoá dân tộc.','Đắk Lắk, Việt Nam','Trung tâm Đắk Lắk','0.0000,0.0000','2025-10-01','2025-12-31',39000.00,'VND',110,1,130,'https://cdn.example.com/attractions/dak-lak/thumb.jpg','["https://cdn.example.com/attractions/dak-lak/1.jpg","https://cdn.example.com/attractions/dak-lak/2.jpg"]',4.2,'coffee,culture','published',120,'["Cao nguyên","Trang trại cà phê","Làng văn hóa"]','["hướng dẫn viên","trải nghiệm nông nghiệp"]','Mang mũ, kem chống nắng.','["culture","adventure"]','{"mon":[{"open":"07:00","close":"17:00"}],"tue":[{"open":"07:00","close":"17:00"}],"wed":[{"open":"07:00","close":"17:00"}],"thu":[{"open":"07:00","close":"17:00"}],"fri":[{"open":"07:00","close":"17:00"}],"sat":[{"open":"07:00","close":"18:00"}],"sun":[{"open":"07:00","close":"18:00"}]}','["08:00","11:00","15:00"]','["tự túc","theo tour"]'),
(1,20,'Điểm tham quan tiêu biểu - Đắk Nông','Điểm tham quan nổi bật tại Đắk Nông, phù hợp cho du khách muốn khám phá thiên nhiên hoang sơ.','Đắk Nông, Việt Nam','Trung tâm Đắk Nông','0.0000,0.0000','2025-10-01','2025-12-31',31000.00,'VND',75,1,90,'https://cdn.example.com/attractions/dak-nong/thumb.jpg','["https://cdn.example.com/attractions/dak-nong/1.jpg","https://cdn.example.com/attractions/dak-nong/2.jpg"]',3.9,'nature','published',110,'["Thác","Rừng nguyên sinh","Làng bản"]','["hướng dẫn viên","đi bộ"]','Chuẩn bị đồ ấm và nước.','["adventure","friends"]','{"mon":[{"open":"07:30","close":"17:00"}],"tue":[{"open":"07:30","close":"17:00"}],"wed":[{"open":"07:30","close":"17:00"}],"thu":[{"open":"07:30","close":"17:00"}],"fri":[{"open":"07:30","close":"17:00"}],"sat":[{"open":"07:30","close":"17:30"}],"sun":[{"open":"07:30","close":"17:30"}]}','["09:00","14:00"]','["tự túc","tham quan nhóm"]'),
(1,21,'Điểm tham quan tiêu biểu - Điện Biên','Điểm tham quan nổi bật tại Điện Biên, phù hợp cho du khách muốn khám phá lịch sử và núi non.','Điện Biên, Việt Nam','Trung tâm Điện Biên','0.0000,0.0000','2025-10-01','2025-12-31',36000.00,'VND',85,1,100,'https://cdn.example.com/attractions/dien-bien/thumb.jpg','["https://cdn.example.com/attractions/dien-bien/1.jpg","https://cdn.example.com/attractions/dien-bien/2.jpg"]',4.1,'history,nature','published',120,'["Đồi A1","Di tích lịch sử","Bản làng"]','["hướng dẫn viên","bãi đỗ xe"]','Tôn trọng các di tích lịch sử.','["culture","history"]','{"mon":[{"open":"07:00","close":"17:00"}],"tue":[{"open":"07:00","close":"17:00"}],"wed":[{"open":"07:00","close":"17:00"}],"thu":[{"open":"07:00","close":"17:00"}],"fri":[{"open":"07:00","close":"17:00"}],"sat":[{"open":"07:00","close":"17:30"}],"sun":[{"open":"07:00","close":"17:30"}]}','["08:30","13:30"]','["tự túc","tham quan nhóm"]'),
(1,22,'Điểm tham quan tiêu biểu - Đồng Nai','Điểm tham quan nổi bật tại Đồng Nai, phù hợp cho du khách muốn khám phá du lịch sinh thái.','Đồng Nai, Việt Nam','Trung tâm Đồng Nai','0.0000,0.0000','2025-10-01','2025-12-31',41000.00,'VND',130,1,160,'https://cdn.example.com/attractions/dong-nai/thumb.jpg','["https://cdn.example.com/attractions/dong-nai/1.jpg","https://cdn.example.com/attractions/dong-nai/2.jpg"]',4.2,'eco,park','published',100,'["Khu sinh thái","Hồ nước","Vườn thú mini"]','["hướng dẫn viên","bãi đỗ xe"]','Thích hợp cho gia đình.','["family"]','{"mon":[{"open":"08:00","close":"17:30"}],"tue":[{"open":"08:00","close":"17:30"}],"wed":[{"open":"08:00","close":"17:30"}],"thu":[{"open":"08:00","close":"17:30"}],"fri":[{"open":"08:00","close":"17:30"}],"sat":[{"open":"08:00","close":"18:00"}],"sun":[{"open":"08:00","close":"18:00"}]}','["09:00","11:00","15:00"]','["tự túc","theo tour"]'),
(1,23,'Điểm tham quan tiêu biểu - Đồng Tháp','Điểm tham quan nổi bật tại Đồng Tháp, phù hợp cho du khách muốn khám phá sen hồng và miền Tây sông nước.','Đồng Tháp, Việt Nam','Trung tâm Đồng Tháp','0.0000,0.0000','2025-10-01','2025-12-31',34000.00,'VND',100,1,120,'https://cdn.example.com/attractions/dong-thap/thumb.jpg','["https://cdn.example.com/attractions/dong-thap/1.jpg","https://cdn.example.com/attractions/dong-thap/2.jpg"]',4.0,'nature,flower','published',90,'["Cánh đồng sen","Chợ nổi nhỏ","Làng nghề"]','["thuyền","hướng dẫn viên"]','Mang mũ và nước.','["family","friends"]','{"mon":[{"open":"06:30","close":"17:30"}],"tue":[{"open":"06:30","close":"17:30"}],"wed":[{"open":"06:30","close":"17:30"}],"thu":[{"open":"06:30","close":"17:30"}],"fri":[{"open":"06:30","close":"17:30"}],"sat":[{"open":"06:30","close":"18:00"}],"sun":[{"open":"06:30","close":"18:00"}]}','["07:30","10:00"]','["tự túc","tham quan nhóm"]'),
(1,24,'Điểm tham quan tiêu biểu - Gia Lai','Điểm tham quan nổi bật tại Gia Lai, phù hợp cho du khách muốn khám phá cao nguyên và văn hoá bản địa.','Gia Lai, Việt Nam','Trung tâm Gia Lai','0.0000,0.0000','2025-10-01','2025-12-31',36000.00,'VND',90,1,110,'https://cdn.example.com/attractions/gia-lai/thumb.jpg','["https://cdn.example.com/attractions/gia-lai/1.jpg","https://cdn.example.com/attractions/gia-lai/2.jpg"]',4.0,'highland,culture','published',120,'["Cao nguyên","Hồ nước","Làng dân tộc"]','["hướng dẫn viên","trải nghiệm văn hoá"]','Tôn trọng phong tục bản địa.','["culture","adventure"]','{"mon":[{"open":"07:00","close":"17:00"}],"tue":[{"open":"07:00","close":"17:00"}],"wed":[{"open":"07:00","close":"17:00"}],"thu":[{"open":"07:00","close":"17:00"}],"fri":[{"open":"07:00","close":"17:00"}],"sat":[{"open":"07:00","close":"18:00"}],"sun":[{"open":"07:00","close":"18:00"}]}','["08:30","13:30"]','["tự túc","theo tour"]'),
(1,25,'Điểm tham quan tiêu biểu - Hà Giang','Điểm tham quan nổi bật tại Hà Giang, phù hợp cho du khách muốn khám phá cao nguyên đá và đèo đèo.','Hà Giang, Việt Nam','Trung tâm Hà Giang','0.0000,0.0000','2025-10-01','2025-12-31',47000.00,'VND',110,1,130,'https://cdn.example.com/attractions/ha-giang/thumb.jpg','["https://cdn.example.com/attractions/ha-giang/1.jpg","https://cdn.example.com/attractions/ha-giang/2.jpg"]',4.5,'scenic,trek','published',180,'["Đèo Mã Pí Lèng","Cao nguyên đá","Làng bản"]','["hướng dẫn viên","xe jeep"]','Chuẩn bị trang phục ấm và giày leo.','["adventure","friends"]','{"mon":[{"open":"06:30","close":"17:00"}],"tue":[{"open":"06:30","close":"17:00"}],"wed":[{"open":"06:30","close":"17:00"}],"thu":[{"open":"06:30","close":"17:00"}],"fri":[{"open":"06:30","close":"17:00"}],"sat":[{"open":"06:30","close":"17:30"}],"sun":[{"open":"06:30","close":"17:30"}]}','["07:00","12:00"]','["tự túc","tham quan nhóm"]'),
(1,26,'Điểm tham quan tiêu biểu - Hà Nam','Điểm tham quan nổi bật tại Hà Nam, phù hợp cho du khách muốn khám phá di tích gần Hà Nội.','Hà Nam, Việt Nam','Trung tâm Hà Nam','0.0000,0.0000','2025-10-01','2025-12-31',30000.00,'VND',70,1,90,'https://cdn.example.com/attractions/ha-nam/thumb.jpg','["https://cdn.example.com/attractions/ha-nam/1.jpg","https://cdn.example.com/attractions/ha-nam/2.jpg"]',3.8,'heritage','published',80,'["Đền miếu","Làng cổ","Cánh đồng"]','["hướng dẫn viên","bãi đỗ xe"]','Thích hợp cho chuyến đi nửa ngày.','["family","culture"]','{"mon":[{"open":"08:00","close":"17:00"}],"tue":[{"open":"08:00","close":"17:00"}],"wed":[{"open":"08:00","close":"17:00"}],"thu":[{"open":"08:00","close":"17:00"}],"fri":[{"open":"08:00","close":"17:00"}],"sat":[{"open":"08:00","close":"17:30"}],"sun":[{"open":"08:00","close":"17:30"}]}','["09:00","14:00"]','["tự túc"]'),
(1,27,'Điểm tham quan tiêu biểu - Hà Tĩnh','Điểm tham quan nổi bật tại Hà Tĩnh, phù hợp cho du khách muốn khám phá bờ biển và di tích.','Hà Tĩnh, Việt Nam','Trung tâm Hà Tĩnh','0.0000,0.0000','2025-10-01','2025-12-31',32000.00,'VND',80,1,100,'https://cdn.example.com/attractions/ha-tinh/thumb.jpg','["https://cdn.example.com/attractions/ha-tinh/1.jpg","https://cdn.example.com/attractions/ha-tinh/2.jpg"]',4.0,'beach,heritage','published',100,'["Bãi biển","Di tích lịch sử","Đền miếu"]','["hướng dẫn viên","bãi đỗ xe"]','Chuẩn bị đồ bơi và nón.','["family","friends"]','{"mon":[{"open":"06:30","close":"17:30"}],"tue":[{"open":"06:30","close":"17:30"}],"wed":[{"open":"06:30","close":"17:30"}],"thu":[{"open":"06:30","close":"17:30"}],"fri":[{"open":"06:30","close":"17:30"}],"sat":[{"open":"06:30","close":"18:00"}],"sun":[{"open":"06:30","close":"18:00"}]}','["08:00","11:00"]','["tự túc","theo tour"]'),
(1,28,'Điểm tham quan tiêu biểu - Hải Dương','Điểm tham quan nổi bật tại Hải Dương, phù hợp cho du khách muốn khám phá nông sản và chợ hoa.','Hải Dương, Việt Nam','Trung tâm Hải Dương','0.0000,0.0000','2025-10-01','2025-12-31',30000.00,'VND',75,1,90,'https://cdn.example.com/attractions/hai-duong/thumb.jpg','["https://cdn.example.com/attractions/hai-duong/1.jpg","https://cdn.example.com/attractions/hai-duong/2.jpg"]',3.9,'agri,market','published',70,'["Chợ hoa","Làng nghề","Cánh đồng"]','["hướng dẫn viên"]','Thử đặc sản địa phương.','["culture","food"]','{"mon":[{"open":"07:00","close":"17:00"}],"tue":[{"open":"07:00","close":"17:00"}],"wed":[{"open":"07:00","close":"17:00"}],"thu":[{"open":"07:00","close":"17:00"}],"fri":[{"open":"07:00","close":"17:00"}],"sat":[{"open":"07:00","close":"17:30"}],"sun":[{"open":"07:00","close":"17:30"}]}','["08:30","10:30"]','["tự túc"]'),
(1,29,'Điểm tham quan tiêu biểu - Hậu Giang','Điểm tham quan nổi bật tại Hậu Giang, phù hợp cho du khách muốn khám phá miền Tây sông nước.','Hậu Giang, Việt Nam','Trung tâm Hậu Giang','0.0000,0.0000','2025-10-01','2025-12-31',29000.00,'VND',60,1,80,'https://cdn.example.com/attractions/hau-giang/thumb.jpg','["https://cdn.example.com/attractions/hau-giang/1.jpg","https://cdn.example.com/attractions/hau-giang/2.jpg"]',3.7,'river,agri','published',85,'["Kênh rạch","Chợ nổi","Làng nghề"]','["thuyền","hướng dẫn viên"]','Chuẩn bị mũ và nước.','["family","friends"]','{"mon":[{"open":"06:30","close":"17:00"}],"tue":[{"open":"06:30","close":"17:00"}],"wed":[{"open":"06:30","close":"17:00"}],"thu":[{"open":"06:30","close":"17:00"}],"fri":[{"open":"06:30","close":"17:00"}],"sat":[{"open":"06:30","close":"17:30"}],"sun":[{"open":"06:30","close":"17:30"}]}','["07:00","10:00"]','["tự túc"]'),
(1,30,'Điểm tham quan tiêu biểu - Hòa Bình','Điểm tham quan nổi bật tại Hòa Bình, phù hợp cho du khách muốn khám phá hồ và cảnh quan núi.','Hòa Bình, Việt Nam','Trung tâm Hòa Bình','0.0000,0.0000','2025-10-01','2025-12-31',35000.00,'VND',85,1,100,'https://cdn.example.com/attractions/hoa-binh/thumb.jpg','["https://cdn.example.com/attractions/hoa-binh/1.jpg","https://cdn.example.com/attractions/hoa-binh/2.jpg"]',4.0,'lake,mountain','published',110,'["Hồ lớn","Đỉnh núi","Làng bản"]','["hướng dẫn viên","xe máy"]','Chuẩn bị giày chắc chắn.','["adventure","friends"]','{"mon":[{"open":"07:00","close":"17:30"}],"tue":[{"open":"07:00","close":"17:30"}],"wed":[{"open":"07:00","close":"17:30"}],"thu":[{"open":"07:00","close":"17:30"}],"fri":[{"open":"07:00","close":"17:30"}],"sat":[{"open":"07:00","close":"18:00"}],"sun":[{"open":"07:00","close":"18:00"}]}','["08:30","14:00"]','["tự túc","tham quan nhóm"]'),
(1,31,'Điểm tham quan tiêu biểu - Hưng Yên','Điểm tham quan nổi bật tại Hưng Yên, phù hợp cho du khách muốn khám phá vải thiều và làng nghề.','Hưng Yên, Việt Nam','Trung tâm Hưng Yên','0.0000,0.0000','2025-10-01','2025-12-31',30000.00,'VND',70,1,90,'https://cdn.example.com/attractions/hung-yen/thumb.jpg','["https://cdn.example.com/attractions/hung-yen/1.jpg","https://cdn.example.com/attractions/hung-yen/2.jpg"]',3.8,'agri,culture','published',70,'["Làng nghề","Vườn vải","Di tích"]','["hướng dẫn viên"]','Thử sản phẩm địa phương.','["food","culture"]','{"mon":[{"open":"08:00","close":"17:00"}],"tue":[{"open":"08:00","close":"17:00"}],"wed":[{"open":"08:00","close":"17:00"}],"thu":[{"open":"08:00","close":"17:00"}],"fri":[{"open":"08:00","close":"17:00"}],"sat":[{"open":"08:00","close":"17:30"}],"sun":[{"open":"08:00","close":"17:30"}]}','["09:00","11:00"]','["tự túc"]'),
(1,32,'Điểm tham quan tiêu biểu - Khánh Hòa','Điểm tham quan nổi bật tại Khánh Hòa, phù hợp cho du khách muốn khám phá Nha Trang và bãi biển.','Khánh Hòa, Việt Nam','Trung tâm Khánh Hòa','0.0000,0.0000','2025-10-01','2025-12-31',65000.00,'VND',200,1,300,'https://cdn.example.com/attractions/khanh-hoa/thumb.jpg','["https://cdn.example.com/attractions/khanh-hoa/1.jpg","https://cdn.example.com/attractions/khanh-hoa/2.jpg"]',4.7,'beach,resort','published',150,'["Bãi biển Nha Trang","Hòn đảo đẹp","Lặn biển"]','["hướng dẫn viên","thuyền","nhà hàng"]','Chuẩn bị đồ lặn nếu muốn.','["family","couple"]','{"mon":[{"open":"06:00","close":"18:00"}],"tue":[{"open":"06:00","close":"18:00"}],"wed":[{"open":"06:00","close":"18:00"}],"thu":[{"open":"06:00","close":"18:00"}],"fri":[{"open":"06:00","close":"18:00"}],"sat":[{"open":"06:00","close":"19:00"}],"sun":[{"open":"06:00","close":"19:00"}]}','["08:00","10:00","15:00"]','["tự túc","theo tour"]'),
(1,33,'Điểm tham quan tiêu biểu - Kiên Giang','Điểm tham quan nổi bật tại Kiên Giang, phù hợp cho du khách muốn khám phá Phú Quốc và đảo.','Kiên Giang, Việt Nam','Trung tâm Kiên Giang','0.0000,0.0000','2025-10-01','2025-12-31',70000.00,'VND',220,1,350,'https://cdn.example.com/attractions/kien-giang/thumb.jpg','["https://cdn.example.com/attractions/kien-giang/1.jpg","https://cdn.example.com/attractions/kien-giang/2.jpg"]',4.8,'island,beach','published',180,'["Phú Quốc","Đảo hoang","Lặn biển"]','["thuyền","hướng dẫn viên","nhà hàng"]','Đặt trước tour đảo vào mùa cao điểm.','["family","couple"]','{"mon":[{"open":"06:00","close":"19:00"}],"tue":[{"open":"06:00","close":"19:00"}],"wed":[{"open":"06:00","close":"19:00"}],"thu":[{"open":"06:00","close":"19:00"}],"fri":[{"open":"06:00","close":"19:00"}],"sat":[{"open":"06:00","close":"20:00"}],"sun":[{"open":"06:00","close":"20:00"}]}','["07:30","11:00","16:00"]','["tự túc","theo tour"]'),
(1,34,'Điểm tham quan tiêu biểu - Kon Tum','Điểm tham quan nổi bật tại Kon Tum, phù hợp cho du khách muốn khám phá văn hoá dân tộc và núi rừng.','Kon Tum, Việt Nam','Trung tâm Kon Tum','0.0000,0.0000','2025-10-01','2025-12-31',33000.00,'VND',70,1,90,'https://cdn.example.com/attractions/kon-tum/thumb.jpg','["https://cdn.example.com/attractions/kon-tum/1.jpg","https://cdn.example.com/attractions/kon-tum/2.jpg"]',4.0,'culture,nature','published',120,'["Nhà rông","Làng bản","Vườn quốc gia"]','["hướng dẫn viên","đi bộ"]','Tôn trọng phong tục bản địa.','["culture","adventure"]','{"mon":[{"open":"07:00","close":"17:00"}],"tue":[{"open":"07:00","close":"17:00"}],"wed":[{"open":"07:00","close":"17:00"}],"thu":[{"open":"07:00","close":"17:00"}],"fri":[{"open":"07:00","close":"17:00"}],"sat":[{"open":"07:00","close":"18:00"}],"sun":[{"open":"07:00","close":"18:00"}]}','["08:30","14:00"]','["tự túc","tham quan nhóm"]'),
(1,35,'Điểm tham quan tiêu biểu - Lai Châu','Điểm tham quan nổi bật tại Lai Châu, phù hợp cho du khách muốn khám phá đèo dốc và cảnh quan hoang sơ.','Lai Châu, Việt Nam','Trung tâm Lai Châu','0.0000,0.0000','2025-10-01','2025-12-31',34000.00,'VND',70,1,90,'https://cdn.example.com/attractions/lai-chau/thumb.jpg','["https://cdn.example.com/attractions/lai-chau/1.jpg","https://cdn.example.com/attractions/lai-chau/2.jpg"]',4.1,'mountain,trek','published',160,'["Đèo","Bản làng","Thác nước"]','["hướng dẫn viên","xe máy"]','Chuẩn bị sức khỏe cho đường đèo.','["adventure","friends"]','{"mon":[{"open":"06:30","close":"17:00"}],"tue":[{"open":"06:30","close":"17:00"}],"wed":[{"open":"06:30","close":"17:00"}],"thu":[{"open":"06:30","close":"17:00"}],"fri":[{"open":"06:30","close":"17:00"}],"sat":[{"open":"06:30","close":"17:30"}],"sun":[{"open":"06:30","close":"17:30"}]}','["08:00","12:00"]','["tự túc","tham quan nhóm"]'),
(1,36,'Điểm tham quan tiêu biểu - Lâm Đồng','Điểm tham quan nổi bật tại Lâm Đồng, phù hợp cho du khách muốn khám phá Đà Lạt và cảnh quan ôn đới.','Lâm Đồng, Việt Nam','Trung tâm Lâm Đồng','0.0000,0.0000','2025-10-01','2025-12-31',60000.00,'VND',160,1,220,'https://cdn.example.com/attractions/lam-dong/thumb.jpg','["https://cdn.example.com/attractions/lam-dong/1.jpg","https://cdn.example.com/attractions/lam-dong/2.jpg"]',4.6,'hillstation,scenic','published',140,'["Đà Lạt","Hồ nước","Vườn hoa"]','["hướng dẫn viên","nhà hàng","bãi đỗ xe"]','Mang áo ấm buổi tối.','["couple","family"]','{"mon":[{"open":"07:00","close":"18:00"}],"tue":[{"open":"07:00","close":"18:00"}],"wed":[{"open":"07:00","close":"18:00"}],"thu":[{"open":"07:00","close":"18:00"}],"fri":[{"open":"07:00","close":"18:00"}],"sat":[{"open":"07:00","close":"19:00"}],"sun":[{"open":"07:00","close":"19:00"}]}','["09:00","11:00","15:00"]','["tự túc","theo tour"]'),
(1,37,'Điểm tham quan tiêu biểu - Lạng Sơn','Điểm tham quan nổi bật tại Lạng Sơn, phù hợp cho du khách muốn khám phá cửa khẩu và danh thắng.','Lạng Sơn, Việt Nam','Trung tâm Lạng Sơn','0.0000,0.0000','2025-10-01','2025-12-31',32000.00,'VND',85,1,100,'https://cdn.example.com/attractions/lang-son/thumb.jpg','["https://cdn.example.com/attractions/lang-son/1.jpg","https://cdn.example.com/attractions/lang-son/2.jpg"]',4.0,'border,scenic','published',100,'["Cửa khẩu","Động đá","Đồi núi"]','["hướng dẫn viên","xe hơi"]','Chuẩn bị giấy tờ khi cần qua cửa khẩu.','["adventure","friends"]','{"mon":[{"open":"07:00","close":"17:00"}],"tue":[{"open":"07:00","close":"17:00"}],"wed":[{"open":"07:00","close":"17:00"}],"thu":[{"open":"07:00","close":"17:00"}],"fri":[{"open":"07:00","close":"17:00"}],"sat":[{"open":"07:00","close":"17:30"}],"sun":[{"open":"07:00","close":"17:30"}]}','["08:30","13:30"]','["tự túc","tham quan nhóm"]'),
(1,38,'Điểm tham quan tiêu biểu - Lào Cai','Điểm tham quan nổi bật tại Lào Cai, phù hợp cho du khách muốn khám phá Sa Pa và cảnh quan núi non.','Lào Cai, Việt Nam','Trung tâm Lào Cai','0.0000,0.0000','2025-10-01','2025-12-31',58000.00,'VND',140,1,200,'https://cdn.example.com/attractions/lao-cai/thumb.jpg','["https://cdn.example.com/attractions/lao-cai/1.jpg","https://cdn.example.com/attractions/lao-cai/2.jpg"]',4.6,'mountain,scenic','published',180,'["Sa Pa","Cáp treo","Bản làng"]','["hướng dẫn viên","xe jeep"]','Mang đồ ấm và giày leo.','["adventure","couple"]','{"mon":[{"open":"06:30","close":"18:00"}],"tue":[{"open":"06:30","close":"18:00"}],"wed":[{"open":"06:30","close":"18:00"}],"thu":[{"open":"06:30","close":"18:00"}],"fri":[{"open":"06:30","close":"18:00"}],"sat":[{"open":"06:30","close":"19:00"}],"sun":[{"open":"06:30","close":"19:00"}]}','["08:00","12:00","15:00"]','["tự túc","theo tour"]'),
(1,39,'Điểm tham quan tiêu biểu - Long An','Điểm tham quan nổi bật tại Long An, phù hợp cho du khách muốn khám phá nông nghiệp và vùng đồng bằng.','Long An, Việt Nam','Trung tâm Long An','0.0000,0.0000','2025-10-01','2025-12-31',29000.00,'VND',60,1,80,'https://cdn.example.com/attractions/long-an/thumb.jpg','["https://cdn.example.com/attractions/long-an/1.jpg","https://cdn.example.com/attractions/long-an/2.jpg"]',3.8,'agri,river','published',70,'["Làng nghề","Đồng lúa","Chợ địa phương"]','["hướng dẫn viên"]','Thử đặc sản địa phương.','["food","family"]','{"mon":[{"open":"08:00","close":"17:00"}],"tue":[{"open":"08:00","close":"17:00"}],"wed":[{"open":"08:00","close":"17:00"}],"thu":[{"open":"08:00","close":"17:00"}],"fri":[{"open":"08:00","close":"17:00"}],"sat":[{"open":"08:00","close":"17:30"}],"sun":[{"open":"08:00","close":"17:30"}]}','["09:00","14:00"]','["tự túc"]'),
(1,40,'Điểm tham quan tiêu biểu - Nam Định','Điểm tham quan nổi bật tại Nam Định, phù hợp cho du khách muốn khám phá di tích lịch sử và bờ biển.','Nam Định, Việt Nam','Trung tâm Nam Định','0.0000,0.0000','2025-10-01','2025-12-31',31000.00,'VND',75,1,90,'https://cdn.example.com/attractions/nam-dinh/thumb.jpg','["https://cdn.example.com/attractions/nam-dinh/1.jpg","https://cdn.example.com/attractions/nam-dinh/2.jpg"]',3.9,'heritage,beach','published',85,'["Đền thờ","Bãi biển","Lễ hội địa phương"]','["hướng dẫn viên","bãi đỗ xe"]','Tôn trọng lễ hội địa phương.','["culture","family"]','{"mon":[{"open":"07:00","close":"17:00"}],"tue":[{"open":"07:00","close":"17:00"}],"wed":[{"open":"07:00","close":"17:00"}],"thu":[{"open":"07:00","close":"17:00"}],"fri":[{"open":"07:00","close":"17:00"}],"sat":[{"open":"07:00","close":"17:30"}],"sun":[{"open":"07:00","close":"17:30"}]}','["09:00","15:00"]','["tự túc","tham quan nhóm"]'),
(1,41,'Điểm tham quan tiêu biểu - Nghệ An','Điểm tham quan nổi bật tại Nghệ An, phù hợp cho du khách muốn khám phá vùng rộng lớn và danh lam.','Nghệ An, Việt Nam','Trung tâm Nghệ An','0.0000,0.0000','2025-10-01','2025-12-31',39000.00,'VND',120,1,150,'https://cdn.example.com/attractions/nghe-an/thumb.jpg','["https://cdn.example.com/attractions/nghe-an/1.jpg","https://cdn.example.com/attractions/nghe-an/2.jpg"]',4.1,'scenic,heritage','published',130,'["Bãi biển","Di tích","Đồi núi"]','["hướng dẫn viên","bãi đỗ xe"]','Chuẩn bị lịch trình dài khi khám phá tỉnh rộng.','["adventure","family"]','{"mon":[{"open":"06:30","close":"17:30"}],"tue":[{"open":"06:30","close":"17:30"}],"wed":[{"open":"06:30","close":"17:30"}],"thu":[{"open":"06:30","close":"17:30"}],"fri":[{"open":"06:30","close":"17:30"}],"sat":[{"open":"06:30","close":"18:00"}],"sun":[{"open":"06:30","close":"18:00"}]}','["08:00","13:00"]','["tự túc","theo tour"]'),
(1,42,'Điểm tham quan tiêu biểu - Ninh Bình','Điểm tham quan nổi bật tại Ninh Bình, phù hợp cho du khách muốn khám phá Tràng An và cảnh quan kì vĩ.','Ninh Bình, Việt Nam','Trung tâm Ninh Bình','0.0000,0.0000','2025-10-01','2025-12-31',48000.00,'VND',160,1,220,'https://cdn.example.com/attractions/ninh-binh/thumb.jpg','["https://cdn.example.com/attractions/ninh-binh/1.jpg","https://cdn.example.com/attractions/ninh-binh/2.jpg"]',4.7,'scenic,heritage','published',140,'["Tràng An","Chùa Bái Đính","Hang động"]','["thuyền","hướng dẫn viên","bãi đỗ xe"]','Đặt vé tham quan trước vào mùa cao điểm.','["family","couple"]','{"mon":[{"open":"07:00","close":"18:00"}],"tue":[{"open":"07:00","close":"18:00"}],"wed":[{"open":"07:00","close":"18:00"}],"thu":[{"open":"07:00","close":"18:00"}],"fri":[{"open":"07:00","close":"18:00"}],"sat":[{"open":"07:00","close":"19:00"}],"sun":[{"open":"07:00","close":"19:00"}]}','["08:30","10:30","14:30"]','["tự túc","theo tour"]'),
(1,43,'Điểm tham quan tiêu biểu - Ninh Thuận','Điểm tham quan nổi bật tại Ninh Thuận, phù hợp cho du khách muốn khám phá di sản Cham và vùng nắng gió.','Ninh Thuận, Việt Nam','Trung tâm Ninh Thuận','0.0000,0.0000','2025-10-01','2025-12-31',35000.00,'VND',80,1,100,'https://cdn.example.com/attractions/ninh-thuan/thumb.jpg','["https://cdn.example.com/attractions/ninh-thuan/1.jpg","https://cdn.example.com/attractions/ninh-thuan/2.jpg"]',4.0,'heritage,beach','published',100,'["Di tích Champa","Bãi biển","Cánh đồng nho"]','["hướng dẫn viên","nhà hàng"]','Tôn trọng văn hoá địa phương.','["culture","family"]','{"mon":[{"open":"07:00","close":"17:30"}],"tue":[{"open":"07:00","close":"17:30"}],"wed":[{"open":"07:00","close":"17:30"}],"thu":[{"open":"07:00","close":"17:30"}],"fri":[{"open":"07:00","close":"17:30"}],"sat":[{"open":"07:00","close":"18:00"}],"sun":[{"open":"07:00","close":"18:00"}]}','["09:00","15:00"]','["tự túc","tham quan nhóm"]'),
(1,44,'Điểm tham quan tiêu biểu - Phú Thọ','Điểm tham quan nổi bật tại Phú Thọ, phù hợp cho du khách muốn khám phá Đất Tổ Hùng Vương và lễ hội.','Phú Thọ, Việt Nam','Trung tâm Phú Thọ','0.0000,0.0000','2025-10-01','2025-12-31',31000.00,'VND',75,1,90,'https://cdn.example.com/attractions/phu-tho/thumb.jpg','["https://cdn.example.com/attractions/phu-tho/1.jpg","https://cdn.example.com/attractions/phu-tho/2.jpg"]',3.9,'heritage,festival','published',80,'["Đền Hùng","Lễ hội","Khu di tích"]','["hướng dẫn viên","bãi đỗ xe"]','Tìm hiểu lịch sử trước khi đi.','["culture","family"]','{"mon":[{"open":"08:00","close":"17:00"}],"tue":[{"open":"08:00","close":"17:00"}],"wed":[{"open":"08:00","close":"17:00"}],"thu":[{"open":"08:00","close":"17:00"}],"fri":[{"open":"08:00","close":"17:00"}],"sat":[{"open":"08:00","close":"17:30"}],"sun":[{"open":"08:00","close":"17:30"}]}','["09:00","13:00"]','["tự túc","theo tour"]'),
(1,45,'Điểm tham quan tiêu biểu - Phú Yên','Điểm tham quan nổi bật tại Phú Yên, phù hợp cho du khách muốn khám phá Gành Đá Dĩa và bờ biển.','Phú Yên, Việt Nam','Trung tâm Phú Yên','0.0000,0.0000','2025-10-01','2025-12-31',42000.00,'VND',110,1,140,'https://cdn.example.com/attractions/phu-yen/thumb.jpg','["https://cdn.example.com/attractions/phu-yen/1.jpg","https://cdn.example.com/attractions/phu-yen/2.jpg"]',4.3,'beach,scenic','published',120,'["Gành Đá Dĩa","Bãi biển","Đỉnh núi"]','["hướng dẫn viên","nhà hàng"]','Chuẩn bị máy ảnh cho cảnh đẹp.','["couple","family"]','{"mon":[{"open":"06:30","close":"18:00"}],"tue":[{"open":"06:30","close":"18:00"}],"wed":[{"open":"06:30","close":"18:00"}],"thu":[{"open":"06:30","close":"18:00"}],"fri":[{"open":"06:30","close":"18:00"}],"sat":[{"open":"06:30","close":"19:00"}],"sun":[{"open":"06:30","close":"19:00"}]}','["08:00","11:00","16:00"]','["tự túc","theo tour"]'),
(1,46,'Điểm tham quan tiêu biểu - Quảng Bình','Điểm tham quan nổi bật tại Quảng Bình, phù hợp cho du khách muốn khám phá Sơn Đoòng và hang động lớn.','Quảng Bình, Việt Nam','Trung tâm Quảng Bình','0.0000,0.0000','2025-10-01','2025-12-31',75000.00,'VND',100,1,120,'https://cdn.example.com/attractions/quang-binh/thumb.jpg','["https://cdn.example.com/attractions/quang-binh/1.jpg","https://cdn.example.com/attractions/quang-binh/2.jpg"]',4.8,'cave,adventure','published',300,'["Sơn Đoòng","Hang động","Địa chất độc đáo"]','["hướng dẫn viên chuyên nghiệp","thiết bị leo"]','Chỉ tham gia tour có hướng dẫn và chuẩn bị sức khỏe tốt.','["adventure","expert"]','{"mon":[{"open":"06:00","close":"18:00"}],"tue":[{"open":"06:00","close":"18:00"}],"wed":[{"open":"06:00","close":"18:00"}],"thu":[{"open":"06:00","close":"18:00"}],"fri":[{"open":"06:00","close":"18:00"}],"sat":[{"open":"06:00","close":"19:00"}],"sun":[{"open":"06:00","close":"19:00"}]}','["07:00","10:00"]','["theo tour"]'),
(1,47,'Điểm tham quan tiêu biểu - Quảng Nam','Điểm tham quan nổi bật tại Quảng Nam, phù hợp cho du khách muốn khám phá Hội An và di sản văn hoá.','Quảng Nam, Việt Nam','Trung tâm Quảng Nam','0.0000,0.0000','2025-10-01','2025-12-31',52000.00,'VND',160,1,220,'https://cdn.example.com/attractions/quang-nam/thumb.jpg','["https://cdn.example.com/attractions/quang-nam/1.jpg","https://cdn.example.com/attractions/quang-nam/2.jpg"]',4.6,'heritage,beach','published',140,'["Phố cổ Hội An","Bãi biển","Di tích"]','["hướng dẫn viên","thuyền","bãi đỗ xe"]','Đặt vé trước vào mùa cao điểm.','["family","couple"]','{"mon":[{"open":"07:00","close":"18:00"}],"tue":[{"open":"07:00","close":"18:00"}],"wed":[{"open":"07:00","close":"18:00"}],"thu":[{"open":"07:00","close":"18:00"}],"fri":[{"open":"07:00","close":"18:00"}],"sat":[{"open":"07:00","close":"19:00"}],"sun":[{"open":"07:00","close":"19:00"}]}','["08:00","10:00","15:00"]','["tự túc","theo tour"]'),
(1,48,'Điểm tham quan tiêu biểu - Quảng Ngãi','Điểm tham quan nổi bật tại Quảng Ngãi, phù hợp cho du khách muốn khám phá bãi biển và lịch sử.','Quảng Ngãi, Việt Nam','Trung tâm Quảng Ngãi','0.0000,0.0000','2025-10-01','2025-12-31',34000.00,'VND',90,1,110,'https://cdn.example.com/attractions/quang-ngai/thumb.jpg','["https://cdn.example.com/attractions/quang-ngai/1.jpg","https://cdn.example.com/attractions/quang-ngai/2.jpg"]',4.0,'beach,history','published',100,'["Bãi biển","Di tích lịch sử","Làng nghề"]','["hướng dẫn viên","bãi đỗ xe"]','Tôn trọng di tích lịch sử.','["culture","family"]','{"mon":[{"open":"07:00","close":"17:30"}],"tue":[{"open":"07:00","close":"17:30"}],"wed":[{"open":"07:00","close":"17:30"}],"thu":[{"open":"07:00","close":"17:30"}],"fri":[{"open":"07:00","close":"17:30"}],"sat":[{"open":"07:00","close":"18:00"}],"sun":[{"open":"07:00","close":"18:00"}]}','["09:00","14:00"]','["tự túc","tham quan nhóm"]'),
(1,49,'Điểm tham quan tiêu biểu - Quảng Ninh','Điểm tham quan nổi bật tại Quảng Ninh, phù hợp cho du khách muốn khám phá Vịnh Hạ Long.','Quảng Ninh, Việt Nam','Trung tâm Quảng Ninh','0.0000,0.0000','2025-10-01','2025-12-31',90000.00,'VND',300,1,500,'https://cdn.example.com/attractions/quang-ninh/thumb.jpg','["https://cdn.example.com/attractions/quang-ninh/1.jpg","https://cdn.example.com/attractions/quang-ninh/2.jpg"]',4.9,'worldheritage,cruise','published',240,'["Vịnh Hạ Long","Hang động","Du thuyền"]','["thuyền","hướng dẫn viên","nhà hàng"]','Đặt tour du thuyền trước.','["family","couple"]','{"mon":[{"open":"06:00","close":"19:00"}],"tue":[{"open":"06:00","close":"19:00"}],"wed":[{"open":"06:00","close":"19:00"}],"thu":[{"open":"06:00","close":"19:00"}],"fri":[{"open":"06:00","close":"19:00"}],"sat":[{"open":"06:00","close":"20:00"}],"sun":[{"open":"06:00","close":"20:00"}]}','["08:00","12:00","16:00"]','["tự túc","theo tour"]'),
(1,50,'Điểm tham quan tiêu biểu - Quảng Trị','Điểm tham quan nổi bật tại Quảng Trị, phù hợp cho du khách muốn khám phá lịch sử chiến tranh và di tích.','Quảng Trị, Việt Nam','Trung tâm Quảng Trị','0.0000,0.0000','2025-10-01','2025-12-31',30000.00,'VND',70,1,90,'https://cdn.example.com/attractions/quang-tri/thumb.jpg','["https://cdn.example.com/attractions/quang-tri/1.jpg","https://cdn.example.com/attractions/quang-tri/2.jpg"]',3.9,'history','published',90,'["Di tích chiến tranh","Nghĩa trang","Bảo tàng"]','["hướng dẫn viên"]','Tôn trọng không gian tưởng niệm.','["history","culture"]','{"mon":[{"open":"07:00","close":"17:00"}],"tue":[{"open":"07:00","close":"17:00"}],"wed":[{"open":"07:00","close":"17:00"}],"thu":[{"open":"07:00","close":"17:00"}],"fri":[{"open":"07:00","close":"17:00"}],"sat":[{"open":"07:00","close":"17:30"}],"sun":[{"open":"07:00","close":"17:30"}]}','["09:00","14:00"]','["tự túc"]'),
(1,51,'Điểm tham quan tiêu biểu - Sóc Trăng','Điểm tham quan nổi bật tại Sóc Trăng, phù hợp cho du khách muốn khám phá văn hoá Khmer và lễ hội.','Sóc Trăng, Việt Nam','Trung tâm Sóc Trăng','0.0000,0.0000','2025-10-01','2025-12-31',30000.00,'VND',70,1,90,'https://cdn.example.com/attractions/soc-trang/thumb.jpg','["https://cdn.example.com/attractions/soc-trang/1.jpg","https://cdn.example.com/attractions/soc-trang/2.jpg"]',4.0,'culture,festival','published',90,'["Chùa Khmer","Lễ hội địa phương","Chợ nổi"]','["hướng dẫn viên","thuyền"]','Tôn trọng sinh hoạt tôn giáo.','["culture","family"]','{"mon":[{"open":"07:00","close":"17:00"}],"tue":[{"open":"07:00","close":"17:00"}],"wed":[{"open":"07:00","close":"17:00"}],"thu":[{"open":"07:00","close":"17:00"}],"fri":[{"open":"07:00","close":"17:00"}],"sat":[{"open":"07:00","close":"17:30"}],"sun":[{"open":"07:00","close":"17:30"}]}','["08:30","13:30"]','["tự túc","tham quan nhóm"]'),
(1,52,'Điểm tham quan tiêu biểu - Sơn La','Điểm tham quan nổi bật tại Sơn La, phù hợp cho du khách muốn khám phá ruộng bậc thang và chè.','Sơn La, Việt Nam','Trung tâm Sơn La','0.0000,0.0000','2025-10-01','2025-12-31',32000.00,'VND',80,1,100,'https://cdn.example.com/attractions/son-la/thumb.jpg','["https://cdn.example.com/attractions/son-la/1.jpg","https://cdn.example.com/attractions/son-la/2.jpg"]',4.0,'scenic,agri','published',130,'["Ruộng bậc thang","Đồi chè","Làng bản"]','["hướng dẫn viên","đi bộ"]','Chuẩn bị thể lực cho leo dốc.','["adventure","friends"]','{"mon":[{"open":"06:30","close":"17:30"}],"tue":[{"open":"06:30","close":"17:30"}],"wed":[{"open":"06:30","close":"17:30"}],"thu":[{"open":"06:30","close":"17:30"}],"fri":[{"open":"06:30","close":"17:30"}],"sat":[{"open":"06:30","close":"18:00"}],"sun":[{"open":"06:30","close":"18:00"}]}','["08:00","13:00"]','["tự túc","tham quan nhóm"]'),
(1,53,'Điểm tham quan tiêu biểu - Tây Ninh','Điểm tham quan nổi bật tại Tây Ninh, phù hợp cho du khách muốn khám phá Núi Bà Đen và hành hương Cao Đài.','Tây Ninh, Việt Nam','Trung tâm Tây Ninh','0.0000,0.0000','2025-10-01','2025-12-31',36000.00,'VND',100,1,120,'https://cdn.example.com/attractions/tay-ninh/thumb.jpg','["https://cdn.example.com/attractions/tay-ninh/1.jpg","https://cdn.example.com/attractions/tay-ninh/2.jpg"]',4.2,'pilgrimage,mountain','published',140,'["Núi Bà Đen","Đền thờ Cao Đài","Phong cảnh"]','["hướng dẫn viên","cáp treo"]','Chuẩn bị sức khỏe cho leo núi.','["culture","adventure"]','{"mon":[{"open":"06:00","close":"18:00"}],"tue":[{"open":"06:00","close":"18:00"}],"wed":[{"open":"06:00","close":"18:00"}],"thu":[{"open":"06:00","close":"18:00"}],"fri":[{"open":"06:00","close":"18:00"}],"sat":[{"open":"06:00","close":"19:00"}],"sun":[{"open":"06:00","close":"19:00"}]}','["08:00","11:00","15:00"]','["tự túc","theo tour"]'),
(1,54,'Điểm tham quan tiêu biểu - Thái Bình','Điểm tham quan nổi bật tại Thái Bình, phù hợp cho du khách muốn khám phá làng nghề và nông sản.','Thái Bình, Việt Nam','Trung tâm Thái Bình','0.0000,0.0000','2025-10-01','2025-12-31',28000.00,'VND',60,1,80,'https://cdn.example.com/attractions/thai-binh/thumb.jpg','["https://cdn.example.com/attractions/thai-binh/1.jpg","https://cdn.example.com/attractions/thai-binh/2.jpg"]',3.7,'agri,culture','published',70,'["Làng nghề","Chợ địa phương","Cánh đồng"]','["hướng dẫn viên"]','Thử đặc sản địa phương.','["food","culture"]','{"mon":[{"open":"08:00","close":"17:00"}],"tue":[{"open":"08:00","close":"17:00"}],"wed":[{"open":"08:00","close":"17:00"}],"thu":[{"open":"08:00","close":"17:00"}],"fri":[{"open":"08:00","close":"17:00"}],"sat":[{"open":"08:00","close":"17:30"}],"sun":[{"open":"08:00","close":"17:30"}]}','["09:00","14:00"]','["tự túc"]'),
(1,55,'Điểm tham quan tiêu biểu - Thái Nguyên','Điểm tham quan nổi bật tại Thái Nguyên, phù hợp cho du khách muốn khám phá chè và cảnh quan trung du.','Thái Nguyên, Việt Nam','Trung tâm Thái Nguyên','0.0000,0.0000','2025-10-01','2025-12-31',32000.00,'VND',80,1,100,'https://cdn.example.com/attractions/thai-nguyen/thumb.jpg','["https://cdn.example.com/attractions/thai-nguyen/1.jpg","https://cdn.example.com/attractions/thai-nguyen/2.jpg"]',4.0,'agri,scenic','published',90,'["Đồi chè","Làng bản","Di tích"]','["hướng dẫn viên","bãi đỗ xe"]','Thử trà đặc sản địa phương.','["food","family"]','{"mon":[{"open":"07:00","close":"17:00"}],"tue":[{"open":"07:00","close":"17:00"}],"wed":[{"open":"07:00","close":"17:00"}],"thu":[{"open":"07:00","close":"17:00"}],"fri":[{"open":"07:00","close":"17:00"}],"sat":[{"open":"07:00","close":"17:30"}],"sun":[{"open":"07:00","close":"17:30"}]}','["08:30","13:30"]','["tự túc","tham quan nhóm"]'),
(1,56,'Điểm tham quan tiêu biểu - Thanh Hóa','Điểm tham quan nổi bật tại Thanh Hóa, phù hợp cho du khách muốn khám phá bờ biển và danh lam.','Thanh Hóa, Việt Nam','Trung tâm Thanh Hóa','0.0000,0.0000','2025-10-01','2025-12-31',46000.00,'VND',180,1,220,'https://cdn.example.com/attractions/thanh-hoa/thumb.jpg','["https://cdn.example.com/attractions/thanh-hoa/1.jpg","https://cdn.example.com/attractions/thanh-hoa/2.jpg"]',4.4,'beach,scenic','published',140,'["Bãi biển","Di tích","Đồi núi"]','["hướng dẫn viên","bãi đỗ xe"]','Chuẩn bị lịch trình dài cho khám phá tỉnh lớn.','["adventure","family"]','{"mon":[{"open":"06:30","close":"18:00"}],"tue":[{"open":"06:30","close":"18:00"}],"wed":[{"open":"06:30","close":"18:00"}],"thu":[{"open":"06:30","close":"18:00"}],"fri":[{"open":"06:30","close":"18:00"}],"sat":[{"open":"06:30","close":"19:00"}],"sun":[{"open":"06:30","close":"19:00"}]}','["08:00","12:00","15:00"]','["tự túc","theo tour"]'),
(1,57,'Điểm tham quan tiêu biểu - Thừa Thiên - Huế','Điểm tham quan nổi bật tại Thừa Thiên - Huế, phù hợp cho du khách muốn khám phá cố đô và kiến trúc cung đình.','Thừa Thiên - Huế, Việt Nam','Trung tâm Huế','0.0000,0.0000','2025-10-01','2025-12-31',53000.00,'VND',160,1,220,'https://cdn.example.com/attractions/thua-thien-hue/thumb.jpg','["https://cdn.example.com/attractions/thua-thien-hue/1.jpg","https://cdn.example.com/attractions/thua-thien-hue/2.jpg"]',4.7,'heritage,culture','published',150,'["Đại nội","Lăng tẩm","Phong cảnh sông Hương"]','["hướng dẫn viên","thuyền","nhà hàng"]','Tham khảo lịch trình văn hoá trước khi đi.','["culture","family"]','{"mon":[{"open":"07:00","close":"18:00"}],"tue":[{"open":"07:00","close":"18:00"}],"wed":[{"open":"07:00","close":"18:00"}],"thu":[{"open":"07:00","close":"18:00"}],"fri":[{"open":"07:00","close":"18:00"}],"sat":[{"open":"07:00","close":"19:00"}],"sun":[{"open":"07:00","close":"19:00"}]}','["08:00","10:00","14:00"]','["tự túc","theo tour"]'),
(1,58,'Điểm tham quan tiêu biểu - Tiền Giang','Điểm tham quan nổi bật tại Tiền Giang, phù hợp cho du khách muốn khám phá miệt vườn và chợ nổi.','Tiền Giang, Việt Nam','Trung tâm Tiền Giang','0.0000,0.0000','2025-10-01','2025-12-31',31000.00,'VND',80,1,100,'https://cdn.example.com/attractions/tien-giang/thumb.jpg','["https://cdn.example.com/attractions/tien-giang/1.jpg","https://cdn.example.com/attractions/tien-giang/2.jpg"]',3.9,'river,village','published',90,'["Chợ nổi","Miệt vườn","Làng nghề"]','["thuyền","hướng dẫn viên"]','Mang mũ và nước.','["family","friends"]','{"mon":[{"open":"06:30","close":"17:30"}],"tue":[{"open":"06:30","close":"17:30"}],"wed":[{"open":"06:30","close":"17:30"}],"thu":[{"open":"06:30","close":"17:30"}],"fri":[{"open":"06:30","close":"17:30"}],"sat":[{"open":"06:30","close":"18:00"}],"sun":[{"open":"06:30","close":"18:00"}]}','["07:30","10:30"]','["tự túc","tham quan nhóm"]'),
(1,59,'Điểm tham quan tiêu biểu - Trà Vinh','Điểm tham quan nổi bật tại Trà Vinh, phù hợp cho du khách muốn khám phá di sản Khmer và chùa chiền.','Trà Vinh, Việt Nam','Trung tâm Trà Vinh','0.0000,0.0000','2025-10-01','2025-12-31',30000.00,'VND',70,1,90,'https://cdn.example.com/attractions/tra-vinh/thumb.jpg','["https://cdn.example.com/attractions/tra-vinh/1.jpg","https://cdn.example.com/attractions/tra-vinh/2.jpg"]',4.0,'culture,heritage','published',90,'["Chùa Khmer","Lễ hội","Làng nghề"]','["hướng dẫn viên","thuyền"]','Tôn trọng sinh hoạt tôn giáo.','["culture","family"]','{"mon":[{"open":"07:00","close":"17:00"}],"tue":[{"open":"07:00","close":"17:00"}],"wed":[{"open":"07:00","close":"17:00"}],"thu":[{"open":"07:00","close":"17:00"}],"fri":[{"open":"07:00","close":"17:00"}],"sat":[{"open":"07:00","close":"17:30"}],"sun":[{"open":"07:00","close":"17:30"}]}','["08:30","13:30"]','["tự túc","tham quan nhóm"]'),
(1,60,'Điểm tham quan tiêu biểu - Tuyên Quang','Điểm tham quan nổi bật tại Tuyên Quang, phù hợp cho du khách muốn khám phá di tích lịch sử cách mạng và núi rừng.','Tuyên Quang, Việt Nam','Trung tâm Tuyên Quang','0.0000,0.0000','2025-10-01','2025-12-31',30000.00,'VND',70,1,90,'https://cdn.example.com/attractions/tuyen-quang/thumb.jpg','["https://cdn.example.com/attractions/tuyen-quang/1.jpg","https://cdn.example.com/attractions/tuyen-quang/2.jpg"]',3.9,'history,nature','published',100,'["Di tích lịch sử","Hồ nước","Bản làng"]','["hướng dẫn viên","đi bộ"]','Tìm hiểu lịch sử trước khi đi.','["history","culture"]','{"mon":[{"open":"07:00","close":"17:00"}],"tue":[{"open":"07:00","close":"17:00"}],"wed":[{"open":"07:00","close":"17:00"}],"thu":[{"open":"07:00","close":"17:00"}],"fri":[{"open":"07:00","close":"17:00"}],"sat":[{"open":"07:00","close":"17:30"}],"sun":[{"open":"07:00","close":"17:30"}]}','["09:00","14:00"]','["tự túc"]'),
(1,61,'Điểm tham quan tiêu biểu - Vĩnh Long','Điểm tham quan nổi bật tại Vĩnh Long, phù hợp cho du khách muốn khám phá sông nước và miệt vườn.','Vĩnh Long, Việt Nam','Trung tâm Vĩnh Long','0.0000,0.0000','2025-10-01','2025-12-31',30000.00,'VND',70,1,90,'https://cdn.example.com/attractions/vinh-long/thumb.jpg','["https://cdn.example.com/attractions/vinh-long/1.jpg","https://cdn.example.com/attractions/vinh-long/2.jpg"]',3.8,'river,village','published',90,'["Chợ nổi","Miệt vườn","Làng nghề"]','["thuyền","hướng dẫn viên"]','Mang mũ và nước.','["family","friends"]','{"mon":[{"open":"06:30","close":"17:30"}],"tue":[{"open":"06:30","close":"17:30"}],"wed":[{"open":"06:30","close":"17:30"}],"thu":[{"open":"06:30","close":"17:30"}],"fri":[{"open":"06:30","close":"17:30"}],"sat":[{"open":"06:30","close":"18:00"}],"sun":[{"open":"06:30","close":"18:00"}]}','["07:30","10:30"]','["tự túc","tham quan nhóm"]'),
(1,62,'Điểm tham quan tiêu biểu - Vĩnh Phúc','Điểm tham quan nổi bật tại Vĩnh Phúc, phù hợp cho du khách muốn khám phá Tam Đảo và khu công nghiệp gần Hà Nội.','Vĩnh Phúc, Việt Nam','Trung tâm Vĩnh Phúc','0.0000,0.0000','2025-10-01','2025-12-31',36000.00,'VND',100,1,120,'https://cdn.example.com/attractions/vinh-phuc/thumb.jpg','["https://cdn.example.com/attractions/vinh-phuc/1.jpg","https://cdn.example.com/attractions/vinh-phuc/2.jpg"]',4.1,'mountain,scenic','published',120,'["Tam Đảo","Công viên","Làng nghề"]','["hướng dẫn viên","cáp treo"]','Chuẩn bị áo ấm và giày leo.','["adventure","family"]','{"mon":[{"open":"07:00","close":"18:00"}],"tue":[{"open":"07:00","close":"18:00"}],"wed":[{"open":"07:00","close":"18:00"}],"thu":[{"open":"07:00","close":"18:00"}],"fri":[{"open":"07:00","close":"18:00"}],"sat":[{"open":"07:00","close":"19:00"}],"sun":[{"open":"07:00","close":"19:00"}]}','["08:00","11:00","15:00"]','["tự túc","theo tour"]'),
(1,63,'Điểm tham quan tiêu biểu - Yên Bái','Điểm tham quan nổi bật tại Yên Bái, phù hợp cho du khách muốn khám phá ruộng bậc thang Mù Cang Chải và bản làng.','Yên Bái, Việt Nam','Trung tâm Yên Bái','0.0000,0.0000','2025-10-01','2025-12-31',38000.00,'VND',90,1,110,'https://cdn.example.com/attractions/yen-bai/thumb.jpg','["https://cdn.example.com/attractions/yen-bai/1.jpg","https://cdn.example.com/attractions/yen-bai/2.jpg"]',4.2,'scenic,agri','published',160,'["Mù Cang Chải","Ruộng bậc thang","Bản làng"]','["hướng dẫn viên","đi bộ"]','Chuẩn bị thể lực và đồ ấm buổi tối.','["adventure","friends"]','{"mon":[{"open":"06:30","close":"17:30"}],"tue":[{"open":"06:30","close":"17:30"}],"wed":[{"open":"06:30","close":"17:30"}],"thu":[{"open":"06:30","close":"17:30"}],"fri":[{"open":"06:30","close":"17:30"}],"sat":[{"open":"06:30","close":"18:00"}],"sun":[{"open":"06:30","close":"18:00"}]}','["08:00","13:00"]','["tự túc","tham quan nhóm"]');









