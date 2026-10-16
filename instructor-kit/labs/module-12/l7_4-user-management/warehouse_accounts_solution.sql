-- state: full
-- =====================================================================
-- warehouse_accounts_solution.sql: least-privilege accounts for two programs
-- Session 12 · Lesson 7.4 · MySQL Foundations instructor kit · instructor reference
--
-- Run as root (or another administrator) with bookstore as the current
-- database. Two programs get their own accounts: the warehouse scanner,
-- which reads the catalog and may only flip books.in_stock, and the
-- accounting export, which reads orders but may see only customers' names.
-- Every account here is a kit_ demo account; the last line drops them all.
-- Never practice on root itself.
-- =====================================================================

DROP USER IF EXISTS 'kit_warehouse'@'localhost', 'kit_accounting'@'localhost';
CREATE USER 'kit_warehouse'@'localhost'  IDENTIFIED BY 'CHANGE-ME-warehouse-1';
CREATE USER 'kit_accounting'@'localhost' IDENTIFIED BY 'CHANGE-ME-accounting-1';

-- 1 · A new account can log in and do nothing else
SHOW GRANTS FOR 'kit_warehouse'@'localhost';

-- 2 · The warehouse: read books and authors, change only the in_stock column
GRANT SELECT ON bookstore.books   TO 'kit_warehouse'@'localhost';
GRANT SELECT ON bookstore.authors TO 'kit_warehouse'@'localhost';
GRANT UPDATE (in_stock) ON bookstore.books TO 'kit_warehouse'@'localhost';
SHOW GRANTS FOR 'kit_warehouse'@'localhost';

-- 3 · Accounting: read orders and their lines, and three customer columns
GRANT SELECT ON bookstore.orders      TO 'kit_accounting'@'localhost';
GRANT SELECT ON bookstore.order_items TO 'kit_accounting'@'localhost';
GRANT SELECT (id, first_name, last_name) ON bookstore.customers TO 'kit_accounting'@'localhost';
SHOW GRANTS FOR 'kit_accounting'@'localhost';

-- 4 · An audit in SQL: every table and column privilege of the kit_ accounts
SELECT GRANTEE, TABLE_NAME, PRIVILEGE_TYPE
FROM information_schema.TABLE_PRIVILEGES
WHERE GRANTEE LIKE '%kit\_%'
ORDER BY GRANTEE, TABLE_NAME, PRIVILEGE_TYPE;
SELECT GRANTEE, TABLE_NAME, COLUMN_NAME, PRIVILEGE_TYPE
FROM information_schema.COLUMN_PRIVILEGES
WHERE GRANTEE LIKE '%kit\_%'
ORDER BY GRANTEE, TABLE_NAME, COLUMN_NAME;

-- 5 · Accounting no longer needs order lines; the warehouse scanner is retired
REVOKE SELECT ON bookstore.order_items FROM 'kit_accounting'@'localhost';
ALTER USER 'kit_warehouse'@'localhost' ACCOUNT LOCK;
SHOW GRANTS FOR 'kit_accounting'@'localhost';
SELECT user, host, plugin, account_locked
FROM mysql.user
WHERE user LIKE 'kit\_%'
ORDER BY user;

-- To log in as these accounts in a second window first, put -- in front of
-- the next line, SOURCE the file, test, then run the DROP USER by hand.
DROP USER 'kit_warehouse'@'localhost', 'kit_accounting'@'localhost';
