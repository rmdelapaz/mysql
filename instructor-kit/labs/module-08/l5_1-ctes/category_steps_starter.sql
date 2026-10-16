-- state: full
-- =====================================================================
-- category_steps_starter.sql: a question in named steps
-- Session 8 · Lesson 5.1 · MySQL Foundations instructor kit
--
-- Which categories earn more than the average category, and which month
-- was the busiest? You build each answer as a WITH query: name a step,
-- test it on its own, then build the next step on top of it.
-- Each query runs as shipped with a placeholder. Fix the TODO, save the
-- file, and SOURCE it again. It only reads.
--
-- From the folder that holds labs/, in the freshly loaded bookstore:
--   SOURCE labs/module-08/l5_1-ctes/category_steps_starter.sql
-- =====================================================================

-- TODO 1 · Step one on its own: copies and revenue per category.
-- The revenue line multiplies by 0. Replace the 0 with oi.price_at_time
-- (the price the customer actually paid).
WITH category_sales AS (
    SELECT cat.name                AS category,
           SUM(oi.quantity)        AS copies,
           SUM(oi.quantity * 0)    AS revenue
    FROM categories AS cat
    JOIN book_categories AS bc ON bc.category_id = cat.id
    JOIN order_items     AS oi ON oi.book_id = bc.book_id
    GROUP BY cat.id, cat.name
)
SELECT category, copies, revenue
FROM category_sales
ORDER BY revenue DESC, category;

-- TODO 2 · Add a second step. The CTE "average" reads category_sales.
-- The WHERE line compares with a huge number, so nothing comes back:
-- compare s.revenue with a.avg_revenue instead.
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
WHERE s.revenue > 1000000
ORDER BY s.revenue DESC;

-- TODO 3 · Read one CTE more than once. Next to each month's orders, show
-- the busiest month's count: replace 0 with (SELECT MAX(orders) FROM monthly).
-- Stretch: add a column  orders = (SELECT MAX(orders) FROM monthly) AS is_busiest
WITH monthly AS (
    SELECT MONTH(order_date) AS month_num, COUNT(*) AS orders
    FROM orders
    GROUP BY MONTH(order_date)
)
SELECT month_num,
       orders,
       0 AS busiest
FROM monthly
ORDER BY month_num;

-- Expected when done:
-- TODO 1  Fiction 21 copies 237.29 · Classic 10 96.90 · Science Fiction 6
--         75.44 · Dystopian 7 70.43 · Fantasy 5 64.95 (every book is in
--         Fiction, so Fiction's revenue is the whole half year)
-- TODO 2  one row: Fiction 237.29, avg_revenue 109.00
-- TODO 3  months 1 to 6 with 2, 3, 2, 2, 2, 1 orders; busiest 3 on every row;
--         is_busiest 1 only for month 2
