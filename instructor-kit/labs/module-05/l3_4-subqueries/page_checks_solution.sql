-- state: flat
-- =====================================================================
-- page_checks_solution.sql: REFERENCE SOLUTION (instructor copy)
-- Session 5 · Lesson 3.4 · MySQL Foundations instructor kit
--
-- Scalar and list subqueries on dates and page counts (the lesson used
-- prices). Every number the outer query compares with is computed.
--
--   SOURCE labs/module-05/l3_4-subqueries/page_checks_solution.sql
-- =====================================================================

-- 1 · The oldest book in the store: the row behind MIN(published).
SELECT title, author, published
FROM books
WHERE published = (SELECT MIN(published) FROM books);

-- 2 · Quick reads at a fair price: fewer pages than average AND cheaper
--     than average (two scalar subqueries).
SELECT title, pages, price
FROM books
WHERE pages < (SELECT AVG(pages) FROM books)
  AND price < (SELECT AVG(price) FROM books)
ORDER BY pages;

-- 3 · Every book by an author who has at least one out-of-stock book (IN).
SELECT title, author, in_stock
FROM books
WHERE author IN (SELECT author FROM books WHERE in_stock = FALSE)
ORDER BY author, title;

-- 4 · Books published after every out-of-stock book (> ALL), and the same
--     answer with MAX.
SELECT title, published
FROM books
WHERE published > ALL (SELECT published FROM books WHERE in_stock = FALSE)
ORDER BY published;
SELECT COUNT(*) AS same_with_max
FROM books
WHERE published > (SELECT MAX(published) FROM books WHERE in_stock = FALSE);
