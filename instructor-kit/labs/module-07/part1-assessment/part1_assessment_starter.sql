-- state: none
-- =====================================================================
-- part1_assessment_starter.sql: Part 1 assessment, the Riverside Cooking School
-- Part 1 assessment · Session 7 · MySQL Foundations instructor kit
--
-- 60 minutes, open book: the lesson pages, your notes and your own scripts
-- are allowed; other people and AI assistants are not.
--
-- The Riverside Cooking School (fictional) runs cooking classes. The file
-- builds its database, kit_riverside, with three tables: instructors,
-- classes and students. You:
--   Part A (about 20 min): build the enrollments table, load it, change
--          data safely.
--   Part B (about 35 min): answer eight questions, one query each.
--   Last 5 min: SOURCE the whole file once more; fix anything that fails.
-- Write every answer in THIS file, below its TODO. Replace each placeholder
-- line (SELECT 'TODO ...') with your query. Turn on the given statements
-- by removing the -- at the start of their lines.
--
-- How to run it (from the folder that holds labs/):
--   SOURCE labs/module-07/part1-assessment/part1_assessment_starter.sql
-- Every run rebuilds kit_riverside from scratch, so run it as often as you
-- like. It drops the database at the end; while you explore at the prompt,
-- you may put -- in front of the last line to keep it.
--
-- Hand in: this file, renamed part1_assessment_<yourname>.sql. It must run
-- from start to finish with SOURCE and print your answers.
-- =====================================================================

-- ---------------------------------------------------------------- given (do not change)
DROP DATABASE IF EXISTS kit_riverside;
CREATE DATABASE kit_riverside;
USE kit_riverside;

CREATE TABLE instructors (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    name      VARCHAR(100) NOT NULL,
    specialty VARCHAR(50)
);
INSERT INTO instructors (id, name, specialty) VALUES
    (1, 'Marco Rossi',   'Italian'),
    (2, 'Aiko Tanaka',   'Japanese'),
    (3, 'Lena Fischer',  'Baking'),
    (4, 'Diego Morales', 'Mexican'),
    (5, 'Nadia Haddad',  'Middle Eastern');

CREATE TABLE classes (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    title         VARCHAR(100) NOT NULL,
    cuisine       VARCHAR(50)  NOT NULL,
    instructor_id INT NOT NULL,
    class_date    DATE NOT NULL,
    price         DECIMAL(6, 2) NOT NULL,
    capacity      INT NOT NULL,
    CONSTRAINT fk_classes_instructor
        FOREIGN KEY (instructor_id) REFERENCES instructors(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);
INSERT INTO classes (id, title, cuisine, instructor_id, class_date, price, capacity) VALUES
    (1, 'Fresh Pasta by Hand', 'Italian',  1, '2026-03-07', 65.00, 10),
    (2, 'Risotto Nights',      'Italian',  1, '2026-04-11', 55.00,  8),
    (3, 'Sushi Basics',        'Japanese', 2, '2026-03-14', 70.00,  8),
    (4, 'Ramen from Scratch',  'Japanese', 2, '2026-04-18', 60.00, 10),
    (5, 'Sourdough Starter',   'Baking',   3, '2026-03-21', 45.00, 12),
    (6, 'French Pastry',       'Baking',   3, '2026-05-02', 75.00,  6),
    (7, 'Tacos and Salsas',    'Mexican',  4, '2026-03-28', 50.00, 12),
    (8, 'Mole Masterclass',    'Mexican',  4, '2026-05-16', 80.00,  6);

CREATE TABLE students (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50)  NOT NULL,
    last_name  VARCHAR(50)  NOT NULL,
    email      VARCHAR(100) NOT NULL UNIQUE,
    city       VARCHAR(50)
);
INSERT INTO students (id, first_name, last_name, email, city) VALUES
    (1, 'Ana',   'Lopez',  'ana.lopez@example.com',   'Springfield'),
    (2, 'Ben',   'Okoro',  'ben.okoro@example.com',   'Riverside'),
    (3, 'Chloe', 'Martin', 'chloe.martin@example.com', 'Riverside'),
    (4, 'Dev',   'Patel',  'dev.patel@example.com',   NULL),
    (5, 'Emma',  'Novak',  'emma.novak@example.com',  'Springfield'),
    (6, 'Felix', 'Grant',  'felix.grant@example.com', 'Lakeview'),
    (7, 'Gina',  'Russo',  'gina.russo@example.com',  NULL),
    (8, 'Hugo',  'Weber',  'hugo.weber@example.com',  'Lakeview');

-- ---------------------------------------------------------------- Part A · Build

-- TODO A1 · Create the enrollments table: one row per student per class.
--   Columns: student_id, class_id, enrolled_on (a date, required),
--   rating (a whole number from 1 to 5, or NULL until the student rates).
--   Rules: a student can enroll in a class only once; every student_id must
--   be a real student and every class_id a real class (named keys);
--   a rating outside 1 to 5 must be refused.
--   For each foreign key choose ON DELETE (and ON UPDATE) and write ONE
--   sentence here saying why:
--     enrollments -> students: ______________________________________
--     enrollments -> classes:  ______________________________________
-- CREATE TABLE enrollments (
--     ...
-- );

-- TODO A2 · Load the enrollments. Turn this INSERT on (remove the -- from
-- its lines) once your table exists, then check the counts below.
-- INSERT INTO enrollments (student_id, class_id, enrolled_on, rating) VALUES
--     (1, 1, '2026-02-20', 5), (1, 3, '2026-03-01', 4), (1, 5, '2026-03-10', NULL),
--     (2, 1, '2026-02-25', 4), (2, 4, '2026-04-02', 5),
--     (3, 3, '2026-03-05', 3), (3, 5, '2026-03-12', 5), (3, 6, '2026-04-20', NULL),
--     (4, 2, '2026-03-30', 4), (4, 7, '2026-03-15', 2),
--     (5, 1, '2026-03-01', NULL), (5, 6, '2026-04-22', 5), (5, 7, '2026-03-20', 4),
--     (6, 4, '2026-04-05', 3), (6, 2, '2026-04-01', 5);
-- SELECT COUNT(*) AS enrollments, COUNT(rating) AS rated FROM enrollments;

-- TODO A3a · Your table must refuse these two statements. Run each ONCE at
-- the mysql> prompt (not in this file), with kit_riverside kept, and write
-- the error number and what it means:
--     INSERT INTO enrollments VALUES (9, 2, '2026-04-03', NULL);
--       -> ERROR ______: ________________________________________________
--     INSERT INTO enrollments VALUES (8, 2, '2026-04-03', 6);
--       -> ERROR ______: ________________________________________________

-- TODO A3b · Every Italian class costs 5.00 more from now on. One UPDATE.
SELECT 'TODO A3b: raise the Italian prices' AS todo;

-- TODO A3c · Mole Masterclass (class 8) was cancelled before anyone
-- enrolled. Delete it. Then show every class's id, title and price, by id.
SELECT 'TODO A3c: delete class 8, then list the classes' AS todo;

-- ---------------------------------------------------------------- Part B · Query
-- Part B runs on the data AFTER Part A. Every query that returns several
-- rows has an ORDER BY. No number that the database can compute is typed by hand.

-- TODO B1 · Classes in March 2026 that cost under $70: title, class_date,
-- price, cheapest first.
SELECT 'TODO B1' AS todo;

-- TODO B2 · Per cuisine: the number of classes and the average price
-- rounded to cents; highest average first, ties by cuisine.
SELECT 'TODO B2' AS todo;

-- TODO B3 · Students with more than two enrollments: first name, last name
-- and the number of enrollments, by last name.
SELECT 'TODO B3' AS todo;

-- TODO B4 · For each class that has at least one enrollment: its title,
-- the number of enrollments, the number of ratings given, and the average
-- rating rounded to one decimal (blank ratings do not count). By class id.
SELECT 'TODO B4' AS todo;

-- TODO B5 · Classes priced above the average class price: title and price,
-- most expensive first, ties by title.
SELECT 'TODO B5' AS todo;

-- TODO B6 · Every enrollment made in April 2026: the date, the student's
-- full name, the class title and the instructor's name, by date.
SELECT 'TODO B6' AS todo;

-- TODO B7 · Students who have never enrolled in any class: first name,
-- last name and email, by last name.
SELECT 'TODO B7' AS todo;

-- TODO B8 · Revenue per instructor: each enrollment brings in its class's
-- price. Show every instructor (also those with no enrollments) with their
-- number of enrollments and their revenue; highest revenue first, ties by name.
SELECT 'TODO B8' AS todo;

-- Clean up (keep the database while you explore; drop it before you hand in).
DROP DATABASE kit_riverside;
