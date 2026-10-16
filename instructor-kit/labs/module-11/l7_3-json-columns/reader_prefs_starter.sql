-- state: full
-- =====================================================================
-- reader_prefs_starter.sql: read, filter and change a JSON column on customers
-- Session 11 · Lesson 7.3 · MySQL Foundations instructor kit
--
-- The lesson put JSON on books. Here customers get a prefs column: whether
-- they want the newsletter, their favorite genres (an array) and, for some,
-- a nested contact object. Not every customer has every key, and three have
-- no prefs at all (NULL). The file adds the column and removes it again at
-- the end, so you can edit it and SOURCE it again. (If a run stops halfway,
-- reload labs/_states/bookstore.sql: MySQL has no DROP COLUMN IF EXISTS.)
--
--   SOURCE labs/module-11/l7_3-json-columns/reader_prefs_starter.sql
-- =====================================================================

ALTER TABLE customers ADD COLUMN prefs JSON;
UPDATE customers SET prefs = '{"newsletter": true, "genres": ["Science Fiction", "Classic"], "contact": {"email": true, "sms": false}}' WHERE id = 1;
UPDATE customers SET prefs = '{"newsletter": false, "genres": ["Dystopian"]}' WHERE id = 2;
UPDATE customers SET prefs = '{"newsletter": false}' WHERE id = 4;
UPDATE customers SET prefs = '{"newsletter": true, "genres": []}' WHERE id = 6;
UPDATE customers SET prefs = '{"newsletter": true, "genres": ["Fantasy", "Classic"], "language": "es"}' WHERE id = 7;

-- TODO 1 · Who wants the newsletter? ->> turns a JSON true into the text
-- 'true'. Replace 'TODO' with the right text.
SELECT id, first_name
FROM customers
WHERE prefs->>'$.newsletter' = 'TODO'
ORDER BY id;

-- TODO 2 · Who likes Classic? Replace 'TODO' with the genre.
SELECT id, first_name
FROM customers
WHERE 'TODO' MEMBER OF (prefs->'$.genres')
ORDER BY id;

-- TODO 3 · Predict each column for Dave (4) and Frank (6) first. Then
-- replace 'TODO' with a ->> expression for the nested path $.contact.email
SELECT id, first_name,
       prefs->'$.genres'               AS genres,
       prefs->>'$.genres[0]'           AS first_genre,
       JSON_LENGTH(prefs->'$.genres')  AS genre_count,
       'TODO'                          AS email_ok
FROM customers
WHERE id IN (1, 4, 6, 7)
ORDER BY id;

-- TODO 4 · Nothing to edit: predict has_genres for Dave (4) and for Carol (3),
-- who has no prefs at all. Why are they different?
SELECT id, first_name,
       JSON_CONTAINS_PATH(prefs, 'one', '$.genres') AS has_genres
FROM customers
ORDER BY id;

-- TODO 5 · Two changes, one UPDATE each. Turn them on and fill the gaps:
-- Bob (2) signs up for the newsletter (JSON_SET), Grace (7) adds
-- 'Science Fiction' to her genres (JSON_ARRAY_APPEND) and drops the
-- language key (JSON_REMOVE) in the same UPDATE.
-- UPDATE customers SET prefs = JSON_SET(prefs, '$.___', TRUE) WHERE id = 2;
-- UPDATE customers
-- SET prefs = JSON_REMOVE(JSON_ARRAY_APPEND(prefs, '$.genres', '___'), '$.___')
-- WHERE id = 7;
SELECT id, first_name, prefs FROM customers WHERE id IN (2, 7) ORDER BY id;

-- TODO 6 · An indexed generated column for the newsletter list. The path
-- '$.todo' exists nowhere, so every row is NULL. Fix the path.
ALTER TABLE customers
    ADD COLUMN newsletter VARCHAR(5) GENERATED ALWAYS AS (prefs->>'$.todo') VIRTUAL,
    ADD INDEX idx_customers_newsletter (newsletter);
SELECT newsletter, COUNT(*) AS customers
FROM customers
GROUP BY newsletter
ORDER BY newsletter;

-- Leave customers as bookstore.sql has it
ALTER TABLE customers DROP INDEX idx_customers_newsletter, DROP COLUMN newsletter, DROP COLUMN prefs;

-- Expected when done: TODO 1 Alice, Frank, Grace (1, 6, 7). TODO 2 Alice and
-- Grace. TODO 3 Alice ["Science Fiction", "Classic"] / Science Fiction / 2 /
-- true; Dave NULL / NULL / NULL / NULL; Frank [] / NULL / 0 / NULL; Grace
-- ["Fantasy", "Classic"] / Fantasy / 2 / NULL. TODO 4 has_genres 1 for 1, 2,
-- 6, 7; 0 for Dave (prefs without that key); NULL for 3, 5, 8 (no prefs).
-- TODO 5 Bob {"genres": ["Dystopian"], "newsletter": true}; Grace
-- {"genres": ["Fantasy", "Classic", "Science Fiction"], "newsletter": true}.
-- TODO 6 NULL 3, false 1, true 4.
