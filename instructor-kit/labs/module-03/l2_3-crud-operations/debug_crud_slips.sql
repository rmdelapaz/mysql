-- state: schema
-- expect-error: 1136, 1054, 1062, 1175, 1292
-- =====================================================================
-- debug_crud_slips.sql: five CRUD slips MySQL refuses (find-the-bug handout)
-- Session 3 · Lesson 2.3 · MySQL Foundations instructor kit
--
-- This file is broken ON PURPOSE. Three customers sign up, then five
-- statements go wrong. Run it (SOURCE keeps going after each error). For
-- each ERROR line write in your workbook: the error number · what went wrong
-- · the fixed statement. Fix them and run it again: the last SELECT should
-- show five customers, Paula and Nina in Aurora, Omar in Chicago with his
-- new email, and no ERROR lines.
--
-- Run it inside bookstore:
--   SOURCE labs/module-03/l2_3-crud-operations/debug_crud_slips.sql
-- It empties customers again at the end.
-- =====================================================================

INSERT INTO customers (first_name, last_name, email, city, created_at) VALUES
    ('Nina', 'Park', 'nina@example.com', 'Denver', '2026-03-01 09:00:00'),
    ('Omar', 'Haddad', 'omar@example.com', 'Boston', '2026-03-02 10:30:00'),
    ('Paula', 'Reyes', 'paula@example.com', 'Denver', '2026-03-03 12:00:00');

-- Bug A: Quinn signs up
INSERT INTO customers (first_name, last_name, email)
VALUES ('Quinn', 'Lee');

-- Bug B: Rosa signs up
INSERT INTO customers (first_name, last_name, email)
VALUES (Rosa, 'Diaz', 'rosa@example.com');

-- Bug C: Nina's sister signs up
INSERT INTO customers (first_name, last_name, email)
VALUES ('Nora', 'Park', 'nina@example.com');

-- Bug D: everyone in Denver moves to Aurora, with the safety switch on
SET SQL_SAFE_UPDATES = 1;
UPDATE customers SET city = 'Aurora' WHERE city = 'Denver';
SET SQL_SAFE_UPDATES = 0;

-- Bug E: Omar (id 2) moves to Chicago and gets a new email
UPDATE customers
SET city = 'Chicago' AND email = 'omar.h@example.com'
WHERE id = 2;

SELECT id, first_name, last_name, city, email FROM customers ORDER BY id;

TRUNCATE TABLE customers;
