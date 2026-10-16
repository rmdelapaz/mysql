-- state: full
-- =====================================================================
-- safe_search_solution.sql: REFERENCE for safe_search_starter.sql
-- Session 14 · Lesson 8.3 · MySQL Foundations instructor kit
--
-- A search box on the shop's website: "customers in city ...". First the
-- way NOT to do it (gluing the input into the SQL text), then the safe
-- way: a placeholder, with the value sent separately. Read-only.
-- Instructor copy.
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
PREPARE by_city FROM
    'SELECT first_name, last_name, city FROM customers WHERE city = ? ORDER BY id';
EXECUTE by_city USING @input;

SET @input = 'Chicago';
EXECUTE by_city USING @input;
DEALLOCATE PREPARE by_city;

-- 3. Several placeholders: one customer's orders between two dates
PREPARE orders_between FROM
    'SELECT o.id, o.order_date
     FROM orders AS o
     JOIN customers AS c ON c.id = o.customer_id
     WHERE c.email = ? AND o.order_date BETWEEN ? AND ?
     ORDER BY o.order_date';
SET @email = 'alice@example.com', @from = '2026-02-01', @to = '2026-06-30';
EXECUTE orders_between USING @email, @from, @to;

SET @email = 'x'' OR ''1''=''1';
EXECUTE orders_between USING @email, @from, @to;
DEALLOCATE PREPARE orders_between;
