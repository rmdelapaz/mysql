-- state: full
-- =====================================================================
-- catalog_joins_solution.sql: REFERENCE SOLUTION (instructor copy)
-- Session 7 · Lesson 4.3 · MySQL Foundations instructor kit
--
-- Four questions about the catalog and the staff, each answered with a
-- join. Two of them were answered with subqueries in Session 6
-- (navigate_links): compare. Read-only.
--
--   SOURCE labs/module-07/l4_3-joins/catalog_joins_solution.sql
-- =====================================================================

-- 1 · INNER JOIN through three tables: the lines of orders 7 and 12 with
--     each book's title and author.
SELECT oi.order_id, b.title, a.name AS author, oi.quantity
FROM order_items AS oi
JOIN books   AS b ON oi.book_id = b.id
JOIN authors AS a ON b.author_id = a.id
WHERE oi.order_id IN (7, 12)
ORDER BY oi.order_id, b.title;

-- 2 · LEFT JOIN with GROUP BY: every author, their number of books and
--     their cheapest price (Asimov included, with 0 and NULL).
SELECT a.name, COUNT(b.id) AS books, MIN(b.price) AS cheapest
FROM authors AS a
LEFT JOIN books AS b ON b.author_id = a.id
GROUP BY a.id, a.name
ORDER BY books DESC, a.name
LIMIT 4;
SELECT a.name, COUNT(b.id) AS books, MIN(b.price) AS cheapest
FROM authors AS a
LEFT JOIN books AS b ON b.author_id = a.id
WHERE a.id = 10
GROUP BY a.id, a.name;

-- 3 · Anti-join on a self-reference: the employees who manage nobody
--     (Session 6 answered this with NOT EXISTS).
SELECT e.first_name, e.department
FROM employees AS e
LEFT JOIN employees AS report ON report.manager_id = e.id
WHERE report.id IS NULL
ORDER BY e.id;

-- 4 · Self-join: sales and inventory staff with their manager, and how many
--     years after the manager they were hired.
SELECT e.first_name AS employee,
       m.first_name AS manager,
       YEAR(e.hire_date) - YEAR(m.hire_date) AS years_after
FROM employees AS e
JOIN employees AS m ON e.manager_id = m.id
WHERE e.department IN ('sales', 'inventory')
ORDER BY years_after DESC, employee;
