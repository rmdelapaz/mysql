-- state: full
-- =====================================================================
-- reader_prefs_solution.sql: read, filter and change a JSON column on customers
-- Session 11 · Lesson 7.3 · MySQL Foundations instructor kit · instructor reference
--
-- The lesson put JSON on books. Here customers get a prefs column: whether
-- they want the newsletter, their favorite genres (an array) and, for some,
-- a nested contact object. Not every customer has every key, and three have
-- no prefs at all (NULL). The file adds the column and removes it again at
-- the end, so it can run again. (If a run stops halfway, reload
-- labs/_states/bookstore.sql: MySQL has no DROP COLUMN IF EXISTS.)
-- =====================================================================

ALTER TABLE customers ADD COLUMN prefs JSON;
UPDATE customers SET prefs = '{"newsletter": true, "genres": ["Science Fiction", "Classic"], "contact": {"email": true, "sms": false}}' WHERE id = 1;
UPDATE customers SET prefs = '{"newsletter": false, "genres": ["Dystopian"]}' WHERE id = 2;
UPDATE customers SET prefs = '{"newsletter": false}' WHERE id = 4;
UPDATE customers SET prefs = '{"newsletter": true, "genres": []}' WHERE id = 6;
UPDATE customers SET prefs = '{"newsletter": true, "genres": ["Fantasy", "Classic"], "language": "es"}' WHERE id = 7;

-- 1 · Who wants the newsletter? (->> gives text: a JSON true reads 'true')
SELECT id, first_name
FROM customers
WHERE prefs->>'$.newsletter' = 'true'
ORDER BY id;

-- 2 · Who likes Classic?
SELECT id, first_name
FROM customers
WHERE 'Classic' MEMBER OF (prefs->'$.genres')
ORDER BY id;

-- 3 · Genres per customer: the array, its first element, its length, a nested value
SELECT id, first_name,
       prefs->'$.genres'               AS genres,
       prefs->>'$.genres[0]'           AS first_genre,
       JSON_LENGTH(prefs->'$.genres')  AS genre_count,
       prefs->>'$.contact.email'       AS email_ok
FROM customers
WHERE id IN (1, 4, 6, 7)
ORDER BY id;

-- 4 · Who has a genres key at all, and who has no prefs?
SELECT id, first_name,
       JSON_CONTAINS_PATH(prefs, 'one', '$.genres') AS has_genres
FROM customers
ORDER BY id;

-- 5 · Changes: Bob signs up for the newsletter; Grace adds Science Fiction
--     and stops wanting Spanish mail (one UPDATE each)
UPDATE customers SET prefs = JSON_SET(prefs, '$.newsletter', TRUE) WHERE id = 2;
UPDATE customers
SET prefs = JSON_REMOVE(JSON_ARRAY_APPEND(prefs, '$.genres', 'Science Fiction'), '$.language')
WHERE id = 7;
SELECT id, first_name, prefs FROM customers WHERE id IN (2, 7) ORDER BY id;

-- 6 · An indexed generated column for the newsletter list
ALTER TABLE customers
    ADD COLUMN newsletter VARCHAR(5) GENERATED ALWAYS AS (prefs->>'$.newsletter') VIRTUAL,
    ADD INDEX idx_customers_newsletter (newsletter);
SELECT newsletter, COUNT(*) AS customers
FROM customers
GROUP BY newsletter
ORDER BY newsletter;

-- Leave customers as bookstore.sql has it
ALTER TABLE customers DROP INDEX idx_customers_newsletter, DROP COLUMN newsletter, DROP COLUMN prefs;
