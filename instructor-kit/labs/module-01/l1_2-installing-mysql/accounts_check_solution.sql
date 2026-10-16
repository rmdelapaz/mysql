-- state: none
-- =====================================================================
-- accounts_check_solution.sql: who may log in to your server, and how?
-- Session 1 · Lesson 1.2 · MySQL Foundations instructor kit · instructor reference
--
-- Read-only. Accounts live in the mysql.user system table: look, never edit
-- it by hand (Lesson 7.4 shows CREATE USER and GRANT).
-- =====================================================================

-- 1 · Who am I? USER() is the name you typed; CURRENT_USER() is the account MySQL matched
SELECT USER() AS you_typed, CURRENT_USER() AS matched_account;

-- 2 · Every account, how it logs in, and whether it is locked
SELECT user, host, plugin, account_locked
FROM mysql.user
ORDER BY user, host;

-- 3 · The built-in helper accounts are locked: nobody can log in as them
SELECT user, account_locked
FROM mysql.user
WHERE user LIKE 'mysql.%'
ORDER BY user;

-- 4 · The old login method from forum advice: does any account use it?
SELECT user, host
FROM mysql.user
WHERE plugin = 'mysql_native_password';
