-- Create Database
CREATE DATABASE FISHFARM_DB;
USE FISHFARM_DB;

-- Create USERS Table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'customer') DEFAULT 'customer',
    full_name VARCHAR(100),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create TANKS Table (200 tanks)
CREATE TABLE tanks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tank_name VARCHAR(50) NOT NULL,
    capacity_kg DECIMAL(10,2) DEFAULT 100.00,
    current_stock_kg DECIMAL(10,2) DEFAULT 0.00,
    status ENUM('ACTIVE', 'MAINTENANCE', 'EMPTY') DEFAULT 'EMPTY',
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Create FISH_TYPES Table (6 species from your image)
CREATE TABLE fish_types (
    id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create FISH_VARIETIES Table (varieties for each type)
CREATE TABLE fish_varieties (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fish_type_id INT NOT NULL,
    variety_name VARCHAR(50) NOT NULL,
    average_weight_kg DECIMAL(5,2),
    price_per_kg DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (fish_type_id) REFERENCES fish_types(id),
    UNIQUE KEY unique_variety (fish_type_id, variety_name)
);

-- Create STOCK Table (linking tanks with varieties)
CREATE TABLE stock (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tank_id INT NOT NULL,
    variety_id INT NOT NULL,
    quantity INT DEFAULT 0,
    total_weight_kg DECIMAL(10,2) DEFAULT 0.00,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tank_id) REFERENCES tanks(id),
    FOREIGN KEY (variety_id) REFERENCES fish_varieties(id),
    UNIQUE KEY unique_tank_variety (tank_id, variety_id)
);

-- Create ORDERS Table
CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2),
    status ENUM('PENDING', 'PROCESSING', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING',
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Create ORDER_ITEMS Table
CREATE TABLE order_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    variety_id INT NOT NULL,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (variety_id) REFERENCES fish_varieties(id)
);

-- Insert Sample Data

-- 1. Insert Users (Admin & Customer)
INSERT INTO users (username, password, role, full_name, email) VALUES
('admin', 'admin123', 'admin', 'Admin User', 'admin@aquaexpress.com'),
('customer', 'customer123', 'customer', 'John Customer', 'john@email.com');

-- 2. Insert Fish Types (From your image)
INSERT INTO fish_types (type_name, description) VALUES
('Angelfish', 'Freshwater angelfish - various colors and patterns'),
('Ramerezi', 'German Blue Ram - colorful dwarf cichlid'),
('Arowana', 'Asian Arowana - dragon fish'),
('Plecostomus', 'Suckerfish - algae eater'),
('Discus', 'Discus fish - king of aquarium'),
('Guppy', 'Guppy fish - colorful livebearer');

-- 3. Insert Fish Varieties (Sample varieties for each type)
INSERT INTO fish_varieties (fish_type_id, variety_name, average_weight_kg, price_per_kg) VALUES
-- Angelfish varieties
(1, 'Platinum Angelfish', 0.5, 25.00),
(1, 'Marble Angelfish', 0.4, 20.00),
(1, 'Koi Angelfish', 0.6, 30.00),
(1, 'Black Angelfish', 0.5, 22.00),
(1, 'Gold Angelfish', 0.4, 28.00),
-- Ramerezi varieties
(2, 'German Blue Ram', 0.3, 35.00),
(2, 'Golden Ram', 0.3, 30.00),
(2, 'Electric Blue Ram', 0.4, 40.00),
-- Arowana varieties
(3, 'Asian Green Arowana', 1.5, 50.00),
(3, 'Asian Red Arowana', 1.8, 75.00),
(3, 'Silver Arowana', 1.0, 30.00),
(3, 'Black Arowana', 1.2, 45.00),
-- Plecostomus varieties
(4, 'Common Pleco', 1.0, 15.00),
(4, 'Bristlenose Pleco', 0.5, 20.00),
(4, 'Zebra Pleco', 0.3, 45.00),
-- Discus varieties
(5, 'Blue Diamond Discus', 0.8, 60.00),
(5, 'Red Discus', 0.7, 55.00),
(5, 'Pigeon Blood Discus', 0.6, 50.00),
(5, 'Snakeskin Discus', 0.7, 65.00),
-- Guppy varieties
(6, 'Fancy Guppy', 0.1, 10.00),
(6, 'Cobra Guppy', 0.1, 12.00),
(6, 'Tuxedo Guppy', 0.1, 11.00);

-- 4. Generate 200 Tanks
DELIMITER $$
CREATE PROCEDURE generate_tanks()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 200 DO
        INSERT INTO tanks (tank_name, capacity_kg, current_stock_kg, status, created_by) 
        VALUES (
            CONCAT('Tank-', LPAD(i, 3, '0')),
            100.00,
            0.00,
            CASE 
                WHEN i <= 160 THEN 'ACTIVE'
                WHEN i <= 180 THEN 'MAINTENANCE'
                ELSE 'EMPTY'
            END,
            1
        );
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;

CALL generate_tanks();

-- 5. Add sample stock to some tanks
INSERT INTO stock (tank_id, variety_id, quantity, total_weight_kg) VALUES
(1, 1, 20, 10.00),
(1, 2, 15, 6.00),
(2, 6, 10, 3.00),
(5, 9, 5, 7.50),
(10, 16, 8, 6.40);

-- Update tank current_stock_kg
UPDATE tanks SET current_stock_kg = 16.00 WHERE id = 1;
UPDATE tanks SET current_stock_kg = 3.00 WHERE id = 2;
UPDATE tanks SET current_stock_kg = 7.50 WHERE id = 5;
UPDATE tanks SET current_stock_kg = 6.40 WHERE id = 10;

-- View sample data
SELECT 'Users:' as '';
SELECT * FROM users;
SELECT 'Fish Types:' as '';
SELECT * FROM fish_types;
SELECT 'Tanks Count:' as '';
SELECT COUNT(*) as total_tanks FROM tanks;
SELECT 'Stock Sample:' as '';
SELECT t.tank_name, ft.type_name, fv.variety_name, s.quantity, s.total_weight_kg
FROM stock s
JOIN tanks t ON s.tank_id = t.id
JOIN fish_varieties fv ON s.variety_id = fv.id
JOIN fish_types ft ON fv.fish_type_id = ft.id
LIMIT 5;