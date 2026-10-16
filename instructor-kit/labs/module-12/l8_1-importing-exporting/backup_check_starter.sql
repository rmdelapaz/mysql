-- state: full
-- =====================================================================
-- backup_check_starter.sql: before a backup, an export and a restore test
-- Session 12 · Lesson 8.1 · MySQL Foundations instructor kit
--
-- Everything mysqldump itself does happens at the terminal (see this
-- session's README). This lab is the SQL around it: what the server allows
-- with files, a least-privilege backup account, the numbers a restore test
-- compares, and a report shaped for INTO OUTFILE, printed on screen. Run it
-- as root with bookstore as the current database. Nothing is written to
-- disk; the kit_ account is dropped at the end, so you can edit the file
-- and SOURCE it again.
--
--   SOURCE labs/module-12/l8_1-importing-exporting/backup_check_starter.sql
-- =====================================================================

-- 1 · What this server allows with files (nothing to edit; local_infile is
--     0 on a fresh install, 1 if you switched it on in Lesson 8.1)
SELECT CASE
           WHEN @@secure_file_priv IS NULL THEN 'disabled'
           WHEN @@secure_file_priv = ''    THEN 'anywhere (unsafe)'
           ELSE 'one folder only'
       END AS server_side_files,
       @@local_infile AS local_infile;

-- TODO 2 · A backup account: read everything mysqldump needs, change
-- nothing. The five privileges are SELECT, SHOW VIEW, TRIGGER, LOCK TABLES
-- and EVENT, on the whole bookstore database. Turn the GRANT on, fill the gap.
DROP USER IF EXISTS 'kit_backup'@'localhost';
CREATE USER 'kit_backup'@'localhost' IDENTIFIED BY 'CHANGE-ME-backup-1';
-- GRANT ___ ON bookstore.* TO 'kit_backup'@'localhost';
SHOW GRANTS FOR 'kit_backup'@'localhost';

-- 3 · Prove it cannot write (nothing to edit; both answers must be 0): no INSERT, UPDATE, DELETE, DROP or FILE anywhere
SELECT COUNT(*) AS write_privileges
FROM information_schema.SCHEMA_PRIVILEGES
WHERE GRANTEE = '''kit_backup''@''localhost'''
  AND PRIVILEGE_TYPE IN ('INSERT', 'UPDATE', 'DELETE', 'DROP', 'ALTER', 'CREATE');
SELECT COUNT(*) AS global_privileges
FROM information_schema.USER_PRIVILEGES
WHERE GRANTEE = '''kit_backup''@''localhost'''
  AND PRIVILEGE_TYPE <> 'USAGE';

-- TODO 4 · The restore test's reference numbers (write them in
-- restore_log.txt). Add one UNION ALL line for order_items, like the others.
SELECT 'books' AS table_name, COUNT(*) AS row_count FROM books
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'orders', COUNT(*) FROM orders;
SELECT SUM(quantity * price_at_time) AS revenue_check FROM order_items;

-- TODO 5 · Revenue per category, shaped as a CSV with a header row. As
-- shipped there is no header row. Replace the first SELECT line in the
-- brackets with one that gives part 0 and the three column names as text:
--   SELECT 0 AS part, 'category' AS category, 'books_sold' AS books_sold, 'revenue' AS revenue
-- Why does the outer ORDER BY start with part? (The README shows the
-- INTO OUTFILE clause that writes the result to a file.)
SELECT category, books_sold, revenue
FROM (
    SELECT 0 AS part, NULL AS category, NULL AS books_sold, NULL AS revenue FROM DUAL WHERE FALSE
    UNION ALL
    SELECT 1, c.name, SUM(oi.quantity), SUM(oi.quantity * oi.price_at_time)
    FROM categories AS c
    JOIN book_categories AS bc ON bc.category_id = c.id
    JOIN order_items AS oi     ON oi.book_id = bc.book_id
    GROUP BY c.id, c.name
) AS t
ORDER BY part, category;

DROP USER 'kit_backup'@'localhost';

-- Expected when done: 1 'one folder only' (your local_infile may be 0).
-- TODO 2 GRANT SELECT, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER ON `bookstore`.*
-- (MySQL lists them in its own order). 3: 0 and 0. TODO 4 books 11,
-- customers 8, orders 12, order_items 18; revenue_check 237.29. TODO 5 the
-- header row category / books_sold / revenue, then Classic 10 96.90,
-- Dystopian 7 70.43, Fantasy 5 64.95, Fiction 21 237.29, Science Fiction 6 75.44.
