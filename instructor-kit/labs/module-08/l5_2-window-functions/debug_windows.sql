-- state: full
-- expect-error: 3593, 1064, 6037
-- =====================================================================
-- debug_windows.sql: three window queries that fail (deliberately broken handout)
-- Session 8 · Lesson 5.2 · MySQL Foundations instructor kit
--
-- All three try to answer one question: "the three most expensive books".
-- Run the file, read each ERROR line, and write the cause and the fix in
-- your workbook. Then rewrite query A with the CTE pattern (number the
-- rows in a CTE, filter in the outer query) and run the file again.
-- (The stray quote at the end of error 3593's message is MySQL's, not yours.)
-- =====================================================================

-- A. Filter on the window in WHERE
SELECT title, price
FROM books
WHERE ROW_NUMBER() OVER (ORDER BY price DESC) <= 3;

-- B. Call the column rank
SELECT title, price, RANK() OVER (ORDER BY price DESC) AS rank
FROM books
ORDER BY price DESC
LIMIT 3;

-- C. Borrow QUALIFY from another database
SELECT title, price, ROW_NUMBER() OVER (ORDER BY price DESC) AS pos
FROM books
QUALIFY pos <= 3;
