-- state: full
-- =====================================================================
-- checkpoint2_starter.sql: Checkpoint 2 (Modules 5 and 6), 30 minutes, open notes
-- Session 11 · MySQL Foundations instructor kit
--
-- Five short parts. Write each query in place of its TODO line (each TODO
-- line is a placeholder SELECT, so the file runs as shipped), SOURCE the
-- file, and copy the key numbers into your workbook. Lesson pages and your
-- own project files are allowed; a neighbor is not. About 5 minutes per
-- part. Part 5 is answered on paper, in the workbook.
--
--   SOURCE labs/module-11/checkpoint-2/checkpoint2_starter.sql
--
-- Leave the bookstore as you found it: the last two lines remove the view
-- and the index you create. (If a run stops halfway, reload
-- labs/_states/bookstore.sql.)
-- =====================================================================

-- Part 1 (Lessons 5.1 and 5.2) · The best seller(s) of each category, by
-- copies sold (SUM of order_items.quantity). Ties share first place.
-- Columns: category, title, copies; one row per category (more on a tie),
-- sorted by category. Use a CTE for the copies and a window function to rank.
SELECT 'TODO Part 1: CTE + window function' AS todo;

-- Part 2 (Lesson 5.1) · Everyone who reports to Daniel Reyes (employee 2),
-- directly or through someone else, with a level column (1 = reports to
-- Daniel directly). Sorted by level, then id. Use a recursive CTE.
SELECT 'TODO Part 2: recursive CTE' AS todo;

-- Part 3 (Lesson 6.2) · Create the view v_customer_revenue with one row per
-- customer who has ordered: customer_id, customer (first and last name),
-- orders (how many), revenue (SUM of quantity * price_at_time). Then query
-- the view: the customers with revenue above 30, highest first.
CREATE OR REPLACE VIEW v_customer_revenue AS SELECT 'TODO Part 3' AS todo;
SELECT 'TODO Part 3: query the view' AS todo;

-- Part 4 (Lesson 6.1) · Show the plan of this search (turn the EXPLAIN line
-- on), then make the placeholder index useful (it indexes the wrong column),
-- and show the plan again. Write down the first line of each plan.
-- EXPLAIN SELECT id, first_name FROM customers WHERE city = 'Chicago'\G
CREATE INDEX idx_customers_city ON customers (id);
SELECT 'TODO Part 4: EXPLAIN, a better index, EXPLAIN again' AS todo;

-- Part 5 (Lesson 6.3) · On paper, in the workbook: normalize class_signups.

DROP INDEX idx_customers_city ON customers;
DROP VIEW v_customer_revenue;
