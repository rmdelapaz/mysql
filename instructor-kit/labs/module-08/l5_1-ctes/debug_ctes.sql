-- state: full
-- expect-error: 1146, 3636, 1406
-- =====================================================================
-- debug_ctes.sql: three broken CTEs (deliberately broken handout)
-- Session 8 · Lesson 5.1 · MySQL Foundations instructor kit
--
-- Each query below fails with a different error. Run the file, read each
-- ERROR line from the left (number, then reason), and write in your
-- workbook: what is wrong, and the one-word or one-line fix. Nothing here
-- changes data. Then fix all three and run it again: no ERROR lines left.
-- =====================================================================

-- A. A countdown from 3 to 1
WITH countdown AS (
    SELECT 3 AS n
    UNION ALL
    SELECT n - 1 FROM countdown WHERE n > 1
)
SELECT n FROM countdown;

-- B. Every day of 2026, counted
WITH RECURSIVE days AS (
    SELECT DATE('2026-01-01') AS d
    UNION ALL
    SELECT d + INTERVAL 1 DAY FROM days
)
SELECT COUNT(*) AS days_in_2026 FROM days;

-- C. A path of names down from the owner
WITH RECURSIVE org AS (
    SELECT id, 'Maria' AS path
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.id, CONCAT(o.path, ' > ', e.first_name)
    FROM employees AS e
    JOIN org AS o ON e.manager_id = o.id
)
SELECT path FROM org ORDER BY path;
