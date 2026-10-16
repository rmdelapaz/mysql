-- state: none
-- =====================================================================
-- system_tour_starter.sql: ask information_schema about the server
-- Session 2 · Lesson 1.3 · MySQL Foundations instructor kit
--
-- information_schema holds "data about data": one row per database, table
-- and column on the server. Here you ask it five questions about the mysql
-- system database. Read-only: nothing is created or changed, and you never
-- need USE. Questions 1 and 3 are written for you; for the others, change
-- the placeholder as the TODO says, save, and run the file again.
--
--   SOURCE labs/module-02/l1_3-mysql-cli-phpmyadmin/system_tour_starter.sql
-- =====================================================================

-- 1 · How many columns does the mysql.user table have?
SELECT COUNT(*) AS user_columns
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'mysql' AND TABLE_NAME = 'user';

-- TODO 2 · How many of them are privilege flags (names ending in _priv)?
-- Copy query 1 and add one more condition to its WHERE:
--   AND COLUMN_NAME LIKE '%\_priv'      (\_ is a real underscore)
SELECT 'TODO 2: count the _priv columns of mysql.user' AS todo;

-- 3 · The types of four columns of mysql.user, in table order
SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'mysql' AND TABLE_NAME = 'user'
  AND COLUMN_NAME IN ('Host', 'User', 'plugin', 'nobody_yet')
ORDER BY ORDINAL_POSITION;
-- TODO 3 · Replace 'nobody_yet' with 'password_last_changed'. What type is it?

-- TODO 4 · The tables of the mysql database whose name starts with help, with
-- about how many rows each holds. Change 'TODO%' to the right pattern.
SELECT TABLE_NAME, TABLE_ROWS
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'mysql' AND TABLE_NAME LIKE 'TODO%'
ORDER BY TABLE_NAME;

-- TODO 5 · The tables of information_schema whose name starts with COLUMN,
-- with a SHOW statement (SHOW TABLES FROM ... LIKE ...).
SELECT 'TODO 5: SHOW the COLUMN... tables of information_schema' AS todo;

-- Expected when done (MySQL 9.7): 1) 51 columns; 2) 31 privilege columns;
-- 3) Host char(255), User char(32), plugin char(64), password_last_changed
-- timestamp (the only one of the four with IS_NULLABLE YES); 4) help_category,
-- help_keyword, help_relation, help_topic (row counts are estimates, about 53,
-- 922, 2265 and 706); 5) COLUMNS, COLUMNS_EXTENSIONS, COLUMN_PRIVILEGES,
-- COLUMN_STATISTICS.
