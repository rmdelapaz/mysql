-- state: flat
-- =====================================================================
-- bestseller_board_solution.sql: six lists for the shop's display board
-- Session 4 · Lesson 3.2 · MySQL Foundations instructor kit · instructor reference
--
-- Every list is an ORDER BY problem: descending, several keys, an
-- expression, a top N with a tie-breaker, a custom order with CASE, and
-- NULLs placed on purpose. Read-only; runs inside bookstore.
-- =====================================================================

-- 1 · Newest customers first
SELECT first_name, last_name, created_at
FROM customers
ORDER BY created_at DESC;

-- 2 · Longest titles first (title breaks ties)
SELECT title, CHAR_LENGTH(title) AS title_length
FROM books
ORDER BY title_length DESC, title;

-- 3 · Authors A to Z, each author's newest book first
SELECT author, title, published
FROM books
ORDER BY author, published DESC;

-- 4 · The three thinnest books we can sell today
SELECT title, pages
FROM books
WHERE in_stock = TRUE
ORDER BY pages, title
LIMIT 3;

-- 5 · Categories: Classic first, then Fiction, then the rest A to Z
SELECT name
FROM categories
ORDER BY
    CASE name
        WHEN 'Classic' THEN 1
        WHEN 'Fiction' THEN 2
        ELSE 3
    END,
    name;

-- 6 · Customers by city Z to A, the ones with no city at the TOP (follow-up list)
SELECT first_name, last_name, city
FROM customers
ORDER BY city IS NOT NULL, city DESC, last_name;
