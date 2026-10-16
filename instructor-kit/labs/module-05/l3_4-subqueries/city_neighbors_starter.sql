-- state: flat
-- =====================================================================
-- city_neighbors_starter.sql: correlated subqueries, EXISTS, derived tables
-- Session 5 · Lesson 3.4 · MySQL Foundations instructor kit
--
-- Four questions about who lives near whom, and one about authors. Every
-- query runs as handed out. Build each subquery on its own first (for one
-- example row), check it, then connect it to the outer query. SOURCE the
-- file again after each TODO.
--
--   SOURCE labs/module-05/l3_4-subqueries/city_neighbors_starter.sql
-- =====================================================================

-- TODO 1 · Each customer with the number of OTHER customers in the same
-- city. Replace the 0 with a correlated subquery that counts the rows of
-- customers AS other WHERE other.city = c.city AND other.id != c.id.
SELECT
    c.first_name,
    c.city,
    0 AS neighbors
FROM customers AS c
ORDER BY c.id;

-- TODO 2 · The first customer to sign up in each city. Replace the date
-- with a correlated subquery: the MIN(created_at) of the customers c2 whose
-- city equals c.city. (Predict: do Eve and Hank, with NULL cities, appear?)
SELECT c.first_name, c.city, c.created_at
FROM customers AS c
WHERE c.created_at = '1999-01-01'
ORDER BY c.created_at;

-- TODO 3 · The inner query below gives each author's total pages. Use it as
-- a derived table: count how many authors have more than 300 pages, and
-- the largest total. Remember the alias after the closing parenthesis.
SELECT author, SUM(pages) AS total_pages
FROM books
GROUP BY author
ORDER BY author;

-- TODO 4 · Customers 1 to 4 whose city no later customer (id 5 to 8) shares.
-- 4a runs, but prints nothing. Why? (Run the subquery on its own.) Fix it
-- by keeping the NULLs out of the list. Then write 4b with NOT EXISTS.
SELECT first_name, city
FROM customers
WHERE id <= 4
  AND city NOT IN (SELECT city FROM customers WHERE id > 4)
ORDER BY id;
SELECT 'TODO 4b: the same question with NOT EXISTS' AS todo;

-- Expected when done:
--   1: Alice 1, Bob 1, Carol 0, Dave 0, Eve 0, Frank 1, Grace 1, Hank 0
--   2: Alice (New York), Bob (Chicago), Carol (Los Angeles), Dave (Houston);
--      Eve and Hank do not appear: NULL = NULL is never true
--   3: authors_over_300 5, longest_total 1488
--   4a and 4b: Carol (Los Angeles) and Dave (Houston)
