-- state: schema
-- =====================================================================
-- types_matter_solution.sql: the same delivery list, with the right types
-- Session 3 · Lesson 2.2 · MySQL Foundations instructor kit · instructor reference
--
-- A delivery list pasted from a spreadsheet: copies as text, cost as FLOAT,
-- dates as US-style text. With INT UNSIGNED, DECIMAL and DATE the same four
-- questions get the right answers. Runs inside bookstore (schema state);
-- creates kit_restock and drops it at the end.
-- =====================================================================

DROP TABLE IF EXISTS kit_restock;
CREATE TABLE kit_restock (
    title      VARCHAR(100) NOT NULL,
    copies     INT UNSIGNED NOT NULL,
    unit_cost  DECIMAL(6, 2) NOT NULL,
    arrives    DATE NOT NULL
);

-- The same rows; the dates are converted from the spreadsheet's MM/DD/YYYY
INSERT INTO kit_restock (title, copies, unit_cost, arrives) VALUES
    ('Dune', 120, 4.10, STR_TO_DATE('03/10/2026', '%m/%d/%Y')),
    ('Emma',  15, 2.35, STR_TO_DATE('12/01/2026', '%m/%d/%Y')),
    ('1984',   9, 3.30, STR_TO_DATE('01/15/2027', '%m/%d/%Y'));

-- 1 · Biggest delivery first
SELECT title, copies FROM kit_restock ORDER BY copies DESC;

-- 2 · What the whole list costs
SELECT SUM(unit_cost * copies) AS total_cost FROM kit_restock;

-- 3 · Deliveries in calendar order
SELECT title, arrives FROM kit_restock ORDER BY arrives;

-- 4 · The last delivery
SELECT MAX(arrives) AS last_delivery FROM kit_restock;

DROP TABLE kit_restock;
