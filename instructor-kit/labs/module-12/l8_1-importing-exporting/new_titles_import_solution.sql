-- state: full
-- =====================================================================
-- new_titles_import_solution.sql: a supplier's file, through a staging table
-- Session 12 · Lesson 8.1 · MySQL Foundations instructor kit · instructor reference
--
-- A European supplier sent new_titles.csv (in this folder): semicolons,
-- dates as day.month.year, an empty page count, a price nobody filled in,
-- an author the store does not know yet, and a book the store already
-- sells. The staging table import_raw holds the file's text exactly as
-- LOAD DATA would store it; the INSERT below puts the same five rows there,
-- so the lab needs no file access. With local_infile on (Lesson 8.1) this
-- one statement does the same from the file:
--   LOAD DATA LOCAL INFILE 'labs/module-12/l8_1-importing-exporting/new_titles.csv'
--   INTO TABLE import_raw FIELDS TERMINATED BY ';' IGNORE 1 LINES
--   (title, author, price_raw, pages_raw, published_raw);
-- =====================================================================

DROP TABLE IF EXISTS import_raw;
CREATE TABLE import_raw (
    title         VARCHAR(200),
    author        VARCHAR(100),
    price_raw     VARCHAR(20),
    pages_raw     VARCHAR(10),
    published_raw VARCHAR(20)
);
INSERT INTO import_raw VALUES
    ('Foundation', 'Isaac Asimov', '9.99', '255', '01.06.1951'),
    ('Persuasion', 'Jane Austen', '7.49', '', '20.12.1817'),
    ('Dracula', 'Bram Stoker', '8.99', '418', '26.05.1897'),
    ('The Two Towers', 'J.R.R. Tolkien', 'N/A', '352', '11.11.1954'),
    ('Animal Farm', 'George Orwell', '8.49', '112', '17.08.1945');

-- 1 · Convert on the way in: text to DECIMAL, '' to NULL, day.month.year to DATE
SELECT title,
       CAST(NULLIF(price_raw, 'N/A') AS DECIMAL(8, 2)) AS price,
       CAST(NULLIF(pages_raw, '') AS UNSIGNED)          AS pages,
       STR_TO_DATE(published_raw, '%d.%m.%Y')           AS published
FROM import_raw
ORDER BY title;

-- 2 · Check against the real tables: rows held back, and why
SELECT i.title,
       CASE
           WHEN i.price_raw = 'N/A' THEN 'no price'
           WHEN EXISTS (SELECT 1 FROM books AS b WHERE b.title = i.title) THEN 'already sold'
           ELSE 'ok'
       END AS verdict,
       a.id AS author_id
FROM import_raw AS i
LEFT JOIN authors AS a ON a.name = i.author
ORDER BY verdict, i.title;

-- 3 · Copy the good rows, all or nothing: missing authors first, then the books
START TRANSACTION;
INSERT INTO authors (name)
SELECT DISTINCT i.author
FROM import_raw AS i
LEFT JOIN authors AS a ON a.name = i.author
WHERE a.id IS NULL AND i.price_raw <> 'N/A';
INSERT INTO books (title, author_id, price, pages, published)
SELECT i.title, a.id,
       CAST(i.price_raw AS DECIMAL(8, 2)),
       CAST(NULLIF(i.pages_raw, '') AS UNSIGNED),
       STR_TO_DATE(i.published_raw, '%d.%m.%Y')
FROM import_raw AS i
JOIN authors AS a ON a.name = i.author
WHERE i.price_raw <> 'N/A'
  AND NOT EXISTS (SELECT 1 FROM books AS b WHERE b.title = i.title)
ORDER BY i.title;
COMMIT;

-- 4 · The result
SELECT b.id, b.title, a.name AS author, b.price, b.pages, b.published
FROM books AS b
JOIN authors AS a ON a.id = b.author_id
WHERE b.id > 11
ORDER BY b.id;
SELECT (SELECT COUNT(*) FROM books) AS books, (SELECT COUNT(*) FROM authors) AS authors;

DROP TABLE import_raw;
