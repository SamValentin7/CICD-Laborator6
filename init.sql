-- Create database
CREATE DATABASE IF NOT EXISTS laborator6;

-- Use database
USE laborator6;

-- Create items table
CREATE TABLE IF NOT EXISTS items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO items (name, description) VALUES
('Sample Item 1', 'This is a sample item'),
('Sample Item 2', 'Another sample item');
