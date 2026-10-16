-- state: none
-- =====================================================================
-- check_environment.sql: is this MySQL server ready for MySQL Foundations?
-- Session 1 · MySQL Foundations instructor kit
--
-- Run it at the mysql> prompt, from the folder that holds labs/:
--   SOURCE labs/module-01/l1_0-orientation/check_environment.sql
-- or let check_environment.sh (macOS, Linux) / check_environment.ps1 (Windows)
-- run it for you: they also check the mysql CLIENT first.
--
-- It only reads settings, and creates and drops one practice database
-- (kit_env_check) to prove you may create tables. Safe to run any time.
-- =====================================================================

-- 1. Which server answered?
SELECT VERSION() AS server_version, @@version_comment AS edition;

SELECT CASE
         WHEN VERSION() LIKE '%MariaDB%' THEN 'CHECK  MariaDB, not MySQL: most SQL works; read the version notes'
         WHEN VERSION() LIKE '9.7.%'     THEN 'OK     MySQL 9.7 LTS, the version the course uses'
         WHEN VERSION() LIKE '8.4.%'     THEN 'CHECK  MySQL 8.4 LTS: nearly everything matches; read the version notes'
         ELSE                                 'CHECK  not MySQL 9.7: some outputs will differ from the lessons'
       END AS server_check;

-- 2. Text, rules and your account
SELECT CASE WHEN @@character_set_server = 'utf8mb4'
            THEN 'OK     utf8mb4 (full Unicode)'
            ELSE CONCAT('CHECK  character set is ', @@character_set_server, ', not utf8mb4') END AS charset_check,
       CASE WHEN @@sql_mode LIKE '%STRICT_TRANS_TABLES%' AND @@sql_mode LIKE '%ONLY_FULL_GROUP_BY%'
            THEN 'OK     default strict SQL mode'
            ELSE 'CHECK  SQL mode differs from the MySQL default' END AS sql_mode_check;

SELECT CURRENT_USER() AS logged_in_as,
       (SELECT plugin FROM mysql.user
         WHERE CONCAT(user, '@', host) = CURRENT_USER()) AS login_plugin;

-- 3. May this account create a database and a table? (created, used, dropped)
DROP DATABASE IF EXISTS kit_env_check;
CREATE DATABASE kit_env_check;
CREATE TABLE kit_env_check.probe (id INT PRIMARY KEY, note VARCHAR(20));
INSERT INTO kit_env_check.probe VALUES (1, 'it works');
SELECT CONCAT('OK     created a database and a table, and read back: ', note) AS write_check
FROM kit_env_check.probe;
DROP DATABASE kit_env_check;

-- 4. The course database (created in Lesson 2.1, Session 2; reloaded from bookstore.sql from Lesson 4.2 on)
SELECT CASE COUNT(*)
         WHEN 0 THEN 'INFO   no bookstore database yet: Lesson 2.1 creates it'
         WHEN 8 THEN 'OK     bookstore has its 8 tables (the full course database)'
         ELSE CONCAT('INFO   bookstore has ', COUNT(*), ' tables (a lesson in progress)')
       END AS bookstore_check
FROM information_schema.tables
WHERE table_schema = 'bookstore';

-- 5. Verdict
SELECT CASE
         WHEN VERSION() LIKE '9.7.%' AND @@character_set_server = 'utf8mb4'
           THEN 'READY for MySQL Foundations'
         WHEN @@character_set_server = 'utf8mb4'
           THEN 'READY WITH NOTES: not MySQL 9.7, read the CHECK lines above'
         ELSE 'NOT READY: fix the CHECK lines above, then run this again'
       END AS verdict;
