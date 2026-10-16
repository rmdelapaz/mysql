-- state: full
-- =====================================================================
-- order_trends_solution.sql: running totals, LAG and first orders (reference solution)
-- Session 8 · Lesson 5.2 · MySQL Foundations instructor kit
--
-- Order by order instead of month by month: the running revenue, each
-- customer's change from their previous order, and every customer's first
-- order (top 1 per group). A CTE totals each order first.
-- =====================================================================

-- 1. Every order's total and the running revenue, in date order (row by row)
WITH order_totals AS (
    SELECT o.id, o.order_date, SUM(oi.quantity * oi.price_at_time) AS total
    FROM orders AS o
    JOIN order_items AS oi ON oi.order_id = o.id
    GROUP BY o.id, o.order_date
)
SELECT id, order_date, total,
       SUM(total) OVER (ORDER BY order_date, id
                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM order_totals
ORDER BY order_date, id;

-- 2. Per customer: which order is it (1st, 2nd, ...), and the change from the previous one
WITH order_totals AS (
    SELECT o.id, o.customer_id, o.order_date, SUM(oi.quantity * oi.price_at_time) AS total
    FROM orders AS o
    JOIN order_items AS oi ON oi.order_id = o.id
    GROUP BY o.id, o.customer_id, o.order_date
)
SELECT c.first_name,
       ROW_NUMBER() OVER w                  AS order_no,
       t.order_date,
       t.total,
       t.total - LAG(t.total) OVER w        AS change_from_last
FROM order_totals AS t
JOIN customers AS c ON c.id = t.customer_id
WINDOW w AS (PARTITION BY t.customer_id ORDER BY t.order_date)
ORDER BY c.first_name, t.order_date;

-- 3. Top 1 per group: every customer's first order (filter the window in the outer query)
WITH numbered AS (
    SELECT c.first_name, o.id AS order_id, o.order_date,
           ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS order_no
    FROM orders AS o
    JOIN customers AS c ON c.id = o.customer_id
)
SELECT first_name, order_id, order_date
FROM numbered
WHERE order_no = 1
ORDER BY order_date;
