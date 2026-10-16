-- state: none
-- =====================================================================
-- server_facts_starter.sql: ask your server who it is and how it is set up
-- Session 1 · Lesson 1.2 · MySQL Foundations instructor kit
--
-- Read-only: nothing is created or changed. Run it once as it is; it shows
-- the version and four TODO lines. Then do the TODOs (each one replaces a
-- placeholder SELECT with a real one; the hints name the settings) and run
-- it again. Copy the answers into the health-check page of your journal.
--
-- How to run it: open a terminal in the folder that holds labs/, log in
-- with  mysql -u root -p  and type
--   SOURCE labs/module-01/l1_2-installing-mysql/server_facts_starter.sql
-- =====================================================================

-- 1 · Which product and version answered?
SELECT VERSION() AS version, @@version_comment AS edition;

-- 2 · Is it the course's version, or a relative? (1 = yes, 0 = no)
SELECT VERSION() LIKE '9.7.%'      AS is_mysql_97,
       VERSION() LIKE '%MariaDB%'  AS is_mariadb;

-- TODO 3 · The character set and collation for new databases.
-- Replace this line with:  SELECT @@character_set_server AS charset, @@collation_server AS collation;
SELECT 'TODO 3: character set and collation' AS todo;

-- TODO 4 · The default storage engine (@@default_storage_engine) and how table
-- names are compared (@@lower_case_table_names). Write the SELECT yourself,
-- one alias per column, like TODO 3.
SELECT 'TODO 4: storage engine and lower_case_table_names' AS todo;

-- TODO 5 · How many connections may be open at once? (@@max_connections)
SELECT 'TODO 5: max_connections' AS todo;

-- TODO 6 · List the four system databases. Fill in the missing name
-- (the one that holds MySQL's helper views; Lesson 1.2, "Connect and Verify").
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('mysql', 'information_schema', 'performance_schema', '___')
ORDER BY schema_name;

-- Expected when done (MySQL 9.7 on Linux): is_mysql_97 1, is_mariadb 0; utf8mb4 and
-- utf8mb4_0900_ai_ci; InnoDB and 0 (Windows shows 1, macOS 2); 151; four rows:
-- information_schema, mysql, performance_schema, sys. Your version can be any 9.7.x.
