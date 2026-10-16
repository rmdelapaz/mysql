-- state: full
-- =====================================================================
-- least_privilege_solution.sql: REFERENCE for least_privilege_starter.sql
-- Session 14 · Lesson 8.2 · MySQL Foundations instructor kit
--
-- Milestone 6 in miniature, on the bookstore: a role per job, one account
-- per program or person, no DELETE anywhere, and changes to stock only
-- through a procedure. Everything it creates is dropped at the end.
-- Instructor copy.
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
GRANT SELECT ON bookstore.* TO 'kit_shop_owner';

-- the till reads the catalog, records customers, restocks through the procedure
GRANT SELECT ON bookstore.* TO 'kit_shop_till';
GRANT INSERT, UPDATE ON bookstore.customers TO 'kit_shop_till';
GRANT EXECUTE ON PROCEDURE bookstore.kit_restock TO 'kit_shop_till';

-- 3. One account per program or person, the role switched on at login
CREATE USER 'kit_till_app'@'localhost' IDENTIFIED BY 'Change-Me-Till-2026';
GRANT 'kit_shop_till' TO 'kit_till_app'@'localhost';
SET DEFAULT ROLE 'kit_shop_till' TO 'kit_till_app'@'localhost';

CREATE USER 'kit_owner'@'localhost' IDENTIFIED BY 'Change-Me-Owner-2026';
GRANT 'kit_shop_owner' TO 'kit_owner'@'localhost';
SET DEFAULT ROLE 'kit_shop_owner' TO 'kit_owner'@'localhost';

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

-- Cleanup: accounts and roles live outside the database; remove them
DROP USER 'kit_till_app'@'localhost', 'kit_owner'@'localhost';
DROP ROLE 'kit_shop_till', 'kit_shop_owner';
DROP PROCEDURE kit_restock;
