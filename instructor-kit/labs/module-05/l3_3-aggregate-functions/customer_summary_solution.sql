-- state: flat
-- =====================================================================
-- customer_summary_solution.sql: REFERENCE SOLUTION (instructor copy)
-- Session 5 · Lesson 3.3 · MySQL Foundations instructor kit
--
-- The lesson summarized the books. This lab summarizes the customers:
-- how many, who is missing a city, when they signed up, where they live.
-- Runs in the flat bookstore of Module 3 (books.author is text). Reload it
-- with  SOURCE labs/_states/flat.sql  if your data has drifted.
--
--   SOURCE labs/module-05/l3_3-aggregate-functions/customer_summary_solution.sql
-- =====================================================================

-- 1 · One headline row: every count and date in a single SELECT.
SELECT
    COUNT(*)             AS customers,
    COUNT(city)          AS with_city,
    COUNT(*) - COUNT(city) AS missing_city,
    COUNT(DISTINCT city) AS cities,
    MIN(created_at)      AS first_signup,
    MAX(created_at)      AS latest_signup
FROM customers;

-- 2 · Signups per month. DATE_FORMAT turns a date into a '2026-01' label.
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    COUNT(*)                         AS signups
FROM customers
GROUP BY month
ORDER BY month;

-- 3 · Cities with more than one customer, and when the first of them joined.
SELECT
    city,
    COUNT(*)        AS customers,
    MIN(created_at) AS first_joined
FROM customers
WHERE city IS NOT NULL
GROUP BY city
HAVING COUNT(*) > 1
ORDER BY first_joined;

-- 4 · Customers who signed up in January, per city, the NULL cities labeled.
SELECT
    COALESCE(city, '(no city)') AS city,
    COUNT(*)                    AS january_signups
FROM customers
WHERE created_at < '2026-02-01'
GROUP BY COALESCE(city, '(no city)')
ORDER BY january_signups DESC, city;
