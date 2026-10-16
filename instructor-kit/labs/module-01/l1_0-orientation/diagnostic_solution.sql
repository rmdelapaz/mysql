-- state: none
-- =====================================================================
-- diagnostic_solution.sql: the six Start Here questions, answered by MySQL.
-- Session 1 · MySQL Foundations instructor kit · instructor reference
--
-- The workbook's diagnostic asks about one small "spreadsheet" of orders.
-- Every spreadsheet move you already know has a SQL twin:
--   filter -> WHERE · sort -> ORDER BY · AND/OR filters -> WHERE ... AND ...
--   a formula column -> an expression in SELECT · COUNTA -> COUNT(column)
-- (D6, the file path question, is about your computer, not SQL: see the end.)
-- Builds a practice database kit_diagnostic and drops it at the end.
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

-- D1 · Filter the city column to Chicago: which rows are left?
SELECT order_no, customer, city
FROM orders_sheet
WHERE city = 'Chicago';

-- D2 · Sort by price, largest first: which item is on top?
SELECT item, price
FROM orders_sheet
ORDER BY price DESC, order_no
LIMIT 1;

-- D3 · Rows in New York AND with a quantity of 2 or more
SELECT order_no, customer, city, qty
FROM orders_sheet
WHERE city = 'New York' AND qty >= 2;

-- D4 · A formula column: total = qty * price (order 1004)
SELECT order_no, qty, price, qty * price AS total
FROM orders_sheet
WHERE order_no = 1004;

-- D5 · COUNTA(city) counts filled cells only; COUNT(*) counts rows
SELECT COUNT(*) AS all_rows, COUNT(city) AS cities_filled_in
FROM orders_sheet;

-- D6 · is about paths on your computer: from your home folder, a file saved
-- in Downloads is Downloads/bookstore.sql (Windows: Downloads\bookstore.sql).

DROP DATABASE kit_diagnostic;
