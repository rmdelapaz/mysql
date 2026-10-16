-- state: full
-- =====================================================================
-- staff_roles_starter.sql: roles for the shop floor, granted, activated, changed
-- Session 12 · Lesson 7.4 · MySQL Foundations instructor kit
--
-- Two jobs, two roles: every clerk reads the catalog; cashiers also record
-- orders. Two demo staff accounts get them. Then the job changes once, for
-- everybody, by changing a role. Run as root with bookstore as the current
-- database; everything here is a kit_ demo account or role, dropped at the
-- end, so you can edit the file and SOURCE it again. Steps 1 and 2 are done;
-- each TODO is one statement.
--
--   SOURCE labs/module-12/l7_4-user-management/staff_roles_starter.sql
-- =====================================================================

DROP USER IF EXISTS 'kit_ana'@'localhost', 'kit_ben'@'localhost';
DROP ROLE IF EXISTS 'kit_clerk', 'kit_cashier';

-- 1 · Two roles, privileges granted once
CREATE ROLE 'kit_clerk', 'kit_cashier';
GRANT SELECT ON bookstore.books   TO 'kit_clerk';
GRANT SELECT ON bookstore.authors TO 'kit_clerk';
GRANT INSERT ON bookstore.orders      TO 'kit_cashier';
GRANT INSERT ON bookstore.order_items TO 'kit_cashier';

-- 2 · Two people: Ana is a clerk, Ben is a clerk and a cashier
CREATE USER 'kit_ana'@'localhost' IDENTIFIED BY 'CHANGE-ME-ana-1';
CREATE USER 'kit_ben'@'localhost' IDENTIFIED BY 'CHANGE-ME-ben-1';
GRANT 'kit_clerk' TO 'kit_ana'@'localhost';
GRANT 'kit_clerk', 'kit_cashier' TO 'kit_ben'@'localhost';

-- TODO 3 · The step everybody forgets. As shipped, the query below is an
-- Empty set: Ana and Ben would log in with no active roles (ERROR 1142 on
-- their first SELECT). Turn the line on.
-- SET DEFAULT ROLE ALL TO 'kit_ana'@'localhost', 'kit_ben'@'localhost';
SELECT user, default_role_user
FROM mysql.default_roles
WHERE user LIKE 'kit\_%'
ORDER BY user, default_role_user;

-- 4 · What Ben's roles add up to (nothing to edit)
SHOW GRANTS FOR 'kit_ben'@'localhost' USING 'kit_clerk', 'kit_cashier';

-- TODO 5 · The job changes: clerks may now read customers too. ONE grant,
-- to the role, and every clerk follows. Turn it on and fill the gaps.
-- GRANT SELECT ON bookstore.___ TO '___';
SHOW GRANTS FOR 'kit_ana'@'localhost' USING 'kit_clerk';

-- TODO 6 · Ben stops working the till: take the whole cashier bundle away
-- with one REVOKE of the role (write it).
SHOW GRANTS FOR 'kit_ben'@'localhost';

-- 7 · Roles are stored as locked accounts that cannot log in (nothing to edit)
SELECT user, host, account_locked
FROM mysql.user
WHERE user LIKE 'kit\_%'
ORDER BY account_locked, user;

DROP USER 'kit_ana'@'localhost', 'kit_ben'@'localhost';
DROP ROLE 'kit_clerk', 'kit_cashier';

-- Expected when done: TODO 3 three rows (kit_ana kit_clerk; kit_ben
-- kit_cashier; kit_ben kit_clerk). Step 4 Ben: SELECT on authors and books,
-- INSERT on order_items and orders, and the line granting both roles.
-- TODO 5 Ana also has SELECT on customers (and so does Ben, through the same
-- role). TODO 6 Ben's own grants: USAGE and `kit_clerk`@`%` only. Step 7:
-- kit_ana and kit_ben N (localhost), kit_cashier and kit_clerk Y (host %).
