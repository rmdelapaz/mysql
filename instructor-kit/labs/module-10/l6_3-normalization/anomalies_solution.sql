-- state: none
-- =====================================================================
-- anomalies_solution.sql: what one big sheet gets wrong (reference solution)
-- Session 10 · Lesson 6.3 · MySQL Foundations instructor kit
--
-- The bookstore's workshop sign-up sheet: one row per attendee per
-- workshop, with the workshop's date, room and host copied onto every
-- row. You make the update and delete anomalies happen (inside
-- transactions, rolled back), then test the functional dependencies the
-- design will be built on. Builds kit_s10_sheet and drops it at the end.
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

-- 2. Update anomaly: the bookbinding workshop moves to July 12, but only one row is edited
START TRANSACTION;
UPDATE workshop_signups SET workshop_date = '2026-07-12'
WHERE workshop = 'Bookbinding Basics' AND attendee_email = 'bob@example.com';
SELECT DISTINCT workshop, workshop_date
FROM workshop_signups
WHERE workshop = 'Bookbinding Basics';
ROLLBACK;

-- 3. Delete anomaly: Frank cancels, and the store forgets the Speed Reading workshop exists
START TRANSACTION;
DELETE FROM workshop_signups WHERE attendee_email = 'frank@example.com';
SELECT COUNT(*) AS rows_about_speed_reading
FROM workshop_signups
WHERE workshop = 'Speed Reading';
ROLLBACK;

-- 4. Test the dependencies: no counterexample means "consistent", never "proved"
--    workshop -> workshop_date, room, host_email, fee
SELECT workshop,
       COUNT(DISTINCT workshop_date) AS dates,
       COUNT(DISTINCT room)          AS rooms,
       COUNT(DISTINCT host_email)    AS hosts,
       COUNT(DISTINCT fee)           AS fees
FROM workshop_signups
GROUP BY workshop
ORDER BY workshop;
--    host_email -> host_name (empty: no counterexample)
SELECT host_email, COUNT(DISTINCT host_name) AS names
FROM workshop_signups
GROUP BY host_email
HAVING COUNT(DISTINCT host_name) > 1;
--    host_email -> workshop? One counterexample proves it is NOT a dependency
SELECT host_email, COUNT(DISTINCT workshop) AS workshops
FROM workshop_signups
GROUP BY host_email
HAVING COUNT(DISTINCT workshop) > 1
ORDER BY host_email;

-- 5. The key: (attendee_email, workshop) identifies every row
SELECT COUNT(*) AS signup_rows,
       COUNT(DISTINCT attendee_email, workshop) AS distinct_pairs,
       COUNT(DISTINCT attendee_email)           AS distinct_attendees
FROM workshop_signups;

DROP DATABASE kit_s10_sheet;
