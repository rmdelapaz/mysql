-- state: flat
-- =====================================================================
-- publisher_split_starter.sql: move a repeated text column into its own table
-- Session 6 · Lesson 4.1 · MySQL Foundations instructor kit
--
-- The lesson moved books.author into an authors table. Here you do the
-- same migration on new data: a table of (fictional) editions that types
-- each publisher's name and city into every row. The file runs as handed
-- out: it builds the flat table and shows its problems. Steps 2 to 6 are
-- written for you but turned off with -- at the start of each line. Turn
-- on ONE step at a time (remove the -- from its statement lines, fill in
-- any ___ gap), save, and SOURCE the file again. It rebuilds the two
-- practice tables on every run and drops them at the end, so the bookstore
-- itself is not changed.
--
--   SOURCE labs/module-06/l4_1-table-relationships/publisher_split_starter.sql
-- =====================================================================

DROP TABLE IF EXISTS kit_editions;
DROP TABLE IF EXISTS kit_publishers;

CREATE TABLE kit_editions (
    id             INT PRIMARY KEY,
    title          VARCHAR(200) NOT NULL,
    edition_year   INT NOT NULL,
    publisher_name VARCHAR(100) NOT NULL,
    publisher_city VARCHAR(50)
);
INSERT INTO kit_editions VALUES
    (1, 'Dune',                  2019, 'Harbor Lane Press',    'Boston'),
    (2, 'The Hobbit',            2020, 'North Star Books',     'Denver'),
    (3, 'Brave New World',       2018, 'Harbor Lane Press',    'Cambridge'),
    (4, '1984',                  2021, 'Blue Door Publishing', 'Portland'),
    (5, 'Fahrenheit 451',        2022, 'North Star Book',      'Denver'),
    (6, 'Pride and Prejudice',   2017, 'Blue Door Publishing', 'Portland');

-- Step 1 (runs as shipped) · Look at the problems. Write in your workbook:
-- which publisher has two cities, and which one is split in two by a typo?
SELECT publisher_name, publisher_city, COUNT(*) AS editions
FROM kit_editions
GROUP BY publisher_name, publisher_city
ORDER BY publisher_name, publisher_city;

-- TODO Step 2 · The parent table: each publisher once, with ONE city
-- (Harbor Lane Press is in Boston). Why UNIQUE on name?
-- CREATE TABLE kit_publishers (
--     id   INT AUTO_INCREMENT PRIMARY KEY,
--     name VARCHAR(100) NOT NULL UNIQUE,
--     city VARCHAR(50)
-- );
-- INSERT INTO kit_publishers (name, city) VALUES
--     ('Harbor Lane Press',    'Boston'),
--     ('North Star Books',     'Denver'),
--     ('Blue Door Publishing', 'Portland');

-- TODO Step 3 · Add the foreign key column, then fill it by matching names.
-- Fill in the gap: which column of kit_publishers goes into publisher_id?
-- ALTER TABLE kit_editions ADD COLUMN publisher_id INT AFTER edition_year;
-- UPDATE kit_editions
-- JOIN kit_publishers ON kit_publishers.name = kit_editions.publisher_name
-- SET kit_editions.publisher_id = kit_publishers.___;

-- TODO Step 4 · Check BEFORE you drop anything. Predict: how many rows did
-- not match, and why? Then fix that row by id (North Star Books is id 2)
-- and count again: the count must be 0.
-- SELECT id, title, publisher_name FROM kit_editions WHERE publisher_id IS NULL;
-- UPDATE kit_editions SET publisher_id = 2 WHERE id = ___;
-- SELECT COUNT(*) AS editions_without_publisher FROM kit_editions WHERE publisher_id IS NULL;

-- TODO Step 5 · Lock it in. What would happen if you ran this while a
-- publisher_id was still NULL?
-- ALTER TABLE kit_editions
--     MODIFY COLUMN publisher_id INT NOT NULL,
--     DROP COLUMN publisher_name,
--     DROP COLUMN publisher_city,
--     ADD CONSTRAINT fk_editions_publisher
--         FOREIGN KEY (publisher_id) REFERENCES kit_publishers(id)
--         ON DELETE RESTRICT
--         ON UPDATE CASCADE;

-- TODO Step 6 · Use the relationship: write two queries.
-- (a) each edition's title with its publisher's name (a correlated subquery
--     in the SELECT list, like the lesson's author lookup), by id;
-- (b) each publisher's name and city with its number of editions.
SELECT 'TODO 6: editions with their publisher; editions per publisher' AS todo;

-- Clean up: the child first, then the parent (IF EXISTS: Step 2 may still be off).
DROP TABLE kit_editions;
DROP TABLE IF EXISTS kit_publishers;

-- Expected when done:
--   Step 1: Harbor Lane Press in Boston AND Cambridge; North Star Book and
--           North Star Books on separate rows (Blue Door Publishing: 2 editions)
--   Step 4: one unmatched row (5, Fahrenheit 451, North Star Book); after the fix: 0
--   Step 6: (a) Dune and Brave New World: Harbor Lane Press; The Hobbit and
--           Fahrenheit 451: North Star Books; 1984 and Pride and Prejudice:
--           Blue Door Publishing. (b) every publisher has 2 editions.
