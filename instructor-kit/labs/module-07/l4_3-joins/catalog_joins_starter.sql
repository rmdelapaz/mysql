-- state: full
-- =====================================================================
-- catalog_joins_starter.sql: answer catalog and staff questions with joins
-- Session 7 · Lesson 4.3 · MySQL Foundations instructor kit
--
-- Four questions, each answered with a join. Every query runs as handed
-- out but is missing its join (or its condition); each TODO tells you what
-- to add. SOURCE the file again after each TODO. Read-only. Load the
-- database first if you have not:  SOURCE labs/_states/bookstore.sql
--
--   SOURCE labs/module-07/l4_3-joins/catalog_joins_starter.sql
-- =====================================================================

-- TODO 1 · The lines of orders 7 and 12 with each book's title and author.
-- The query shows only ids. Add  JOIN books AS b ON oi.book_id = b.id  and
-- JOIN authors AS a ON b.author_id = a.id, then show b.title and
-- a.name AS author instead of the two ids. Sort by order_id, then title.
SELECT oi.order_id, oi.book_id, oi.quantity
FROM order_items AS oi
WHERE oi.order_id IN (7, 12)
ORDER BY oi.order_id, oi.book_id;

-- TODO 2 · Every author with their number of books and their cheapest
-- price, Isaac Asimov included. Add  LEFT JOIN books AS b ON ...,  GROUP BY
-- a.id, a.name, and replace the two placeholders with COUNT(b.id) AS books
-- and MIN(b.price) AS cheapest. Sort by books (most first), then name.
-- (Why COUNT(b.id) and not COUNT(*)? Look at Asimov in the second query.)
SELECT a.name, 0 AS books, NULL AS cheapest
FROM authors AS a
ORDER BY a.name
LIMIT 4;
SELECT a.name, 0 AS books, NULL AS cheapest
FROM authors AS a
WHERE a.id = 10;

-- TODO 3 · The employees who manage nobody, as an anti-join. Session 6 did
-- this with NOT EXISTS. Add  LEFT JOIN employees AS report ON
-- report.manager_id = e.id  and replace the placeholder (1 = 0) with the
-- test that keeps only the rows where no report was found.
SELECT e.first_name, e.department
FROM employees AS e
WHERE 1 = 0
ORDER BY e.id;

-- TODO 4 · A self-join: sales and inventory staff with their manager's first
-- name and how many years after the manager they were hired:
-- YEAR(e.hire_date) - YEAR(m.hire_date) AS years_after. Join employees AS m
-- ON e.manager_id = m.id; sort by years_after (largest first), then employee.
SELECT e.first_name AS employee, e.department
FROM employees AS e
WHERE e.department IN ('sales', 'inventory')
ORDER BY employee;

-- Expected when done:
--   1: order 7: 1984 and Animal Farm (George Orwell); order 12: Animal Farm
--      (George Orwell) and Fahrenheit 451 (Ray Bradbury); quantity 1 each
--   2: George Orwell 2 / 8.49, J.R.R. Tolkien 2 / 10.99, Aldous Huxley 1 / 9.49,
--      F. Scott Fitzgerald 1 / 8.99 · Isaac Asimov 0 / NULL
--   3: Tom, Lena, Sofia, Nina, Ben
--   4: Sofia (Marcus) 5, Tom (Priya) 3, Lena (Priya) 2, Priya (Daniel) 2,
--      Ben (Priya) 1, Marcus (Daniel) 1
