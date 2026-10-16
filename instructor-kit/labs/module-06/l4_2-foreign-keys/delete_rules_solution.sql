-- state: full
-- =====================================================================
-- delete_rules_solution.sql: REFERENCE SOLUTION (instructor copy)
-- Session 6 · Lesson 4.2 · MySQL Foundations instructor kit
--
-- Watch each delete or update rule of the bookstore act on rows the lesson
-- did not use, inside a transaction, then undo it with ROLLBACK. Nothing
-- is changed when the file ends (the last query proves it).
--
--   SOURCE labs/module-06/l4_2-foreign-keys/delete_rules_solution.sql
-- =====================================================================

-- 1 · CASCADE (fk_bc_category): delete the Dystopian category. Its links go too.
START TRANSACTION;
SELECT COUNT(*) AS links_before FROM book_categories;
DELETE FROM categories WHERE id = 5;
SELECT COUNT(*) AS links_after FROM book_categories;
ROLLBACK;

-- 2 · SET NULL (fk_employees_manager): Marcus Hill (6) leaves. His report stays.
START TRANSACTION;
DELETE FROM employees WHERE id = 6;
SELECT id, first_name, manager_id FROM employees WHERE id = 7;
ROLLBACK;

-- 3 · RESTRICT with nothing to protect (fk_orders_customer): Hank (8) never
--     ordered, so deleting him works.
START TRANSACTION;
DELETE FROM customers WHERE id = 8;
SELECT COUNT(*) AS customers_left FROM customers;
ROLLBACK;

-- 4 · ON UPDATE CASCADE (fk_orders_customer): renumber Grace from 7 to 70.
--     Her two orders follow her.
START TRANSACTION;
UPDATE customers SET id = 70 WHERE id = 7;
SELECT id, customer_id, order_date FROM orders WHERE customer_id = 70 ORDER BY id;
ROLLBACK;

-- 5 · CASCADE through order_items (fk_items_order): delete Eve's only order (9).
START TRANSACTION;
SELECT COUNT(*) AS items_before FROM order_items;
DELETE FROM orders WHERE id = 9;
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
