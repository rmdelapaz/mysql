-- state: full
-- =====================================================================
-- least_privilege_starter.sql: roles, accounts and an audit
-- Session 14 · Lesson 8.2 · MySQL Foundations instructor kit
--
-- Milestone 6 in miniature, on the bookstore. The shop's till program and
-- its owner need accounts. The till reads the catalog, records customers
-- and restocks books ONLY through the kit_restock procedure; the owner
-- only reads reports; nobody may delete anything. A hurried colleague
-- wrote the grants below: they run, but they give far too much. The
-- audit at the end shows it. Fix the TODOs until the audit is right.
-- Everything the script creates is dropped again at the end.
--
--   SOURCE labs/module-14/l8_2-final-project/least_privilege_starter.sql
-- =====================================================================

-- 0. Start clean, so the script can run again
DROP USER IF EXISTS 'kit_till_app'@'localhost', 'kit_owner'@'localhost';
DROP ROLE IF EXISTS 'kit_shop_till', 'kit_shop_owner';
DROP PROCEDURE IF EXISTS kit_restock;

-- 1. The only way the till may change stock: a procedure
CREATE PROCEDURE kit_restock(IN p_book_id INT)
    UPDATE books SET in_stock = TRUE WHERE id = p_book_id;

-- 2. One role per job
CREATE ROLE 'kit_shop_till', 'kit_shop_owner';

-- the owner reads every report, changes nothing
-- TODO 1: the owner only reads. Keep SELECT, remove the other three.
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstore.* TO 'kit_shop_owner';

-- the till reads the catalog, records customers, restocks through the procedure
-- TODO 2: ALL PRIVILEGES is the shortcut that defeats the point. Replace
--   this line with three grants: SELECT on bookstore.*; INSERT, UPDATE on
--   bookstore.customers only; EXECUTE ON PROCEDURE bookstore.kit_restock.
GRANT ALL PRIVILEGES ON bookstore.* TO 'kit_shop_till';

-- 3. One account per program or person, the role switched on at login
CREATE USER 'kit_till_app'@'localhost' IDENTIFIED BY 'Change-Me-Till-2026';
GRANT 'kit_shop_till' TO 'kit_till_app'@'localhost';
-- TODO 3: without this line the role stays switched off at login and the
--   till gets error 1142 on everything (the silent mistake of Lesson 7.4).
--   Turn it on, and write the same line for the owner below.
-- SET DEFAULT ROLE 'kit_shop_till' TO 'kit_till_app'@'localhost';

CREATE USER 'kit_owner'@'localhost' IDENTIFIED BY 'Change-Me-Owner-2026';
GRANT 'kit_shop_owner' TO 'kit_owner'@'localhost';

-- 4. What the till's account may do, with its role expanded
SHOW GRANTS FOR 'kit_till_app'@'localhost' USING 'kit_shop_till';

-- 5. The audit: every privilege the two roles hold, from information_schema
SELECT GRANTEE, 'whole database' AS on_what, PRIVILEGE_TYPE
FROM information_schema.SCHEMA_PRIVILEGES
WHERE GRANTEE LIKE '''kit_shop%'
UNION ALL
SELECT GRANTEE, TABLE_NAME, PRIVILEGE_TYPE
FROM information_schema.TABLE_PRIVILEGES
WHERE GRANTEE LIKE '''kit_shop%'
ORDER BY GRANTEE, on_what, PRIVILEGE_TYPE;

-- 6. The rule that matters most: nobody may delete history
SELECT COUNT(*) AS delete_privileges
FROM (SELECT PRIVILEGE_TYPE FROM information_schema.SCHEMA_PRIVILEGES WHERE GRANTEE LIKE '''kit_shop%'
      UNION ALL
      SELECT PRIVILEGE_TYPE FROM information_schema.TABLE_PRIVILEGES WHERE GRANTEE LIKE '''kit_shop%') AS p
WHERE PRIVILEGE_TYPE = 'DELETE';

-- Expected when done: SHOW GRANTS lists five lines for kit_till_app
-- (USAGE; SELECT ON `bookstore`.*; INSERT, UPDATE ON `bookstore`.`customers`;
-- EXECUTE ON PROCEDURE `bookstore`.`kit_restock`; the role kit_shop_till);
-- the audit has four rows: kit_shop_owner whole database SELECT,
-- kit_shop_till customers INSERT and UPDATE, kit_shop_till whole database
-- SELECT; delete_privileges 0. (EXECUTE on a procedure is not in these two
-- information_schema tables; SHOW GRANTS shows it.)

-- Cleanup: accounts and roles live outside the database; remove them
DROP USER 'kit_till_app'@'localhost', 'kit_owner'@'localhost';
DROP ROLE 'kit_shop_till', 'kit_shop_owner';
DROP PROCEDURE kit_restock;
