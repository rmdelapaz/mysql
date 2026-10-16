-- state: full
-- =====================================================================
-- index_killers_starter.sql: four habits that hide a column from its index
-- Session 9 · Lesson 6.1 · MySQL Foundations instructor kit
--
-- The same 100,000-row visit_log as plan_reading, this time WITH an index
-- on visited_on and a unique index on ticket. Each section shows a query
-- that cannot use the index (its plan says Table scan). Your job: rewrite
-- it so it can, WITHOUT changing the answer. Replace each TODO line with
-- your COUNT(*) query and an EXPLAIN of it. Same count + a better plan = done.
-- The file rebuilds visit_log on every run and drops it at the end:
--   SOURCE labs/module-09/l6_1-indexes/index_killers_starter.sql
-- =====================================================================

DROP TABLE IF EXISTS visit_log;
CREATE TABLE visit_log (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    ticket      CHAR(6)     NOT NULL,
    customer_id INT         NOT NULL,
    visited_on  DATE        NOT NULL,
    page        VARCHAR(10) NOT NULL
);
INSERT INTO visit_log (ticket, customer_id, visited_on, page)
WITH digits AS (
    SELECT 0 AS d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
),
seq AS (
    SELECT 1 + a.d + 10 * b.d + 100 * c.d + 1000 * e.d + 10000 * f.d AS n
    FROM digits a
    CROSS JOIN digits b CROSS JOIN digits c CROSS JOIN digits e CROSS JOIN digits f
)
SELECT LPAD(n, 6, '0'),                                    -- ticket 000001, 000002, ...
       1 + MOD(n * 5, 8),                                  -- customers 1 to 8
       DATE '2025-01-01' + INTERVAL MOD(n * 11, 500) DAY,  -- 500 days from 2025-01-01
       ELT(1 + MOD(n, 5), 'home', 'search', 'book', 'cart', 'checkout')
FROM seq
ORDER BY n;
CREATE INDEX idx_visits_on ON visit_log (visited_on);
CREATE UNIQUE INDEX uq_visits_ticket ON visit_log (ticket);
ANALYZE TABLE visit_log;

-- 1. A function around the column
SELECT COUNT(*) AS slow_june FROM visit_log WHERE YEAR(visited_on) = 2025 AND MONTH(visited_on) = 6;
EXPLAIN SELECT * FROM visit_log WHERE YEAR(visited_on) = 2025 AND MONTH(visited_on) = 6\G
-- TODO 1 · The same June 2025, as a range on the bare column
--         (from the first of the month up to, but not including, the first of the next).
SELECT 'TODO 1: fast_june, and its EXPLAIN' AS todo;

-- 2. Arithmetic on the column
SELECT COUNT(*) AS slow_first_week FROM visit_log WHERE visited_on + INTERVAL 7 DAY <= '2025-01-08';
-- TODO 2 · Move the arithmetic to the other side of <= (what is 2025-01-08 minus 7 days?).
SELECT 'TODO 2: fast_first_week, and its EXPLAIN' AS todo;

-- 3. A text column compared with a number
SELECT COUNT(*) AS slow_ticket FROM visit_log WHERE ticket = 4242;
EXPLAIN SELECT * FROM visit_log WHERE ticket = 4242\G
SHOW WARNINGS;
-- TODO 3 · ticket is CHAR(6). Compare it with the text it really holds.
SELECT 'TODO 3: fast_ticket, and its EXPLAIN' AS todo;

-- 4. A wildcard at the start of LIKE (the traditional format: read type, key, rows)
EXPLAIN FORMAT=TRADITIONAL SELECT * FROM visit_log WHERE ticket LIKE '%4242';
-- TODO 4 · Not every question can be rewritten: "ends with 4242" really needs
-- the scan. Count the tickets that START with 0042 instead, and EXPLAIN it
-- with FORMAT=TRADITIONAL: what are type and key now?
SELECT 'TODO 4: starts_0042, and its EXPLAIN FORMAT=TRADITIONAL' AS todo;

-- Expected when done (the shapes; your cost and rows estimates differ):
-- 1  slow_june and fast_june both 6000; Table scan becomes
--    Index range scan on visit_log using idx_visits_on over ('2025-06-01' <= visited_on < '2025-07-01')
-- 2  both 200; Index range scan ... over (visited_on <= '2025-01-01')
-- 3  both 1; Table scan (plus warning 1739: Cannot use ref access on index
--    'uq_visits_ticket' due to type or collation conversion) becomes Rows fetched before execution
-- 4  starts_0042 = 100; type ALL, key NULL becomes type range, key uq_visits_ticket, rows 100

DROP TABLE visit_log;
