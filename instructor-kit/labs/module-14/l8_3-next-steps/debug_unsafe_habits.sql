-- state: full
-- expect-error: 1175
-- =====================================================================
-- debug_unsafe_habits.sql: safe-update mode catches a forgotten WHERE
-- Session 14 · Lesson 8.3 · MySQL Foundations instructor kit
--
-- SQL_SAFE_UPDATES (the client's --safe-updates option) refuses an
-- UPDATE or DELETE whose WHERE does not use a key column. Below, three
-- changes a tired colleague typed with it switched on (deliberately
-- broken). Two are refused with error 1175. One gets through: which one,
-- and why does safe-update mode accept it? Fix the two refused ones so they change exactly
-- the rows the comment asks for, using the key (id) in the WHERE.
--   SOURCE labs/module-14/l8_3-next-steps/debug_unsafe_habits.sql
-- Every change runs inside a transaction that is rolled back at the end,
-- so the bookstore stays as it was.
-- =====================================================================

SET SQL_SAFE_UPDATES = 1;
START TRANSACTION;

-- A: raise the price of Dune (id 1) by 10 percent
UPDATE books SET price = price * 1.10;

-- B: Bob Smith (id 2) moved to Boston
UPDATE customers SET city = 'Boston' WHERE first_name = 'Bob';

-- C: remove any order lines for The Great Gatsby (id 4), which is out of print
DELETE FROM order_items WHERE book_id = 4;

-- What changed inside the transaction?
SELECT id, title, price FROM books WHERE id = 1;
SELECT id, first_name, city FROM customers WHERE id = 2;
SELECT COUNT(*) AS gatsby_lines FROM order_items WHERE book_id = 4;

ROLLBACK;
SET SQL_SAFE_UPDATES = 0;
