-- state: full
-- =====================================================================
-- check_environment.sql: is this server ready for Part 2 (Sessions 8-14)?
-- Session 8 · Part 2 start · MySQL Foundations instructor kit
--
-- Part 2 starts from the FULL course database: load it first, from the
-- folder where you saved bookstore.sql (the course download):
--   SOURCE bookstore.sql
-- then run this check at the mysql> prompt, from the folder that holds labs/:
--   SOURCE labs/module-08/l5_0-part2-start/check_environment.sql
-- or let check_environment.sh (macOS, Linux) / check_environment.ps1
-- (Windows) run it for you: they also check the mysql CLIENT first.
--
-- It only reads, and creates and drops one practice database
-- (kit_env_check) to prove you may create tables. Safe to run any time.
-- Unlike Session 1's check, the bookstore is REQUIRED here: 8 tables,
-- with the row counts of a fresh bookstore.sql.
-- =====================================================================

-- 1. Which server answered?
SELECT VERSION() AS server_version, @@version_comment AS edition;

SELECT CASE
         WHEN VERSION() LIKE '%MariaDB%' THEN 'CHECK  MariaDB, not MySQL: read the version notes in Lessons 5.1 to 7.4'
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

-- 3. May this account create a database and a table? (created, used, dropped)
DROP DATABASE IF EXISTS kit_env_check;
CREATE DATABASE kit_env_check;
CREATE TABLE kit_env_check.probe (id INT PRIMARY KEY, note VARCHAR(20));
INSERT INTO kit_env_check.probe VALUES (1, 'it works');
SELECT CONCAT('OK     created a database and a table, and read back: ', note) AS write_check
FROM kit_env_check.probe;
DROP DATABASE kit_env_check;

-- 4. The course database: REQUIRED from Session 8 on (8 tables, fresh row counts)
SELECT CASE COUNT(*)
         WHEN 8 THEN 'OK     bookstore has its 8 tables'
         WHEN 0 THEN 'NOT READY  no bookstore database: SOURCE bookstore.sql first'
         ELSE CONCAT('NOT READY  bookstore has ', COUNT(*), ' tables: reload it with SOURCE bookstore.sql')
       END AS bookstore_check
FROM information_schema.tables
WHERE table_schema = 'bookstore' AND table_type = 'BASE TABLE';

SELECT CONCAT(
         IF((SELECT COUNT(*) FROM bookstore.books) = 11
            AND (SELECT COUNT(*) FROM bookstore.customers) = 8
            AND (SELECT COUNT(*) FROM bookstore.orders) = 12
            AND (SELECT COUNT(*) FROM bookstore.order_items) = 18
            AND (SELECT COUNT(*) FROM bookstore.employees) = 10,
            'OK     fresh row counts: ', 'CHECK  not a fresh copy (reload bookstore.sql): '),
         (SELECT COUNT(*) FROM bookstore.books), ' books, ',
         (SELECT COUNT(*) FROM bookstore.customers), ' customers, ',
         (SELECT COUNT(*) FROM bookstore.orders), ' orders, ',
         (SELECT COUNT(*) FROM bookstore.employees), ' employees') AS data_check;

-- 5. Verdict
SELECT CASE
         WHEN (SELECT COUNT(*) FROM information_schema.tables
                WHERE table_schema = 'bookstore' AND table_type = 'BASE TABLE') <> 8
           THEN 'NOT READY: load bookstore.sql, then run this again'
         WHEN VERSION() LIKE '9.7.%' AND @@character_set_server = 'utf8mb4'
           THEN 'READY for Part 2'
         WHEN @@character_set_server = 'utf8mb4'
           THEN 'READY WITH NOTES: not MySQL 9.7, read the CHECK lines above'
         ELSE 'NOT READY: fix the CHECK lines above, then run this again'
       END AS verdict;
