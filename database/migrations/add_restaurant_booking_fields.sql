-- Migration: Add reservation fields to restaurant_bookings table
-- Date: 2025-12-09
-- Note: Chỉ thêm các trường còn thiếu (reservation_date, reservation_time, special_requests, deposit_amount)
-- Các trường khác đã có sẵn trong database
-- IMPORTANT: Chỉ chạy script này 1 lần duy nhất!

USE tripfinity;

-- Add only missing columns
ALTER TABLE restaurant_bookings
ADD COLUMN reservation_date DATE DEFAULT NULL COMMENT 'Ngày đặt bàn' AFTER booking_date;

ALTER TABLE restaurant_bookings
ADD COLUMN reservation_time TIME DEFAULT NULL COMMENT 'Giờ đặt bàn (HH:mm:ss)' AFTER reservation_date;

ALTER TABLE restaurant_bookings
ADD COLUMN special_requests TEXT DEFAULT NULL COMMENT 'Yêu cầu đặc biệt (ghế gần cửa sổ, sinh nhật, etc)' AFTER num_adults;

ALTER TABLE restaurant_bookings
ADD COLUMN deposit_amount DECIMAL(12,2) DEFAULT NULL COMMENT 'Tiền đặt cọc' AFTER total_price;

-- Add indexes for better query performance
CREATE INDEX idx_rest_booking_reservation_date ON restaurant_bookings(reservation_date);
