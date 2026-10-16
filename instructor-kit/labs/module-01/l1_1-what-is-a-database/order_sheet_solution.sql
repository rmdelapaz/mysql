-- state: none
-- =====================================================================
-- order_sheet_solution.sql: what goes wrong when a "database" is one big sheet
-- Session 1 · Lesson 1.1 · MySQL Foundations instructor kit · instructor reference
--
-- A bookshop kept its orders in ONE spreadsheet-style table. Every
-- question below has a simple answer in a relational design and a
-- slippery one here. Builds kit_s1_sheet and drops it at the end.
-- =====================================================================

DROP DATABASE IF EXISTS kit_s1_sheet;
CREATE DATABASE kit_s1_sheet;
USE kit_s1_sheet;

CREATE TABLE order_sheet (
    order_no       INT PRIMARY KEY,
    customer_name  VARCHAR(50),
    customer_email VARCHAR(100),
    customer_city  VARCHAR(50),
    books          VARCHAR(200),
    total          VARCHAR(20)
);

INSERT INTO order_sheet VALUES
    (1, 'Alice Johnson', 'alice@example.com', 'New York', 'Dune, 1984, 1984',      '34.97'),
    (2, 'Alice Jonson',  'alice@example.com', 'New York', 'Pride and Prejudice',   '7.99'),
    (3, 'Bob Smith',     'bob@example.com',   'Chicago',  'Dune',                  '14.99'),
    (4, 'Bob Smith',     'bob@example.com',   'Boston',   'Dune Messiah',          '9.99'),
    (5, 'Grace Wilson',  'grace@example.com', 'Chicago',  'The Hobbit, Dune',      'about 26'),
    (6, 'alice johnson', 'alice@example.com', 'New York', 'Brave New World',       '9.49');

-- 1 · One customer, how many spellings? Every row for Alice's email:
SELECT order_no, customer_name, customer_email
FROM order_sheet
WHERE customer_email = 'alice@example.com'
ORDER BY order_no;

-- 2 · Where does Bob live? His city was typed twice and now disagrees:
SELECT order_no, customer_name, customer_city
FROM order_sheet
WHERE customer_email = 'bob@example.com'
ORDER BY order_no;

-- 3 · Which orders contain Dune? A list squeezed into one cell forces a text
--     search, and the search also matches a DIFFERENT book (Dune Messiah):
SELECT order_no, books
FROM order_sheet
WHERE books LIKE '%Dune%'
ORDER BY order_no;

-- 4 · The total column is text, so nothing stops a non-number getting in:
SELECT order_no, total
FROM order_sheet
WHERE total = 'about 26';

-- 5 · The fix, in miniature: each customer stored ONCE, orders point at them.
CREATE TABLE customers (
    id    INT AUTO_INCREMENT PRIMARY KEY,
    name  VARCHAR(50)  NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    city  VARCHAR(50)
);
CREATE TABLE orders (
    order_no    INT PRIMARY KEY,
    customer_id INT NOT NULL,
    total       DECIMAL(8,2) NOT NULL
);
INSERT INTO customers (name, email, city) VALUES
    ('Alice Johnson', 'alice@example.com', 'New York'),
    ('Bob Smith',     'bob@example.com',   'Boston'),
    ('Grace Wilson',  'grace@example.com', 'Chicago');
INSERT INTO orders VALUES (1, 1, 34.97), (2, 1, 7.99), (3, 2, 14.99), (6, 1, 9.49);

-- Alice's orders: follow the key by hand (customer 1), no spellings involved
SELECT order_no, customer_id, total
FROM orders
WHERE customer_id = 1
ORDER BY order_no;

-- Alice changes her email: ONE row changes, every order still points at her
UPDATE customers SET email = 'alice.j@example.com' WHERE id = 1;
SELECT id, name, email FROM customers ORDER BY id;

DROP DATABASE kit_s1_sheet;
