-- state: schema
-- =====================================================================
-- category_feed_solution.sql: a nightly feed with an upsert
-- Session 3 · Lesson 2.3 · MySQL Foundations instructor kit · instructor reference
--
-- A supplier sends its category list every night: some names are new, some
-- are already there with a new description, some have not changed. One
-- INSERT ... AS new ON DUPLICATE KEY UPDATE handles all three; then INSERT
-- IGNORE and REPLACE show their sharp edges. Runs inside bookstore (schema
-- state) and empties categories again at the end.
-- =====================================================================

INSERT INTO categories (name, description) VALUES
    ('Fiction', 'Novels and stories'),
    ('Poetry', 'Verse'),
    ('Travel', 'Guides and journeys'),
    ('History', 'The past, told well');

-- 1 · Tonight's feed: Poetry has a new text, Travel is unchanged, Cooking is new
INSERT INTO categories (name, description) VALUES
    ('Poetry', 'Poems and verse collections'),
    ('Travel', 'Guides and journeys'),
    ('Cooking', 'Recipes and kitchen craft') AS new
ON DUPLICATE KEY UPDATE description = new.description;
SELECT ROW_COUNT() AS affected;

SELECT id, name, description FROM categories ORDER BY id;

-- 2 · INSERT IGNORE with a name that exists: no error, nothing stored, a warning
INSERT IGNORE INTO categories (name, description) VALUES ('History', 'This text is never stored');
SHOW WARNINGS;

-- 3 · REPLACE with a name that exists: delete + insert, a new id, the description lost
REPLACE INTO categories (name) VALUES ('Fiction');

SELECT id, name, description FROM categories ORDER BY id;

TRUNCATE TABLE categories;
