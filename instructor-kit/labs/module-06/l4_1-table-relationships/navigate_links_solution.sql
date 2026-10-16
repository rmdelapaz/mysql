-- state: full
-- =====================================================================
-- navigate_links_solution.sql: REFERENCE SOLUTION (instructor copy)
-- Session 6 · Lesson 4.1 · MySQL Foundations instructor kit
--
-- Read the finished relational bookstore (bookstore.sql) by following its
-- keys with subqueries, the way Lesson 4.1 does before joins (Lesson 4.3).
-- Read-only.
--
--   SOURCE labs/module-06/l4_1-table-relationships/navigate_links_solution.sql
-- =====================================================================

-- 1 · The map: every declared foreign key, from information_schema.
SELECT TABLE_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME AS points_to
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'bookstore'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;

-- 2 · Many-to-many: how many categories does each book have? (the junction
--     table, counted per book with a correlated subquery)
SELECT
    title,
    (SELECT COUNT(*) FROM book_categories AS bc WHERE bc.book_id = b.id) AS categories
FROM books AS b
ORDER BY categories DESC, title
LIMIT 5;

-- 3 · One-to-many, the "zero or many" end: every customer with their
--     number of orders, zeros included.
SELECT
    first_name,
    (SELECT COUNT(*) FROM orders AS o WHERE o.customer_id = c.id) AS orders
FROM customers AS c
ORDER BY orders DESC, first_name;

-- 4 · Self-referencing: the employees who manage nobody (NOT EXISTS).
SELECT e.first_name, e.department
FROM employees AS e
WHERE NOT EXISTS (
    SELECT 1 FROM employees AS report WHERE report.manager_id = e.id
)
ORDER BY e.id;

-- 5 · Through two links: the titles in order 4 (order_items, then books).
SELECT title
FROM books
WHERE id IN (SELECT book_id FROM order_items WHERE order_id = 4)
ORDER BY title;
