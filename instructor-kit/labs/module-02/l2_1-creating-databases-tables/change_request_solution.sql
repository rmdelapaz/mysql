-- state: none
-- =====================================================================
-- change_request_solution.sql: ALTER TABLE from a change request
-- Session 2 · Lesson 2.1 · MySQL Foundations instructor kit · instructor reference
--
-- The newsletter_signups table already holds two rows. The marketing team
-- sends five changes; ALTER TABLE makes them without losing a row. Builds
-- kit_s2_signups and drops it at the end.
-- =====================================================================

DROP DATABASE IF EXISTS kit_s2_signups;
CREATE DATABASE kit_s2_signups CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE kit_s2_signups;

CREATE TABLE newsletter_signups (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    email       VARCHAR(100) NOT NULL UNIQUE,
    first_name  VARCHAR(30) NOT NULL,
    city        VARCHAR(50),
    signed_up   DATE
);
INSERT INTO newsletter_signups (email, first_name, city, signed_up) VALUES
    ('maya@example.com', 'Maya', 'Denver', '2026-03-01'),
    ('omar@example.com', 'Omar', NULL, '2026-03-04');

-- 1 · Add a ZIP code (text, up to 10 characters) right after city
ALTER TABLE newsletter_signups
    ADD COLUMN zip_code VARCHAR(10) AFTER city;

-- 2 · Rename signed_up to joined_on
ALTER TABLE newsletter_signups
    RENAME COLUMN signed_up TO joined_on;

-- 3 · Allow first names up to 60 characters, and keep them required
ALTER TABLE newsletter_signups
    MODIFY COLUMN first_name VARCHAR(60) NOT NULL;

-- 4 · In one statement: record where each signup came from ('website' unless
--     given), and drop the ZIP code again (marketing changed its mind)
ALTER TABLE newsletter_signups
    ADD COLUMN source VARCHAR(20) DEFAULT 'website',
    DROP COLUMN zip_code;

DESCRIBE newsletter_signups;
SELECT * FROM newsletter_signups ORDER BY id;

-- 5 · An empty copy for testing, renamed, emptied and removed again
CREATE TABLE signups_test LIKE newsletter_signups;
INSERT INTO signups_test (email, first_name) VALUES ('test@example.com', 'Test');
TRUNCATE TABLE signups_test;
INSERT INTO signups_test (email, first_name) VALUES ('again@example.com', 'Again');
SELECT id, email, source FROM signups_test;
RENAME TABLE signups_test TO old_signups_test;
DROP TABLE old_signups_test;
SHOW TABLES;

DROP DATABASE kit_s2_signups;
