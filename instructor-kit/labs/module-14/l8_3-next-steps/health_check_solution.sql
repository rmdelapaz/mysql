-- state: full
-- =====================================================================
-- health_check_solution.sql: REFERENCE for health_check_starter.sql
-- Session 14 · Lesson 8.3 · MySQL Foundations instructor kit
--
-- An audit you can point at any database: it reads information_schema,
-- never the data. A deliberately flawed "legacy" table is planted first
-- so every check has something to find; it is dropped at the end.
-- Instructor copy.
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
SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, CHARACTER_SET_NAME
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = @db
  AND (DATA_TYPE IN ('float', 'double')
       OR CHARACTER_SET_NAME NOT IN ('utf8mb4', 'binary'))
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- Check 3: columns named like a key (..._id) that no foreign key protects
SELECT col.TABLE_NAME, col.COLUMN_NAME
FROM information_schema.COLUMNS AS col
LEFT JOIN information_schema.KEY_COLUMN_USAGE AS k
       ON k.TABLE_SCHEMA = col.TABLE_SCHEMA
      AND k.TABLE_NAME = col.TABLE_NAME
      AND k.COLUMN_NAME = col.COLUMN_NAME
      AND k.REFERENCED_TABLE_NAME IS NOT NULL
WHERE col.TABLE_SCHEMA = @db
  AND col.COLUMN_NAME LIKE '%\_id'
  AND k.CONSTRAINT_NAME IS NULL
ORDER BY col.TABLE_NAME, col.COLUMN_NAME;

-- Check 4: what deleting a parent row does, for every foreign key that
-- does more than refuse (CASCADE or SET NULL deserve a second look)
SELECT TABLE_NAME, CONSTRAINT_NAME, REFERENCED_TABLE_NAME, DELETE_RULE
FROM information_schema.REFERENTIAL_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = @db
  AND DELETE_RULE IN ('CASCADE', 'SET NULL')
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

-- Cleanup: remove the planted table
DROP TABLE kit_legacy_refunds;
