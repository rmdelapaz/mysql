-- state: full
-- expect-error: 1410, 1141, 1396, 1147
-- =====================================================================
-- debug_grants.sql: an account script with four mistakes (find-the-bug handout)
-- Session 12 · Lesson 7.4 · MySQL Foundations instructor kit
--
-- This file is broken ON PURPOSE. A colleague wrote the setup script for
-- the store's newsletter tool: one account, kit_mailer, that may read
-- customers' first names and emails, nothing else. Four statements fail.
-- Run it as root (bookstore as the current database), then for each ERROR
-- line write in your workbook: the number, what it means, and the fixed
-- statement. Fixed, the file runs twice in a row without an error and the
-- last SHOW GRANTS lists exactly one column grant.
--
--   SOURCE labs/module-12/l7_4-user-management/debug_grants.sql
-- =====================================================================

DROP USER IF EXISTS 'kit_mailer'@'localhost';
CREATE USER 'kit_mailer'@'localhost' IDENTIFIED BY 'CHANGE-ME-mailer-1';
GRANT SELECT ON bookstore.* TO 'kit_mailer'@'localhost';

-- Bug A
GRANT SELECT (first_name, email) ON bookstore.customers TO 'kit_mailr'@'localhost';

-- Bug B
SHOW GRANTS FOR 'kit_mailer'@'%';

-- Bug C
CREATE USER 'kit_mailer'@'localhost' IDENTIFIED BY 'CHANGE-ME-mailer-1';

-- Bug D: the database-wide SELECT was a mistake; take orders away
REVOKE SELECT ON bookstore.orders FROM 'kit_mailer'@'localhost';

SHOW GRANTS FOR 'kit_mailer'@'localhost';

DROP USER IF EXISTS 'kit_mailer'@'localhost';
