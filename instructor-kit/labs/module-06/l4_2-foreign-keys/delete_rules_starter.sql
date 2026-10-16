-- state: full
-- =====================================================================
-- delete_rules_starter.sql: predict, then watch each rule act
-- Session 6 · Lesson 4.2 · MySQL Foundations instructor kit
--
-- Five tests of the bookstore's foreign key rules, on rows the lesson did
-- not use. Each test runs inside a transaction and ends with ROLLBACK, so
-- nothing is changed for good. As handed out, the line that deletes or
-- updates is turned off with --, so you see only the "before" picture.
-- For each test: write your prediction in the workbook, remove the -- from
-- the TODO line, save, SOURCE the file again, compare. Look the rule up
-- first with the lesson's "every rule in the bookstore" query if needed.
-- Load the database first if you have not:  SOURCE labs/_states/bookstore.sql
--
--   SOURCE labs/module-06/l4_2-foreign-keys/delete_rules_starter.sql
-- =====================================================================

-- 1 · fk_bc_category is ON DELETE CASCADE. Delete the Dystopian category (5):
--     how many links are left?
START TRANSACTION;
SELECT COUNT(*) AS links_before FROM book_categories;
-- TODO 1: DELETE FROM categories WHERE id = 5;
SELECT COUNT(*) AS links_after FROM book_categories;
ROLLBACK;

-- 2 · fk_employees_manager is ON DELETE SET NULL. Marcus Hill (6) manages
--     Sofia (7). Marcus leaves: what is Sofia's manager_id now?
START TRANSACTION;
-- TODO 2: DELETE FROM employees WHERE id = 6;
SELECT id, first_name, manager_id FROM employees WHERE id = 7;
ROLLBACK;

-- 3 · fk_orders_customer is ON DELETE RESTRICT. Hank (8) never ordered.
--     Refused, or deleted?
START TRANSACTION;
-- TODO 3: DELETE FROM customers WHERE id = 8;
SELECT COUNT(*) AS customers_left FROM customers;
ROLLBACK;

-- 4 · fk_orders_customer is ON UPDATE CASCADE. Renumber Grace from 7 to 70:
--     which orders now say customer_id 70?
START TRANSACTION;
-- TODO 4: UPDATE customers SET id = 70 WHERE id = 7;
SELECT id, customer_id, order_date FROM orders WHERE customer_id = 70 ORDER BY id;
ROLLBACK;

-- 5 · fk_items_order is ON DELETE CASCADE. Eve's only order is 9: how many
--     order lines are left after deleting it?
START TRANSACTION;
SELECT COUNT(*) AS items_before FROM order_items;
-- TODO 5: DELETE FROM orders WHERE id = 9;
SELECT COUNT(*) AS items_after FROM order_items;
ROLLBACK;

-- After every ROLLBACK the database is as loaded:
SELECT
    (SELECT COUNT(*) FROM categories)      AS categories,
    (SELECT COUNT(*) FROM book_categories) AS links,
    (SELECT COUNT(*) FROM customers)       AS customers,
    (SELECT COUNT(*) FROM orders)          AS orders,
    (SELECT COUNT(*) FROM order_items)     AS items,
    (SELECT manager_id FROM employees WHERE id = 7) AS sofias_manager;

-- Expected when done (all five TODO lines on):
--   1: links_before 25, links_after 22 (the three Dystopian links went too)
--   2: Sofia's manager_id NULL
--   3: customers_left 7 (nothing to restrict: Hank has no orders)
--   4: orders 6 and 11 now have customer_id 70
--   5: items_before 18, items_after 16 (order 9 had two lines)
--   last row, unchanged: 5 categories, 25 links, 8 customers, 12 orders,
--   18 items, Sofia's manager 6
-- Bonus: why is "delete Alice (1)" not in this file? Try it at the prompt.
