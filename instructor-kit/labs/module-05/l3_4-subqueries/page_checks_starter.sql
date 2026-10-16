-- state: flat
-- =====================================================================
-- page_checks_starter.sql: subqueries on dates and page counts
-- Session 5 · Lesson 3.4 · MySQL Foundations instructor kit
--
-- The lesson compared prices with subqueries. Here you compare dates and
-- page counts. Every query runs as handed out: each one compares with a
-- hand-typed placeholder value. Replace each placeholder with a subquery
-- in parentheses, so that no number is typed by hand. SOURCE the file
-- again after each TODO.
--
--   SOURCE labs/module-05/l3_4-subqueries/page_checks_starter.sql
-- =====================================================================

-- TODO 1 · The oldest book. Replace '1900-01-01' with a scalar subquery
-- that returns the earliest published date.
SELECT title, author, published
FROM books
WHERE published = '1900-01-01';

-- TODO 2 · Quick reads at a fair price: fewer pages than the average book
-- AND cheaper than the average book. Replace both 0s with subqueries.
SELECT title, pages, price
FROM books
WHERE pages < 0
  AND price < 0
ORDER BY pages;

-- TODO 3 · Every book by an author who has at least one out-of-stock book.
-- Replace the hand-typed list with a one-column subquery:
-- SELECT author FROM books WHERE in_stock = FALSE
SELECT title, author, in_stock
FROM books
WHERE author IN ('nobody')
ORDER BY author, title;

-- TODO 4 · Books published after EVERY out-of-stock book. Replace the
-- date with  > ALL (SELECT published FROM books WHERE in_stock = FALSE).
-- Then write the second query with MAX instead of ALL: same count?
SELECT title, published
FROM books
WHERE published > '2100-01-01'
ORDER BY published;
SELECT 'TODO 4b: the same question with MAX' AS todo;

-- Expected when done:
--   1: Pride and Prejudice, Jane Austen, 1813-01-28
--   2: five books: Fahrenheit 451 (158 pages), The Great Gatsby, The Catcher
--      in the Rye, Brave New World, 1984 (328 pages)
--   3: The Great Gatsby (F. Scott Fitzgerald) and The Catcher in the Rye
--      (J.D. Salinger), both in_stock 0
--   4: Fahrenheit 451, Lord of the Rings, To Kill a Mockingbird, Dune;
--      4b: same_with_max 4
