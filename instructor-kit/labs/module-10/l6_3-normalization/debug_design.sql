-- state: none
-- expect-error: 1062, 3780, 1451
-- =====================================================================
-- debug_design.sql: three design errors that are the design working (deliberately broken handout)
-- Session 10 · Lesson 6.3 · MySQL Foundations instructor kit
--
-- A tiny normalized design for the store's workshops, then three mistakes.
-- Run it, read each ERROR line, and write in your workbook: which rule
-- refused the statement, and what the right move is. Builds kit_s10_debug
-- and drops it at the end (the DROP runs even after the errors).
-- =====================================================================

DROP DATABASE IF EXISTS kit_s10_debug;
CREATE DATABASE kit_s10_debug;
USE kit_s10_debug;

CREATE TABLE hosts (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    name   VARCHAR(100) NOT NULL,
    email  VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE workshops (
    id       INT AUTO_INCREMENT PRIMARY KEY,
    title    VARCHAR(60) NOT NULL UNIQUE,
    host_id  INT NOT NULL,
    CONSTRAINT fk_dbg_workshops_host FOREIGN KEY (host_id) REFERENCES hosts(id)
);
INSERT INTO hosts (name, email) VALUES
    ('Lena Park', 'lena.park@bookstore.example'),
    ('James Okafor', 'james.okafor@bookstore.example');
INSERT INTO workshops (title, host_id) VALUES ('Bookbinding Basics', 1), ('Speed Reading', 1);

-- A. The migration script is run a second time
INSERT INTO hosts (name, email) VALUES
    ('Lena Park', 'lena.park@bookstore.example'),
    ('James Okafor', 'james.okafor@bookstore.example');

-- B. A new table for feedback: its foreign key column is "big enough"
CREATE TABLE feedback (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    workshop_id  BIGINT NOT NULL,
    stars        TINYINT NOT NULL,
    CONSTRAINT fk_dbg_feedback_workshop FOREIGN KEY (workshop_id) REFERENCES workshops(id)
);

-- C. Lena leaves the store; remove her
DELETE FROM hosts WHERE email = 'lena.park@bookstore.example';

-- Nothing got in, nothing got lost:
SELECT (SELECT COUNT(*) FROM hosts) AS hosts, (SELECT COUNT(*) FROM workshops) AS workshops;

DROP DATABASE kit_s10_debug;
