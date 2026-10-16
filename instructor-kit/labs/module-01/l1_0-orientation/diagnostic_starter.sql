-- state: none
-- =====================================================================
-- diagnostic_starter.sql: the Start Here questions, in SQL (optional homework)
-- Session 1 · MySQL Foundations instructor kit
--
-- The workbook's diagnostic asked about one small "spreadsheet" of orders.
-- Here is the same sheet as a MySQL table. Each question below has a
-- query with ONE gap to fill. Replace the gap, run the file again, and
-- check MySQL's answer against what you circled in the workbook.
--
-- How to run it: open a terminal in the folder that holds labs/, log in
-- with  mysql -u root -p  and type
--   SOURCE labs/module-01/l1_0-orientation/diagnostic_starter.sql
-- Every run rebuilds the practice database kit_diagnostic and drops it at
-- the end, so you can run it as often as you like.
-- =====================================================================

DROP DATABASE IF EXISTS kit_diagnostic;
CREATE DATABASE kit_diagnostic;
USE kit_diagnostic;

CREATE TABLE orders_sheet (
    order_no  INT PRIMARY KEY,
    customer  VARCHAR(50)  NOT NULL,
    city      VARCHAR(50),
    item      VARCHAR(100) NOT NULL,
    qty       INT          NOT NULL,
    price     DECIMAL(8,2) NOT NULL
);

INSERT INTO orders_sheet VALUES
    (1001, 'Alice Johnson', 'New York', 'Dune',                1, 14.99),
    (1002, 'Bob Smith',     'Chicago',  '1984',                2,  9.99),
    (1003, 'Grace Wilson',  'Chicago',  'The Hobbit',          1, 10.99),
    (1004, 'Dave Brown',    'Houston',  'Dune',                3, 14.99),
    (1005, 'Frank Miller',  'New York', 'Fahrenheit 451',      2, 10.49),
    (1006, 'Eve Davis',     NULL,       'Pride and Prejudice', 1,  7.99);

-- The whole sheet
SELECT * FROM orders_sheet;

-- D1 · Filter the city column to Chicago.
-- TODO 1: replace 'Somewhere' with the city. (Prints "Empty set" until you do.)
SELECT order_no, customer, city
FROM orders_sheet
WHERE city = 'Somewhere';

-- D2 · Sort by price, largest first, and keep the top row.
-- TODO 2: add DESC after "ORDER BY price" (largest first).
SELECT item, price
FROM orders_sheet
ORDER BY price, order_no
LIMIT 1;

-- D3 · Rows in New York AND with a quantity of 2 or more.
-- TODO 3: change OR to AND. How many rows does each version give?
SELECT order_no, customer, city, qty
FROM orders_sheet
WHERE city = 'New York' OR qty >= 2;

-- D4 · A formula column: total = qty * price, for order 1004.
-- TODO 4: replace the 0 with  qty * price
SELECT order_no, qty, price, 0 AS total
FROM orders_sheet
WHERE order_no = 1004;

-- D5 · How many rows, and how many cities are filled in?
-- TODO 5: nothing to change. Predict both numbers first, then compare.
SELECT COUNT(*) AS all_rows, COUNT(city) AS cities_filled_in
FROM orders_sheet;

-- D6 · is about paths on your computer, not SQL: see the workbook.

-- Expected when done: D1 two rows (1002 Bob Smith, 1003 Grace Wilson);
-- D2 Dune 14.99; D3 one row (1005 Frank Miller, New York, 2); D4 total 44.97;
-- D5 all_rows 6, cities_filled_in 5.

DROP DATABASE kit_diagnostic;
