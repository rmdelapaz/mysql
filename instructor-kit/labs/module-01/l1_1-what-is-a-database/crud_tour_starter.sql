-- state: none
-- =====================================================================
-- crud_tour_starter.sql: Create, Read, Update, Delete on a small books table
-- Session 1 · Lesson 1.1 · MySQL Foundations instructor kit
--
-- The lesson's "first taste" used customers. Here you do the same four
-- operations on books. Each TODO is a statement written for you but turned
-- off with -- at the start of the line. Before you turn one on, write in
-- your workbook what you think the final table will look like. Then remove
-- the -- (only from the statement lines), fill in any ___ gap, and run the
-- file again.
--
-- How to run it: open a terminal in the folder that holds labs/, log in
-- with  mysql -u root -p  and type
--   SOURCE labs/module-01/l1_1-what-is-a-database/crud_tour_starter.sql
-- Every run rebuilds the practice database kit_s1_shop and drops it at
-- the end.
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

-- TODO 1 · Read: the books under $10. Change 0 to 10.
SELECT id, title, price
FROM books
WHERE price < 0;

-- TODO 2 · Create: add Fahrenheit 451 at 10.49. Which id will it get?
-- INSERT INTO books (title, price) VALUES ('Fahrenheit 451', 10.49);

-- TODO 3 · Update: The Great Gatsby (id 2) sold out. FALSE means no.
-- UPDATE books SET in_stock = FALSE WHERE id = 2;

-- TODO 4 · Update: The Hobbit goes on sale, one dollar off. Fill in its id.
-- UPDATE books SET price = price - 1.00 WHERE id = ___;

-- TODO 5 · Delete: the shop stops selling Dune. Fill in its id.
-- What would happen if you forgot the WHERE line?
-- DELETE FROM books WHERE id = ___;

-- The table at the end (in_stock prints 1 for yes, 0 for no)
SELECT * FROM books ORDER BY id;

-- Expected when done: TODO 1 one row (2, The Great Gatsby, 8.99); the final
-- table holds 2 The Great Gatsby 8.99 in_stock 0, 3 The Hobbit 9.99 in_stock 1,
-- 4 Fahrenheit 451 10.49 in_stock 1 (Dune, id 1, is gone).

DROP DATABASE kit_s1_shop;
