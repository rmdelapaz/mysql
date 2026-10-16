-- state: flat
-- =====================================================================
-- staff_requests_starter.sql: seven requests from the bookstore staff
-- Session 4 · Lesson 3.1 · MySQL Foundations instructor kit
--
-- Each request is a ready-made SELECT whose WHERE clause says FALSE, so it
-- finds nothing yet. Replace FALSE with the condition the request asks for
-- (one request at a time), save, and run the file again. Count the rows you
-- expect BEFORE you run it, using the tables at the start of Lesson 3.1.
--
-- Read-only. Run it inside bookstore with the Module 3 data
-- (Lesson 3.1's setup script, or SOURCE labs/_states/flat.sql):
--   SOURCE labs/module-04/l3_1-where-clauses-operators-filtering/staff_requests_starter.sql
-- =====================================================================

-- 1 · In-stock books by Orwell, Bradbury or Harper Lee
-- TODO: in stock AND the author is one of the three (IN)
SELECT title, author
FROM books
WHERE FALSE
ORDER BY title;

-- 2 · Published before 1950 and costing at least $9
-- TODO: two conditions joined by AND; dates are written 'YYYY-MM-DD'
SELECT title, price, published
FROM books
WHERE FALSE
ORDER BY published;

-- 3 · Customers whose last name ends in "son"
-- TODO: LIKE with % in the right place
SELECT first_name, last_name
FROM customers
WHERE FALSE
ORDER BY last_name;

-- 4 · Titles that are exactly four characters long
-- TODO: LIKE with four underscores
SELECT title
FROM books
WHERE FALSE
ORDER BY title;

-- 5 · Everyone not known to live in New York (no city on file included)
-- TODO: != alone gives 4 rows; you want 6 (what about NULL?)
SELECT first_name, city
FROM customers
WHERE FALSE
ORDER BY first_name;

-- 6 · Priced from $9.49 to $10.99, but not by Tolkien
-- TODO: BETWEEN, AND not Tolkien
SELECT title, author, price
FROM books
WHERE FALSE
ORDER BY price;

-- 7 · Signed up in the first two weeks of February 2026
-- TODO: a half-open range: on or after Feb 1, before Feb 15
SELECT first_name, created_at
FROM customers
WHERE FALSE
ORDER BY created_at;

-- Expected when done: see the README (3, 3, 2, 2, 6, 3 and 2 rows).
