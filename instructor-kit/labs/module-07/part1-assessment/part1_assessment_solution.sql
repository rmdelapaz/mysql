-- state: none
-- =====================================================================
-- part1_assessment_solution.sql: REFERENCE SOLUTION (instructor copy)
-- Part 1 assessment · Session 7 · MySQL Foundations instructor kit
--
-- The Riverside Cooking School (fictional): instructors, classes and
-- students are given; the learner builds the enrollments table (Part A),
-- changes data safely, and answers eight questions (Part B). This file is
-- the instructor's reference: it runs start to finish and prints every
-- answer. Every number in final-assessment.html comes from running it.
-- Other correct answers exist (NOT EXISTS for an anti-join, IN for a
-- join, other delete rules with a reason): score them on the rubric.
--
--   SOURCE labs/module-07/part1-assessment/part1_assessment_solution.sql
-- =====================================================================

-- ---------------------------------------------------------------- given
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
-- A1 · The enrollments table: one row per student per class.
--   Rules chosen: enrollments -> students RESTRICT (an enrollment is a paid
--   booking: the school keeps that history; deactivate a student instead).
--   enrollments -> classes CASCADE (a cancelled class's bookings mean
--   nothing without it; refunds are handled outside the database).
CREATE TABLE enrollments (
    student_id  INT NOT NULL,
    class_id    INT NOT NULL,
    enrolled_on DATE NOT NULL,
    rating      TINYINT,
    PRIMARY KEY (student_id, class_id),
    CONSTRAINT chk_enrollments_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT fk_enrollments_student
        FOREIGN KEY (student_id) REFERENCES students(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_enrollments_class
        FOREIGN KEY (class_id) REFERENCES classes(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- A2 · Load the enrollments (given; ratings are NULL until a student rates).
INSERT INTO enrollments (student_id, class_id, enrolled_on, rating) VALUES
    (1, 1, '2026-02-20', 5), (1, 3, '2026-03-01', 4), (1, 5, '2026-03-10', NULL),
    (2, 1, '2026-02-25', 4), (2, 4, '2026-04-02', 5),
    (3, 3, '2026-03-05', 3), (3, 5, '2026-03-12', 5), (3, 6, '2026-04-20', NULL),
    (4, 2, '2026-03-30', 4), (4, 7, '2026-03-15', 2),
    (5, 1, '2026-03-01', NULL), (5, 6, '2026-04-22', 5), (5, 7, '2026-03-20', 4),
    (6, 4, '2026-04-05', 3), (6, 2, '2026-04-01', 5);
SELECT COUNT(*) AS enrollments, COUNT(rating) AS rated FROM enrollments;

-- A3a · Two statements that must be refused (run each once at the prompt,
--   NOT in this file; record the error):
--     INSERT INTO enrollments VALUES (9, 2, '2026-04-03', NULL);
--       -> ERROR 1452: student 9 does not exist (a child row with no parent)
--     INSERT INTO enrollments VALUES (8, 2, '2026-04-03', 6);
--       -> ERROR 3819: Check constraint 'chk_enrollments_rating' is violated
-- A3b · Every Italian class costs 5.00 more from now on.
UPDATE classes SET price = price + 5.00 WHERE cuisine = 'Italian';
-- A3c · Mole Masterclass (8) was cancelled before anyone enrolled.
DELETE FROM classes WHERE id = 8;
SELECT id, title, price FROM classes ORDER BY id;

-- ---------------------------------------------------------------- Part B · Query
-- B1 · Classes in March 2026 that cost under $70, cheapest first.
SELECT title, class_date, price
FROM classes
WHERE class_date BETWEEN '2026-03-01' AND '2026-03-31'
  AND price < 70
ORDER BY price;

-- B2 · Per cuisine: number of classes and average price (rounded to cents),
--      highest average first, ties by cuisine.
SELECT cuisine, COUNT(*) AS classes, ROUND(AVG(price), 2) AS avg_price
FROM classes
GROUP BY cuisine
ORDER BY avg_price DESC, cuisine;

-- B3 · Students with more than two enrollments, with their names.
SELECT s.first_name, s.last_name, COUNT(*) AS enrollments
FROM students AS s
JOIN enrollments AS e ON e.student_id = s.id
GROUP BY s.id, s.first_name, s.last_name
HAVING COUNT(*) > 2
ORDER BY s.last_name;

-- B4 · Per class with at least one enrollment: enrollments, ratings given,
--      and the average rating (one decimal). Ratings left blank do not count.
SELECT c.title,
       COUNT(*)                AS enrollments,
       COUNT(e.rating)         AS ratings,
       ROUND(AVG(e.rating), 1) AS avg_rating
FROM classes AS c
JOIN enrollments AS e ON e.class_id = c.id
GROUP BY c.id, c.title
ORDER BY c.id;

-- B5 · Classes priced above the average class price (no typed numbers).
SELECT title, price
FROM classes
WHERE price > (SELECT AVG(price) FROM classes)
ORDER BY price DESC, title;

-- B6 · April 2026 enrollments: date, student, class and instructor.
SELECT e.enrolled_on,
       CONCAT(s.first_name, ' ', s.last_name) AS student,
       c.title AS class,
       i.name  AS instructor
FROM enrollments AS e
JOIN students    AS s ON e.student_id = s.id
JOIN classes     AS c ON e.class_id = c.id
JOIN instructors AS i ON c.instructor_id = i.id
WHERE e.enrolled_on >= '2026-04-01' AND e.enrolled_on < '2026-05-01'
ORDER BY e.enrolled_on;

-- B7 · Students who have never enrolled (anti-join).
SELECT s.first_name, s.last_name, s.email
FROM students AS s
LEFT JOIN enrollments AS e ON e.student_id = s.id
WHERE e.student_id IS NULL
ORDER BY s.last_name;

-- B8 · Revenue per instructor (the class price for every enrollment),
--      every instructor included, highest first.
--      CASE adds a class's price only for rows that ARE an enrollment: a
--      class with no enrollments still appears once, padded with NULLs.
SELECT i.name,
       COUNT(e.student_id) AS enrollments,
       SUM(CASE WHEN e.student_id IS NOT NULL THEN c.price ELSE 0 END) AS revenue
FROM instructors AS i
LEFT JOIN classes     AS c ON c.instructor_id = i.id
LEFT JOIN enrollments AS e ON e.class_id = c.id
GROUP BY i.id, i.name
ORDER BY revenue DESC, i.name;

-- Clean up (keep the database while you explore; drop it before you hand in).
DROP DATABASE kit_riverside;
