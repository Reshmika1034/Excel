-- Database Creation
CREATE DATABASE rm;
USE rm;

-- 1. Customers Table
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact VARCHAR(15) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE
);

-- 2. Staff Table
CREATE TABLE Staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    role ENUM('Manager', 'Chef', 'Waiter') NOT NULL,
    contact VARCHAR(15) UNIQUE NOT NULL
);

-- 3. Menu Table
CREATE TABLE Menu (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    category VARCHAR(50) NOT NULL
);

-- 4. Tables (Restaurant seating) Table
CREATE TABLE Tables (
    table_id INT AUTO_INCREMENT PRIMARY KEY,
    capacity INT NOT NULL,
    status ENUM('Available', 'Reserved') DEFAULT 'Available'
);

-- 5. Reservations Table
CREATE TABLE Reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    table_id INT NOT NULL,
    reservation_date DATE NOT NULL,
    time_slot TIME NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (table_id) REFERENCES Tables(table_id)
);

-- 6. Orders Table
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- 7. Order_Items Table (for many-to-many relationship between Orders and Menu)
CREATE TABLE Order_Items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (item_id) REFERENCES Menu(item_id)
);

INSERT INTO Customers (name, contact, email)
VALUES
('Sam', '9876543210', 'sam@gmail.com'),
('Iniyaal', '8765432109', 'iniyaal@gmail.com'),
('Harish', '7654321098', 'harish@gmail.com');


INSERT INTO Staff (name, role, contact)
VALUES
('Sunitha', 'Manager', '1239874560'),
('Sindhu', 'Chef', '7891234560'),
('Peter', 'Waiter', '4567891230');

INSERT INTO Menu (name, price, category)
VALUES
('Margherita Pizza', 250, 'Main Course'),
('Caesar Salad', 150, 'Starter'),
('Chocolate Cake', 100, 'Dessert'),
('Orange Juice', 60, 'Beverage');

INSERT INTO Tables (capacity, status)
VALUES
(4, 'Available'),  
(2, 'Reserved'),
(6, 'Available'),
(4, 'Reserved');


INSERT INTO Reservations (customer_id, table_id, reservation_date, time_slot)
VALUES
(1, 1, '2024-12-15', '18:30:00'),
(2, 2, '2024-12-15', '20:00:00'),
(3, 3, '2024-12-15', '21:30:00');


INSERT INTO Orders (customer_id, order_date, total_amount)
VALUES
(1, '2024-12-15 18:45:00', 310),
(2, '2024-12-15 20:15:00', 250),
(3, '2024-12-15 21:00:00', 350);


INSERT INTO Order_Items (order_id, item_id, quantity)
VALUES
(1, 1, 2),  -- 2 Margherita Pizzas for Order 1
(1, 4, 1),  -- 1 Orange Juice for Order 1
(2, 2, 1),  -- 1 Caesar Salad for Order 2
(2, 3, 1),  -- 1 Chocolate Cake for Order 2
(3, 1, 1),  -- 1 Margherita Pizza for Order 3
(3, 3, 1);  -- 1 Chocolate Cake for Order 3

 -- a. Retrieve all customers
 SELECT * FROM Customers;

-- b. Get the total number of orders placed by a customer
SELECT COUNT(*) AS total_orders
FROM Orders
WHERE customer_id = 1;

-- c. List all reservations
SELECT * FROM Reservations;

-- d. Get details of a  customer 1 (by ID)
SELECT * FROM Customers WHERE customer_id = 1;

-- e. Find the staff members (by role)
SELECT name, role FROM Staff WHERE role = 'Waiter';

-- f. Find the order details (including item names) for a order_id 1

SELECT 
    o.order_id,
    o.order_date,
    m.name AS item_name,
    oi.quantity,
    m.price * oi.quantity AS item_total
FROM Orders o
JOIN Order_Items oi ON o.order_id = oi.order_id
JOIN Menu m ON oi.item_id = m.item_id
WHERE o.order_id = 1;

-- g. Get menu items with their price sorted in descending order
SELECT name, price FROM Menu ORDER BY price DESC;

-- h. Get the total amount spent by each customer
SELECT 
    c.name AS customer_name,
    SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.name;

-- i. Get the number of orders placed by each customer
SELECT 
    c.name AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.name;

-- j. Find the most ordered menu items (grouped by item name)
SELECT 
    m.name AS item_name,
    SUM(oi.quantity) AS total_quantity_ordered
FROM Order_Items oi
JOIN Menu m ON oi.item_id = m.item_id
GROUP BY m.name
ORDER BY total_quantity_ordered DESC;


-- k. List the customers who have reserved tables along with their reservation times
SELECT 
    c.name AS customer_name,
    r.reservation_date,
    r.time_slot
FROM Reservations r
JOIN Customers c ON r.customer_id = c.customer_id;


-- l. Get the number of reservations per table (grouped by table_id)
SELECT 
    t.table_id,
    COUNT(r.reservation_id) AS total_reservations
FROM Reservations r
JOIN Tables t ON r.table_id = t.table_id
GROUP BY t.table_id;

-- m. Find the most recent order placed by each customer
SELECT 
    c.name AS customer_name,
    MAX(o.order_date) AS latest_order_date
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.name;

-- n. Find the total number of reservations per day
SELECT 
    r.reservation_date,
    COUNT(r.reservation_id) AS total_reservations
FROM Reservations r
GROUP BY r.reservation_date
ORDER BY r.reservation_date DESC;

-- o. Get the staff who served the most reservations
SELECT 
    s.name AS staff_name,
    s.role AS staff_role,
    COUNT(r.reservation_id) AS total_reservations_served
FROM Staff s
JOIN Reservations r ON r.staff_id = s.staff_id
GROUP BY s.name
ORDER BY total_reservations_served DESC
LIMIT 1;

-- p. Get the total sales of all menu items for category 'beverage'
SELECT 
    m.category AS item_category,
    SUM(oi.quantity * m.price) AS total_sales
FROM Order_Items oi
JOIN Menu m ON oi.item_id = m.item_id
JOIN Orders o ON oi.order_id = o.order_id
WHERE m.category = 'Beverage'
GROUP BY m.category;

-- q. Find the orders placed in the last 7 days
SELECT 
    o.order_id,
    o.order_date,
    c.name AS customer_name,
    o.total_amount
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
WHERE o.order_date >= CURDATE() - INTERVAL 7 DAY
ORDER BY o.order_date DESC;

-- r. Get the details of customers who have placed orders but haven't made any reservations
SELECT 
    c.name AS customer_name,
    c.email AS customer_email,
    o.order_id,
    o.order_date,
    o.total_amount
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
LEFT JOIN Reservations r ON c.customer_id = r.customer_id
WHERE r.reservation_id IS NULL;

-- s. Get the list of all staff members along with the number of orders they’ve handled (based on the assigned reservation)
SELECT 
    s.name AS staff_name,
    s.role AS staff_role,
    COUNT(DISTINCT o.order_id) AS orders_handled
FROM Staff s
JOIN Reservations r ON r.staff_id = s.staff_id
JOIN Orders o ON r.reservation_id = o.reservation_id
GROUP BY s.staff_id
ORDER BY orders_handled DESC;

-- t. Find menu categories where the average price of items exceeds 50.
SELECT 
    category,
    AVG(price) AS avg_price
FROM 
    Menu
GROUP BY 
    category
HAVING 
    AVG(price) > 50;

-- -----------------------------------
-- View customer_order_summary
-- -----------------------------------
CREATE VIEW customer_order_summary AS
SELECT 
    c.customer_id,
    c.name AS customer_name,
    o.order_id,
    o.order_date,
    COUNT(oi.item_id) AS number_of_items,
    SUM(oi.quantity * m.price) AS total_sales
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Order_Items oi ON o.order_id = oi.order_id
JOIN Menu m ON oi.item_id = m.item_id
GROUP BY c.customer_id, o.order_id;

-- --------------------------------------
-- STORED PROCEDURES
-- --------------------------------------

-- add a new customer
delimiter $$
CREATE PROCEDURE add_new_customer(
    IN p_name VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_phone_number VARCHAR(15)
)
BEGIN
    -- Insert the new customer into the Customers table
    INSERT INTO Customers (name, email, phone_number)
    VALUES (p_name, p_email, p_phone_number);
END $$

DELIMITER $$
-- inserting a customer
CALL add_new_customer('Narendra prasath', 'np.gmail.com', '1234567890');



-- update a customer phone number
CREATE PROCEDURE update_customer_phone(
    IN p_customer_id INT,
    IN p_new_phone_number VARCHAR(15)
)
BEGIN
    -- Update the phone number for the specified customer_id
    UPDATE Customers
    SET phone_number = p_new_phone_number
    WHERE customer_id = p_customer_id;
END$$

DELIMITER ;
-- updating a customer
CALL update_customer_phone(101, '9876543210');


-- ----------------------------------------
-- TRIGGERS
-- ----------------------------------------
--  Update Table Status on Reservation
-- Automatically update the Tables table's status to "Reserved" when a new reservation is added.
DELIMITER $$
CREATE TRIGGER after_reservation_insert
AFTER INSERT ON Reservations
FOR EACH ROW
BEGIN
    UPDATE Tables
    SET status = 'Reserved'
    WHERE table_id = NEW.table_id;
END$$
DELIMITER ;



