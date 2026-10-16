-- state: none
-- =====================================================================
-- system_tour_solution.sql: ask information_schema about the server
-- Session 2 · Lesson 1.3 · MySQL Foundations instructor kit · instructor reference
--
-- Read-only: every answer comes from information_schema ("data about data")
-- or a SHOW statement with FROM, so the file never needs USE and changes
-- nothing. The counts are MySQL 9.7's; 8.4 and MariaDB differ a little.
-- =====================================================================

-- 1 · How many columns does the mysql.user table have?
SELECT COUNT(*) AS user_columns
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'mysql' AND TABLE_NAME = 'user';

-- 2 · How many of them are privilege flags (names ending in _priv)?
SELECT COUNT(*) AS priv_columns
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'mysql' AND TABLE_NAME = 'user'
  AND COLUMN_NAME LIKE '%\_priv';

-- 3 · The types of four columns of mysql.user, in table order
SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'mysql' AND TABLE_NAME = 'user'
  AND COLUMN_NAME IN ('Host', 'User', 'plugin', 'password_last_changed')
ORDER BY ORDINAL_POSITION;

-- 4 · The tables that hold the built-in HELP texts, and about how many rows each has
SELECT TABLE_NAME, TABLE_ROWS
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'mysql' AND TABLE_NAME LIKE 'help%'
ORDER BY TABLE_NAME;

-- 5 · The information_schema tables whose name starts with COLUMN
SHOW TABLES FROM information_schema LIKE 'COLUMN%';
