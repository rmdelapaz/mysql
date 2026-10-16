-- state: full
-- =====================================================================
-- backup_check_solution.sql: before a backup, an export and a restore test
-- Session 12 · Lesson 8.1 · MySQL Foundations instructor kit · instructor reference
--
-- Everything mysqldump itself does happens at the terminal (see this
-- session's README). This lab is the SQL around it: what the server allows
-- with files, a least-privilege backup account, the numbers a restore test
-- compares, and a report shaped for INTO OUTFILE, printed on screen. Run it
-- as root with bookstore as the current database. Nothing is written to
-- disk; the kit_ account is dropped at the end.
-- =====================================================================

-- 1 · What this server allows with files
SELECT CASE
           WHEN @@secure_file_priv IS NULL THEN 'disabled'
           WHEN @@secure_file_priv = ''    THEN 'anywhere (unsafe)'
           ELSE 'one folder only'
       END AS server_side_files,
       @@local_infile AS local_infile;

-- 2 · A backup account: read everything mysqldump needs, change nothing
DROP USER IF EXISTS 'kit_backup'@'localhost';
CREATE USER 'kit_backup'@'localhost' IDENTIFIED BY 'CHANGE-ME-backup-1';
GRANT SELECT, SHOW VIEW, TRIGGER, LOCK TABLES, EVENT ON bookstore.* TO 'kit_backup'@'localhost';
SHOW GRANTS FOR 'kit_backup'@'localhost';

-- 3 · Prove it cannot write: no INSERT, UPDATE, DELETE, DROP or FILE anywhere
SELECT COUNT(*) AS write_privileges
FROM information_schema.SCHEMA_PRIVILEGES
WHERE GRANTEE = '''kit_backup''@''localhost'''
  AND PRIVILEGE_TYPE IN ('INSERT', 'UPDATE', 'DELETE', 'DROP', 'ALTER', 'CREATE');
SELECT COUNT(*) AS global_privileges
FROM information_schema.USER_PRIVILEGES
WHERE GRANTEE = '''kit_backup''@''localhost'''
  AND PRIVILEGE_TYPE <> 'USAGE';

-- 4 · The restore test's reference numbers: write them in restore_log.txt
SELECT 'books' AS table_name, COUNT(*) AS row_count FROM books
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items;
SELECT SUM(quantity * price_at_time) AS revenue_check FROM order_items;

-- 5 · Revenue per category, shaped as a CSV with a header row (add the
--     INTO OUTFILE clause from the README to write it to a file)
SELECT category, books_sold, revenue
FROM (
    SELECT 0 AS part, 'category' AS category, 'books_sold' AS books_sold, 'revenue' AS revenue
    UNION ALL
    SELECT 1, c.name, SUM(oi.quantity), SUM(oi.quantity * oi.price_at_time)
    FROM categories AS c
    JOIN book_categories AS bc ON bc.category_id = c.id
    JOIN order_items AS oi     ON oi.book_id = bc.book_id
    GROUP BY c.id, c.name
) AS t
ORDER BY part, category;

DROP USER 'kit_backup'@'localhost';
