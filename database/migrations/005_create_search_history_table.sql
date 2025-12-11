-- Migration: Create search_history table
-- Created: 2025-12-11
-- Description: Store user search history for hotels, restaurants, tours, and attractions

USE tripfinity;

-- Create search_history table
CREATE TABLE IF NOT EXISTS search_history (
    search_history_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    
    -- Search query information
    search_query VARCHAR(255) NOT NULL,
    search_type ENUM('hotel', 'restaurant', 'tour', 'attraction', 'general') NOT NULL DEFAULT 'general',
    
    -- Reference to the viewed item (nullable, as user might just search without clicking)
    item_type ENUM('hotel', 'restaurant', 'tour', 'attraction', 'area') DEFAULT NULL,
    item_id INT DEFAULT NULL,
    item_title VARCHAR(255) DEFAULT NULL,
    item_location VARCHAR(255) DEFAULT NULL,
    item_thumbnail_url VARCHAR(512) DEFAULT NULL,
    
    -- Additional metadata
    search_timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    clicked BOOLEAN NOT NULL DEFAULT FALSE,
    click_timestamp DATETIME DEFAULT NULL,
    
    -- Indexes for better query performance
    INDEX idx_user_timestamp (user_id, search_timestamp DESC),
    INDEX idx_user_clicked (user_id, clicked, search_timestamp DESC),
    INDEX idx_search_query (search_query),
    INDEX idx_item_type_id (item_type, item_id),
    
    CONSTRAINT fk_search_history_user 
        FOREIGN KEY (user_id) 
        REFERENCES users(user_id) 
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add comment to table
ALTER TABLE search_history COMMENT = 'Stores user search history and clicked items for personalized recommendations';
