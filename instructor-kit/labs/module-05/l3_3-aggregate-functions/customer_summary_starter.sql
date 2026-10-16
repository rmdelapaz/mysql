-- state: flat
-- =====================================================================
-- customer_summary_starter.sql: summarize the customers table
-- Session 5 · Lesson 3.3 · MySQL Foundations instructor kit
--
-- The lesson summarized the books. Here you summarize the customers: how
-- many there are, who is missing a city, when they signed up and where
-- they live. Every query runs as handed out, with placeholders. Each TODO
-- tells you what to change; save the file and SOURCE it again after each one.
-- Runs in the flat bookstore of Module 3. If your data has drifted:
--   SOURCE labs/_states/flat.sql
--
--   SOURCE labs/module-05/l3_3-aggregate-functions/customer_summary_starter.sql
-- =====================================================================

-- TODO 1 · One headline row. COUNT(*) is done. Replace each placeholder:
--   with_city     COUNT of the city column (skips NULL)
--   missing_city  rows minus filled-in cities
--   cities        COUNT(DISTINCT ...)
--   first_signup / latest_signup   MIN and MAX of created_at
SELECT
    COUNT(*) AS customers,
    0        AS with_city,
    0        AS missing_city,
    0        AS cities,
    NULL     AS first_signup,
    NULL     AS latest_signup
FROM customers;

-- TODO 2 · Signups per month. Write a query that groups the customers by
-- DATE_FORMAT(created_at, '%Y-%m') AS month and counts each group, sorted
-- by month. Replace this placeholder line with your query:
SELECT 'TODO 2: signups per month' AS todo;

-- TODO 3 · This lists every known city with its customer count. Keep only
-- the cities with more than one customer (HAVING), add MIN(created_at) AS
-- first_joined, and sort by first_joined.
SELECT city, COUNT(*) AS customers
FROM customers
WHERE city IS NOT NULL
GROUP BY city
ORDER BY city;

-- TODO 4 · January signups per city. Two changes: (a) a WHERE line that
-- keeps only created_at before '2026-02-01'; (b) label the NULL group
-- '(no city)' with COALESCE(city, '(no city)'), in the SELECT list AND in
-- GROUP BY. Then sort by the count, largest first, then by city.
SELECT city, COUNT(*) AS january_signups
FROM customers
GROUP BY city
ORDER BY city;

-- Expected when done:
--   1: 8 customers, 6 with a city, 2 missing, 4 cities,
--      first 2026-01-04 10:15:00, latest 2026-02-10 19:12:00
--   2: 2026-01 6 · 2026-02 2
--   3: New York 2 (first joined 2026-01-04 10:15:00), Chicago 2 (2026-01-06 14:02:00)
--   4: New York 2, then (no city) 1, Chicago 1, Houston 1, Los Angeles 1
