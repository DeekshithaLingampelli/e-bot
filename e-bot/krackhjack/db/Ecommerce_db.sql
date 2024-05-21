-- Create Database
CREATE DATABASE IF NOT EXISTS `ecommerce_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */;
USE `ecommerce_db`;

-- Users Table
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
    `user_id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) UNIQUE NOT NULL,
    `password` VARCHAR(255) NOT NULL,
    `address` TEXT,
    `phone_number` VARCHAR(15),
    `role` ENUM('customer', 'admin') DEFAULT 'customer' NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Categories Table
DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` (
    `category_id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Products Table
DROP TABLE IF EXISTS `products`;
CREATE TABLE `products` (
    `product_id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT,
    `price` DECIMAL(10, 2) NOT NULL,
    `category_id` INT,
    `stock_quantity` INT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Orders Table
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
    `order_id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT,
    `order_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `status` VARCHAR(50) NOT NULL,
    `total_amount` DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Order Items Table
DROP TABLE IF EXISTS `order_items`;
CREATE TABLE `order_items` (
    `order_item_id` INT AUTO_INCREMENT PRIMARY KEY,
    `order_id` INT,
    `product_id` INT,
    `quantity` INT NOT NULL,
    `price` DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
    FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Payments Table
DROP TABLE IF EXISTS `payments`;
CREATE TABLE `payments` (
    `payment_id` INT AUTO_INCREMENT PRIMARY KEY,
    `order_id` INT,
    `payment_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `amount` DECIMAL(10, 2) NOT NULL,
    `payment_method` VARCHAR(50) NOT NULL,
    `status` VARCHAR(50) NOT NULL,
    FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Reviews Table
DROP TABLE IF EXISTS `reviews`;
CREATE TABLE `reviews` (
    `review_id` INT AUTO_INCREMENT PRIMARY KEY,
    `product_id` INT,
    `user_id` INT,
    `rating` INT CHECK (rating >= 1 AND rating <= 5),
    `comment` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`),
    FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Wishlists Table
DROP TABLE IF EXISTS `wishlists`;
CREATE TABLE `wishlists` (
    `wishlist_id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT,
    FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Wishlist Items Table
DROP TABLE IF EXISTS `wishlist_items`;
CREATE TABLE `wishlist_items` (
    `wishlist_item_id` INT AUTO_INCREMENT PRIMARY KEY,
    `wishlist_id` INT,
    `product_id` INT,
    FOREIGN KEY (`wishlist_id`) REFERENCES `wishlists` (`wishlist_id`),
    FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Shopping Cart Items Table
DROP TABLE IF EXISTS `shopping_cart_items`;
CREATE TABLE `shopping_cart_items` (
    `cart_item_id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT,
    `product_id` INT,
    `quantity` INT NOT NULL,
    FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
    FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Sample Data Insertion
INSERT INTO `users` (`name`, `email`, `password`, `address`, `phone_number`, `role`) VALUES
('John Doe', 'john@example.com', 'hashed_password1', '123 Elm Street', '555-1234', 'customer'),
('Jane Smith', 'jane@example.com', 'hashed_password2', '456 Oak Avenue', '555-5678', 'customer'),
('Admin User', 'admin@example.com', 'hashed_password3', '789 Pine Road', '555-9012', 'admin');

INSERT INTO `categories` (`name`, `description`) VALUES
('Electronics', 'Devices and gadgets'),
('Books', 'Fiction and non-fiction books'),
('Clothing', 'Men\'s and women\'s clothing');

INSERT INTO `products` (`name`, `description`, `price`, `category_id`, `stock_quantity`) VALUES
('Laptop', 'High performance laptop', 999.99, 1, 50),
('Smartphone', 'Latest model smartphone', 699.99, 1, 150),
('Science Fiction Novel', 'A gripping science fiction novel', 19.99, 2, 100),
('T-Shirt', 'Comfortable cotton t-shirt', 9.99, 3, 200);

INSERT INTO `orders` (`user_id`, `status`, `total_amount`) VALUES
(1, 'Processing', 1009.98),
(2, 'Shipped', 719.98);

INSERT INTO `order_items` (`order_id`, `product_id`, `quantity`, `price`) VALUES
(1, 1, 1, 999.99),
(1, 3, 1, 19.99),
(2, 2, 1, 699.99),
(2, 4, 2, 19.99);

-- Stored Procedures and Functions

-- Function to Get Product Price
DELIMITER ;;
CREATE FUNCTION `get_product_price`(p_product_name VARCHAR(100)) RETURNS DECIMAL(10,2)
    DETERMINISTIC
BEGIN
    DECLARE v_price DECIMAL(10,2);

    SELECT `price` INTO v_price
    FROM `products`
    WHERE `name` = p_product_name
    LIMIT 1;

    RETURN v_price;
END ;;
DELIMITER ;

-- Function to Get Total Order Amount
DELIMITER ;;
CREATE FUNCTION `get_total_order_amount`(p_order_id INT) RETURNS DECIMAL(10,2)
    DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10,2);

    SELECT SUM(`price` * `quantity`) INTO v_total
    FROM `order_items`
    WHERE `order_id` = p_order_id;

    RETURN v_total;
END ;;
DELIMITER ;

-- Procedure to Add Item to Order
DELIMITER ;;
CREATE PROCEDURE `add_item_to_order`(
    IN p_order_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_total DECIMAL(10,2);

    -- Get product price
    SELECT `price` INTO v_price
    FROM `products`
    WHERE `product_id` = p_product_id;

    -- Calculate total price
    SET v_total = v_price * p_quantity;

    -- Insert order item
    INSERT INTO `order_items` (`order_id`, `product_id`, `quantity`, `price`)
    VALUES (p_order_id, p_product_id, p_quantity, v_total);

    -- Update order total
    UPDATE `orders`
    SET `total_amount` = (SELECT `get_total_order_amount`(p_order_id))
    WHERE `order_id` = p_order_id;
END ;;
DELIMITER ;

-- Final Environment Reset (Optional)
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY */;
