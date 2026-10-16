-- state: none
-- expect-error: 1007, 1046, 1064, 1050, 1146
-- =====================================================================
-- debug_build_script.sql: a coworker's build script that fails five times
-- Session 2 · Lesson 2.1 · MySQL Foundations instructor kit
--
-- This file is broken ON PURPOSE. It should build kit_s2_shelf with one
-- table, shelves, and describe it. Five statements fail. Run it (SOURCE
-- keeps going after each error), then for each ERROR line write in your
-- workbook: the error number · what went wrong · the fix. Fix the file and
-- run it again: no ERROR lines, and DESCRIBE shows four columns.
--
--   SOURCE labs/module-02/l2_1-creating-databases-tables/debug_build_script.sql
-- =====================================================================

DROP DATABASE IF EXISTS kit_s2_shelf;
CREATE DATABASE kit_s2_shelf CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Bug A: "make sure the database is there"
CREATE DATABASE kit_s2_shelf;

-- A scratch database for a quick test, then gone again
CREATE DATABASE kit_s2_scratch;
USE kit_s2_scratch;
DROP DATABASE kit_s2_scratch;

-- Bug B
CREATE TABLE shelves (
    id INT AUTO_INCREMENT PRIMARY KEY
);

USE kit_s2_shelf;

-- Bug C
CREATE TABLE shelves (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    label     VARCHAR(20) NOT NULL UNIQUE,
    genre     VARCHAR(50),
    capacity  INT NOT NULL,
);

CREATE TABLE shelves (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    label     VARCHAR(20) NOT NULL UNIQUE,
    genre     VARCHAR(50),
    capacity  INT NOT NULL
);

-- Bug D: the script is run a second time from here
CREATE TABLE shelves (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    label     VARCHAR(20) NOT NULL UNIQUE,
    genre     VARCHAR(50),
    capacity  INT NOT NULL
);

-- Bug E
DESCRIBE shelf;

DROP DATABASE kit_s2_shelf;
