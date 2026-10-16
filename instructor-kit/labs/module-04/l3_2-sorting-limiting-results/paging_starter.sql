-- state: flat
-- =====================================================================
-- paging_starter.sql: the catalog, four books per page
-- Session 4 · Lesson 3.2 · MySQL Foundations instructor kit
--
-- The website's catalog is sorted by price, cheapest first, with id as the
-- tie-breaker (two books cost 8.99), four books per page. Page 1 is written.
-- Fill in the other pages, the page count and the keyset query; each TODO
-- has a placeholder that prints nothing or a TODO line until you fix it.
--
-- Read-only. Run it inside bookstore with the Module 3 data:
--   SOURCE labs/module-04/l3_2-sorting-limiting-results/paging_starter.sql
-- =====================================================================

-- 1 · Page 1
SELECT id, title, price FROM books ORDER BY price, id LIMIT 4 OFFSET 0;

-- TODO 2 · Page 2: how many rows do you skip? (Replace 99.)
SELECT id, title, price FROM books ORDER BY price, id LIMIT 4 OFFSET 99;

-- TODO 3 · Page 3, the last one. How many rows will it show?
SELECT 'TODO 3: page 3' AS todo;

-- TODO 4 · How many pages does the website need? COUNT(*) counts the books;
-- CEILING rounds up.
SELECT COUNT(*) AS books, 0 AS pages FROM books;

-- TODO 5 · What happens on page 4? Write the query; is it an error?
SELECT 'TODO 5: page 4' AS todo;

-- TODO 6 · Keyset pagination. Page 1 ended with Brave New World (price 9.49,
-- id 7). Ask for the rows that come after (9.49, 7) in price-then-id order:
-- a higher price, or the same price and a higher id. Replace FALSE.
SELECT id, title, price
FROM books
WHERE FALSE
ORDER BY price, id
LIMIT 4;

-- Expected when done: page 1 ids 5, 4, 8, 7; page 2 ids 2, 10, 6, 3;
-- page 3 ids 1, 9 (two rows); 10 books, 3 pages; page 4 prints nothing (no
-- error); the keyset page is the same as page 2.
