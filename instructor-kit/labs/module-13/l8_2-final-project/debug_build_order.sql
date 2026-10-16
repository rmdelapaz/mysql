-- state: none
-- expect-error: 1064, 3780, 3814, 1824
-- =====================================================================
-- debug_build_order.sql: a build script with four classic mistakes
-- Session 13 · Lesson 8.2 · MySQL Foundations instructor kit
--
-- A volunteer started the database for a neighborhood bike-share. The
-- script fails in four places, each a mistake from the lesson's Common
-- Mistakes (deliberately broken). Run it, read each ERROR from the left
-- (number first), and fix the script until it runs without one ERROR
-- and SHOW TABLES lists all six tables. Change as little as you can.
--
--   SOURCE labs/module-13/l8_2-final-project/debug_build_order.sql
-- Every run rebuilds kit_s13_bikes and drops it at the end.
-- =====================================================================

DROP DATABASE IF EXISTS kit_s13_bikes;
CREATE DATABASE kit_s13_bikes;
USE kit_s13_bikes;

CREATE TABLE riders (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    joined_on DATE         NOT NULL
);

-- Bug A: an e-bike's battery range in kilometers
CREATE TABLE bikes (
    id    INT AUTO_INCREMENT PRIMARY KEY,
    model VARCHAR(50) NOT NULL,
    range INT         NOT NULL
);

-- Bug B: who rode when
CREATE TABLE rides (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    rider_id   BIGINT NOT NULL,
    started_on DATE   NOT NULL,
    CONSTRAINT fk_rides_rider FOREIGN KEY (rider_id) REFERENCES riders (id)
);

-- Bug C: monthly price plans may not start in the past
CREATE TABLE price_plans (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    name      VARCHAR(50)   NOT NULL,
    monthly   DECIMAL(6, 2) NOT NULL,
    starts_on DATE          NOT NULL,
    CONSTRAINT chk_plans_start CHECK (starts_on >= CURDATE())
);

-- Bug D: which spare parts each repair used
CREATE TABLE repair_parts (
    repair_no INT NOT NULL,
    part_id   INT NOT NULL,
    PRIMARY KEY (repair_no, part_id),
    CONSTRAINT fk_rp_part FOREIGN KEY (part_id) REFERENCES parts (id)
);

CREATE TABLE parts (
    id   INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

-- Which tables exist now? As shipped only two; fixed, all six:
-- bikes, parts, price_plans, repair_parts, rides, riders
SHOW TABLES;

DROP DATABASE kit_s13_bikes;
