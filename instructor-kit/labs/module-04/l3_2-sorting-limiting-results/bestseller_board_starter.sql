-- state: flat
-- =====================================================================
-- bestseller_board_starter.sql: six lists for the shop's display board
-- Session 4 · Lesson 3.2 · MySQL Foundations instructor kit
--
-- Every list below comes out in id order (ORDER BY id), which is not what
-- the board needs. Replace each ORDER BY id with the order the comment asks
-- for (list 4 also needs a LIMIT), save, and run the file again. Before
-- each one, ask: could two rows tie? If yes, add a tie-breaker.
--
-- Read-only. Run it inside bookstore with the Module 3 data:
--   SOURCE labs/module-04/l3_2-sorting-limiting-results/bestseller_board_starter.sql
-- =====================================================================

-- 1 · Newest customers first
-- TODO 1: newest first
SELECT first_name, last_name, created_at
FROM customers
ORDER BY id;

-- 2 · Longest titles first (title breaks ties)
-- TODO 2: the alias title_length, longest first; title breaks ties
SELECT title, CHAR_LENGTH(title) AS title_length
FROM books
ORDER BY id;

-- 3 · Authors A to Z, each author's newest book first
-- TODO 3: two keys, each with its own direction
SELECT author, title, published
FROM books
ORDER BY id;

-- 4 · The three thinnest books we can sell today
-- TODO 4: fewest pages first, a tie-breaker, and keep only 3 rows
SELECT title, pages
FROM books
WHERE in_stock = TRUE
ORDER BY id;

-- 5 · Categories: Classic first, then Fiction, then the rest A to Z
-- TODO 5: a CASE that turns Classic into 1, Fiction into 2, anything else into 3; then name
SELECT name
FROM categories
ORDER BY id;

-- 6 · Customers by city Z to A, the ones with no city at the TOP (follow-up list)
-- TODO 6: city IS NULL is 1 for a missing city; which way puts those rows first? Then city Z to A
SELECT first_name, last_name, city
FROM customers
ORDER BY id;

-- Expected when done: see the README (Hank first in list 1; The Catcher in the Rye
-- first in list 2; Fahrenheit 451, To Kill a Mockingbird, The Hobbit in list 4;
-- Classic, Fiction, Dystopian, Fantasy, Science Fiction in list 5; Eve and Hank
-- first in list 6).
