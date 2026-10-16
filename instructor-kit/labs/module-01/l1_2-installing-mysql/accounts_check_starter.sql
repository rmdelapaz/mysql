-- state: none
-- =====================================================================
-- accounts_check_starter.sql: who may log in to your server, and how?
-- Session 1 · Lesson 1.2 · MySQL Foundations instructor kit
--
-- Read-only. Accounts live in the mysql.user system table: look, never edit
-- it by hand. Run the file once, then do the TODOs and run it again.
--
--   SOURCE labs/module-01/l1_2-installing-mysql/accounts_check_starter.sql
-- =====================================================================

-- 1 · Who am I? USER() is the name you typed; CURRENT_USER() is the account MySQL matched
SELECT USER() AS you_typed, CURRENT_USER() AS matched_account;

-- TODO 2 · Add the columns plugin and account_locked to this list, separated by commas.
SELECT user, host
FROM mysql.user
ORDER BY user, host;

-- TODO 3 · Show only the built-in helper accounts (their names start with mysql.).
-- Replace 'nobody' with  'mysql.%'  (keep the quotes and the % sign).
SELECT user, account_locked
FROM mysql.user
WHERE user LIKE 'nobody'
ORDER BY user;

-- TODO 4 · Does any account use the old login method from forum advice?
-- Replace 'some_plugin' with 'mysql_native_password'. Is an empty answer good news?
SELECT user, host
FROM mysql.user
WHERE plugin = 'some_plugin';

-- Expected when done (a native install; Docker adds root with host %):
-- TODO 2: root@localhost uses caching_sha2_password and is not locked (N);
-- TODO 3: mysql.infoschema, mysql.session and mysql.sys, all locked (Y);
-- TODO 4: Empty set. That is good news: no account uses the removed method.
