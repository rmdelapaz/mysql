-- state: full
-- =====================================================================
-- leaderboards_starter.sql: ranks, ties and top N per group
-- Session 8 · Lesson 5.2 · MySQL Foundations instructor kit
--
-- Three leaderboards: customers by copies bought (there are ties), the two
-- cheapest books in every category, and each salary's share of its
-- department's payroll. Each query runs as shipped. Before each fix, write
-- your prediction in the workbook; then fix the TODO, save, SOURCE again.
--
--   SOURCE labs/module-08/l5_2-window-functions/leaderboards_starter.sql
-- =====================================================================

-- TODO 1 · Only ROW_NUMBER is there. Add RANK() and DENSE_RANK() over the
-- same order (ORDER BY copies DESC, no tie-breaker), named rank_num and
-- dense_num (not "rank": it is a reserved word). Predict first: which
-- numbers do Dave and Frank get from each function?
WITH bought AS (
    SELECT c.first_name, SUM(oi.quantity) AS copies
    FROM customers AS c
    JOIN orders      AS o  ON o.customer_id = c.id
    JOIN order_items AS oi ON oi.order_id = o.id
    GROUP BY c.id, c.first_name
)
SELECT first_name,
       copies,
       ROW_NUMBER() OVER (ORDER BY copies DESC, first_name) AS row_num
FROM bought
ORDER BY copies DESC, first_name;

-- TODO 2 · Top 2 per category. The window numbers the books over the whole
-- result, so only two books come back in total. Add  PARTITION BY cat.id
-- in front of ORDER BY inside OVER, so the numbering restarts in every category.
WITH ranked AS (
    SELECT cat.name AS category, b.title, b.price,
           ROW_NUMBER() OVER (ORDER BY b.price, b.title) AS pos
    FROM categories AS cat
    JOIN book_categories AS bc ON bc.category_id = cat.id
    JOIN books           AS b  ON b.id = bc.book_id
)
SELECT category, pos, title, price
FROM ranked
WHERE pos <= 2
ORDER BY category, pos;

-- TODO 3 · Each salary's share of its department's payroll. dept_payroll
-- sums the whole table (OVER ()). Make it a per-department sum, then add
--   ROUND(100 * salary / SUM(salary) OVER (PARTITION BY department), 1) AS pct_of_dept
SELECT department,
       first_name,
       salary,
       SUM(salary) OVER () AS dept_payroll
FROM employees
WHERE department IN ('sales', 'inventory')
ORDER BY department, salary DESC;

-- Expected when done:
-- TODO 1  Alice 5 · 1 1 1; Dave 4 · 2 2 2; Frank 4 · 3 2 2; Bob 3 · 4 4 3;
--         Grace 3 · 5 4 3; Eve 2 · 6 6 4
-- TODO 2  ten rows, two per category: Classic Pride and Prejudice 7.99, Animal
--         Farm 8.49 · Dystopian Brave New World 9.49, 1984 9.99 · Fantasy The
--         Hobbit 10.99, Lord of the Rings 15.99 · Fiction Pride and Prejudice,
--         Animal Farm · Science Fiction Brave New World, Fahrenheit 451 10.49
-- TODO 3  sales payroll 158500.00 (Priya 29.0, Lena 24.9, Tom 24.0, Ben 22.1);
--         inventory 84000.00 (Marcus 56.0, Sofia 44.0)
