-- state: flat
-- =====================================================================
-- city_neighbors_solution.sql: REFERENCE SOLUTION (instructor copy)
-- Session 5 · Lesson 3.4 · MySQL Foundations instructor kit
--
-- Correlated subqueries, EXISTS, a derived table and the NOT IN / NULL
-- trap, on the customers and books of the flat bookstore.
--
--   SOURCE labs/module-05/l3_4-subqueries/city_neighbors_solution.sql
-- =====================================================================

-- 1 · Each customer with the number of OTHER customers in the same city
--     (a correlated subquery in the SELECT list).
SELECT
    c.first_name,
    c.city,
    (SELECT COUNT(*)
     FROM customers AS other
     WHERE other.city = c.city
       AND other.id != c.id) AS neighbors
FROM customers AS c
ORDER BY c.id;

-- 2 · The first customer to sign up in each city (correlated, in WHERE).
SELECT c.first_name, c.city, c.created_at
FROM customers AS c
WHERE c.created_at = (
    SELECT MIN(c2.created_at)
    FROM customers AS c2
    WHERE c2.city = c.city
)
ORDER BY c.created_at;

-- 3 · A summary of a summary (derived table): how many authors have more
--     than 300 pages in the store, and what is the longest author total?
SELECT COUNT(*) AS authors_over_300, MAX(total_pages) AS longest_total
FROM (
    SELECT author, SUM(pages) AS total_pages
    FROM books
    GROUP BY author
) AS author_pages
WHERE total_pages > 300;

-- 4 · Customers 1 to 4 whose city no later customer (id 5 to 8) shares.
--     4a · NOT IN, with the NULLs kept out of the list:
SELECT first_name, city
FROM customers
WHERE id <= 4
  AND city NOT IN (SELECT city FROM customers WHERE id > 4 AND city IS NOT NULL)
ORDER BY id;
--     4b · NOT EXISTS gives the same rows here, with no NULL trap:
SELECT c.first_name, c.city
FROM customers AS c
WHERE c.id <= 4
  AND NOT EXISTS (
      SELECT 1 FROM customers AS later
      WHERE later.id > 4 AND later.city = c.city
  )
ORDER BY c.id;
