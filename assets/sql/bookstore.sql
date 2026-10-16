-- =====================================================================
-- MySQL Foundations: the bookstore sample database
-- =====================================================================
-- Builds the complete course database from scratch. Running it again
-- throws away the old copy and starts fresh, so you can always get back
-- to a known state.
--
-- How to run it (from the folder you saved it in):
--   mysql -u root -p < bookstore.sql
-- or, inside the mysql client:
--   SOURCE bookstore.sql;
--
-- Works on MySQL 9.7 LTS, MySQL 8.4 LTS and MariaDB (LTS releases).
-- Customers, employees and orders are fictional. The books and their
-- authors are real classics.
-- =====================================================================

DROP DATABASE IF EXISTS bookstore;

CREATE DATABASE bookstore
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE bookstore;

-- ---------------------------------------------------------------------
-- authors: one row per author ("one" side of books)
-- ---------------------------------------------------------------------
CREATE TABLE authors (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    birth_year  INT
);

INSERT INTO authors (id, name, birth_year) VALUES
    (1, 'Frank Herbert', 1920),
    (2, 'George Orwell', 1903),
    (3, 'Harper Lee', 1926),
    (4, 'F. Scott Fitzgerald', 1896),
    (5, 'Jane Austen', 1775),
    (6, 'J.R.R. Tolkien', 1892),
    (7, 'Aldous Huxley', 1894),
    (8, 'J.D. Salinger', 1919),
    (9, 'Ray Bradbury', 1920),
    (10, 'Isaac Asimov', 1920);

-- ---------------------------------------------------------------------
-- books: each book belongs to one author
-- ---------------------------------------------------------------------
CREATE TABLE books (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    title       VARCHAR(200) NOT NULL,
    author_id   INT NOT NULL,
    price       DECIMAL(8, 2) NOT NULL,
    pages       INT,
    published   DATE,
    in_stock    BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_books_author
        FOREIGN KEY (author_id) REFERENCES authors(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

INSERT INTO books (id, title, author_id, price, pages, published, in_stock) VALUES
    (1, 'Dune', 1, 14.99, 412, '1965-08-01', TRUE),
    (2, '1984', 2, 9.99, 328, '1949-06-08', TRUE),
    (3, 'To Kill a Mockingbird', 3, 11.99, 281, '1960-07-11', TRUE),
    (4, 'The Great Gatsby', 4, 8.99, 180, '1925-04-10', FALSE),
    (5, 'Pride and Prejudice', 5, 7.99, 432, '1813-01-28', TRUE),
    (6, 'The Hobbit', 6, 10.99, 310, '1937-09-21', TRUE),
    (7, 'Brave New World', 7, 9.49, 311, '1932-01-01', TRUE),
    (8, 'The Catcher in the Rye', 8, 8.99, 234, '1951-07-16', FALSE),
    (9, 'Lord of the Rings', 6, 15.99, 1178, '1954-07-29', TRUE),
    (10, 'Fahrenheit 451', 9, 10.49, 158, '1953-10-19', TRUE),
    (11, 'Animal Farm', 2, 8.49, 112, '1945-08-17', TRUE);

-- ---------------------------------------------------------------------
-- categories and the book_categories junction table (many-to-many)
-- ---------------------------------------------------------------------
CREATE TABLE categories (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255)
);

INSERT INTO categories (id, name, description) VALUES
    (1, 'Fiction', 'Novels, short stories, and other imaginative works'),
    (2, 'Science Fiction', 'Stories exploring futuristic or scientific concepts'),
    (3, 'Classic', 'Timeless literary works recognized across generations'),
    (4, 'Fantasy', 'Stories set in imaginary worlds with magical elements'),
    (5, 'Dystopian', 'Stories about oppressive societies and dark futures');

CREATE TABLE book_categories (
    book_id     INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (book_id, category_id),
    CONSTRAINT fk_bc_book
        FOREIGN KEY (book_id) REFERENCES books(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_bc_category
        FOREIGN KEY (category_id) REFERENCES categories(id)
        ON DELETE CASCADE
);

INSERT INTO book_categories (book_id, category_id) VALUES
    (1, 1), (1, 2),
    (2, 1), (2, 3), (2, 5),
    (3, 1), (3, 3),
    (4, 1), (4, 3),
    (5, 1), (5, 3),
    (6, 1), (6, 4),
    (7, 1), (7, 2), (7, 5),
    (8, 1), (8, 3),
    (9, 1), (9, 4),
    (10, 1), (10, 2), (10, 5),
    (11, 1), (11, 3);

-- ---------------------------------------------------------------------
-- customers
-- ---------------------------------------------------------------------
CREATE TABLE customers (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
    city        VARCHAR(50),
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO customers (id, first_name, last_name, email, city, created_at) VALUES
    (1, 'Alice', 'Johnson', 'alice@example.com', 'New York', '2026-01-04 10:15:00'),
    (2, 'Bob', 'Smith', 'bob@example.com', 'Chicago', '2026-01-06 14:02:00'),
    (3, 'Carol', 'Williams', 'carol@example.com', 'Los Angeles', '2026-01-09 09:40:00'),
    (4, 'Dave', 'Brown', 'dave@example.com', 'Houston', '2026-01-12 16:25:00'),
    (5, 'Eve', 'Davis', 'eve@example.com', NULL, '2026-01-20 11:08:00'),
    (6, 'Frank', 'Miller', 'frank@example.com', 'New York', '2026-01-27 13:30:00'),
    (7, 'Grace', 'Wilson', 'grace@example.com', 'Chicago', '2026-02-02 08:55:00'),
    (8, 'Hank', 'Taylor', 'hank@example.com', NULL, '2026-02-10 19:12:00');

-- ---------------------------------------------------------------------
-- orders and order_items (one order has many items)
-- price_at_time records what the customer paid, even if the book's
-- price changes later.
-- ---------------------------------------------------------------------
CREATE TABLE orders (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date  DATE NOT NULL,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customers(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

INSERT INTO orders (id, customer_id, order_date) VALUES
    (1, 1, '2026-01-15'),
    (2, 1, '2026-02-20'),
    (3, 2, '2026-03-10'),
    (4, 4, '2026-01-22'),
    (5, 6, '2026-02-03'),
    (6, 7, '2026-02-14'),
    (7, 2, '2026-03-28'),
    (8, 1, '2026-04-05'),
    (9, 5, '2026-04-18'),
    (10, 6, '2026-05-02'),
    (11, 7, '2026-05-19'),
    (12, 4, '2026-06-07');

CREATE TABLE order_items (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    order_id      INT NOT NULL,
    book_id       INT NOT NULL,
    quantity      INT NOT NULL DEFAULT 1,
    price_at_time DECIMAL(8, 2) NOT NULL,
    CONSTRAINT fk_items_order
        FOREIGN KEY (order_id) REFERENCES orders(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_items_book
        FOREIGN KEY (book_id) REFERENCES books(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

INSERT INTO order_items (id, order_id, book_id, quantity, price_at_time) VALUES
    (1, 1, 1, 1, 14.99),
    (2, 1, 2, 2, 9.99),
    (3, 2, 5, 1, 7.99),
    (4, 3, 1, 1, 14.99),
    (5, 4, 6, 1, 10.99),
    (6, 4, 9, 1, 15.99),
    (7, 5, 10, 1, 10.49),
    (8, 5, 7, 1, 9.49),
    (9, 6, 3, 2, 11.99),
    (10, 7, 2, 1, 9.99),
    (11, 7, 11, 1, 8.49),
    (12, 8, 9, 1, 15.99),
    (13, 9, 1, 1, 14.99),
    (14, 9, 5, 1, 7.99),
    (15, 10, 6, 2, 10.99),
    (16, 11, 2, 1, 9.99),
    (17, 12, 11, 1, 8.49),
    (18, 12, 10, 1, 10.49);

-- ---------------------------------------------------------------------
-- employees: store staff; manager_id points at another employee
-- (a self-referencing foreign key, used for hierarchies)
-- ---------------------------------------------------------------------
CREATE TABLE employees (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
    hire_date   DATE NOT NULL,
    salary      DECIMAL(8, 2) NOT NULL,
    department  ENUM('sales', 'inventory', 'management', 'support'),
    manager_id  INT,
    is_active   BOOLEAN DEFAULT TRUE,
    CONSTRAINT chk_salary CHECK (salary > 0),
    CONSTRAINT fk_employees_manager
        FOREIGN KEY (manager_id) REFERENCES employees(id)
        ON DELETE SET NULL
);

INSERT INTO employees (id, first_name, last_name, email, hire_date, salary, department, manager_id, is_active) VALUES
    (1, 'Maria', 'Santos', 'maria.santos@bookstore.example', '2015-03-02', 92000.00, 'management', NULL, TRUE),
    (2, 'Daniel', 'Reyes', 'daniel.reyes@bookstore.example', '2017-06-12', 68000.00, 'management', 1, TRUE),
    (3, 'Priya', 'Nair', 'priya.nair@bookstore.example', '2019-04-01', 46000.00, 'sales', 2, TRUE),
    (4, 'Tom', 'Becker', 'tom.becker@bookstore.example', '2022-09-15', 38000.00, 'sales', 3, TRUE),
    (5, 'Lena', 'Park', 'lena.park@bookstore.example', '2021-01-11', 39500.00, 'sales', 3, TRUE),
    (6, 'Marcus', 'Hill', 'marcus.hill@bookstore.example', '2018-08-20', 47000.00, 'inventory', 2, TRUE),
    (7, 'Sofia', 'Alvarez', 'sofia.alvarez@bookstore.example', '2023-02-06', 37000.00, 'inventory', 6, TRUE),
    (8, 'James', 'Okafor', 'james.okafor@bookstore.example', '2020-05-18', 52000.00, 'support', 1, TRUE),
    (9, 'Nina', 'Kowalski', 'nina.kowalski@bookstore.example', '2024-03-04', 36500.00, 'support', 8, TRUE),
    (10, 'Ben', 'Carter', 'ben.carter@bookstore.example', '2020-07-01', 35000.00, 'sales', 3, FALSE);

-- Quick check: every table and its row count
SELECT 'authors' AS table_name, COUNT(*) AS row_count FROM authors
UNION ALL SELECT 'books', COUNT(*) FROM books
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'book_categories', COUNT(*) FROM book_categories
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'employees', COUNT(*) FROM employees;
