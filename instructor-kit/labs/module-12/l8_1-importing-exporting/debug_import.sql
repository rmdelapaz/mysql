-- state: full
-- expect-error: 1064, 1290, 1411, 1292
-- =====================================================================
-- debug_import.sql: an export-and-import session with four mistakes (find-the-bug handout)
-- Session 12 · Lesson 8.1 · MySQL Foundations instructor kit
--
-- This file is broken ON PURPOSE. A colleague typed this at the mysql>
-- prompt: back up, export the cheap books, load two new titles from a
-- US spreadsheet. Four statements fail. Run it as root (bookstore as the
-- current database), then for each bug (A to D) write in your workbook:
-- the error number, the cause, and the fix. Fixed (Bug A moves to the
-- terminal), the last SELECT shows Emma and Frankenstein with real prices
-- and dates. Nothing is written to disk.
--
--   SOURCE labs/module-12/l8_1-importing-exporting/debug_import.sql
-- =====================================================================

-- Bug A: a backup before the import
mysqldump -u root -p bookstore > bookstore_backup.sql;

-- Bug B: the cheap books for the newsletter
SELECT title, price FROM books WHERE price < 9 INTO OUTFILE '/tmp/cheap_books.csv';

-- The staging table, filled as LOAD DATA would fill it from the spreadsheet
DROP TABLE IF EXISTS import_raw;
CREATE TABLE import_raw (title VARCHAR(200), price_raw VARCHAR(20), published_raw VARCHAR(20));
INSERT INTO import_raw VALUES ('Emma', '8.49', '12/23/1815'), ('Frankenstein', '7,49', '01/01/1818');

DROP TABLE IF EXISTS import_clean;
CREATE TABLE import_clean (title VARCHAR(200), price DECIMAL(8, 2), published DATE);

-- Bug C
INSERT INTO import_clean
SELECT title, CAST(price_raw AS DECIMAL(8, 2)), STR_TO_DATE(published_raw, '%d/%m/%Y')
FROM import_raw;

-- Bug D: the same INSERT with the date pattern corrected
INSERT INTO import_clean
SELECT title, CAST(price_raw AS DECIMAL(8, 2)), STR_TO_DATE(published_raw, '%m/%d/%Y')
FROM import_raw;

SELECT title, price, published FROM import_clean ORDER BY title;

DROP TABLE import_clean;
DROP TABLE import_raw;
