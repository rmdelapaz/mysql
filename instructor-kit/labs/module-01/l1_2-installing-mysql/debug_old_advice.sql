-- state: none
-- expect-error: 1524, 1193
-- =====================================================================
-- debug_old_advice.sql: two pieces of old forum advice, tried on MySQL 9.7
-- Session 1 · Lesson 1.2 · MySQL Foundations instructor kit (find-the-bug handout)
--
-- Both "fixes" below come from tutorials written for MySQL 5.7 and 8.0.
-- Run the file and read each ERROR line. For each one, write in your
-- workbook: the error number, what it means, and the modern replacement.
-- (The replacements are in the comments at the bottom: cover them first.)
-- Nothing here changes your server: both statements fail.
--
--   SOURCE labs/module-01/l1_2-installing-mysql/debug_old_advice.sql
-- =====================================================================

-- Advice 1: "if your app can't log in, create its user with the native plugin"
CREATE USER 'legacy_app'@'localhost'
    IDENTIFIED WITH mysql_native_password BY 'placeholder-password';

-- Advice 2: "check which login method new accounts get"
SELECT @@default_authentication_plugin;

-- This one works: what really happened to Advice 1? (no row = no account was created)
SELECT user, host FROM mysql.user WHERE user = 'legacy_app';

-- Modern replacements (cover these before you start):
--   1. Leave out IDENTIFIED WITH ...: CREATE USER 'legacy_app'@'localhost' IDENTIFIED BY '...';
--      gives caching_sha2_password, which current clients, PHP and phpMyAdmin 5.2 support.
--      (Lesson 7.4 creates real accounts. Do not run it now: the course does that later.)
--   2. The setting is now @@authentication_policy:  SELECT @@authentication_policy;
