-- state: none
-- =====================================================================
-- events_build_solution.sql: a build script for the bookstore's events database
-- Session 2 · Lesson 2.1 · MySQL Foundations instructor kit · instructor reference
--
-- The bookstore runs author readings in two rooms. This script builds an
-- empty kit_s2_events database for them, from nothing, every time it runs,
-- and ends with a self-check. Drops kit_s2_events at the very end so the lab
-- leaves nothing behind (in a real build script you would keep it).
-- =====================================================================

-- 1 · A clean slate, with the character set and collation named
DROP DATABASE IF EXISTS kit_s2_events;
CREATE DATABASE kit_s2_events
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE kit_s2_events;

-- 2 · The rooms: a name nobody may repeat, and how many seats
CREATE TABLE rooms (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    name   VARCHAR(50) NOT NULL UNIQUE,
    seats  INT NOT NULL
);

-- 3 · The readings: which author, when, in which room, and the ticket price
CREATE TABLE readings (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    author        VARCHAR(100) NOT NULL,
    book_title    VARCHAR(200) NOT NULL,
    room_id       INT NOT NULL,
    starts_at     DATETIME NOT NULL,
    ticket_price  DECIMAL(6, 2) DEFAULT 0.00,
    sold_out      BOOLEAN DEFAULT FALSE
);

-- 4 · Running it twice must not fail: IF NOT EXISTS skips an existing table
CREATE TABLE IF NOT EXISTS rooms (
    id INT AUTO_INCREMENT PRIMARY KEY
);
SHOW WARNINGS;

-- 5 · Self-check: two tables, both utf8mb4_unicode_ci, and their column counts
SELECT TABLE_NAME, TABLE_COLLATION
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'kit_s2_events'
ORDER BY TABLE_NAME;

SELECT TABLE_NAME, COUNT(*) AS columns_count
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'kit_s2_events'
GROUP BY TABLE_NAME
ORDER BY TABLE_NAME;

DESCRIBE readings;

DROP DATABASE kit_s2_events;
