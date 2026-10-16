-- state: none
-- =====================================================================
-- find_your_way_starter.sql: explore a database you have never seen
-- Session 2 · Lesson 1.3 · MySQL Foundations instructor kit
--
-- A coworker built kit_s2_cafe, the bookstore cafe's small database, and
-- left. Do not read the setup part: find your way around with the exploring
-- statements of Lesson 1.3 instead. Each TODO is a placeholder SELECT that
-- prints a reminder: replace it with the statement that answers the
-- question, save, and run the file again. Write each answer in your
-- workbook.
--
-- How to run it: open a terminal in the folder that holds labs/, log in
-- with  mysql -u root -p  and type
--   SOURCE labs/module-02/l1_3-mysql-cli-phpmyadmin/find_your_way_starter.sql
-- Every run rebuilds kit_s2_cafe and drops it at the end.
-- =====================================================================

-- ---------- setup: a coworker's database (do not edit) ----------
DROP DATABASE IF EXISTS kit_s2_cafe;
CREATE DATABASE kit_s2_cafe CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE TABLE kit_s2_cafe.menu_items (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    name      VARCHAR(60)  NOT NULL UNIQUE,
    price     DECIMAL(5,2) NOT NULL,
    vegan     BOOLEAN      DEFAULT FALSE,
    added_on  DATE
);
CREATE TABLE kit_s2_cafe.cafe_orders (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    item_id    INT NOT NULL,
    quantity   INT NOT NULL DEFAULT 1,
    ordered_at DATETIME NOT NULL,
    paid_at    DATETIME
);
CREATE TABLE kit_s2_cafe.staff_notes (
    id    INT AUTO_INCREMENT PRIMARY KEY,
    note  VARCHAR(200) NOT NULL
);
INSERT INTO kit_s2_cafe.menu_items (name, price, vegan, added_on) VALUES
    ('Espresso', 2.50, TRUE, '2026-01-05'),
    ('Blueberry Muffin', 3.25, FALSE, '2026-01-05'),
    ('Oat Latte', 4.10, TRUE, '2026-02-14');
USE kit_s2_cafe;
-- ---------- end of setup ----------

-- 0 · Where am I?
SELECT DATABASE() AS current_db;

-- TODO 1 · Which tables are in this database?
SELECT 'TODO 1: list the tables of the current database' AS todo;

-- TODO 2 · What does menu_items look like? Which column is the primary key?
-- Which columns are required (Null = NO)?
SELECT 'TODO 2: show the columns of menu_items' AS todo;

-- TODO 3 · Only the columns of cafe_orders whose name ends in _at.
-- Hint: SHOW COLUMNS FROM ... LIKE '...'  (write \_ for a real underscore)
SELECT 'TODO 3: the _at columns of cafe_orders' AS todo;

-- TODO 4 · Without leaving the cafe: the tables of the mysql database whose
-- name starts with time_zone.
SELECT 'TODO 4: the time_zone tables of mysql' AS todo;

-- TODO 5 · Menu item 3, every column on its own line.
-- Hint: end the query with \G instead of a semicolon.
SELECT 'TODO 5: menu item 3, vertically' AS todo;

-- TODO 6 · The full CREATE TABLE statement of staff_notes, vertically.
SELECT 'TODO 6: the definition of staff_notes' AS todo;

-- Expected when done: see the README (current_db kit_s2_cafe; three tables
-- cafe_orders, menu_items, staff_notes; id is the primary key of menu_items
-- and name, price are required; ordered_at and paid_at; five time_zone
-- tables; Oat Latte 4.10 vegan 1; staff_notes with ENGINE=InnoDB).

DROP DATABASE kit_s2_cafe;
