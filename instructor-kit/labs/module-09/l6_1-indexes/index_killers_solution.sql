-- state: full
-- =====================================================================
-- index_killers_solution.sql: four habits that hide a column from its index (reference solution)
-- Session 9 · Lesson 6.1 · MySQL Foundations instructor kit
--
-- The same 100,000-row visit_log as plan_reading, this time WITH an index
-- on visited_on and a unique index on ticket. Each pair asks the same
-- question twice: the first form cannot use the index, the rewrite can.
-- The counts prove both forms give the same answer. Estimates differ from
-- server to server; compare the plan shapes. The file drops visit_log at the end.
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

-- 1. A function around the column: YEAR()/MONTH() versus a range on the bare column
SELECT COUNT(*) AS slow_june FROM visit_log WHERE YEAR(visited_on) = 2025 AND MONTH(visited_on) = 6;
SELECT COUNT(*) AS fast_june FROM visit_log WHERE visited_on >= '2025-06-01' AND visited_on < '2025-07-01';
EXPLAIN SELECT * FROM visit_log WHERE YEAR(visited_on) = 2025 AND MONTH(visited_on) = 6\G
EXPLAIN SELECT * FROM visit_log WHERE visited_on >= '2025-06-01' AND visited_on < '2025-07-01'\G

-- 2. Arithmetic on the column: move it to the other side
SELECT COUNT(*) AS slow_first_week FROM visit_log WHERE visited_on + INTERVAL 7 DAY <= '2025-01-08';
SELECT COUNT(*) AS fast_first_week FROM visit_log WHERE visited_on <= '2025-01-01';
EXPLAIN SELECT * FROM visit_log WHERE visited_on <= '2025-01-01'\G

-- 3. A text column compared with a number: compare like with like
SELECT COUNT(*) AS slow_ticket FROM visit_log WHERE ticket = 4242;
SELECT COUNT(*) AS fast_ticket FROM visit_log WHERE ticket = '004242';
EXPLAIN SELECT * FROM visit_log WHERE ticket = 4242\G
SHOW WARNINGS;
EXPLAIN SELECT * FROM visit_log WHERE ticket = '004242'\G

-- 4. A wildcard at the start of LIKE: a leading % has no place to jump to
--    (the traditional format: read type, key and rows)
SELECT COUNT(*) AS starts_0042 FROM visit_log WHERE ticket LIKE '0042%';
EXPLAIN FORMAT=TRADITIONAL SELECT * FROM visit_log WHERE ticket LIKE '%4242';
EXPLAIN FORMAT=TRADITIONAL SELECT * FROM visit_log WHERE ticket LIKE '0042%';

DROP TABLE visit_log;
