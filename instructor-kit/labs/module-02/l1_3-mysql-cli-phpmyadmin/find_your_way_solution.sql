-- state: none
-- =====================================================================
-- find_your_way_solution.sql: explore a database you have never seen
-- Session 2 · Lesson 1.3 · MySQL Foundations instructor kit · instructor reference
--
-- The setup part builds kit_s2_cafe, the bookstore cafe's small database,
-- the way a coworker might leave it for you. The six answers use only the
-- exploring statements of Lesson 1.3. Drops kit_s2_cafe at the end.
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

-- 1 · Which tables are in this database?
SHOW TABLES;

-- 2 · What does menu_items look like? (primary key? required columns?)
DESCRIBE menu_items;

-- 3 · Only the columns of cafe_orders whose name ends in _at
SHOW COLUMNS FROM cafe_orders LIKE '%\_at';

-- 4 · Without leaving the cafe: the mysql tables whose name starts with time_zone
SHOW TABLES FROM mysql LIKE 'time_zone%';

-- 5 · One menu item, shown vertically
SELECT * FROM menu_items WHERE id = 3\G

-- 6 · The full definition of staff_notes, vertically
SHOW CREATE TABLE staff_notes\G

DROP DATABASE kit_s2_cafe;
