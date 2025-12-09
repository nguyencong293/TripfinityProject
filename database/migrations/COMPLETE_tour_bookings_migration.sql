-- Add missing fields to tour_bookings table
-- Date: 2025-12-09

USE tripfinity;

ALTER TABLE tour_bookings
ADD COLUMN special_requests TEXT DEFAULT NULL COMMENT 'Yêu cầu đặc biệt' AFTER num_adults,
ADD COLUMN deposit_amount DECIMAL(12,2) DEFAULT NULL COMMENT 'Tiền đặt cọc' AFTER total_price,
ADD COLUMN payment_method VARCHAR(50) DEFAULT NULL COMMENT 'Phương thức thanh toán' AFTER currency_code,
ADD COLUMN provider_confirmed TINYINT NOT NULL DEFAULT 0 COMMENT '0=pending, 1=confirmed, 2=cancelled' AFTER provider_notes,
ADD COLUMN provider_confirmed_at DATETIME DEFAULT NULL COMMENT 'Thời điểm xác nhận' AFTER provider_confirmed;

CREATE INDEX idx_tour_bookings_provider_confirmed ON tour_bookings(provider_confirmed);
