-- state: flat
-- expect-error: 1054, 1064
-- =====================================================================
-- debug_filters.sql: five filters that go wrong (find-the-bug handout)
-- Session 4 · Lesson 3.1 · MySQL Foundations instructor kit
--
-- This file is broken ON PURPOSE. Two queries fail with an ERROR. Three
-- run without any error and return the WRONG rows: those are the
-- dangerous ones. For each query write in your workbook: what the staff
-- member asked for · what MySQL did · the fixed WHERE clause.
--
-- Read-only. Run it inside bookstore with the Module 3 data:
--   SOURCE labs/module-04/l3_1-where-clauses-operators-filtering/debug_filters.sql
-- =====================================================================

-- Bug A: "every customer in Chicago"
SELECT first_name, last_name FROM customers WHERE city = Chicago ORDER BY last_name;

-- Bug B: "books with more than 300 and fewer than 500 pages"
SELECT title, pages FROM books WHERE pages > 300 AND < 500 ORDER BY pages;

-- Bug C: "customers with no city on file" (expects Eve and Hank)
SELECT first_name FROM customers WHERE city = NULL ORDER BY first_name;

-- Bug D: "titles that start with The" (expects three)
SELECT title FROM books WHERE title = 'The%' ORDER BY title;

-- Bug E: "in-stock books by Austen or Salinger"
SELECT title, author, in_stock
FROM books
WHERE in_stock = TRUE AND author = 'Jane Austen' OR author = 'J.D. Salinger'
ORDER BY title;
