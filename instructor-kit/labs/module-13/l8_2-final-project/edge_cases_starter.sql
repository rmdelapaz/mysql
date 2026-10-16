-- state: full
-- =====================================================================
-- edge_cases_starter.sql: report queries that only edge cases can test
-- Session 13 · Lesson 8.2 · MySQL Foundations instructor kit
--
-- Milestone 3 asks you to plant edge cases in your test data: a member
-- who never borrowed, a tool never lent, a tie. Why? Because a broken
-- query looks fine on happy data. The bookstore already has such edge
-- cases. Each query below runs, but gives a WRONG or unfinished answer.
-- Fix one TODO at a time, save, SOURCE again. Read-only: nothing changes.
--
--   SOURCE labs/module-13/l8_2-final-project/edge_cases_starter.sql
-- =====================================================================

-- A fixed report date, set once (the project's @today habit)
SET @today = '2026-06-30';

-- 1. Customers who have never ordered.
-- TODO 1: an inner JOIN can never find a customer WITHOUT orders, so this
--   prints Empty set. Make it a LEFT JOIN; the WHERE line stays.
SELECT c.id, CONCAT(c.first_name, ' ', c.last_name) AS customer
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.id
WHERE o.id IS NULL
ORDER BY c.id;

-- 2. Books that have never been sold.
-- TODO 2: same pattern, books and order_items. Replace the placeholder.
SELECT 'TODO 2: books never sold' AS todo;

-- 3. Orders per customer in the 90 days before @today, ZERO included.
-- TODO 3: this prints 5 customers, not all 8: the date test in WHERE throws
--   away every customer whose joined row has no order (o.order_date is
--   NULL). Move the date test into the ON clause (AND ...), delete WHERE.
SELECT CONCAT(c.first_name, ' ', c.last_name) AS customer,
       COUNT(o.id) AS recent_orders
FROM customers AS c
LEFT JOIN orders AS o
       ON o.customer_id = c.id
WHERE o.order_date > @today - INTERVAL 90 DAY
GROUP BY c.id, c.first_name, c.last_name
ORDER BY recent_orders DESC, customer;

-- 4. The most popular book in each category: the number of ORDERS that
--    include it.
-- TODO 4: ROW_NUMBER gives every row a different number, so a tie for first
--   place loses one of the two books. Change ROW_NUMBER() to RANK() and
--   count the rows that come back.
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
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY orders DESC) AS rnk
    FROM sold
)
SELECT category, title, orders
FROM ranked
WHERE rnk = 1
ORDER BY category, title;

-- Expected when done: 1. 3 Carol Williams, 8 Hank Taylor; 2. 4 The Great
-- Gatsby, 8 The Catcher in the Rye; 3. eight rows: Alice Johnson, Dave
-- Brown, Eve Davis, Frank Miller, Grace Wilson 1 each, then Bob Smith,
-- Carol Williams, Hank Taylor 0; 4. seven rows: Classic 1984 3,
-- Dystopian 1984 3, Fantasy Lord of the Rings 2 and The Hobbit 2,
-- Fiction 1984 3 and Dune 3, Science Fiction Dune 3.
