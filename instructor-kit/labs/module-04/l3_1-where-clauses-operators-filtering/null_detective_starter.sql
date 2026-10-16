-- state: flat
-- =====================================================================
-- null_detective_starter.sql: where do the customers without a city go?
-- Session 4 · Lesson 3.1 · MySQL Foundations instructor kit
--
-- Eight customers, two of them with no city on file (NULL). Run the file as
-- it is first and answer in your workbook: in query 1, what do the three
-- test columns show for Eve and Hank? In query 2, do the counts add up to 8?
-- Then do TODOs 2 to 4 and run it again.
--
-- Read-only. Run it inside bookstore with the Module 3 data:
--   SOURCE labs/module-04/l3_1-where-clauses-operators-filtering/null_detective_starter.sql
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
-- TODO 2 · The third count is missing its condition: who is in neither of
-- the first two counts? Replace FALSE.
SELECT COUNT(*) AS no_city     FROM customers WHERE FALSE;

-- 3 · Everyone outside Houston, the customers without a city included.
-- TODO 3 · This finds nobody at all (try it). Why? Fix the WHERE so it
-- returns 7 rows.
SELECT first_name, city
FROM customers
WHERE city NOT IN ('Houston', NULL)
ORDER BY first_name;

-- 4 · The customers with no city.
-- TODO 4 · This finds nobody either. Fix it twice: once with IS NULL, then
-- with MySQL's NULL-safe equals operator <=> instead of =.
SELECT first_name, city
FROM customers
WHERE city = NULL
ORDER BY first_name;

-- Expected when done: query 1 shows NULL in is_chicago and not_chicago for
-- Eve and Hank (and 1 in no_city); the counts are 2 + 4 + 2 = 8; TODO 3
-- lists 7 customers (everyone but Dave); TODO 4 lists Eve and Hank.
