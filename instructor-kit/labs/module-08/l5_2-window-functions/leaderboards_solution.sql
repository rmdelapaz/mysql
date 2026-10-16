-- state: full
-- =====================================================================
-- leaderboards_solution.sql: ranks, ties and top N per group (reference solution)
-- Session 8 · Lesson 5.2 · MySQL Foundations instructor kit
--
-- Three leaderboards: customers by copies bought (with ties), the two
-- cheapest books in every category, and each salary's share of its
-- department's payroll. Every row stays; OVER decides what it is compared with.
-- =====================================================================

-- 1. Customers by copies bought: ROW_NUMBER, RANK and DENSE_RANK side by side
WITH bought AS (
    SELECT c.first_name, SUM(oi.quantity) AS copies
    FROM customers AS c
    JOIN orders      AS o  ON o.customer_id = c.id
    JOIN order_items AS oi ON oi.order_id = o.id
    GROUP BY c.id, c.first_name
)
SELECT first_name,
       copies,
       ROW_NUMBER() OVER (ORDER BY copies DESC, first_name) AS row_num,
       RANK()       OVER (ORDER BY copies DESC)             AS rank_num,
       DENSE_RANK() OVER (ORDER BY copies DESC)             AS dense_num
FROM bought
ORDER BY copies DESC, first_name;

-- 2. Top N per group: the two cheapest books in every category
--    (number the rows inside each category in a CTE, keep the low numbers outside)
WITH ranked AS (
    SELECT cat.name AS category, b.title, b.price,
           ROW_NUMBER() OVER (PARTITION BY cat.id ORDER BY b.price, b.title) AS pos
    FROM categories AS cat
    JOIN book_categories AS bc ON bc.category_id = cat.id
    JOIN books           AS b  ON b.id = bc.book_id
)
SELECT category, pos, title, price
FROM ranked
WHERE pos <= 2
ORDER BY category, pos;

-- 3. A window aggregate per department: each salary's share of the department payroll
SELECT department,
       first_name,
       salary,
       SUM(salary) OVER (PARTITION BY department)                     AS dept_payroll,
       ROUND(100 * salary / SUM(salary) OVER (PARTITION BY department), 1) AS pct_of_dept
FROM employees
WHERE department IN ('sales', 'inventory')
ORDER BY department, salary DESC;
