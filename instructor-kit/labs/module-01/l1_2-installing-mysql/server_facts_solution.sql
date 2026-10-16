-- state: none
-- =====================================================================
-- server_facts_solution.sql: ask your server who it is and how it is set up
-- Session 1 · Lesson 1.2 · MySQL Foundations instructor kit · instructor reference
--
-- Read-only: every statement reads a setting; nothing is created or changed.
-- The @@ names are server settings ("system variables").
-- =====================================================================

-- 1 · Which product and version answered?
SELECT VERSION() AS version, @@version_comment AS edition;

-- 2 · Is it the course's version, or a relative? (1 = yes, 0 = no)
SELECT VERSION() LIKE '9.7.%'      AS is_mysql_97,
       VERSION() LIKE '%MariaDB%'  AS is_mariadb;

-- 3 · Text: the character set and the sorting rules (collation) for new databases
SELECT @@character_set_server AS charset, @@collation_server AS collation;

-- 4 · Where the tables live, and how names are compared
--     (storage engine; lower_case_table_names: 0 on Linux, 1 on Windows, 2 on macOS)
SELECT @@default_storage_engine AS engine, @@lower_case_table_names AS lower_case_names;

-- 5 · How many people can connect at once (default 151)
SELECT @@max_connections AS max_connections;

-- 6 · The four system databases every server has
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('mysql', 'information_schema', 'performance_schema', 'sys')
ORDER BY schema_name;
