-- state: full
-- =====================================================================
-- order_trends_starter.sql: running totals, LAG and first orders
-- Session 8 · Lesson 5.2 · MySQL Foundations instructor kit
--
-- Order by order instead of month by month: a running revenue total, each
-- customer's change from their previous order, and every customer's first
-- order. A CTE totals each order first. Each query runs as shipped; fix the
-- TODO, save, SOURCE again. It only reads.
--
--   SOURCE labs/module-08/l5_2-window-functions/order_trends_starter.sql
-- =====================================================================

-- TODO 1 · running_total shows the grand total on every row (OVER () is the
-- whole result). Make it a running total, row by row, in date order:
--   OVER (ORDER BY order_date, id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
WITH order_totals AS (
    SELECT o.id, o.order_date, SUM(oi.quantity * oi.price_at_time) AS total
    FROM orders AS o
    JOIN order_items AS oi ON oi.order_id = o.id
    GROUP BY o.id, o.order_date
)
SELECT id, order_date, total,
       SUM(total) OVER () AS running_total
FROM order_totals
ORDER BY order_date, id;

-- TODO 2 · Per customer: order_no is done. Replace the 0 in change_from_last
-- with  t.total - LAG(t.total) OVER w  (the named window w restarts for each
-- customer). What will every customer's first row show, and why?
WITH order_totals AS (
    SELECT o.id, o.customer_id, o.order_date, SUM(oi.quantity * oi.price_at_time) AS total
    FROM orders AS o
    JOIN order_items AS oi ON oi.order_id = o.id
    GROUP BY o.id, o.customer_id, o.order_date
)
SELECT c.first_name,
       ROW_NUMBER() OVER w AS order_no,
       t.order_date,
       t.total,
       0 AS change_from_last
FROM order_totals AS t
JOIN customers AS c ON c.id = t.customer_id
WINDOW w AS (PARTITION BY t.customer_id ORDER BY t.order_date)
ORDER BY c.first_name, t.order_date;

-- TODO 3 · Every customer's FIRST order. WHERE cannot use a window function
-- (error 3593), so the numbering is done in the CTE. Change the outer WHERE
-- from order_no = 0 to keep the first order of each customer.
WITH numbered AS (
    SELECT c.first_name, o.id AS order_id, o.order_date,
           ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS order_no
    FROM orders AS o
    JOIN customers AS c ON c.id = o.customer_id
)
SELECT first_name, order_id, order_date
FROM numbered
WHERE order_no = 0
ORDER BY order_date;

-- Expected when done:
-- TODO 1  twelve orders from 34.97 (order 1) up to a running total of 237.29
--         (order 12); after order 4 it is 61.95, January's revenue
-- TODO 2  the first row of every customer shows NULL (no previous order);
--         Alice -26.98 then 8.00 · Bob 3.49 · Dave -8.00 · Frank 2.00 · Grace -13.99
-- TODO 3  six rows by date: Alice 1, Dave 4, Frank 5, Grace 6, Bob 3, Eve 9
