-- state: full
-- =====================================================================
-- category_steps_solution.sql: a question in named steps (reference solution)
-- Session 8 · Lesson 5.1 · MySQL Foundations instructor kit
--
-- Which categories earn more than the average category, and which month
-- was the busiest? Each query names its steps with WITH, and the second
-- and third read a CTE more than once. Runs in the freshly loaded bookstore.
-- =====================================================================

-- 1. Step one on its own: copies and revenue per category
WITH category_sales AS (
    SELECT cat.name                            AS category,
           SUM(oi.quantity)                    AS copies,
           SUM(oi.quantity * oi.price_at_time) AS revenue
    FROM categories AS cat
    JOIN book_categories AS bc ON bc.category_id = cat.id
    JOIN order_items     AS oi ON oi.book_id = bc.book_id
    GROUP BY cat.id, cat.name
)
SELECT category, copies, revenue
FROM category_sales
ORDER BY revenue DESC;

-- 2. Two CTEs: the average category revenue, and the categories above it
WITH category_sales AS (
    SELECT cat.name                            AS category,
           SUM(oi.quantity * oi.price_at_time) AS revenue
    FROM categories AS cat
    JOIN book_categories AS bc ON bc.category_id = cat.id
    JOIN order_items     AS oi ON oi.book_id = bc.book_id
    GROUP BY cat.id, cat.name
),
average AS (
    SELECT AVG(revenue) AS avg_revenue FROM category_sales
)
SELECT s.category, s.revenue, ROUND(a.avg_revenue, 2) AS avg_revenue
FROM category_sales AS s
CROSS JOIN average AS a
WHERE s.revenue > a.avg_revenue
ORDER BY s.revenue DESC;

-- 3. One CTE read three times: orders per month next to the busiest month
WITH monthly AS (
    SELECT MONTH(order_date) AS month_num, COUNT(*) AS orders
    FROM orders
    GROUP BY MONTH(order_date)
)
SELECT month_num,
       orders,
       (SELECT MAX(orders) FROM monthly)          AS busiest,
       orders = (SELECT MAX(orders) FROM monthly) AS is_busiest
FROM monthly
ORDER BY month_num;
