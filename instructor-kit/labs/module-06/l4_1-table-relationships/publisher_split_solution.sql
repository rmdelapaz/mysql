-- state: flat
-- =====================================================================
-- publisher_split_solution.sql: REFERENCE SOLUTION (instructor copy)
-- Session 6 · Lesson 4.1 · MySQL Foundations instructor kit
--
-- The lesson moved books.author into an authors table. This lab does the
-- same migration on new data: a table of (fictional) editions that types
-- each publisher's name and city into every row. Same four steps: create
-- the parent, add the column, fill it by matching, check, lock it in.
-- It works on two practice tables (kit_editions, kit_publishers) and drops
-- them at the end, so the bookstore itself is not changed.
--
--   SOURCE labs/module-06/l4_1-table-relationships/publisher_split_solution.sql
-- =====================================================================

DROP TABLE IF EXISTS kit_editions;
DROP TABLE IF EXISTS kit_publishers;

-- The flat table: the publisher's name and city are typed into every row.
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

-- 1 · The anomalies: one publisher in two cities, and a misspelled name
--     that splits North Star in two.
SELECT publisher_name, publisher_city, COUNT(*) AS editions
FROM kit_editions
GROUP BY publisher_name, publisher_city
ORDER BY publisher_name, publisher_city;

-- 2 · The parent table: each publisher once, with ONE city.
CREATE TABLE kit_publishers (
    id   INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    city VARCHAR(50)
);
INSERT INTO kit_publishers (name, city) VALUES
    ('Harbor Lane Press',    'Boston'),
    ('North Star Books',     'Denver'),
    ('Blue Door Publishing', 'Portland');

-- 3 · The foreign key column, filled by matching names.
ALTER TABLE kit_editions ADD COLUMN publisher_id INT AFTER edition_year;
UPDATE kit_editions
JOIN kit_publishers ON kit_publishers.name = kit_editions.publisher_name
SET kit_editions.publisher_id = kit_publishers.id;

-- 4 · Check BEFORE dropping anything: which rows did not match?
SELECT id, title, publisher_name
FROM kit_editions
WHERE publisher_id IS NULL;
--     One typo. Fix it by id (the publisher North Star Books is id 2), check again.
UPDATE kit_editions SET publisher_id = 2 WHERE id = 5;
SELECT COUNT(*) AS editions_without_publisher
FROM kit_editions
WHERE publisher_id IS NULL;

-- 5 · Lock it in: required, old text columns gone, the key declared.
ALTER TABLE kit_editions
    MODIFY COLUMN publisher_id INT NOT NULL,
    DROP COLUMN publisher_name,
    DROP COLUMN publisher_city,
    ADD CONSTRAINT fk_editions_publisher
        FOREIGN KEY (publisher_id) REFERENCES kit_publishers(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;

-- 6 · Use the relationship: each edition with its publisher (a correlated
--     subquery: joins come in Lesson 4.3), then editions per publisher.
SELECT
    title,
    (SELECT name FROM kit_publishers AS p WHERE p.id = e.publisher_id) AS publisher
FROM kit_editions AS e
ORDER BY id;
SELECT
    p.name,
    p.city,
    (SELECT COUNT(*) FROM kit_editions AS e WHERE e.publisher_id = p.id) AS editions
FROM kit_publishers AS p
ORDER BY p.id;

-- Clean up: the child first, then the parent.
DROP TABLE kit_editions;
DROP TABLE kit_publishers;
