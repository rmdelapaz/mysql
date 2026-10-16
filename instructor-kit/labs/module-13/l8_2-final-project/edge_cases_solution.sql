-- state: full
-- =====================================================================
-- edge_cases_solution.sql: REFERENCE for edge_cases_starter.sql
-- Session 13 · Lesson 8.2 · MySQL Foundations instructor kit
--
-- Four report queries that only give the right answer when the data has
-- edge cases in it: customers with no orders, books never sold, a month
-- with nothing in it, two books tied for first place. Read-only.
-- Instructor copy: do not hand out before the lab.
-- =====================================================================

-- A fixed report date, set once (the project's @today habit)
SET @today = '2026-06-30';

-- 1. Customers who have never ordered (LEFT JOIN ... IS NULL)
SELECT c.id, CONCAT(c.first_name, ' ', c.last_name) AS customer
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.id
WHERE o.id IS NULL
ORDER BY c.id;

-- 2. Books that have never been sold
SELECT b.id, b.title
FROM books AS b
LEFT JOIN order_items AS oi ON oi.book_id = b.id
WHERE oi.id IS NULL
ORDER BY b.id;

-- 3. Orders per customer in the 90 days before @today, ZERO included:
--    the date condition belongs in ON, so customers without a recent
--    order keep their row
SELECT CONCAT(c.first_name, ' ', c.last_name) AS customer,
       COUNT(o.id) AS recent_orders
FROM customers AS c
LEFT JOIN orders AS o
       ON o.customer_id = c.id
      AND o.order_date > @today - INTERVAL 90 DAY
GROUP BY c.id, c.first_name, c.last_name
ORDER BY recent_orders DESC, customer;

-- 4. The most popular book in each category: the number of ORDERS that
--    include it, ties kept (RANK gives equal counts the same rank)
WITH sold AS (
    SELECT cat.name AS category, b.title, COUNT(DISTINCT oi.order_id) AS orders
    FROM categories AS cat
    JOIN book_categories AS bc ON bc.category_id = cat.id
    JOIN books AS b            ON b.id = bc.book_id
    JOIN order_items AS oi     ON oi.book_id = b.id
    GROUP BY cat.name, b.id, b.title
),
ranked AS (
    SELECT category, title, orders,
           RANK() OVER (PARTITION BY category ORDER BY orders DESC) AS rnk
    FROM sold
)
SELECT category, title, orders
FROM ranked
WHERE rnk = 1
ORDER BY category, title;
