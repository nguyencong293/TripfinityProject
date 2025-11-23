-- Migration: Add rooms management columns
-- Date: 2025-11-23

-- 1. Add total_rooms column to hotels table
ALTER TABLE tripfinity.hotels 
ADD COLUMN total_rooms INT NULL 
COMMENT 'Tổng số phòng của khách sạn';

-- 2. Add rooms column to hotel_bookings table
ALTER TABLE tripfinity.hotel_bookings 
ADD COLUMN rooms INT NOT NULL DEFAULT 1 
COMMENT 'Số phòng được đặt trong booking này';

-- Optional: Update existing bookings to have default 1 room
UPDATE tripfinity.hotel_bookings 
SET rooms = 1 
WHERE rooms IS NULL OR rooms = 0;
