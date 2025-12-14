-- Migration: Create Trip System Tables
-- Date: 2025-12-14
-- Description: Create tables for Trip, TripItinerary, TripItineraryItem

-- Table: trips
-- Stores user trip information
CREATE TABLE IF NOT EXISTS trips (
    trip_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    trip_name VARCHAR(200) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    cover_image VARCHAR(500) DEFAULT 'assets/images/onboarding1.png',
    status ENUM('active', 'completed', 'cancelled') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_trip_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) 
        ON DELETE CASCADE,
    
    INDEX idx_trip_user (user_id),
    INDEX idx_trip_status (status),
    INDEX idx_trip_dates (start_date, end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: trip_itineraries
-- Stores daily itineraries for each trip
CREATE TABLE IF NOT EXISTS trip_itineraries (
    itinerary_id INT AUTO_INCREMENT PRIMARY KEY,
    trip_id INT NOT NULL,
    itinerary_date DATE NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_itinerary_trip FOREIGN KEY (trip_id) 
        REFERENCES trips(trip_id) 
        ON DELETE CASCADE,
    
    UNIQUE KEY unique_trip_date (trip_id, itinerary_date),
    INDEX idx_itinerary_trip (trip_id),
    INDEX idx_itinerary_date (itinerary_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: trip_itinerary_items
-- Stores individual items (services) in each daily itinerary
CREATE TABLE IF NOT EXISTS trip_itinerary_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    itinerary_id INT NOT NULL,
    service_type ENUM('hotel', 'restaurant', 'attraction', 'tour') NOT NULL,
    service_id INT NOT NULL,
    item_order INT DEFAULT 0,
    start_time TIME,
    end_time TIME,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_item_itinerary FOREIGN KEY (itinerary_id) 
        REFERENCES trip_itineraries(itinerary_id) 
        ON DELETE CASCADE,
    
    INDEX idx_item_itinerary (itinerary_id),
    INDEX idx_item_service (service_type, service_id),
    INDEX idx_item_order (itinerary_id, item_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert sample data for testing
INSERT INTO trips (user_id, trip_name, start_date, end_date, status) 
VALUES 
    (1, 'Du lịch Đà Nẵng', '2025-06-12', '2025-06-20', 'active'),
    (1, 'Khám phá Hội An', '2025-03-15', '2025-03-20', 'completed');

-- Insert sample itineraries
INSERT INTO trip_itineraries (trip_id, itinerary_date, notes) 
VALUES 
    (1, '2025-06-12', 'Ngày đầu tiên - Khám phá Bà Nà Hills'),
    (1, '2025-06-13', 'Ngày thứ hai - Tham quan các địa điểm lịch sử');

-- Insert sample itinerary items
-- Assuming these service IDs exist in respective tables
INSERT INTO trip_itinerary_items (itinerary_id, service_type, service_id, item_order, start_time, end_time, notes) 
VALUES 
    (1, 'attraction', 1, 1, '08:00:00', '12:00:00', 'Tham quan Cầu Vàng'),
    (1, 'restaurant', 1, 2, '12:30:00', '14:00:00', 'Ăn trưa tại nhà hàng Waterfront'),
    (1, 'attraction', 2, 3, '15:00:00', '18:00:00', 'Sun World Bà Nà Hills');
