-- state: full
-- =====================================================================
-- staff_tree_solution.sql: series and hierarchies (reference solution)
-- Session 8 · Lesson 5.1 · MySQL Foundations instructor kit
--
-- A recursive CTE makes the twelve months of the year out of thin air,
-- then walks the staff tree and carries each person's division head
-- (the level-2 manager they work under) down to every level.
-- =====================================================================

-- 1. Every month of 2026, with the copies sold in it (zero when nothing sold)
WITH RECURSIVE months AS (
    SELECT 1 AS month_num
    UNION ALL
    SELECT month_num + 1 FROM months WHERE month_num < 12
)
SELECT m.month_num, COALESCE(SUM(oi.quantity), 0) AS copies
FROM months AS m
LEFT JOIN orders      AS o  ON MONTH(o.order_date) = m.month_num
LEFT JOIN order_items AS oi ON oi.order_id = o.id
GROUP BY m.month_num
ORDER BY m.month_num;

-- 2. Level and division for everyone: level-2 people start a division,
--    everyone below inherits it (the anchor's CAST makes the column wide enough)
WITH RECURSIVE org AS (
    SELECT id, first_name, 1 AS level, CAST(NULL AS CHAR(50)) AS division
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.id, e.first_name, o.level + 1, COALESCE(o.division, e.first_name)
    FROM employees AS e
    JOIN org AS o ON e.manager_id = o.id
)
SELECT level, first_name, COALESCE(division, '(owner)') AS division
FROM org
ORDER BY division, level, first_name;

-- 3. The same walk, aggregated in the main query: people and payroll per division
WITH RECURSIVE org AS (
    SELECT id, salary, CAST(NULL AS CHAR(50)) AS division
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.id, e.salary, COALESCE(o.division, e.first_name)
    FROM employees AS e
    JOIN org AS o ON e.manager_id = o.id
)
SELECT division, COUNT(*) AS people, SUM(salary) AS payroll
FROM org
WHERE division IS NOT NULL
GROUP BY division
ORDER BY people DESC;
