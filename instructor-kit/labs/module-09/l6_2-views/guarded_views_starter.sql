-- state: full
-- =====================================================================
-- guarded_views_starter.sql: a write door and a read-only window
-- Session 9 · Lesson 6.2 · MySQL Foundations instructor kit
--
-- v_shelf lets the shop change the books that are on the shelf. A view of
-- a single table with no grouping is updatable: writes go through to books.
-- You add the guard that keeps writes inside the view, then build a
-- read-only window and an account that may read only that window.
-- Every change is undone (ROLLBACK); the practice account is dropped at the end:
--   SOURCE labs/module-09/l6_2-views/guarded_views_starter.sql
-- =====================================================================

-- TODO 1 · Add WITH CHECK OPTION at the end of the view (before the ;).
-- Then, at the mysql> prompt, try  UPDATE v_shelf SET in_stock = FALSE WHERE id = 1;
-- before and after the change: what happens to Dune each time? (Undo with
-- SOURCE bookstore.sql if the first try succeeded.)
CREATE OR REPLACE VIEW v_shelf AS
SELECT id, title, price, in_stock
FROM books
WHERE in_stock = TRUE;

SELECT COUNT(*) AS on_shelf FROM v_shelf;

-- 2. A write that stays inside the view goes through to books (then undone).
--    Predict the two prices first.
START TRANSACTION;
UPDATE v_shelf SET price = price + 1.00 WHERE id = 6;
SELECT id, title, price FROM books WHERE id = 6;
ROLLBACK;
SELECT id, title, price FROM books WHERE id = 6;

-- TODO 2 · A read-only window for marketing: only first_name and city, and
-- only customers who have a city. Fill in the WHERE (the view shows all
-- eight customers until you do).
CREATE OR REPLACE VIEW v_customer_cities AS
SELECT first_name, city
FROM customers;

SELECT city, COUNT(*) AS customers
FROM v_customer_cities
GROUP BY city
ORDER BY customers DESC, city;

-- TODO 3 · An account that may read the view and nothing else. The account
-- is created and dropped; write the GRANT line between them:
--   GRANT SELECT ON bookstore.v_customer_cities TO 'kit_marketing'@'localhost';
DROP USER IF EXISTS 'kit_marketing'@'localhost';
CREATE USER 'kit_marketing'@'localhost' IDENTIFIED BY 'Kit-Lab-Passw0rd!';
SHOW GRANTS FOR 'kit_marketing'@'localhost';
DROP USER 'kit_marketing'@'localhost';

-- 5. MySQL's verdict on both views
SELECT TABLE_NAME, IS_UPDATABLE, CHECK_OPTION
FROM information_schema.VIEWS
WHERE TABLE_SCHEMA = 'bookstore' AND TABLE_NAME IN ('v_shelf', 'v_customer_cities')
ORDER BY TABLE_NAME;

-- Expected when done:
-- TODO 1  on_shelf 9; with the check option, the in_stock = FALSE update fails with
--         ERROR 1369 (HY000): CHECK OPTION failed 'bookstore.v_shelf' (without it, Dune
--         silently leaves the view); CHECK_OPTION says CASCADED in query 5
-- 2       The Hobbit 11.99 inside the transaction, 10.99 after ROLLBACK
-- TODO 2  Chicago 2, New York 2, Houston 1, Los Angeles 1
-- TODO 3  two grant lines: GRANT USAGE ON *.* ... and
--         GRANT SELECT ON `bookstore`.`v_customer_cities` TO `kit_marketing`@`localhost`
-- 5       v_customer_cities YES NONE · v_shelf YES CASCADED
