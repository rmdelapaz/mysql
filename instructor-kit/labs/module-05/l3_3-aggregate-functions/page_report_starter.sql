-- state: flat
-- =====================================================================
-- page_report_starter.sql: a reading-time report on the books
-- Session 5 · Lesson 3.3 · MySQL Foundations instructor kit
--
-- Four summaries of the books' page counts. Every query runs as handed
-- out; each TODO tells you what to change. SOURCE the file again after
-- each TODO.
--
--   SOURCE labs/module-05/l3_3-aggregate-functions/page_report_starter.sql
-- =====================================================================

-- TODO 1 · Length bands. The CASE expression is written for you, but the
-- query does not group yet, so every book is its own row. Add
-- GROUP BY length_band, replace title with COUNT(*) AS books and
-- ROUND(AVG(price), 2) AS avg_price, and sort with ORDER BY MIN(pages).
SELECT
    CASE
        WHEN pages < 250 THEN 'Short (under 250)'
        WHEN pages < 400 THEN 'Medium (250 to 399)'
        ELSE 'Long (400 and up)'
    END AS length_band,
    title
FROM books
ORDER BY pages;

-- TODO 2 · The five authors with the most pages in the store. Group by
-- author; show COUNT(*) AS books and SUM(pages) AS total_pages; sort by
-- total_pages (largest first), then author; LIMIT 5.
SELECT 'TODO 2: pages per author' AS todo;

-- TODO 3 · Books per century: FLOOR((YEAR(published) - 1) / 100) + 1 gives
-- 19 for 1813 and 20 for 1925. It is done; add MIN(published) AS earliest.
SELECT
    FLOOR((YEAR(published) - 1) / 100) + 1 AS century,
    COUNT(*)                               AS books
FROM books
GROUP BY century
ORDER BY century;

-- TODO 4 · Counting only in-stock books (WHERE), which authors have more
-- than 200 pages on the shelf (HAVING)? Show author and
-- SUM(pages) AS pages_in_stock, largest first, then author.
-- Before you add the WHERE line: who gets in without it?
SELECT 'TODO 4: authors with more than 200 pages in stock' AS todo;

-- Expected when done:
--   1: Short 3 books 9.49 · Medium 4 books 10.62 · Long 3 books 12.99
--   2: J.R.R. Tolkien 2 / 1488, Jane Austen 1 / 432, Frank Herbert 1 / 412,
--      George Orwell 1 / 328, Aldous Huxley 1 / 311
--   3: century 19: 1 book, earliest 1813-01-28 · century 20: 9 books, 1925-04-10
--   4: six authors, Tolkien 1488 down to Harper Lee 281
--      (without WHERE, J.D. Salinger and his 234 pages get in too)
