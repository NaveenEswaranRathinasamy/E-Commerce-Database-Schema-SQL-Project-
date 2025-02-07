-- Creating Enum Type for Payment Method
CREATE TYPE payment_method_enum AS ENUM ('Cash', 'Credit Card', 'PayPal');

-- Creating Tables

CREATE TABLE Suppliers (
    supplier_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT
);

CREATE TABLE Products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL,
    supplier_id INT REFERENCES Suppliers(supplier_id)
);

CREATE TABLE Customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    address TEXT
);

CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES Customers(customer_id),
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2)
);

CREATE TABLE OrderDetails (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES Orders(order_id),
    product_id INT REFERENCES Products(product_id),
    quantity INT NOT NULL,
    subtotal DECIMAL(10,2)
);

CREATE TABLE Payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES Orders(order_id),
    payment_date DATE NOT NULL,
    amount DECIMAL(10,2),
    payment_method payment_method_enum
);

-- Inserting Sample Data

INSERT INTO Suppliers (name, contact_email, phone, address) VALUES
('ABC Suppliers', 'abc@supplier.com', '1234567890', '123 Street, City'),
('XYZ Wholesalers', 'xyz@wholesale.com', '9876543210', '456 Avenue, Town');

INSERT INTO Products (name, category, price, stock_quantity, supplier_id) VALUES
('Laptop', 'Electronics', 800.00, 50, 1),
('Smartphone', 'Electronics', 500.00, 100, 1),
('Headphones', 'Accessories', 50.00, 200, 2),
('Keyboard', 'Accessories', 30.00, 150, 2);

INSERT INTO Customers (name, email, phone, address) VALUES
('John Doe', 'john@example.com', '1112223333', '789 Street, City'),
('Jane Smith', 'jane@example.com', '4445556666', '101 Road, Town');

INSERT INTO Orders (customer_id, order_date, total_amount) VALUES
(1, '2024-02-01', 850.00),
(2, '2024-02-03', 530.00);

INSERT INTO OrderDetails (order_id, product_id, quantity, subtotal) VALUES
(1, 1, 1, 800.00),
(1, 3, 1, 50.00),
(2, 2, 1, 500.00),
(2, 4, 1, 30.00);

INSERT INTO Payments (order_id, payment_date, amount, payment_method) VALUES
(1, '2024-02-02', 850.00, 'Credit Card'),
(2, '2024-02-04', 530.00, 'PayPal');

--================================================
--1) Retrieve product details with low stock.
SELECT product_id,
    name,
    category,
    price,
    stock_quantity,
    supplier_id 
FROM products
WHERE stock_quantity < 150;

--2) Find the Total Revenue for a Given Period 
SELECT order_id,
    customer_id,
    order_date,
    total_amount 
FROM orders
WHERE order_date BETWEEN '2024-01-01' AND '2024-06-30';

--3) Identify the Most Popular Product Category
SELECT P.name, SUM(O.quantity) AS most_popular 
FROM products P
JOIN OrderDetails O ON P.product_id = O.product_id
GROUP BY P.name
ORDER BY most_popular DESC
LIMIT 1;

--4) List Top Customer by Total Spending
SELECT C.customer_id, C.name, SUM(O.total_amount) AS total_spendings_by_customers
FROM Customers C
JOIN Orders O ON C.customer_id = O.customer_id
GROUP BY C.customer_id, C.name
ORDER BY total_spendings_by_customers DESC
LIMIT 1;

--5) Get Monthly Sales Reports
SELECT 
    EXTRACT(MONTH FROM O.order_date) AS month,
    P.product_id,
    SUM(OD.quantity) AS total_quantity_sold,
    SUM(OD.subtotal) AS subtotal,
    SUM(O.total_amount) AS total_sales
FROM Orders O
JOIN OrderDetails OD ON O.order_id = OD.order_id
JOIN Products P ON OD.product_id = P.product_id
GROUP BY month, P.product_id
ORDER BY month DESC;