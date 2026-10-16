-- state: full
-- =====================================================================
-- guarded_views_solution.sql: a write door and a read-only window (reference solution)
-- Session 9 · Lesson 6.2 · MySQL Foundations instructor kit
--
-- v_shelf lets the shop change the books that are on the shelf, and its
-- check option keeps every write inside the view. v_customer_cities shows
-- only first names and cities, and a practice account may read that view
-- and nothing else. Every change is undone (ROLLBACK) and the practice
-- account is dropped again at the end.
-- =====================================================================

-- 1. The in-stock books, guarded by a check option
CREATE OR REPLACE VIEW v_shelf AS
SELECT id, title, price, in_stock
FROM books
WHERE in_stock = TRUE
WITH CHECK OPTION;

SELECT COUNT(*) AS on_shelf FROM v_shelf;

-- 2. A write that stays inside the view goes through to books (then undone)
START TRANSACTION;
UPDATE v_shelf SET price = price + 1.00 WHERE id = 6;
SELECT id, title, price FROM books WHERE id = 6;
ROLLBACK;
SELECT id, title, price FROM books WHERE id = 6;

-- 3. A read-only window: first names and cities, no emails, no customers without a city
CREATE OR REPLACE VIEW v_customer_cities AS
SELECT first_name, city
FROM customers
WHERE city IS NOT NULL;

SELECT city, COUNT(*) AS customers
FROM v_customer_cities
GROUP BY city
ORDER BY customers DESC, city;

-- 4. An account that may read the view and nothing else (created, shown, dropped)
DROP USER IF EXISTS 'kit_marketing'@'localhost';
CREATE USER 'kit_marketing'@'localhost' IDENTIFIED BY 'Kit-Lab-Passw0rd!';
GRANT SELECT ON bookstore.v_customer_cities TO 'kit_marketing'@'localhost';
SHOW GRANTS FOR 'kit_marketing'@'localhost';
DROP USER 'kit_marketing'@'localhost';

-- 5. MySQL's verdict on both views
SELECT TABLE_NAME, IS_UPDATABLE, CHECK_OPTION
FROM information_schema.VIEWS
WHERE TABLE_SCHEMA = 'bookstore' AND TABLE_NAME IN ('v_shelf', 'v_customer_cities')
ORDER BY TABLE_NAME;
