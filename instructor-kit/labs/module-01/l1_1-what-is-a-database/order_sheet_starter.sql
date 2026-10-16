-- state: none
-- =====================================================================
-- order_sheet_starter.sql: what goes wrong when a "database" is one big sheet
-- Session 1 · Lesson 1.1 · MySQL Foundations instructor kit
--
-- A bookshop kept its orders in ONE spreadsheet-style table. Run this file,
-- read each result, then do the TODOs (each one changes a single word or
-- value) and run it again. Write one sentence per TODO in your workbook:
-- what is the problem, and how would separate tables with keys prevent it?
--
-- How to run it: open a terminal in the folder that holds labs/, log in
-- with  mysql -u root -p  and type
--   SOURCE labs/module-01/l1_1-what-is-a-database/order_sheet_starter.sql
-- Every run rebuilds the practice database kit_s1_sheet and drops it at
-- the end, so run it as often as you like.
-- =====================================================================

DROP DATABASE IF EXISTS kit_s1_sheet;
CREATE DATABASE kit_s1_sheet;
USE kit_s1_sheet;

CREATE TABLE order_sheet (
    order_no       INT PRIMARY KEY,
    customer_name  VARCHAR(50),
    customer_email VARCHAR(100),
    customer_city  VARCHAR(50),
    books          VARCHAR(200),
    total          VARCHAR(20)
);

INSERT INTO order_sheet VALUES
    (1, 'Alice Johnson', 'alice@example.com', 'New York', 'Dune, 1984, 1984',      '34.97'),
    (2, 'Alice Jonson',  'alice@example.com', 'New York', 'Pride and Prejudice',   '7.99'),
    (3, 'Bob Smith',     'bob@example.com',   'Chicago',  'Dune',                  '14.99'),
    (4, 'Bob Smith',     'bob@example.com',   'Boston',   'Dune Messiah',          '9.99'),
    (5, 'Grace Wilson',  'grace@example.com', 'Chicago',  'The Hobbit, Dune',      'about 26'),
    (6, 'alice johnson', 'alice@example.com', 'New York', 'Brave New World',       '9.49');

-- The whole sheet
SELECT * FROM order_sheet ORDER BY order_no;

-- TODO 1 · One customer, how many spellings?
-- Replace nobody@example.com with Alice's email, run again, count the spellings.
SELECT order_no, customer_name, customer_email
FROM order_sheet
WHERE customer_email = 'nobody@example.com'
ORDER BY order_no;

-- TODO 2 · Where does Bob live?
-- Change the email to Bob's. His city was typed into every order: do they agree?
SELECT order_no, customer_name, customer_city
FROM order_sheet
WHERE customer_email = 'nobody@example.com'
ORDER BY order_no;

-- TODO 3 · Which orders contain Dune?
-- Replace Nothing with Dune (keep the % signs). Look closely at every row you get.
SELECT order_no, books
FROM order_sheet
WHERE books LIKE '%Nothing%'
ORDER BY order_no;

-- TODO 4 · Is every total a number?
-- Replace 0.00 with: about 26   (keep the quotes). Why did MySQL accept that value?
SELECT order_no, total
FROM order_sheet
WHERE total = '0.00';

-- TODO 5 (stretch) · The solution file builds the fix in miniature: a customers
-- table (each customer once) and an orders table that stores only customer_id.
-- Before you open it, sketch those two tables in your workbook.

-- Expected when done: TODO 1 three rows, three spellings of Alice (orders 1, 2, 6);
-- TODO 2 Chicago (order 3) and Boston (order 4); TODO 3 four rows (1, 3, 4, 5),
-- and order 4 is Dune Messiah, a different book; TODO 4 order 5, 'about 26'.

DROP DATABASE kit_s1_sheet;
