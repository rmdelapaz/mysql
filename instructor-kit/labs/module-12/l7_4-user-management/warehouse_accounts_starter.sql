-- state: full
-- =====================================================================
-- warehouse_accounts_starter.sql: least-privilege accounts for two programs
-- Session 12 · Lesson 7.4 · MySQL Foundations instructor kit
--
-- Run as root (or another administrator) with bookstore as the current
-- database. Two programs get their own accounts: the warehouse scanner,
-- which reads the catalog and may only flip books.in_stock, and the
-- accounting export, which reads orders but may see only customers' names.
-- Every account here is a kit_ demo account; the file drops them at the
-- end, so you can edit it and SOURCE it again. Never practice on root.
--
--   SOURCE labs/module-12/l7_4-user-management/warehouse_accounts_starter.sql
-- =====================================================================

DROP USER IF EXISTS 'kit_warehouse'@'localhost', 'kit_accounting'@'localhost';
CREATE USER 'kit_warehouse'@'localhost'  IDENTIFIED BY 'CHANGE-ME-warehouse-1';
CREATE USER 'kit_accounting'@'localhost' IDENTIFIED BY 'CHANGE-ME-accounting-1';

-- 1 · A new account can log in and do nothing else (nothing to edit)
SHOW GRANTS FOR 'kit_warehouse'@'localhost';

-- TODO 2 · The warehouse: SELECT on books and on authors, and UPDATE of the
-- in_stock column only. Turn the three lines on and fill the gaps.
-- GRANT SELECT ON bookstore.___   TO 'kit_warehouse'@'localhost';
-- GRANT SELECT ON bookstore.___ TO 'kit_warehouse'@'localhost';
-- GRANT UPDATE (___) ON bookstore.books TO 'kit_warehouse'@'localhost';
SHOW GRANTS FOR 'kit_warehouse'@'localhost';

-- TODO 3 · Accounting: SELECT on orders and order_items, and SELECT on only
-- the id, first_name and last_name columns of customers. Write the three
-- GRANTs yourself (the column syntax: GRANT SELECT (col, col) ON db.table ...).
SHOW GRANTS FOR 'kit_accounting'@'localhost';

-- 4 · An audit in SQL: every table and column privilege of the kit_ accounts
-- (nothing to edit; predict how many rows each query returns when done)
SELECT GRANTEE, TABLE_NAME, PRIVILEGE_TYPE
FROM information_schema.TABLE_PRIVILEGES
WHERE GRANTEE LIKE '%kit\_%'
ORDER BY GRANTEE, TABLE_NAME, PRIVILEGE_TYPE;
SELECT GRANTEE, TABLE_NAME, COLUMN_NAME, PRIVILEGE_TYPE
FROM information_schema.COLUMN_PRIVILEGES
WHERE GRANTEE LIKE '%kit\_%'
ORDER BY GRANTEE, TABLE_NAME, COLUMN_NAME;

-- TODO 5 · Accounting no longer needs order lines (REVOKE at the level you
-- granted), and the warehouse scanner is retired (lock it, keep its grants).
-- REVOKE SELECT ON bookstore.___ FROM 'kit_accounting'@'localhost';
-- ALTER USER 'kit_warehouse'@'localhost' ACCOUNT ___;
SHOW GRANTS FOR 'kit_accounting'@'localhost';
SELECT user, host, plugin, account_locked
FROM mysql.user
WHERE user LIKE 'kit\_%'
ORDER BY user;

-- TODO 6 · Test both directions in a SECOND window (see the README): put --
-- in front of the DROP USER line, SOURCE this file, then log in with
--   mysql -u kit_warehouse -p bookstore      (before TODO 5 locks it)
-- and try  UPDATE books SET in_stock = FALSE WHERE id = 1;  (works) and
--          UPDATE books SET price = 0 WHERE id = 1;          (ERROR 1143).
-- Then run the DROP USER line by hand.
DROP USER 'kit_warehouse'@'localhost', 'kit_accounting'@'localhost';

-- Expected when done: TODO 2 two GRANT lines besides USAGE: SELECT on
-- authors, and SELECT, UPDATE (`in_stock`) on books (MySQL merges the two
-- books grants). TODO 3 three: SELECT (`first_name`, `id`, `last_name`) on
-- customers, SELECT on order_items, SELECT on orders. Audit: 4 table rows
-- and 4 column rows. TODO 5 accounting keeps customers' columns and orders;
-- kit_accounting N, kit_warehouse Y; both caching_sha2_password.
