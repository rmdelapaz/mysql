-- state: flat
-- =====================================================================
-- staff_requests_solution.sql: seven requests from the bookstore staff
-- Session 4 · Lesson 3.1 · MySQL Foundations instructor kit · instructor reference
--
-- Each request is one SELECT with a WHERE clause: IN, BETWEEN, LIKE, IS
-- NULL, AND/OR with parentheses, and a half-open date range. Read-only:
-- runs inside bookstore (the Module 3 data, 10 books and 8 customers).
-- =====================================================================

-- 1 · In-stock books by Orwell, Bradbury or Harper Lee
SELECT title, author
FROM books
WHERE in_stock = TRUE
  AND author IN ('George Orwell', 'Ray Bradbury', 'Harper Lee')
ORDER BY title;

-- 2 · Published before 1950 and costing at least $9
SELECT title, price, published
FROM books
WHERE published < '1950-01-01'
  AND price >= 9
ORDER BY published;

-- 3 · Customers whose last name ends in "son"
SELECT first_name, last_name
FROM customers
WHERE last_name LIKE '%son'
ORDER BY last_name;

-- 4 · Titles that are exactly four characters long
SELECT title
FROM books
WHERE title LIKE '____'
ORDER BY title;

-- 5 · Everyone not known to live in New York (no city on file included)
SELECT first_name, city
FROM customers
WHERE city != 'New York' OR city IS NULL
ORDER BY first_name;

-- 6 · Priced from $9.49 to $10.99, but not by Tolkien
SELECT title, author, price
FROM books
WHERE price BETWEEN 9.49 AND 10.99
  AND author != 'J.R.R. Tolkien'
ORDER BY price;

-- 7 · Signed up in the first two weeks of February 2026
SELECT first_name, created_at
FROM customers
WHERE created_at >= '2026-02-01'
  AND created_at <  '2026-02-15'
ORDER BY created_at;
