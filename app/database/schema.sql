-- AI-Vision Locust Monitoring App Database Schema
-- MySQL Database for XAMPP

CREATE DATABASE IF NOT EXISTS locust_monitoring;
USE locust_monitoring;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    role VARCHAR(20) DEFAULT 'staff',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Environmental data table
CREATE TABLE IF NOT EXISTS environmental_data (
    id INT PRIMARY KEY AUTO_INCREMENT,
    temperature DECIMAL(5,2),
    humidity DECIMAL(5,2),
    light_level DECIMAL(5,2),
    activity_index DECIMAL(5,2),
    feed_level DECIMAL(5,2),
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_recorded_at (recorded_at)
);

-- Predictions/Logs table
CREATE TABLE IF NOT EXISTS predictions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    condition_type VARCHAR(20) NOT NULL, -- 'normal', 'hungry', 'stressed'
    confidence DECIMAL(5,2),
    frame_data TEXT, -- JSON or base64 encoded frame features
    recommended_action VARCHAR(100),
    notes TEXT,
    user_id INT,
    environmental_data_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (environmental_data_id) REFERENCES environmental_data(id),
    INDEX idx_created_at (created_at),
    INDEX idx_condition (condition_type)
);

-- Actions taken table
CREATE TABLE IF NOT EXISTS actions_taken (
    id INT PRIMARY KEY AUTO_INCREMENT,
    prediction_id INT,
    action_type VARCHAR(50) NOT NULL, -- 'feed', 'misting', 'no_action'
    action_details TEXT,
    user_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (prediction_id) REFERENCES predictions(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_created_at (created_at)
);

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    title VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(20), -- 'alert', 'info', 'warning'
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_user_read (user_id, is_read)
);

-- Insert default admin user (password: admin123)
INSERT INTO users (username, email, password_hash, full_name, role) 
VALUES ('admin', 'admin@locustfarm.com', '$2a$11$KIXQZ8QZ8QZ8QZ8QZ8QZ8O', 'Admin User', 'admin')
ON DUPLICATE KEY UPDATE username=username;

-- Insert sample environmental data
INSERT INTO environmental_data (temperature, humidity, light_level, activity_index, feed_level) VALUES
(25.5, 60.0, 75.0, 0.65, 80.0),
(26.0, 58.0, 72.0, 0.60, 75.0),
(24.8, 62.0, 78.0, 0.70, 85.0);

