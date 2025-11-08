1. Basic Queries
-- 1. List all customers with their email and join date
SELECT customer_id, customer_name, email, join_date
FROM customers
ORDER BY join_date ASC;

-- 2. Get all products with their category and supplier names
SELECT p.product_name, c.category_name, s.supplier_name, p.unit_price
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN suppliers s ON p.supplier_id = s.supplier_id
ORDER BY p.unit_price DESC;

-- 3. Show total number of orders per customer
SELECT c.customer_name, COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name
ORDER BY total_orders DESC;

-- 4. Find all products that are low in stock (less than 50)
SELECT product_name, stock_quantity
FROM products
WHERE stock_quantity < 50
ORDER BY stock_quantity ASC;

-- 5. Display all completed payments with amount and date
SELECT p.payment_id, o.order_id, p.amount, p.payment_date, p.payment_method
FROM payments p
JOIN orders o ON p.order_id = o.order_id
WHERE p.status = 'Completed'
ORDER BY p.payment_date DESC;

2. Intermediate Queries
-- 1. Calculate total sales per category
SELECT c.category_name, ROUND(SUM(od.quantity * od.unit_price), 2) AS total_sales
FROM order_details od
JOIN products p ON od.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_sales DESC;

-- 2. Find top 5 customers by total amount spent
SELECT c.customer_name, ROUND(SUM(o.total_amount), 2) AS total_spent
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY total_spent DESC
LIMIT 5;

-- 3. Count number of orders by status
SELECT status, COUNT(order_id) AS total_orders
FROM orders
GROUP BY status;

-- 4. Find most popular products (by total quantity sold)
SELECT p.product_name, SUM(od.quantity) AS total_sold
FROM order_details od
JOIN products p ON od.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sold DESC
LIMIT 10;

-- 5. Show monthly sales trend for 2025
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, 
       ROUND(SUM(total_amount), 2) AS monthly_sales
FROM orders
WHERE YEAR(order_date) = 2025
GROUP BY month
ORDER BY month;

3. Advanced Queries
-- 1. Top 3 categories by revenue contribution (%)
SELECT 
    c.category_name,
    ROUND(SUM(od.quantity * od.unit_price), 2) AS total_revenue,
    ROUND(SUM(od.quantity * od.unit_price) * 100 / 
          (SELECT SUM(od2.quantity * od2.unit_price)
           FROM order_details od2), 2) AS revenue_percent
FROM order_details od
JOIN products p ON od.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_revenue DESC
LIMIT 3;

-- 2. Find repeat customers (those who made more than 2 orders)
SELECT c.customer_name, COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name
HAVING COUNT(o.order_id) > 2
ORDER BY order_count DESC;

-- 3. Average order value (AOV) per month
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
       ROUND(SUM(total_amount)/COUNT(order_id), 2) AS avg_order_value
FROM orders
GROUP BY month
ORDER BY month;

-- 4. Payment success rate by method
SELECT payment_method,
       COUNT(CASE WHEN status = 'Completed' THEN 1 END) AS successful,
       COUNT(*) AS total,
       ROUND(COUNT(CASE WHEN status = 'Completed' THEN 1 END)*100 / COUNT(*), 2) AS success_rate_percent
FROM payments
GROUP BY payment_method
ORDER BY success_rate_percent DESC;

-- 5. Customer lifetime value (CLV) – total spent by each customer
SELECT c.customer_name,
       ROUND(SUM(o.total_amount), 2) AS lifetime_value,
       MIN(o.order_date) AS first_purchase,
       MAX(o.order_date) AS last_purchase
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name
ORDER BY lifetime_value DESC;
