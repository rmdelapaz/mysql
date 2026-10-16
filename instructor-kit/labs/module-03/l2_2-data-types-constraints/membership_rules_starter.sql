-- state: schema
-- =====================================================================
-- membership_rules_starter.sql: turn the club's rules into constraints
-- Session 3 · Lesson 2.2 · MySQL Foundations instructor kit
--
-- The bookstore is starting a loyalty club. The owner's rules:
--   R1  every member has an email, and no two members share one
--   R2  every member has a first name
--   R3  the tier is reader, collector or patron, and reader unless given
--   R4  points are a whole number, 0 unless given, and never negative
--       (name the rule chk_points so its errors are easy to read)
--   R5  a birthday is optional
-- The table below has the right TYPES but none of the rules yet. Run it as it
-- is: look at the NULLs in Ana's and Ben's rows and at the one constraint
-- MySQL knows about. Then add the rules to the CREATE TABLE (TODOs 1 to 4),
-- run it again, and compare.
--
-- Run it inside bookstore:
--   SOURCE labs/module-03/l2_2-data-types-constraints/membership_rules_starter.sql
-- It creates kit_members and drops it at the end. To see the rules refuse
-- bad rows, run debug_bad_rows.sql in the same folder afterward.
-- =====================================================================

DROP TABLE IF EXISTS kit_members;
CREATE TABLE kit_members (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    email       VARCHAR(100),                           -- TODO 1: R1
    first_name  VARCHAR(30),                            -- TODO 2: R2
    tier        ENUM('reader', 'collector', 'patron'),  -- TODO 3: R3
    points      INT,                                    -- TODO 4: R4 (two parts here, plus a CHECK below)
    birthday    DATE                                    -- R5: nothing to add
    -- TODO 4 (continued): add a comma after DATE above, then on this line:
    -- CONSTRAINT chk_points CHECK (___)
);

-- Two members who give only the required values, one who gives everything
INSERT INTO kit_members (email, first_name) VALUES
    ('ana@example.com', 'Ana'),
    ('ben@example.com', 'Ben');
INSERT INTO kit_members (email, first_name, tier, points, birthday) VALUES
    ('cleo@example.com', 'Cleo', 'patron', 250, '1990-07-14');

SELECT id, email, first_name, tier, points, birthday FROM kit_members ORDER BY id;

-- The rules MySQL knows about
SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'kit_members'
ORDER BY CONSTRAINT_TYPE, CONSTRAINT_NAME;

SHOW COLUMNS FROM kit_members;

-- Expected when done: Ana and Ben show tier reader and points 0 (Cleo patron,
-- 250); three constraints: chk_points CHECK, PRIMARY PRIMARY KEY, email
-- UNIQUE; SHOW COLUMNS says NO under Null for email, first_name, tier and
-- points, with defaults reader and 0.

DROP TABLE kit_members;
