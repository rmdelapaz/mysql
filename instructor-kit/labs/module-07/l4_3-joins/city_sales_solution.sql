-- state: full
-- =====================================================================
-- city_sales_solution.sql: REFERENCE SOLUTION (instructor copy)
-- Session 7 · Lesson 4.3 · MySQL Foundations instructor kit
--
-- Sales by where the customers live: joins with GROUP BY, the NULL group,
-- DISTINCT after a fan-out, and the WHERE-after-LEFT-JOIN trap on a new
-- question. Read-only.
--
--   SOURCE labs/module-07/l4_3-joins/city_sales_solution.sql
-- =====================================================================

-- 1 · Revenue per city: every city that has customers, also the ones whose
--     customers never ordered; the customers with no city as '(no city)'.
SELECT
    COALESCE(c.city, '(no city)')                     AS city,
    COUNT(DISTINCT c.id)                              AS customers,
    COUNT(DISTINCT o.id)                              AS orders,
    COALESCE(SUM(oi.quantity * oi.price_at_time), 0) AS revenue
FROM customers AS c
LEFT JOIN orders      AS o  ON o.customer_id = c.id
LEFT JOIN order_items AS oi ON oi.order_id = o.id
GROUP BY COALESCE(c.city, '(no city)')
ORDER BY revenue DESC, city;

-- 2 · Every different book bought by a Chicago customer (DISTINCT: Bob
--     and Grace both bought 1984).
SELECT DISTINCT b.title
FROM customers AS c
JOIN orders      AS o  ON o.customer_id = c.id
JOIN order_items AS oi ON oi.order_id = o.id
JOIN books       AS b  ON oi.book_id = b.id
WHERE c.city = 'Chicago'
ORDER BY b.title;

-- 3 · Every customer with their number of orders from March 2026 on,
--     zeros included: the date condition belongs in ON, not in WHERE.
SELECT c.first_name, COUNT(o.id) AS orders_since_march
FROM customers AS c
LEFT JOIN orders AS o
       ON o.customer_id = c.id
      AND o.order_date >= '2026-03-01'
GROUP BY c.id, c.first_name
ORDER BY orders_since_march DESC, c.first_name;
