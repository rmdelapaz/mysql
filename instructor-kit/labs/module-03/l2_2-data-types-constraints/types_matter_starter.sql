-- state: schema
-- =====================================================================
-- types_matter_starter.sql: a delivery list with the wrong types
-- Session 3 · Lesson 2.2 · MySQL Foundations instructor kit
--
-- Someone pasted the next deliveries from a spreadsheet into a table where
-- copies is text, the cost is FLOAT and the dates are text in US style. Run
-- the file as it is and read the four answers: three of them are wrong, and
-- MySQL never complains. Then fix the TYPES (TODOs 1 to 3) and run it again.
--
-- Run it inside bookstore (USE bookstore; first):
--   SOURCE labs/module-03/l2_2-data-types-constraints/types_matter_starter.sql
-- It creates kit_restock and drops it at the end.
-- =====================================================================

DROP TABLE IF EXISTS kit_restock;
CREATE TABLE kit_restock (
    title      VARCHAR(100) NOT NULL,
    copies     VARCHAR(10)  NOT NULL,   -- TODO 1: a whole number that is never negative
    unit_cost  FLOAT        NOT NULL,   -- TODO 2: money, exact to the cent, up to 9999.99
    arrives    VARCHAR(20)  NOT NULL    -- TODO 3: a real date
);

-- TODO 3 (continued): a DATE column refuses '03/10/2026' (error 1292). Either
-- retype each date as 'YYYY-MM-DD', or convert it as it goes in:
--   STR_TO_DATE('03/10/2026', '%m/%d/%Y')
INSERT INTO kit_restock (title, copies, unit_cost, arrives) VALUES
    ('Dune', '120', 4.10, '03/10/2026'),
    ('Emma',  '15', 2.35, '12/01/2026'),
    ('1984',   '9', 3.30, '01/15/2027');

-- 1 · Biggest delivery first
SELECT title, copies FROM kit_restock ORDER BY copies DESC;

-- 2 · What the whole list costs (120 x 4.10 + 15 x 2.35 + 9 x 3.30 = ?)
SELECT SUM(unit_cost * copies) AS total_cost FROM kit_restock;

-- 3 · Deliveries in calendar order
SELECT title, arrives FROM kit_restock ORDER BY arrives;

-- 4 · The last delivery
SELECT MAX(arrives) AS last_delivery FROM kit_restock;

-- Expected when done: 1) Dune 120, Emma 15, 1984 9; 2) total_cost 556.95
-- exactly; 3) Dune 2026-03-10, Emma 2026-12-01, 1984 2027-01-15;
-- 4) last_delivery 2027-01-15.

DROP TABLE kit_restock;
