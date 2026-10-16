-- state: none
-- =====================================================================
-- events_build_starter.sql: a build script for the bookstore's events database
-- Session 2 · Lesson 2.1 · MySQL Foundations instructor kit
--
-- The bookstore runs author readings in two rooms, and the events team wants
-- a small database for them. You write the build script: a file that builds
-- the empty database from nothing, every time it runs.
--
-- Step 1 is written for you. For TODOs 1 and 2, write a CREATE TABLE below
-- the TODO (the skeleton is in the comment; remove the -- at the start of
-- each line and fill every ___). Save, run the file, read the self-check,
-- and run it a second time: a build script must work twice in a row.
--
--   SOURCE labs/module-02/l2_1-creating-databases-tables/events_build_starter.sql
--
-- The file drops kit_s2_events at the very end so the lab leaves nothing
-- behind (a real build script would keep it).
-- =====================================================================

-- 1 · A clean slate, with the character set and collation named
DROP DATABASE IF EXISTS kit_s2_events;
CREATE DATABASE kit_s2_events
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE kit_s2_events;

-- TODO 1 · The rooms table: an id MySQL numbers itself (the primary key);
-- a name of up to 50 characters that is required and never repeated; a
-- required whole number of seats.
-- CREATE TABLE rooms (
--     id     INT AUTO_INCREMENT PRIMARY KEY,
--     name   VARCHAR(___) NOT NULL ___,
--     seats  ___ NOT NULL
-- );

-- TODO 2 · The readings table, one row per author reading. Write it yourself:
--   id            numbered by MySQL, the primary key
--   author        text, up to 100 characters, required
--   book_title    text, up to 200 characters, required
--   room_id       a whole number, required (which room)
--   starts_at     a date AND a time, required
--   ticket_price  money with cents, up to 9999.99, 0.00 unless given
--   sold_out      true or false, false unless given
-- Remember: commas between the column lines, none after the last one.

-- TODO 3 · Make the script safe to grow: turn on the two lines below. What
-- does MySQL say, and did rooms change?
-- CREATE TABLE IF NOT EXISTS rooms (id INT AUTO_INCREMENT PRIMARY KEY);
-- SHOW WARNINGS;

-- Self-check (runs as it is): the tables, their collation, their column counts
SELECT TABLE_NAME, TABLE_COLLATION
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'kit_s2_events'
ORDER BY TABLE_NAME;

SELECT TABLE_NAME, COUNT(*) AS columns_count
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'kit_s2_events'
GROUP BY TABLE_NAME
ORDER BY TABLE_NAME;

-- Expected when done: see the README (TODO 3 prints Note 1050 Table 'rooms'
-- already exists; the self-check lists readings and rooms, both
-- utf8mb4_unicode_ci, with 7 and 3 columns).

DROP DATABASE kit_s2_events;
