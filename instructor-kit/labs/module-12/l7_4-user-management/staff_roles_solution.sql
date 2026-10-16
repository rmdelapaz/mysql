-- state: full
-- =====================================================================
-- staff_roles_solution.sql: roles for the shop floor, granted, activated, changed
-- Session 12 · Lesson 7.4 · MySQL Foundations instructor kit · instructor reference
--
-- Two jobs, two roles: every clerk reads the catalog; cashiers also record
-- orders. Two demo staff accounts get them. Then the job changes once, for
-- everybody, by changing a role. Run as root with bookstore as the current
-- database; everything here is a kit_ demo account or role, dropped at the end.
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

-- 3 · The step everybody forgets: make the roles active at every login
SET DEFAULT ROLE ALL TO 'kit_ana'@'localhost', 'kit_ben'@'localhost';
SELECT user, default_role_user
FROM mysql.default_roles
WHERE user LIKE 'kit\_%'
ORDER BY user, default_role_user;

-- 4 · What Ben's roles add up to
SHOW GRANTS FOR 'kit_ben'@'localhost' USING 'kit_clerk', 'kit_cashier';

-- 5 · The job changes: clerks may now read customers too. One GRANT, everyone follows
GRANT SELECT ON bookstore.customers TO 'kit_clerk';
SHOW GRANTS FOR 'kit_ana'@'localhost' USING 'kit_clerk';

-- 6 · Ben stops working the till: take the whole cashier bundle away
REVOKE 'kit_cashier' FROM 'kit_ben'@'localhost';
SHOW GRANTS FOR 'kit_ben'@'localhost';

-- 7 · Roles are stored as locked accounts that cannot log in
SELECT user, host, account_locked
FROM mysql.user
WHERE user LIKE 'kit\_%'
ORDER BY account_locked, user;

DROP USER 'kit_ana'@'localhost', 'kit_ben'@'localhost';
DROP ROLE 'kit_clerk', 'kit_cashier';
