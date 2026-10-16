-- state: none
-- expect-error: 1062, 1364, 1366, 1406
-- =====================================================================
-- debug_rules.sql: four INSERTs that MySQL refuses (find-the-bug handout)
-- Session 1 · Lesson 1.1 · MySQL Foundations instructor kit
--
-- This file is broken ON PURPOSE. Four of the INSERT statements below break
-- one of the table's rules, and MySQL refuses each with a numbered error.
-- Run it (MySQL keeps going after each error when you SOURCE a file),
-- then for each ERROR line write in your workbook:
--   the error number · which rule was broken · the fixed statement.
-- Fix the four statements, run the file again: the last SELECT should then
-- show six books and no ERROR lines.
--
--   SOURCE labs/module-01/l1_1-what-is-a-database/debug_rules.sql
-- =====================================================================

DROP DATABASE IF EXISTS kit_s1_rules;
CREATE DATABASE kit_s1_rules;
USE kit_s1_rules;

CREATE TABLE books (
    id     INT PRIMARY KEY,
    title  VARCHAR(200) NOT NULL,
    isbn   VARCHAR(13),
    price  DECIMAL(8,2) NOT NULL
);

INSERT INTO books (id, title, isbn, price) VALUES (1, 'Dune', '9780441013593', 14.99);
INSERT INTO books (id, title, isbn, price) VALUES (2, '1984', '9780451524935', 9.99);

-- Bug A
INSERT INTO books (id, title, isbn, price) VALUES (2, 'Animal Farm', '9780451526342', 8.49);

-- Bug B
INSERT INTO books (id, isbn, price) VALUES (3, '9780547928227', 10.99);

-- Bug C
INSERT INTO books (id, title, isbn, price) VALUES (4, 'Brave New World', '9780060850524', 'cheap');

-- Bug D
INSERT INTO books (id, title, isbn, price) VALUES (5, 'Fahrenheit 451', '978-1-4516-7331-9', 10.49);

INSERT INTO books (id, title, isbn, price) VALUES (6, 'Pride and Prejudice', '9780141439518', 7.99);

SELECT * FROM books ORDER BY id;

DROP DATABASE kit_s1_rules;
