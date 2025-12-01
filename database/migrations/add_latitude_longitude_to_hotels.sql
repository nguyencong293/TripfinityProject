-- Migration: Add latitude and longitude columns to hotels table
-- Date: 2025-12-01
-- Description: Add geographic coordinates to enable map-based location selection and display

USE tripfinity;

-- Add latitude and longitude columns
ALTER TABLE hotels 
ADD COLUMN latitude DECIMAL(10,8) DEFAULT NULL COMMENT 'Latitude coordinate for map location' AFTER address,
ADD COLUMN longitude DECIMAL(11,8) DEFAULT NULL COMMENT 'Longitude coordinate for map location' AFTER latitude;

-- Add index for location-based queries (optional but recommended for performance)
CREATE INDEX idx_hotels_location ON hotels(latitude, longitude);

-- Verify the changes
DESCRIBE hotels;

-- Example: Update existing hotels with coordinates if needed
-- UPDATE hotels SET latitude = 10.7751, longitude = 106.7005 WHERE hotel_id = 1;
