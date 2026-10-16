-- state: none
-- =====================================================================
-- change_request_starter.sql: ALTER TABLE from a change request
-- Session 2 · Lesson 2.1 · MySQL Foundations instructor kit
--
-- The newsletter_signups table already holds two rows, and the marketing
-- team sends five changes. Make each one with ALTER TABLE, without losing a
-- row or a rule. Every change is written for you but turned off with -- at
-- the start of the line, with a ___ gap to fill. Before you turn one on,
-- predict what DESCRIBE will show. Then remove the -- (only from the
-- statement lines), fill the gap, save, and run the file again.
--
--   SOURCE labs/module-02/l2_1-creating-databases-tables/change_request_starter.sql
--
-- Every run rebuilds kit_s2_signups and drops it at the end.
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

-- TODO 1 · Add a ZIP code (text, up to 10 characters) right after city.
-- ALTER TABLE newsletter_signups
--     ADD COLUMN zip_code VARCHAR(10) ___ city;

-- TODO 2 · Rename signed_up to joined_on.
-- ALTER TABLE newsletter_signups
--     RENAME COLUMN signed_up ___ joined_on;

-- TODO 3 · Allow first names up to 60 characters. Careful: first_name must
-- stay required. Run DESCRIBE afterward and check the Null column says NO.
-- ALTER TABLE newsletter_signups
--     MODIFY COLUMN first_name VARCHAR(60) ___;

-- TODO 4 · In one statement: record where each signup came from ('website'
-- unless given), and drop the ZIP code again (marketing changed its mind).
-- What do Maya's and Omar's rows show in the new column?
-- ALTER TABLE newsletter_signups
--     ADD COLUMN source VARCHAR(20) DEFAULT 'website',
--     ___ COLUMN zip_code;

DESCRIBE newsletter_signups;
SELECT * FROM newsletter_signups ORDER BY id;

-- TODO 5 · An empty copy for testing. Turn on the eight lines below. Which
-- id does Again get after the TRUNCATE, and why? What does SHOW TABLES
-- list at the end?
-- CREATE TABLE signups_test LIKE newsletter_signups;
-- INSERT INTO signups_test (email, first_name) VALUES ('test@example.com', 'Test');
-- TRUNCATE TABLE signups_test;
-- INSERT INTO signups_test (email, first_name) VALUES ('again@example.com', 'Again');
-- SELECT id, email, source FROM signups_test;
-- RENAME TABLE signups_test TO old_signups_test;
-- DROP TABLE old_signups_test;
-- SHOW TABLES;

-- Expected when done: see the README (columns id, email, first_name
-- varchar(60) NO, city, joined_on, source with default website; both rows
-- show source = website; Again gets id 1; SHOW TABLES lists only
-- newsletter_signups).

DROP DATABASE kit_s2_signups;
