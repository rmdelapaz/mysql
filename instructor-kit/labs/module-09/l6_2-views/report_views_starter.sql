-- state: full
-- =====================================================================
-- report_views_starter.sql: a small reporting layer
-- Session 9 · Lesson 6.2 · MySQL Foundations instructor kit
--
-- Two new views for the owner: sales per author (every author, zero
-- included) and orders with their city. A view is a saved SELECT: you
-- write the query once, then anyone reads it like a table. Every view uses
-- CREATE OR REPLACE, so edit, save and SOURCE again as often as you like:
--   SOURCE labs/module-09/l6_2-views/report_views_starter.sql
-- The views stay in bookstore until you reload bookstore.sql.
-- =====================================================================

-- TODO 1 · The view keeps only authors who sold something (inner joins).
-- Make both joins LEFT JOINs, so all ten authors appear, and wrap the two
-- SUMs in COALESCE(..., 0) so the authors with no sales show 0, not NULL.
CREATE OR REPLACE VIEW v_author_sales AS
SELECT a.id                                AS author_id,
       a.name                              AS author,
       COUNT(DISTINCT b.id)                AS books,
       SUM(oi.quantity)                    AS copies,
       SUM(oi.quantity * oi.price_at_time) AS revenue
FROM authors AS a
JOIN books       AS b  ON b.author_id = a.id
JOIN order_items AS oi ON oi.book_id = b.id
GROUP BY a.id, a.name;

SELECT author, books, copies, revenue
FROM v_author_sales
ORDER BY revenue DESC, author;

-- 2. Query the view like a table: the authors who sold nothing
--    (empty until TODO 1 is done: why?)
SELECT author, books
FROM v_author_sales
WHERE copies = 0
ORDER BY author;

-- TODO 2 · Create v_city_orders: every order with order_id, order_date, the
-- customer's first_name and city (COALESCE(c.city, '(no city)') AS city),
-- from orders joined to customers. No GROUP BY inside the view. Then remove
-- the -- from the query below it.
SELECT 'TODO 2: create v_city_orders' AS todo;
-- SELECT city, COUNT(*) AS orders, MIN(order_date) AS first_order
-- FROM v_city_orders
-- GROUP BY city
-- ORDER BY orders DESC, city;

-- TODO 3 · Replace v_author_sales so it also shows each author's cheapest
-- price: copy your CREATE OR REPLACE from TODO 1 here and add
-- MIN(b.price) AS cheapest after books. Then remove the -- below.
-- SELECT author, books, cheapest, revenue
-- FROM v_author_sales
-- WHERE books >= 2
-- ORDER BY author;

-- 5. What this file built, and whether each view is updatable
SHOW FULL TABLES WHERE Table_type = 'VIEW';
SELECT TABLE_NAME, IS_UPDATABLE
FROM information_schema.VIEWS
WHERE TABLE_SCHEMA = 'bookstore'
ORDER BY TABLE_NAME;

-- Expected when done:
-- TODO 1  ten authors: J.R.R. Tolkien 2 books 5 copies 64.95 ... Aldous Huxley 9.49,
--         then F. Scott Fitzgerald, Isaac Asimov (0 books) and J.D. Salinger with 0 and 0.00;
--         query 2: those three
-- TODO 2  New York 5 orders (first 2026-01-15) · Chicago 4 · Houston 2 · (no city) 1
-- TODO 3  George Orwell 2 books cheapest 8.49 revenue 56.94 · J.R.R. Tolkien 2 10.99 64.95
-- 5       v_author_sales NO (it groups), v_city_orders YES (a join, no grouping)
