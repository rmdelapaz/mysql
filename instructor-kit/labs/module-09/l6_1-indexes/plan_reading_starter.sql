-- state: full
-- =====================================================================
-- plan_reading_starter.sql: measure, index, measure again
-- Session 9 · Lesson 6.1 · MySQL Foundations instructor kit
--
-- A website visit log big enough to notice: 100,000 rows, built with a
-- CTE and a cross join exactly like the lesson's sales_log. You read a
-- plan, add the index the query needs, and read the plan again.
-- The file rebuilds visit_log on every run (about a second) and drops it
-- at the end, so edit, save and SOURCE again as often as you like:
--   SOURCE labs/module-09/l6_1-indexes/plan_reading_starter.sql
-- Cost and row ESTIMATES in the plans differ from server to server;
-- compare the shape (Table scan, Index lookup, range scan), not the numbers.
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
ANALYZE TABLE visit_log;

-- 1. How big, and over which dates?
SELECT COUNT(*) AS visits, MIN(visited_on) AS first_day, MAX(visited_on) AS last_day
FROM visit_log;

-- 2. Before: one day's visits. Read the plan from the most indented line up.
EXPLAIN SELECT * FROM visit_log WHERE visited_on = '2025-06-01'\G

-- TODO 1 · Predict in your workbook how the plan below will change, then
-- turn the CREATE INDEX on (remove the -- at the start of its line).
-- CREATE INDEX idx_visits_on ON visit_log (visited_on);
EXPLAIN SELECT * FROM visit_log WHERE visited_on = '2025-06-01'\G
SELECT COUNT(*) AS visits_on_june_1 FROM visit_log WHERE visited_on = '2025-06-01';

-- TODO 2 · One customer in one month. Write the composite index that lets
-- MySQL jump to customer 3 and read only June: which column goes first?
-- Fill in the two columns and remove the --.
-- CREATE INDEX idx_visits_customer_on ON visit_log (___, ___);
EXPLAIN SELECT COUNT(*) FROM visit_log
WHERE customer_id = 3 AND visited_on >= '2025-06-01' AND visited_on < '2025-07-01'\G
SELECT COUNT(*) AS customer_3_in_june FROM visit_log
WHERE customer_id = 3 AND visited_on >= '2025-06-01' AND visited_on < '2025-07-01';

-- TODO 3 · Every ticket is unique. Add a UNIQUE index named uq_visits_ticket
-- on ticket (one line, like TODO 1's but with UNIQUE), then read the plan:
-- what does "Rows fetched before execution" mean?
EXPLAIN SELECT * FROM visit_log WHERE ticket = '004242'\G

-- 6. The indexes on visit_log now, columns in order
SELECT INDEX_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns_in_order, NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'bookstore' AND TABLE_NAME = 'visit_log'
GROUP BY INDEX_NAME, NON_UNIQUE
ORDER BY INDEX_NAME;

-- Expected when done (the shapes; your cost and rows estimates differ):
-- 2       Filter ... -> Table scan on visit_log (100,000 visits, 2025-01-01 to 2026-05-15)
-- TODO 1  Index lookup on visit_log using idx_visits_on; 200 visits on June 1
-- TODO 2  (customer_id, visited_on): Covering index range scan on visit_log using
--         idx_visits_customer_on over (customer_id = 3 AND '2025-06-01' <= visited_on < '2025-07-01');
--         700 visits for customer 3 in June
-- TODO 3  Rows fetched before execution
-- 6       four indexes: idx_visits_customer_on (customer_id,visited_on), idx_visits_on,
--         PRIMARY (id), uq_visits_ticket (ticket, NON_UNIQUE 0)

DROP TABLE visit_log;
