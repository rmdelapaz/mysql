-- state: schema
-- =====================================================================
-- membership_rules_solution.sql: turn the club's rules into constraints
-- Session 3 · Lesson 2.2 · MySQL Foundations instructor kit · instructor reference
--
-- The bookstore's loyalty club has five rules. Each becomes a constraint, so
-- MySQL enforces it for every program that writes to the table. Runs inside
-- bookstore (schema state); creates kit_members and drops it at the end.
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

-- Two members who give only the required values, one who gives everything
INSERT INTO kit_members (email, first_name) VALUES
    ('ana@example.com', 'Ana'),
    ('ben@example.com', 'Ben');
INSERT INTO kit_members (email, first_name, tier, points, birthday) VALUES
    ('cleo@example.com', 'Cleo', 'patron', 250, '1990-07-14');

SELECT id, email, first_name, tier, points, birthday FROM kit_members ORDER BY id;

-- The rules MySQL now knows about
SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'kit_members'
ORDER BY CONSTRAINT_TYPE, CONSTRAINT_NAME;

SHOW COLUMNS FROM kit_members;

DROP TABLE kit_members;
