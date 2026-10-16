-- state: full
-- =====================================================================
-- city_sales_starter.sql: sales by where the customers live
-- Session 7 · Lesson 4.3 · MySQL Foundations instructor kit
--
-- Three questions about the customers' cities and what they bought. Every
-- query runs as handed out; each TODO tells you what to change. Before you
-- aggregate, ask: what does ONE row of this join stand for? Read-only.
--
--   SOURCE labs/module-07/l4_3-joins/city_sales_starter.sql
-- =====================================================================

-- TODO 1 · Revenue per city, every city that has customers (also Los
-- Angeles, whose only customer never ordered), the no-city customers as
-- '(no city)'. The joins are done. Replace the three 0 placeholders:
--   COUNT(DISTINCT c.id) AS customers, COUNT(DISTINCT o.id) AS orders,
--   COALESCE(SUM(oi.quantity * oi.price_at_time), 0) AS revenue
-- and sort by revenue (highest first), then city.
SELECT
    COALESCE(c.city, '(no city)') AS city,
    0 AS customers,
    0 AS orders,
    0 AS revenue
FROM customers AS c
LEFT JOIN orders      AS o  ON o.customer_id = c.id
LEFT JOIN order_items AS oi ON oi.order_id = o.id
GROUP BY COALESCE(c.city, '(no city)')
ORDER BY city;

-- TODO 2 · Every different book bought by a Chicago customer. Write the
-- four-table join (customers, orders, order_items, books), keep Chicago,
-- and make each title appear once. Replace the placeholder line.
SELECT 'TODO 2: books bought in Chicago' AS todo;

-- TODO 3 · Every customer with their number of orders from March 2026 on,
-- zeros included. This version runs, but it shows six customers, not
-- eight: Carol and Hank are missing. Why? Move the date condition from
-- WHERE into the ON clause (ON o.customer_id = c.id AND o.order_date >= '2026-03-01').
SELECT c.first_name, COUNT(o.id) AS orders_since_march
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.id
WHERE o.order_date >= '2026-03-01'
GROUP BY c.id, c.first_name
ORDER BY orders_since_march DESC, c.first_name;

-- Expected when done:
--   1: New York 2 customers / 5 orders / 100.91 · Chicago 2 / 4 / 67.44 ·
--      Houston 1 / 2 / 45.96 · (no city) 2 / 1 / 22.98 · Los Angeles 1 / 0 / 0.00
--   2: 1984, Animal Farm, Dune, To Kill a Mockingbird
--   3: Bob 2; Alice, Dave, Eve, Frank, Grace 1; Carol 0, Hank 0 (eight rows)
