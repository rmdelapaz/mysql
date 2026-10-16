-- state: schema
-- expect-error: 1048, 1062, 1265, 1292, 1364, 3819
-- =====================================================================
-- debug_bad_rows.sql: six sign-ups the loyalty club's rules refuse
-- Session 3 · Lesson 2.2 · MySQL Foundations instructor kit
--
-- This file is broken ON PURPOSE: the table is the finished kit_members from
-- membership_rules, and six of the INSERTs below break one of its rules.
-- Run it (SOURCE keeps going after each error). For each ERROR line write
-- in your workbook: the error number · which rule (R1 to R5) it protects ·
-- a fixed INSERT. Fix the six and run it again: the last SELECT should then
-- list nine members and no ERROR lines.
--
-- Run it inside bookstore:
--   SOURCE labs/module-03/l2_2-data-types-constraints/debug_bad_rows.sql
-- =====================================================================

DROP TABLE IF EXISTS kit_members;
CREATE TABLE kit_members (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    email       VARCHAR(100) NOT NULL UNIQUE,
    first_name  VARCHAR(30)  NOT NULL,
    tier        ENUM('reader', 'collector', 'patron') NOT NULL DEFAULT 'reader',
    points      INT NOT NULL DEFAULT 0,
    birthday    DATE,
    CONSTRAINT chk_points CHECK (points >= 0)
);

INSERT INTO kit_members (email, first_name) VALUES ('ana@example.com', 'Ana');
INSERT INTO kit_members (email, first_name, tier) VALUES ('ben@example.com', 'Ben', 'collector');

-- Bug A
INSERT INTO kit_members (email, first_name) VALUES (NULL, 'Dev');

-- Bug B
INSERT INTO kit_members (email, first_name) VALUES ('ana@example.com', 'Anna');

-- Bug C
INSERT INTO kit_members (email, first_name, tier) VALUES ('eli@example.com', 'Eli', 'gold');

-- Bug D
INSERT INTO kit_members (email, first_name, birthday) VALUES ('fay@example.com', 'Fay', '1995-02-29');

-- Bug E
INSERT INTO kit_members (email) VALUES ('gus@example.com');

-- Bug F
INSERT INTO kit_members (email, first_name, points) VALUES ('hal@example.com', 'Hal', -40);

INSERT INTO kit_members (email, first_name, points) VALUES ('ivy@example.com', 'Ivy', 75);

SELECT id, email, first_name, tier, points, birthday FROM kit_members ORDER BY id;

DROP TABLE kit_members;
