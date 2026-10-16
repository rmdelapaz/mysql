-- state: full
-- =====================================================================
-- navigate_links_starter.sql: follow the keys of the relational bookstore
-- Session 6 · Lesson 4.1 · MySQL Foundations instructor kit
--
-- The finished bookstore (bookstore.sql) has eight related tables. Read it
-- by following its keys with subqueries, the way Lesson 4.1 does before
-- joins arrive in Lesson 4.3. Every query runs as handed out; each TODO
-- tells you what to change. Read-only. Load the database first if you
-- have not:  SOURCE labs/_states/bookstore.sql
--
--   SOURCE labs/module-06/l4_1-table-relationships/navigate_links_starter.sql
-- =====================================================================

-- 1 (runs as shipped) · The map: every declared foreign key. Read each row
-- as a sentence: "order_items.order_id points to orders". Which one points
-- at its own table?
SELECT TABLE_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME AS points_to
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'bookstore'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;

-- TODO 2 · Many-to-many: each book's number of categories. Replace the 0
-- with a correlated subquery that counts the rows of book_categories AS bc
-- WHERE bc.book_id = b.id. Keep the ORDER BY and LIMIT.
SELECT
    title,
    0 AS categories
FROM books AS b
ORDER BY categories DESC, title
LIMIT 5;

-- TODO 3 · One-to-many: every customer with their number of orders,
-- including the customers with none. Replace the 0 (orders.customer_id
-- points at customers.id). Sort by orders, largest first, then first_name.
SELECT
    first_name,
    0 AS orders
FROM customers AS c
ORDER BY first_name;

-- TODO 4 · Self-referencing: the employees who manage nobody. Write a NOT
-- EXISTS whose subquery looks for a row of employees AS report with
-- report.manager_id = e.id. Replace the placeholder condition (1 = 0).
SELECT e.first_name, e.department
FROM employees AS e
WHERE 1 = 0
ORDER BY e.id;

-- TODO 5 · Through two links: the titles in order 4. Replace the list
-- (0) with a subquery on order_items.
SELECT title
FROM books
WHERE id IN (0)
ORDER BY title;

-- Expected when done:
--   1: seven keys; employees.manager_id points to employees
--   2: 1984, Brave New World, Fahrenheit 451 with 3; Animal Farm, Dune with 2
--   3: Alice 3; Bob, Dave, Frank, Grace 2; Eve 1; Carol and Hank 0
--   4: Tom, Lena, Sofia, Nina, Ben
--   5: Lord of the Rings, The Hobbit
