-- state: full
-- =====================================================================
-- safe_search_starter.sql: placeholders instead of glued-in input
-- Session 14 · Lesson 8.3 · MySQL Foundations instructor kit
--
-- A search box on the shop's website: "customers in city ...". Part 1
-- shows the way NOT to do it: the visitor's input glued into the SQL
-- text. Run it as shipped and look at what leaks. Then write the safe
-- versions (TODOs 1 and 2) with ? placeholders and EXECUTE ... USING:
-- exactly what the PHP, Python, Node and C# drivers in Lesson 8.3 do.
-- Read-only: nothing in the bookstore changes.
--
--   SOURCE labs/module-14/l8_3-next-steps/safe_search_starter.sql
-- =====================================================================

-- What a visitor typed into the search box (crafted, not innocent)
SET @input = 'Chicago'' OR ''x''=''x';

-- 1. UNSAFE: the input becomes part of the SQL
SET @sql = CONCAT('SELECT first_name, last_name, city FROM customers WHERE city = ''', @input, ''' ORDER BY id');
SELECT @sql AS query_sent;
PREPARE unsafe_search FROM @sql;
EXECUTE unsafe_search;
DEALLOCATE PREPARE unsafe_search;

-- 2. SAFE: a placeholder; the value can only ever be a value
-- TODO 1: PREPARE by_city FROM a query like the one in part 1, but with
--   city = ? (no quotes around the ?). EXECUTE it USING @input (the crafted
--   text), then SET @input = 'Chicago' and EXECUTE it again. DEALLOCATE it.
SELECT 'TODO 1: by_city with a placeholder' AS todo;

-- 3. Several placeholders: one customer's orders between two dates
-- TODO 2: PREPARE orders_between with THREE placeholders (email, from date,
--   to date): orders joined to customers, WHERE c.email = ? AND
--   o.order_date BETWEEN ? AND ?, ORDER BY o.order_date. The values are set
--   for you; EXECUTE it USING @email, @from, @to (same order as the ?s).
--   Then try @email = 'x'' OR ''1''=''1' and EXECUTE again.
SET @email = 'alice@example.com', @from = '2026-02-01', @to = '2026-06-30';
SELECT 'TODO 2: orders_between with three placeholders' AS todo;

-- Expected when done: part 1 (as shipped) leaks all eight customers;
-- TODO 1 prints Empty set for the crafted input, then Bob Smith and Grace
-- Wilson (Chicago); TODO 2 prints orders 2 (2026-02-20) and 8
-- (2026-04-05), then Empty set for the crafted email.
