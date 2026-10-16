-- state: flat
-- =====================================================================
-- page_report_solution.sql: REFERENCE SOLUTION (instructor copy)
-- Session 5 · Lesson 3.3 · MySQL Foundations instructor kit
--
-- A reading-time report on the books: length bands, pages per author,
-- books per century, and one WHERE-plus-HAVING question.
--
--   SOURCE labs/module-05/l3_3-aggregate-functions/page_report_solution.sql
-- =====================================================================

-- 1 · Length bands: a CASE expression becomes the group.
SELECT
    CASE
        WHEN pages < 250 THEN 'Short (under 250)'
        WHEN pages < 400 THEN 'Medium (250 to 399)'
        ELSE 'Long (400 and up)'
    END                  AS length_band,
    COUNT(*)             AS books,
    ROUND(AVG(price), 2) AS avg_price
FROM books
GROUP BY length_band
ORDER BY MIN(pages);

-- 2 · Pages per author, longest total first; ties alphabetically.
SELECT author, COUNT(*) AS books, SUM(pages) AS total_pages
FROM books
GROUP BY author
ORDER BY total_pages DESC, author
LIMIT 5;

-- 3 · Books per century. 1813 is in the 19th century, 1925 in the 20th.
SELECT
    FLOOR((YEAR(published) - 1) / 100) + 1 AS century,
    COUNT(*)                               AS books,
    MIN(published)                         AS earliest
FROM books
GROUP BY century
ORDER BY century;

-- 4 · WHERE and HAVING together: counting only in-stock books, which authors
--     have more than 200 pages on the shelf? (Without the WHERE line,
--     J.D. Salinger's out-of-stock 234 pages would let him in.)
SELECT author, SUM(pages) AS pages_in_stock
FROM books
WHERE in_stock = TRUE
GROUP BY author
HAVING SUM(pages) > 200
ORDER BY pages_in_stock DESC, author;
