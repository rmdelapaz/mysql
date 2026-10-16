-- state: full
-- =====================================================================
-- checkpoint2_solution.sql: Checkpoint 2 (Modules 5 and 6), model answer
-- Session 11 · MySQL Foundations instructor kit · instructor reference
--
-- Five short parts, one per lesson of Modules 5 and 6: a CTE with a window
-- function (5.1, 5.2), a recursive CTE (5.1), a view (6.2), an index read
-- with EXPLAIN (6.1) and a normalization question on paper (6.3).
-- The file leaves bookstore as it found it (the view and index are dropped).
-- =====================================================================

-- Part 1 · The best seller(s) of each category, by copies sold; ties share first place
WITH sold AS (
    SELECT c.name AS category, b.title, SUM(oi.quantity) AS copies
    FROM categories AS c
    JOIN book_categories AS bc ON bc.category_id = c.id
    JOIN books AS b            ON b.id = bc.book_id
    JOIN order_items AS oi     ON oi.book_id = b.id
    GROUP BY c.id, c.name, b.id, b.title
),
ranked AS (
    SELECT category, title, copies,
           RANK() OVER (PARTITION BY category ORDER BY copies DESC) AS place
    FROM sold
)
SELECT category, title, copies
FROM ranked
WHERE place = 1
ORDER BY category, title;

-- Part 2 · Everyone who reports to Daniel Reyes (employee 2), directly or not, with the level
WITH RECURSIVE team AS (
    SELECT id, first_name, last_name, manager_id, 1 AS level
    FROM employees
    WHERE manager_id = 2
    UNION ALL
    SELECT e.id, e.first_name, e.last_name, e.manager_id, t.level + 1
    FROM employees AS e
    JOIN team AS t ON e.manager_id = t.id
)
SELECT level, id, CONCAT(first_name, ' ', last_name) AS employee, manager_id
FROM team
ORDER BY level, id;

-- Part 3 · A view of each customer's orders and revenue, then the customers above $30
DROP VIEW IF EXISTS v_customer_revenue;
CREATE VIEW v_customer_revenue AS
SELECT c.id AS customer_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer,
       COUNT(DISTINCT o.id) AS orders,
       SUM(oi.quantity * oi.price_at_time) AS revenue
FROM customers AS c
JOIN orders AS o       ON o.customer_id = c.id
JOIN order_items AS oi ON oi.order_id = o.id
GROUP BY c.id, c.first_name, c.last_name;
SELECT customer, orders, revenue
FROM v_customer_revenue
WHERE revenue > 30
ORDER BY revenue DESC;

-- Part 4 · An index for the city search, before and after (read the first line of each plan)
EXPLAIN SELECT id, first_name FROM customers WHERE city = 'Chicago'\G
CREATE INDEX idx_customers_city ON customers (city);
EXPLAIN SELECT id, first_name FROM customers WHERE city = 'Chicago'\G

-- Part 5 · On paper (see the answer key): class_signups normalized to 3NF.

DROP INDEX idx_customers_city ON customers;
DROP VIEW v_customer_revenue;
