-- Migration: Xóa các trường không sử dụng
-- Date: 2025-12-12
-- Description: Xóa rating_average, booking_settings_json, coordinates từ các bảng dịch vụ

-- Xóa rating_average từ tours
ALTER TABLE tours DROP COLUMN IF EXISTS rating_average;

-- Xóa rating_average từ restaurants  
ALTER TABLE restaurants DROP COLUMN IF EXISTS rating_average;

-- Xóa rating_average và coordinates từ attractions
ALTER TABLE attractions DROP COLUMN IF EXISTS rating_average;
ALTER TABLE attractions DROP COLUMN IF EXISTS coordinates;

-- Xóa rating_average từ hotels
ALTER TABLE hotels DROP COLUMN IF EXISTS rating_average;

-- Xóa booking_settings_json từ tours (nếu còn)
ALTER TABLE tours DROP COLUMN IF EXISTS booking_settings_json;

-- Xóa booking_settings_json từ restaurants (nếu còn)
ALTER TABLE restaurants DROP COLUMN IF EXISTS booking_settings_json;

-- Xóa booking_settings_json từ attractions (nếu còn)
ALTER TABLE attractions DROP COLUMN IF EXISTS booking_settings_json;

-- Note: published_at đã có trong tất cả các bảng và đang hoạt động
-- Note: is_featured được giữ lại vì có công dụng
