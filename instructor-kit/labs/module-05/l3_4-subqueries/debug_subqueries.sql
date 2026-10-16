-- state: flat
-- expect-error: 1242, 1241, 1248, 1235
-- =====================================================================
-- debug_subqueries.sql: four broken subqueries (find-the-bug handout)
-- Session 5 · Lesson 3.4 · MySQL Foundations instructor kit
--
-- This file is broken ON PURPOSE. Each query wants a sensible answer, and
-- MySQL refuses each one with a numbered error. Run it, then for each
-- ERROR line write in your workbook:
--   the error number · what shape of result MySQL expected · the fix.
-- Fixed, the file prints four result tables and no ERROR lines.
--
--   SOURCE labs/module-05/l3_4-subqueries/debug_subqueries.sql
-- =====================================================================

-- Bug A · "Customers who signed up on the same day as a February customer"
SELECT first_name, created_at
FROM customers
WHERE DATE(created_at) = (SELECT DATE(created_at) FROM customers WHERE created_at >= '2026-02-01');

-- Bug B · "Books by authors with more than 400 pages in the store"
SELECT title, author
FROM books
WHERE author IN (
    SELECT author, SUM(pages)
    FROM books
    GROUP BY author
    HAVING SUM(pages) > 400
);

-- Bug C · "The average number of customers per known city"
SELECT AVG(n)
FROM (
    SELECT city, COUNT(*) AS n
    FROM customers
    WHERE city IS NOT NULL
    GROUP BY city
);

-- Bug D · "The two longest books"
SELECT title, pages
FROM books
WHERE pages IN (SELECT pages FROM books ORDER BY pages DESC LIMIT 2);
