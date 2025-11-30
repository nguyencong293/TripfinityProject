-- Add fcm_token column to users table for push notification
ALTER TABLE users 
ADD COLUMN fcm_token VARCHAR(255) NULL 
COMMENT 'Firebase Cloud Messaging token for push notifications';

-- Add index for faster lookup
CREATE INDEX idx_fcm_token ON users(fcm_token);
