-- Migration: Remove booking_settings_json column from hotels, tours, and activities tables
-- Date: 2025-12-01
-- Reason: Field is not being used and adds unnecessary complexity

-- Remove from hotels table
ALTER TABLE hotels DROP COLUMN IF EXISTS booking_settings_json;

-- Remove from tours table
ALTER TABLE tours DROP COLUMN IF EXISTS booking_settings_json;

-- Remove from activities table
ALTER TABLE activities DROP COLUMN IF EXISTS booking_settings_json;
