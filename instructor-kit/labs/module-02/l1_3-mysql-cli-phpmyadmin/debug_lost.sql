-- state: none
-- expect-error: 1049, 1146, 1064
-- =====================================================================
-- debug_lost.sql: four statements that go wrong at the prompt (find-the-bug handout)
-- Session 2 · Lesson 1.3 · MySQL Foundations instructor kit
--
-- This file is broken ON PURPOSE. Four statements below fail. Run it (SOURCE
-- keeps going after each error), then for each ERROR line write in your
-- workbook: the error number · what MySQL is telling you · the fix.
-- Fix the file and run it again: no ERROR lines, and the last query shows
-- the four accounts of a fresh server.
--
--   SOURCE labs/module-02/l1_3-mysql-cli-phpmyadmin/debug_lost.sql
--
-- Read-only, but it leaves your session inside the mysql database: type
-- USE with the database you want afterward.
-- =====================================================================

-- Bug A: go to the system database that holds the accounts
USE mysq;

USE mysql;

-- Bug B: the accounts table
SELECT User, Host FROM users;

-- Bug C: today's date with a friendly column name
SELECT CURDATE() AS current_date;

-- Bug D: two questions, one after the other
SELECT VERSION() AS version
SELECT CURRENT_USER() AS account;

-- This one is fine
SELECT User, Host FROM user ORDER BY User, Host;
