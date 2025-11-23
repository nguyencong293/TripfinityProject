-- Migration: Add 'checked_out' status to hotel_bookings.booking_status enum
-- Date: 2025-11-23
-- Description: Thêm status 'checked_out' để đánh dấu booking đã trả phòng

-- Bước 1: Thêm 'checked_out' vào enum booking_status
ALTER TABLE tripfinity.hotel_bookings 
MODIFY COLUMN booking_status ENUM('pending', 'confirmed', 'cancelled', 'completed', 'refunded', 'checked_out') 
NOT NULL;

-- Bước 2: Tự động check-out các booking completed đã quá endDate
-- (Optional - chỉ chạy nếu muốn migrate data cũ)
-- UPDATE tripfinity.hotel_bookings 
-- SET booking_status = 'checked_out'
-- WHERE booking_status = 'completed' 
-- AND end_date < CURDATE();

-- Kiểm tra kết quả
SELECT booking_status, COUNT(*) as count 
FROM tripfinity.hotel_bookings 
GROUP BY booking_status;
