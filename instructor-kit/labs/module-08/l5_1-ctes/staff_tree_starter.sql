-- state: full
-- =====================================================================
-- staff_tree_starter.sql: series and hierarchies
-- Session 8 · Lesson 5.1 · MySQL Foundations instructor kit
--
-- A recursive CTE has an anchor (runs once), UNION ALL, and a recursive
-- member (runs once per round) with a stop condition. You generate the
-- twelve months of the year, then walk the staff tree and carry each
-- person's division (the level-2 manager they work under) down the tree.
-- Each query runs as shipped. Fix the TODO, save, SOURCE again. It only reads.
--
--   SOURCE labs/module-08/l5_1-ctes/staff_tree_starter.sql
-- =====================================================================

-- TODO 1 · The stop condition stops after month 1. Make the series run to
-- month 12, so the report shows the empty months too.
WITH RECURSIVE months AS (
    SELECT 1 AS month_num
    UNION ALL
    SELECT month_num + 1 FROM months WHERE month_num < 1
)
SELECT m.month_num, COALESCE(SUM(oi.quantity), 0) AS copies
FROM months AS m
LEFT JOIN orders      AS o  ON MONTH(o.order_date) = m.month_num
LEFT JOIN order_items AS oi ON oi.order_id = o.id
GROUP BY m.month_num
ORDER BY m.month_num;

-- TODO 2 · Each round copies the division from the manager's row (o.division).
-- But the owner's row has no division, so nobody ever gets one. Level-2
-- people should START a division with their own name: replace o.division in
-- the recursive member with  COALESCE(o.division, e.first_name)
-- (Why the CAST in the anchor? Without it the column would be too narrow:
--  Lesson 5.1, Common Mistake 3.)
WITH RECURSIVE org AS (
    SELECT id, first_name, 1 AS level, CAST(NULL AS CHAR(50)) AS division
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.id, e.first_name, o.level + 1, o.division
    FROM employees AS e
    JOIN org AS o ON e.manager_id = o.id
)
SELECT level, first_name, COALESCE(division, '(owner)') AS division
FROM org
ORDER BY division, level, first_name;

-- TODO 3 · People and payroll per division. Copy the CTE from TODO 2 (with
-- your fix, plus a salary column), then group in the MAIN query:
--   SELECT division, COUNT(*) AS people, SUM(salary) AS payroll
--   FROM org WHERE division IS NOT NULL GROUP BY division ORDER BY people DESC;
-- (Aggregates are not allowed inside the recursive member: error 3575.)
SELECT 'TODO 3: people and payroll per division' AS todo;

-- Expected when done:
-- TODO 1  twelve rows: copies 5, 5, 3, 3, 3, 2 for January to June, then 0
-- TODO 2  ten rows: Maria (owner); Daniel's division: Daniel, Marcus, Priya,
--         Ben, Lena, Sofia, Tom; James's division: James, Nina
-- TODO 3  Daniel 7 people 310500.00 · James 2 people 88500.00
