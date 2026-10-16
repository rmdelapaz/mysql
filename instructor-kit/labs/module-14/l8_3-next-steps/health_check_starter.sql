-- state: full
-- =====================================================================
-- health_check_starter.sql: an audit for any database
-- Session 14 · Lesson 8.3 · MySQL Foundations instructor kit
--
-- The lesson's health check reads information_schema, never the data, so
-- it works on any database. This version adds two checks the lesson does
-- not have. A deliberately flawed "legacy" table is planted first so
-- every check has something to find; it is dropped at the end.
-- Check 1 is done. TODOs 2 to 4 finish the others. Then point the file at
-- your project (USE tool_library; first) and fix what it reports.
--
--   SOURCE labs/module-14/l8_3-next-steps/health_check_starter.sql
-- =====================================================================

-- 0. Plant an old table of the kind real projects inherit
DROP TABLE IF EXISTS kit_legacy_refunds;
CREATE TABLE kit_legacy_refunds (
    order_id    INT,
    amount      FLOAT,
    reason      VARCHAR(100) CHARACTER SET latin1,
    refunded_on DATE
);

-- 1. Which database? Set once; DATABASE() is the one you are in
SET @db = DATABASE();

-- Check 1: tables without a primary key
SELECT t.TABLE_NAME AS table_without_pk
FROM information_schema.TABLES AS t
LEFT JOIN information_schema.TABLE_CONSTRAINTS AS c
       ON c.TABLE_SCHEMA = t.TABLE_SCHEMA
      AND c.TABLE_NAME = t.TABLE_NAME
      AND c.CONSTRAINT_TYPE = 'PRIMARY KEY'
WHERE t.TABLE_SCHEMA = @db
  AND t.TABLE_TYPE = 'BASE TABLE'
  AND c.CONSTRAINT_NAME IS NULL
ORDER BY t.TABLE_NAME;

-- Check 2: money in FLOAT or DOUBLE, text not in utf8mb4
-- TODO 2: replace the placeholder with a query on information_schema.COLUMNS
--   (TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, CHARACTER_SET_NAME) for this @db
--   where DATA_TYPE is 'float' or 'double' OR CHARACTER_SET_NAME is NOT IN
--   ('utf8mb4', 'binary'). (Number columns have no character set: NULL.)
SELECT 'TODO 2: risky types' AS todo;

-- Check 3: columns named like a key (..._id) that no foreign key protects
-- TODO 3: the pattern is "find what is missing" (LEFT JOIN ... IS NULL).
--   Remove the -- from the six lines below and fill in the two ___ gaps:
--   the join must only match KEY_COLUMN_USAGE rows that REFERENCE another
--   table, and the WHERE must keep the columns that found no such row.
-- SELECT col.TABLE_NAME, col.COLUMN_NAME
-- FROM information_schema.COLUMNS AS col
-- LEFT JOIN information_schema.KEY_COLUMN_USAGE AS k
--        ON k.TABLE_SCHEMA = col.TABLE_SCHEMA AND k.TABLE_NAME = col.TABLE_NAME
--       AND k.COLUMN_NAME = col.COLUMN_NAME AND k.REFERENCED_TABLE_NAME IS ___
-- WHERE col.TABLE_SCHEMA = @db AND col.COLUMN_NAME LIKE '%\_id' AND k.CONSTRAINT_NAME IS ___
-- ORDER BY col.TABLE_NAME, col.COLUMN_NAME;

-- Check 4: what deleting a parent row does, for every foreign key that
-- does more than refuse (CASCADE or SET NULL deserve a second look)
SELECT TABLE_NAME, CONSTRAINT_NAME, REFERENCED_TABLE_NAME, DELETE_RULE
FROM information_schema.REFERENTIAL_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = @db
-- TODO 4: this lists all seven foreign keys. Keep only the ones whose
--   DELETE_RULE is CASCADE or SET NULL (add one AND line here).
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

-- Expected when done: check 1 kit_legacy_refunds; check 2
-- kit_legacy_refunds amount float NULL and reason varchar(100) latin1;
-- check 3 kit_legacy_refunds order_id; check 4 four rows: book_categories
-- fk_bc_book books CASCADE, book_categories fk_bc_category categories
-- CASCADE, employees fk_employees_manager employees SET NULL, order_items
-- fk_items_order orders CASCADE.

-- Cleanup: remove the planted table
DROP TABLE kit_legacy_refunds;
