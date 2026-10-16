-- state: full
-- =====================================================================
-- report_views_solution.sql: a small reporting layer (reference solution)
-- Session 9 · Lesson 6.2 · MySQL Foundations instructor kit
--
-- Two new views for the owner: sales per author (every author, zero
-- included) and orders with their city. Each is queried like a table,
-- one is replaced with an extra column, and the file ends by listing the
-- views and whether each is updatable. CREATE OR REPLACE makes the file
-- rerunnable. The views stay in bookstore until you reload bookstore.sql.
-- =====================================================================

-- 1. Sales per author: a LEFT JOIN keeps authors with no books or no sales; COALESCE says 0
CREATE OR REPLACE VIEW v_author_sales AS
SELECT a.id                                             AS author_id,
       a.name                                           AS author,
       COUNT(DISTINCT b.id)                             AS books,
       COALESCE(SUM(oi.quantity), 0)                    AS copies,
       COALESCE(SUM(oi.quantity * oi.price_at_time), 0) AS revenue
FROM authors AS a
LEFT JOIN books       AS b  ON b.author_id = a.id
LEFT JOIN order_items AS oi ON oi.book_id = b.id
GROUP BY a.id, a.name;

SELECT author, books, copies, revenue
FROM v_author_sales
ORDER BY revenue DESC, author;

-- 2. Query the view like a table: the authors who sold nothing
SELECT author, books
FROM v_author_sales
WHERE copies = 0
ORDER BY author;

-- 3. A join view with no grouping: every order with its customer's city
CREATE OR REPLACE VIEW v_city_orders AS
SELECT o.id                          AS order_id,
       o.order_date,
       c.first_name,
       COALESCE(c.city, '(no city)') AS city
FROM orders AS o
JOIN customers AS c ON c.id = o.customer_id;

SELECT city, COUNT(*) AS orders, MIN(order_date) AS first_order
FROM v_city_orders
GROUP BY city
ORDER BY orders DESC, city;

-- 4. Replace a view: v_author_sales gains each author's cheapest price
CREATE OR REPLACE VIEW v_author_sales AS
SELECT a.id                                             AS author_id,
       a.name                                           AS author,
       COUNT(DISTINCT b.id)                             AS books,
       MIN(b.price)                                     AS cheapest,
       COALESCE(SUM(oi.quantity), 0)                    AS copies,
       COALESCE(SUM(oi.quantity * oi.price_at_time), 0) AS revenue
FROM authors AS a
LEFT JOIN books       AS b  ON b.author_id = a.id
LEFT JOIN order_items AS oi ON oi.book_id = b.id
GROUP BY a.id, a.name;

SELECT author, books, cheapest, revenue
FROM v_author_sales
WHERE books >= 2
ORDER BY author;

-- 5. What this file built
SHOW FULL TABLES WHERE Table_type = 'VIEW';
SELECT TABLE_NAME, IS_UPDATABLE
FROM information_schema.VIEWS
WHERE TABLE_SCHEMA = 'bookstore'
ORDER BY TABLE_NAME;
