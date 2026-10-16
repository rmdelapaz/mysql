-- state: none
-- =====================================================================
-- anomalies_starter.sql: what one big sheet gets wrong
-- Session 10 · Lesson 6.3 · MySQL Foundations instructor kit
--
-- The bookstore's workshop sign-up sheet: one row per attendee per
-- workshop, with the workshop's date, room and host copied onto every
-- row. You make two anomalies happen (inside transactions, rolled back),
-- then test the dependencies a better design would be built on.
-- Builds kit_s10_sheet on every run and drops it at the end:
--   SOURCE labs/module-10/l6_3-normalization/anomalies_starter.sql
-- =====================================================================

DROP DATABASE IF EXISTS kit_s10_sheet;
CREATE DATABASE kit_s10_sheet;
USE kit_s10_sheet;

CREATE TABLE workshop_signups (
    attendee_name   VARCHAR(100) NOT NULL,
    attendee_email  VARCHAR(100) NOT NULL,
    workshop        VARCHAR(60)  NOT NULL,
    workshop_date   DATE         NOT NULL,
    room            VARCHAR(20)  NOT NULL,
    host_name       VARCHAR(100) NOT NULL,
    host_email      VARCHAR(100) NOT NULL,
    fee             DECIMAL(6, 2) NOT NULL
);
INSERT INTO workshop_signups VALUES
    ('Alice Johnson', 'alice@example.com', 'Bookbinding Basics', '2026-07-11', 'Back room',  'Lena Park',     'lena.park@bookstore.example',     15.00),
    ('Bob Smith',     'bob@example.com',   'Bookbinding Basics', '2026-07-11', 'Back room',  'Lena Park',     'lena.park@bookstore.example',     15.00),
    ('Eve Davis',     'eve@example.com',   'Bookbinding Basics', '2026-07-11', 'Back room',  'Lena Park',     'lena.park@bookstore.example',     15.00),
    ('Alice Johnson', 'alice@example.com', 'Writing Fan Fiction', '2026-07-18', 'Front room', 'James Okafor', 'james.okafor@bookstore.example',  10.00),
    ('Grace Wilson',  'grace@example.com', 'Writing Fan Fiction', '2026-07-18', 'Front room', 'James Okafor', 'james.okafor@bookstore.example',  10.00),
    ('Frank Miller',  'frank@example.com', 'Speed Reading',       '2026-07-25', 'Back room',  'Lena Park',     'lena.park@bookstore.example',     12.00);

-- 1. The sheet
SELECT attendee_name, workshop, workshop_date, room, host_name, fee
FROM workshop_signups
ORDER BY workshop_date, attendee_name;

-- TODO 1 · Update anomaly. Bookbinding Basics moves to July 12, but someone
-- edits only Bob's row. Replace ___ with Bob's email and remove the -- from
-- the UPDATE line. How many dates does one workshop have now?
START TRANSACTION;
-- UPDATE workshop_signups SET workshop_date = '2026-07-12' WHERE workshop = 'Bookbinding Basics' AND attendee_email = '___';
SELECT DISTINCT workshop, workshop_date
FROM workshop_signups
WHERE workshop = 'Bookbinding Basics';
ROLLBACK;

-- TODO 2 · Delete anomaly. Frank cancels his only sign-up. Write the DELETE
-- for his row (attendee_email = 'frank@example.com') in place of the TODO
-- line. What does the store still know about Speed Reading afterward?
START TRANSACTION;
SELECT 'TODO 2: DELETE Frank''s row here' AS todo;
SELECT COUNT(*) AS rows_about_speed_reading
FROM workshop_signups
WHERE workshop = 'Speed Reading';
ROLLBACK;

-- TODO 3 · Test the dependencies. The first query checks workshop -> date,
-- room, host, fee (one of each per workshop?). Write two more in the same
-- style (GROUP BY the left side, HAVING COUNT(DISTINCT right side) > 1):
--   host_email -> host_name   and   host_email -> workshop
-- Which one finds a counterexample, and what does that prove?
SELECT workshop,
       COUNT(DISTINCT workshop_date) AS dates,
       COUNT(DISTINCT room)          AS rooms,
       COUNT(DISTINCT host_email)    AS hosts,
       COUNT(DISTINCT fee)           AS fees
FROM workshop_signups
GROUP BY workshop
ORDER BY workshop;

-- 5. The key: does (attendee_email, workshop) identify every row?
SELECT COUNT(*) AS signup_rows,
       COUNT(DISTINCT attendee_email, workshop) AS distinct_pairs,
       COUNT(DISTINCT attendee_email)           AS distinct_attendees
FROM workshop_signups;

-- Expected when done:
-- TODO 1  Bookbinding Basics with two dates: 2026-07-11 and 2026-07-12
-- TODO 2  rows_about_speed_reading 0: the workshop, its date, room and fee are gone
-- TODO 3  every workshop 1 1 1 1; host_email -> host_name: no rows (consistent, not
--         proved); host_email -> workshop: lena.park@bookstore.example hosts 2
--         workshops, so the host does NOT determine the workshop
-- 5       6 rows, 6 distinct pairs, 5 attendees: the pair is the key, the email alone is not

DROP DATABASE kit_s10_sheet;
