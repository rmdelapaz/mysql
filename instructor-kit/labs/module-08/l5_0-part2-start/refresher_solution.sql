-- state: full
-- =====================================================================
-- refresher_solution.sql: Part 1 in four queries (reference solution)
-- Session 8 · Part 2 start · MySQL Foundations instructor kit
--
-- Joins (4.3), GROUP BY and HAVING (3.3), a derived table (3.4) and a
-- self-join (4.3): the four Part 1 moves that Lessons 5.1 and 5.2 build on.
-- Runs in your current database: the freshly loaded bookstore.
-- =====================================================================

-- 1. INNER JOIN: every order line with the customer's first name and the title
SELECT o.id AS order_id, c.first_name, b.title, oi.quantity
FROM orders AS o
JOIN customers   AS c  ON c.id = o.customer_id
JOIN order_items AS oi ON oi.order_id = o.id
JOIN books       AS b  ON b.id = oi.book_id
WHERE o.order_date < '2026-02-01'
ORDER BY o.id, b.title;

-- 2. LEFT JOIN + GROUP BY: orders per customer, including customers with none
SELECT c.first_name, COUNT(o.id) AS orders
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.id
GROUP BY c.id, c.first_name
ORDER BY orders DESC, c.first_name;

-- 3. A derived table (subquery in FROM): customers whose spending is above 40
SELECT t.first_name, t.spent
FROM (
    SELECT c.first_name, SUM(oi.quantity * oi.price_at_time) AS spent
    FROM customers AS c
    JOIN orders      AS o  ON o.customer_id = c.id
    JOIN order_items AS oi ON oi.order_id = o.id
    GROUP BY c.id, c.first_name
) AS t
WHERE t.spent > 40
ORDER BY t.spent DESC;

-- 4. Self-join: each employee next to their manager (the boss has none)
SELECT e.first_name AS employee, m.first_name AS manager
FROM employees AS e
LEFT JOIN employees AS m ON m.id = e.manager_id
WHERE e.department = 'sales'
ORDER BY e.first_name;
