-- state: full
-- expect-error: 1052, 1054, 1066
-- =====================================================================
-- debug_joins.sql: three joins MySQL refuses, and one that lies (find-the-bug)
-- Session 7 · Lesson 4.3 · MySQL Foundations instructor kit
--
-- This file is broken ON PURPOSE. Bugs A to C are refused with a numbered
-- error. Bug D runs without an error and prints a wrong number: find it by
-- asking "what does one row of this join stand for?". For each bug write
-- in your workbook: the error (or the wrong number) · the cause · the fix.
--
--   SOURCE labs/module-07/l4_3-joins/debug_joins.sql
-- =====================================================================

-- Bug A · "Every order with the customer's city"
SELECT id, order_date, city
FROM orders
JOIN customers ON orders.customer_id = customers.id
ORDER BY order_date;

-- Bug B · "Every book in the Fantasy category"
SELECT books.title
FROM books AS b
JOIN book_categories AS bc ON bc.book_id = b.id
WHERE bc.category_id = 4;

-- Bug C · "Each employee next to their manager"
SELECT employees.first_name, employees.first_name
FROM employees
JOIN employees ON employees.manager_id = employees.id;

-- Bug D (silent) · "How many orders has each customer placed?" Alice has
-- three. What does this say?
SELECT c.first_name, COUNT(o.id) AS orders
FROM customers AS c
JOIN orders      AS o  ON o.customer_id = c.id
JOIN order_items AS oi ON oi.order_id = o.id
WHERE c.id IN (1, 2)
GROUP BY c.id, c.first_name
ORDER BY c.id;
