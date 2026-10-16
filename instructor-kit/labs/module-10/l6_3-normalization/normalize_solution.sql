-- state: none
-- =====================================================================
-- normalize_solution.sql: the workshop sheet in 3NF, proved lossless (reference solution)
-- Session 10 · Lesson 6.3 · MySQL Foundations instructor kit
--
-- Dependencies (from anomalies_*.sql): attendee_email -> attendee_name;
-- workshop -> workshop_date, room, host_email, fee; host_email -> host_name.
-- Key of the sheet: (attendee_email, workshop).
-- 3NF design: attendees, hosts, workshops (pointing at a host), and the
-- junction table signups. Parents first, children last; then EXCEPT in
-- both directions proves nothing was lost. Builds kit_s10_sheet, drops it.
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

CREATE TABLE attendees (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    name   VARCHAR(100) NOT NULL,
    email  VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE hosts (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    name   VARCHAR(100) NOT NULL,
    email  VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE workshops (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    title         VARCHAR(60)  NOT NULL UNIQUE,
    workshop_date DATE         NOT NULL,
    room          VARCHAR(20)  NOT NULL,
    fee           DECIMAL(6, 2) NOT NULL,
    host_id       INT NOT NULL,
    CONSTRAINT fk_workshops_host FOREIGN KEY (host_id) REFERENCES hosts(id)
);
CREATE TABLE signups (
    attendee_id  INT NOT NULL,
    workshop_id  INT NOT NULL,
    PRIMARY KEY (attendee_id, workshop_id),
    CONSTRAINT fk_signups_attendee FOREIGN KEY (attendee_id) REFERENCES attendees(id),
    CONSTRAINT fk_signups_workshop FOREIGN KEY (workshop_id) REFERENCES workshops(id)
);

-- 1. Parents first: one row per attendee, per host, per workshop
INSERT INTO attendees (name, email)
SELECT DISTINCT attendee_name, attendee_email FROM workshop_signups ORDER BY attendee_email;
INSERT INTO hosts (name, email)
SELECT DISTINCT host_name, host_email FROM workshop_signups ORDER BY host_email;
INSERT INTO workshops (title, workshop_date, room, fee, host_id)
SELECT DISTINCT s.workshop, s.workshop_date, s.room, s.fee, h.id
FROM workshop_signups AS s
JOIN hosts AS h ON h.email = s.host_email
ORDER BY s.workshop_date;

-- 2. Children last: the junction table, found through the natural identifiers
INSERT INTO signups (attendee_id, workshop_id)
SELECT a.id, w.id
FROM workshop_signups AS s
JOIN attendees AS a ON a.email = s.attendee_email
JOIN workshops AS w ON w.title = s.workshop;

SELECT (SELECT COUNT(*) FROM attendees) AS attendees,
       (SELECT COUNT(*) FROM hosts)     AS hosts,
       (SELECT COUNT(*) FROM workshops) AS workshops,
       (SELECT COUNT(*) FROM signups)   AS signups;

-- 3. Prove the split is lossless: both directions must be empty
SELECT attendee_name, attendee_email, workshop, workshop_date, room, host_name, host_email, fee
FROM workshop_signups
EXCEPT
SELECT a.name, a.email, w.title, w.workshop_date, w.room, h.name, h.email, w.fee
FROM signups AS g
JOIN attendees AS a ON a.id = g.attendee_id
JOIN workshops AS w ON w.id = g.workshop_id
JOIN hosts     AS h ON h.id = w.host_id;

SELECT a.name, a.email, w.title, w.workshop_date, w.room, h.name, h.email, w.fee
FROM signups AS g
JOIN attendees AS a ON a.id = g.attendee_id
JOIN workshops AS w ON w.id = g.workshop_id
JOIN hosts     AS h ON h.id = w.host_id
EXCEPT
SELECT attendee_name, attendee_email, workshop, workshop_date, room, host_name, host_email, fee
FROM workshop_signups;

-- 4. The update anomaly is gone: one row changes, every attendee sees the new date
UPDATE workshops SET workshop_date = '2026-07-12' WHERE title = 'Bookbinding Basics';
SELECT a.name AS attendee, w.title, w.workshop_date
FROM signups AS g
JOIN attendees AS a ON a.id = g.attendee_id
JOIN workshops AS w ON w.id = g.workshop_id
WHERE w.title = 'Bookbinding Basics'
ORDER BY a.name;

DROP DATABASE kit_s10_sheet;
