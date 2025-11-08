-- Create the database
CREATE DATABASE ecommerce_analytics_enhanced;
USE ecommerce_analytics_enhanced;

-- Drop tables if they exist (for re-runs, in reverse dependency order)
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_details;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS addresses;
DROP TABLE IF EXISTS customers;

-- Create customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    join_date DATE NOT NULL
);

-- Create addresses table (one-to-many: customers can have multiple addresses)
CREATE TABLE addresses (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    address_type ENUM('Billing', 'Shipping') NOT NULL,
    street VARCHAR(200) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50),
    zip_code VARCHAR(10),
    country VARCHAR(50) DEFAULT 'USA',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

-- Create categories table (lookup for products)
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- Create suppliers table (lookup for products)
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100),
    city VARCHAR(50)
);

-- Create products table (now links to categories and suppliers)
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category_id INT NOT NULL,
    supplier_id INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE RESTRICT
);

-- Create orders table
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    shipping_address_id INT,  -- References addresses for shipping
    order_date DATE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status ENUM('Pending', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (shipping_address_id) REFERENCES addresses(address_id) ON DELETE SET NULL
);

-- Create order_details table
CREATE TABLE order_details (
    order_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,  -- Price at time of order
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
);

-- Create payments table (one-to-many: orders can have multiple payments, e.g., split)
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    payment_method ENUM('Credit Card', 'Debit Card', 'PayPal', 'Bank Transfer') NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date DATE NOT NULL,
    status ENUM('Completed', 'Failed', 'Pending') DEFAULT 'Pending',
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);

-- Indexes for performance
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_order_details_product ON order_details(product_id);
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_addresses_customer ON addresses(customer_id);
-- Insert categories (4 samples)
INSERT INTO categories (category_name, description) VALUES
('Electronics', 'Gadgets and devices'),
('Books', 'Printed and digital books'),
('Apparel', 'Clothing and accessories'),
('Home', 'Household items');

-- Insert suppliers (5 samples)
INSERT INTO suppliers (supplier_name, contact_email, city) VALUES
('TechCorp', 'sales@techcorp.com', 'Silicon Valley'),
('BookHouse', 'orders@bookhouse.com', 'New York'),
('FashionHub', 'info@fashionhub.com', 'Los Angeles'),
('HomeEssentials', 'supply@homeess.com', 'Chicago'),
('GadgetWorld', 'contact@gadgetworld.com', 'Seattle');

-- Insert customers (10 samples)
INSERT INTO customers (customer_name, email, phone, join_date) VALUES
('Alice Johnson', 'alice@email.com', '555-0101', '2024-01-15'),
('Bob Smith', 'bob@email.com', '555-0102', '2024-02-20'),
('Carol Davis', 'carol@email.com', '555-0103', '2024-03-10'),
('David Wilson', 'david@email.com', '555-0104', '2024-04-05'),
('Eve Brown', 'eve@email.com', '555-0105', '2024-05-12'),
('Frank Garcia', 'frank@email.com', '555-0106', '2024-06-01'),
('Grace Lee', 'grace@email.com', '555-0107', '2024-06-15'),
('Henry Martinez', 'henry@email.com', '555-0108', '2024-07-01'),
('Ivy Taylor', 'ivy@email.com', '555-0109', '2024-07-20'),
('Jack Anderson', 'jack@email.com', '555-0110', '2024-08-10');

-- Insert addresses (2 per customer: billing & shipping)
INSERT INTO addresses (customer_id, address_type, street, city, state, zip_code) VALUES
-- Alice
(1, 'Billing', '123 Main St', 'New York', 'NY', '10001'),
(1, 'Shipping', '456 Park Ave', 'New York', 'NY', '10002'),
-- Bob
(2, 'Billing', '789 Sunset Blvd', 'Los Angeles', 'CA', '90210'),
(2, 'Shipping', '101 Ocean Dr', 'Los Angeles', 'CA', '90211'),
-- Carol
(3, 'Billing', '202 Lake Shore', 'Chicago', 'IL', '60601'),
(3, 'Shipping', '303 River Rd', 'Chicago', 'IL', '60602'),
-- David
(4, 'Billing', '404 Bayou St', 'Houston', 'TX', '77001'),
(4, 'Shipping', '505 Gulf Way', 'Houston', 'TX', '77002'),
-- Eve
(5, 'Billing', '606 Desert Ln', 'Phoenix', 'AZ', '85001'),
(5, 'Shipping', '707 Cactus Ave', 'Phoenix', 'AZ', '85002'),
-- Frank
(6, 'Billing', '808 Vine St', 'Miami', 'FL', '33101'),
(6, 'Shipping', '909 Palm Dr', 'Miami', 'FL', '33102'),
-- Grace
(7, 'Billing', '1010 Cherry Blvd', 'Seattle', 'WA', '98101'),
(7, 'Shipping', '1111 Rainier Ave', 'Seattle', 'WA', '98102'),
-- Henry
(8, 'Billing', '1212 Oak St', 'Denver', 'CO', '80201'),
(8, 'Shipping', '1313 Pine Rd', 'Denver', 'CO', '80202'),
-- Ivy
(9, 'Billing', '1414 Elm Ave', 'Boston', 'MA', '02101'),
(9, 'Shipping', '1515 Harbor St', 'Boston', 'MA', '02102'),
-- Jack
(10, 'Billing', '1616 Hill Dr', 'Atlanta', 'GA', '30301'),
(10, 'Shipping', '1717 Peach Blvd', 'Atlanta', 'GA', '30302');

-- Insert products (15 samples, assigned to categories/suppliers)
INSERT INTO products (product_name, category_id, supplier_id, unit_price, stock_quantity) VALUES
(1, 1, 1, 999.99, 50),    -- iPhone 15, Electronics, TechCorp
(2, 1, 1, 1999.99, 20),   -- MacBook Pro
(3, 1, 5, 29.99, 100),    -- Wireless Mouse, GadgetWorld
(4, 2, 2, 149.99, 75),    -- Kindle Paperwhite, Books, BookHouse
(5, 2, 2, 39.99, 200),    -- Python Book
(6, 2, 2, 49.99, 150),    -- Data Science Book
(7, 3, 3, 129.99, 30),    -- Nike Shoes, Apparel, FashionHub
(8, 3, 3, 59.99, 40),     -- Adidas Hoodie
(9, 4, 4, 19.99, 80),     -- Coffee Mug, Home, HomeEssentials
(10, 1, 5, 79.99, 60),    -- Bluetooth Speaker
(11, 1, 1, 499.99, 25),   -- Smart Watch
(12, 3, 3, 89.99, 35),    -- Levi Jeans
(13, 2, 2, 29.99, 180),   -- Fiction Novel
(14, 4, 4, 39.99, 45),    -- Kitchen Blender
(15, 1, 5, 149.99, 55);   -- Earbuds

-- Insert orders (30 samples; assign shipping_address_id as 2nd address per customer)
INSERT INTO orders (customer_id, shipping_address_id, order_date, total_amount, status) VALUES
(1, 2, '2025-01-01', 1029.98, 'Delivered'),  -- Alice
(1, 2, '2025-01-15', 2049.98, 'Shipped'),
(2, 4, '2025-01-05', 89.97, 'Delivered'),    -- Bob
(2, 4, '2025-01-20', 199.98, 'Pending'),
(3, 6, '2025-01-10', 79.99, 'Delivered'),    -- Carol
(3, 6, '2025-02-01', 89.98, 'Shipped'),
(4, 8, '2025-01-25', 159.98, 'Delivered'),   -- David
(4, 8, '2025-02-05', 109.98, 'Pending'),
(5, 10, '2025-02-10', 1049.98, 'Shipped'),   -- Eve
(5, 10, '2025-02-15', 69.98, 'Delivered'),
(6, 12, '2025-02-20', 549.98, 'Delivered'),  -- Frank: Watch + Book
(6, 12, '2025-03-01', 129.99, 'Shipped'),    -- Shoes
(7, 14, '2025-03-05', 229.98, 'Pending'),    -- Grace: Hoodie + Mug + Novel
(7, 14, '2025-03-10', 79.99, 'Delivered'),   -- Speaker
(8, 16, '2025-03-15', 139.98, 'Shipped'),    -- Henry: Jeans + Blender
(8, 16, '2025-03-20', 1999.99, 'Delivered'), -- MacBook
(9, 18, '2025-03-25', 179.98, 'Pending'),    -- Ivy: Earbuds + Fiction
(9, 18, '2025-04-01', 49.99, 'Shipped'),     -- Data Book
(10, 20, '2025-04-05', 109.98, 'Delivered'), -- Jack: Jeans + Mug
(10, 20, '2025-04-10', 999.99, 'Pending'),   -- iPhone
(1, 2, '2025-04-15', 49.99, 'Delivered'),    -- Alice: Python Book
(2, 4, '2025-04-20', 129.99, 'Shipped'),     -- Bob: Shoes
(3, 6, '2025-04-25', 199.99, 'Pending'),     -- Carol: Kindle + Mouse
(4, 8, '2025-05-01', 149.99, 'Delivered'),   -- David: Blender
(5, 10, '2025-05-05', 39.99, 'Shipped'),     -- Eve: Novel
(6, 12, '2025-05-10', 29.99, 'Delivered'),   -- Frank: Mouse
(7, 14, '2025-05-15', 59.99, 'Pending'),     -- Grace: Hoodie
(8, 16, '2025-05-20', 79.99, 'Shipped'),     -- Henry: Speaker
(9, 18, '2025-05-25', 19.99, 'Delivered'),   -- Ivy: Mug
(10, 20, '2025-06-01', 499.99, 'Pending');    -- Jack: Watch

-- Insert order_details (links for all 30 orders; sample quantities/prices)
INSERT INTO order_details (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 999.99), (1, 3, 1, 29.99),
(2, 2, 1, 1999.99), (2, 5, 1, 49.99),
(3, 3, 2, 29.99), (3, 9, 1, 19.99),
(4, 4, 1, 149.99), (4, 10, 1, 49.99),  -- Adjusted for sample
(5, 10, 1, 79.99),
(6, 3, 1, 29.99), (6, 6, 1, 59.99),
(7, 7, 1, 129.99), (7, 9, 1, 29.99),
(8, 8, 1, 59.99), (8, 10, 1, 49.99),
(9, 1, 1, 999.99), (9, 5, 1, 49.99),
(10, 8, 1, 59.99), (10, 9, 1, 9.99),
(11, 11, 1, 499.99), (11, 13, 1, 49.99),
(12, 7, 1, 129.99),
(13, 8, 1, 59.99), (13, 9, 1, 19.99), (13, 13, 1, 29.99),  -- 3 items
(14, 10, 1, 79.99),
(15, 12, 1, 89.99), (15, 14, 1, 49.99),
(16, 2, 1, 1999.99),
(17, 15, 1, 149.99), (17, 13, 1, 29.99),
(18, 6, 1, 49.99),
(19, 12, 1, 89.99), (19, 9, 1, 19.99),
(20, 1, 1, 999.99),
(21, 5, 1, 39.99),
(22, 7, 1, 129.99),
(23, 4, 1, 149.99), (23, 3, 1, 49.99),  -- Adjusted
(24, 14, 1, 39.99),
(25, 13, 1, 29.99),
(26, 3, 1, 29.99),
(27, 8, 1, 59.99),
(28, 10, 1, 79.99),
(29, 9, 1, 19.99),
(30, 11, 1, 499.99);

-- Insert payments (most orders have 1 payment; some split)
INSERT INTO payments (order_id, payment_method, amount, payment_date, status) VALUES
(1, 'Credit Card', 1029.98, '2025-01-01', 'Completed'),
(2, 'PayPal', 2049.98, '2025-01-15', 'Completed'),
(3, 'Debit Card', 44.99, '2025-01-05', 'Completed'), (3, 'Bank Transfer', 44.98, '2025-01-05', 'Completed'),  -- Split
(4, 'Credit Card', 199.98, '2025-01-20', 'Pending'),
(5, 'PayPal', 79.99, '2025-01-10', 'Completed'),
(6, 'Debit Card', 89.98, '2025-02-01', 'Completed'),
(7, 'Credit Card', 159.98, '2025-01-25', 'Completed'),
(8, 'PayPal', 109.98, '2025-02-05', 'Pending'),
(9, 'Debit Card', 1049.98, '2025-02-10', 'Completed'),
(10, 'Credit Card', 69.98, '2025-02-15', 'Completed'),
(11, 'PayPal', 549.98, '2025-02-20', 'Completed'),
(12, 'Debit Card', 129.99, '2025-03-01', 'Completed'),
(13, 'Credit Card', 229.98, '2025-03-05', 'Pending'),
(14, 'PayPal', 79.99, '2025-03-10', 'Completed'),
(15, 'Debit Card', 139.98, '2025-03-15', 'Completed'),
(16, 'Credit Card', 1999.99, '2025-03-20', 'Completed'),
(17, 'PayPal', 179.98, '2025-03-25', 'Pending'),
(18, 'Debit Card', 49.99, '2025-04-01', 'Completed'),
(19, 'Credit Card', 109.98, '2025-04-05', 'Completed'),
(20, 'PayPal', 999.99, '2025-04-10', 'Pending'),
(21, 'Debit Card', 39.99, '2025-04-15', 'Completed'),
(22, 'Credit Card', 129.99, '2025-04-20', 'Completed'),
(23, 'PayPal', 199.99, '2025-04-25', 'Pending'),
(24, 'Debit Card', 39.99, '2025-05-01', 'Completed'),
(25, 'Credit Card', 29.99, '2025-05-05', 'Completed'),
(26, 'PayPal', 29.99, '2025-05-10', 'Completed'),
(27, 'Debit Card', 59.99, '2025-05-15', 'Pending'),
(28, 'Credit Card', 79.99, '2025-05-20', 'Completed'),
(29, 'PayPal', 19.99, '2025-05-25', 'Completed'),
(30, 'Debit Card', 499.99, '2025-06-01', 'Pending'),
-- Extra for split example
(3, 'Bank Transfer', 44.98, '2025-01-05', 'Completed');  -- Duplicate for clarity, but adjust if needed
