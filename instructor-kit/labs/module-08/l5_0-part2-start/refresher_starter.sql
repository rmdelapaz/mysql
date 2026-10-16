-- state: full
-- =====================================================================
-- refresher_starter.sql: Part 1 in four queries
-- Session 8 · Part 2 start · MySQL Foundations instructor kit
--
-- Lessons 5.1 and 5.2 build on four Part 1 moves: joins (4.3), GROUP BY
-- (3.3), a derived table (3.4) and a self-join (4.3). Each query below runs
-- as shipped but is missing one piece. Fix the TODO, save, SOURCE again.
--
-- First load a fresh copy of the course database (SOURCE bookstore.sql),
-- then, from the folder that holds labs/:
--   SOURCE labs/module-08/l5_0-part2-start/refresher_starter.sql
-- It only reads: run it as often as you like.
-- =====================================================================

-- TODO 1 · INNER JOIN: the order lines from January 2026, with the
-- customer's first name and the book title. The join to books is missing:
-- add  JOIN books AS b ON b.id = oi.book_id , replace 'TODO' with b.title
-- and sort by o.id, b.title.
SELECT o.id AS order_id, c.first_name, 'TODO' AS title, oi.quantity
FROM orders AS o
JOIN customers   AS c  ON c.id = o.customer_id
JOIN order_items AS oi ON oi.order_id = o.id
WHERE o.order_date < '2026-02-01'
ORDER BY o.id, oi.id;

-- TODO 2 · Orders per customer, INCLUDING the customers who never ordered.
-- Change the inner JOIN to a LEFT JOIN, and count o.id instead of *.
-- (Why not COUNT(*)? Lesson 4.3, Common Mistake 4.)
SELECT c.first_name, COUNT(*) AS orders
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.id
GROUP BY c.id, c.first_name
ORDER BY orders DESC, c.first_name;

-- TODO 3 · A derived table: the customers who spent more than 40.
-- The inner query is done. Change the outer WHERE so it keeps t.spent > 40.
SELECT t.first_name, t.spent
FROM (
    SELECT c.first_name, SUM(oi.quantity * oi.price_at_time) AS spent
    FROM customers AS c
    JOIN orders      AS o  ON o.customer_id = c.id
    JOIN order_items AS oi ON oi.order_id = o.id
    GROUP BY c.id, c.first_name
) AS t
WHERE t.spent < 0
ORDER BY t.spent DESC;

-- TODO 4 · Self-join: each sales employee next to their manager's first
-- name. The ON line compares the wrong columns: it should match the
-- manager's id (m.id) with the employee's manager_id (e.manager_id).
SELECT e.first_name AS employee, m.first_name AS manager
FROM employees AS e
LEFT JOIN employees AS m ON m.id = e.id
WHERE e.department = 'sales'
ORDER BY e.first_name;

-- Expected when done:
-- TODO 1  four lines: 1 Alice 1984 2 · 1 Alice Dune 1 · 4 Dave Lord of the
--         Rings 1 · 4 Dave The Hobbit 1 (sorted by title within each order)
-- TODO 2  eight rows from Alice 3 down to Carol 0 and Hank 0
-- TODO 3  Alice 58.95, Dave 45.96, Frank 41.96
-- TODO 4  Ben Priya · Lena Priya · Priya Daniel · Tom Priya
