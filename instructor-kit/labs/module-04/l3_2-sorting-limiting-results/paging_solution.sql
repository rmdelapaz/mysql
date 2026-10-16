-- state: flat
-- =====================================================================
-- paging_solution.sql: the catalog, four books per page
-- Session 4 · Lesson 3.2 · MySQL Foundations instructor kit · instructor reference
--
-- The website's catalog is sorted by price, cheapest first, with id as the
-- tie-breaker, four books per page: OFFSET pages, the page count, a page past
-- the end, and keyset pagination. Read-only; runs inside bookstore.
-- =====================================================================

-- 1 · Page 1
SELECT id, title, price FROM books ORDER BY price, id LIMIT 4 OFFSET 0;

-- 2 · Page 2: skip (2 - 1) x 4 = 4 rows
SELECT id, title, price FROM books ORDER BY price, id LIMIT 4 OFFSET 4;

-- 3 · Page 3: skip 8 rows
SELECT id, title, price FROM books ORDER BY price, id LIMIT 4 OFFSET 8;

-- 4 · How many pages?
SELECT COUNT(*) AS books, CEILING(COUNT(*) / 4) AS pages FROM books;

-- 5 · A page past the end is not an error
SELECT id, title, price FROM books ORDER BY price, id LIMIT 4 OFFSET 12;
SELECT 'page 4 printed nothing' AS note;

-- 6 · Keyset: the page after the last row of page 1 (price 9.49, id 7)
SELECT id, title, price
FROM books
WHERE price > 9.49 OR (price = 9.49 AND id > 7)
ORDER BY price, id
LIMIT 4;
