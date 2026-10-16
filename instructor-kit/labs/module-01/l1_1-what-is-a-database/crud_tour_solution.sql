-- state: none
-- =====================================================================
-- crud_tour_solution.sql: Create, Read, Update, Delete on a small books table
-- Session 1 · Lesson 1.1 · MySQL Foundations instructor kit · instructor reference
--
-- The lesson's "first taste" used customers. This lab does the same four
-- operations on books, with prices. Builds kit_s1_shop and drops it at the end.
-- =====================================================================

DROP DATABASE IF EXISTS kit_s1_shop;
CREATE DATABASE kit_s1_shop;
USE kit_s1_shop;

CREATE TABLE books (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    title     VARCHAR(200) NOT NULL,
    price     DECIMAL(8,2) NOT NULL,
    in_stock  BOOLEAN      NOT NULL DEFAULT TRUE
);

-- Create: three books (MySQL hands out id 1, 2, 3)
INSERT INTO books (title, price) VALUES
    ('Dune', 14.99),
    ('The Great Gatsby', 8.99),
    ('The Hobbit', 10.99);

-- 1 · Read: the books under $10
SELECT id, title, price
FROM books
WHERE price < 10;

-- 2 · Create: add Fahrenheit 451 at 10.49 (no id: MySQL picks 4)
INSERT INTO books (title, price) VALUES ('Fahrenheit 451', 10.49);

-- 3 · Update: The Great Gatsby sold out (FALSE = no)
UPDATE books SET in_stock = FALSE WHERE id = 2;

-- 4 · Update: The Hobbit goes on sale, one dollar off
UPDATE books SET price = price - 1.00 WHERE id = 3;

-- 5 · Delete: the shop stops selling Dune
DELETE FROM books WHERE id = 1;

-- The table at the end (in_stock prints 1 for yes, 0 for no)
SELECT * FROM books ORDER BY id;

DROP DATABASE kit_s1_shop;
