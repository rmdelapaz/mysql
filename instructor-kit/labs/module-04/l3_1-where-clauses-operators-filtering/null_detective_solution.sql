-- state: flat
-- =====================================================================
-- null_detective_solution.sql: where do the customers without a city go?
-- Session 4 · Lesson 3.1 · MySQL Foundations instructor kit · instructor reference
--
-- Eight customers, two with no city (NULL). Showing each condition as a
-- column makes the third answer, unknown, visible; then the counts only add
-- up to 8 once IS NULL is counted too. Read-only; runs inside bookstore.
-- =====================================================================

-- 1 · Every condition as a column: 1 true, 0 false, NULL unknown
SELECT first_name, city,
       city = 'Chicago'   AS is_chicago,
       city <> 'Chicago'  AS not_chicago,
       city IS NULL       AS no_city
FROM customers
ORDER BY id;

-- 2 · Three counts that should cover all 8 customers
SELECT COUNT(*) AS in_chicago  FROM customers WHERE city = 'Chicago';
SELECT COUNT(*) AS elsewhere   FROM customers WHERE city <> 'Chicago';
SELECT COUNT(*) AS no_city     FROM customers WHERE city IS NULL;

-- 3 · Everyone outside Houston, the customers without a city included
SELECT first_name, city
FROM customers
WHERE city NOT IN ('Houston') OR city IS NULL
ORDER BY first_name;

-- 4 · MySQL's NULL-safe equals finds the missing cities too
SELECT first_name, city
FROM customers
WHERE city <=> NULL
ORDER BY first_name;
