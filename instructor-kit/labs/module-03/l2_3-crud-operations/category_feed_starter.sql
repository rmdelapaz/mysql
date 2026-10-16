-- state: schema
-- =====================================================================
-- category_feed_starter.sql: a nightly feed with an upsert
-- Session 3 · Lesson 2.3 · MySQL Foundations instructor kit
--
-- A supplier sends its category list every night: some names are new, some
-- are already there with a new description, some have not changed. A plain
-- INSERT fails on the first existing name (error 1062: name is UNIQUE). Your
-- job: one upsert that handles all three cases, then a look at INSERT IGNORE
-- and REPLACE. The statements are turned off with -- ; remove the -- from
-- the statement lines, fill each ___, save and run again.
--
-- Run it inside bookstore:
--   SOURCE labs/module-03/l2_3-crud-operations/category_feed_starter.sql
-- Every run fills categories first and empties it at the end.
-- =====================================================================

INSERT INTO categories (name, description) VALUES
    ('Fiction', 'Novels and stories'),
    ('Poetry', 'Verse'),
    ('Travel', 'Guides and journeys'),
    ('History', 'The past, told well');

-- TODO 1 · Tonight's feed: Poetry has a new text, Travel is unchanged, Cooking
-- is new. Predict ROW_COUNT() first: 1 per inserted row, 2 per updated row,
-- 0 per row that already had those values.
-- INSERT INTO categories (name, description) VALUES
--     ('Poetry', 'Poems and verse collections'),
--     ('Travel', 'Guides and journeys'),
--     ('Cooking', 'Recipes and kitchen craft') AS new
-- ON DUPLICATE KEY UPDATE description = ___;
-- SELECT ROW_COUNT() AS affected;

SELECT id, name, description FROM categories ORDER BY id;

-- TODO 2 · INSERT IGNORE with a name that exists. What is stored? What does
-- SHOW WARNINGS say?
-- INSERT IGNORE INTO categories (name, description) VALUES ('History', 'This text is never stored');
-- SHOW WARNINGS;

-- TODO 3 · REPLACE with a name that exists. Compare Fiction's id and
-- description before and after.
-- REPLACE INTO categories (name) VALUES ('Fiction');

SELECT id, name, description FROM categories ORDER BY id;

-- Expected when done: affected 3 (2 for Poetry, 0 for Travel, 1 for Cooking);
-- Poetry's new text and Cooking with a new id; INSERT IGNORE stores nothing and
-- warns 1062; after REPLACE, Fiction has a new id and a NULL description.
-- See the README for the exact ids.

TRUNCATE TABLE categories;
