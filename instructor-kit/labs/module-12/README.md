# Session 12 labs: Users, Permissions and Backups

Lessons **7.4 User Management & Permissions** and **8.1 Importing & Exporting Data** (Part 2). Every lab
is new practice on the lessons' ideas; none of them repeats a lesson project or exercise. All of them
start from `-- state: full` (`labs/_states/bookstore.sql`) and are run **as root (or another
administrator)** with `bookstore` as the current database.

Hand out the `*_starter.sql` files, `new_titles.csv` and the two `debug_*.sql` files. Keep every
`*_solution.sql` for yourself until after the lab.

## Safety rules for these labs

- Every account and role a lab creates is a demo named `kit_...` (`kit_warehouse`, `kit_clerk`,
  `kit_backup`), and every lab drops what it created at its end, so it can be SOURCEd again.
- No lab touches root, changes the password of the account you are logged in with, or changes a server
  setting (`SET GLOBAL`, `SET PERSIST`). `labs/check_labs.py` refuses any file that would.
- No lab writes a file on disk. The import lab fills its staging table with an INSERT (the rows `LOAD DATA`
  would produce); the export lab prints its CSV-shaped result on screen.

## What is here

| File | Practices | In class | Expected output (solution) |
|------|-----------|---------:|----------------------------|
| `l7_4-user-management/warehouse_accounts_starter.sql` / `_solution.sql` | Two program accounts: table and column privileges (`UPDATE (in_stock)`, `SELECT (id, first_name, last_name)`), `SHOW GRANTS`, an audit through `information_schema.TABLE_PRIVILEGES` / `COLUMN_PRIVILEGES`, `REVOKE` at the granted level, `ACCOUNT LOCK` | 15 min | warehouse: `SELECT ON authors`, `SELECT, UPDATE (in_stock) ON books` (MySQL merges the two); accounting: three customer columns, `orders`, `order_items`; audit 4 table rows + 4 column rows; after TODO 5 accounting loses `order_items`, `kit_warehouse` is locked (Y) |
| `l7_4-user-management/staff_roles_starter.sql` / `_solution.sql` | Two roles (`kit_clerk`, `kit_cashier`), two staff accounts, `SET DEFAULT ROLE ALL`, `mysql.default_roles`, `SHOW GRANTS ... USING`, one GRANT to a role that every member follows, REVOKE of a whole role | fast finishers / homework | 3 default-role rows; Ben's combined grants (SELECT on authors and books, INSERT on order_items and orders); Ana gains SELECT on customers through the role; Ben keeps only `kit_clerk`; roles are locked accounts with host `%` |
| `l7_4-user-management/debug_grants.sql` | A setup script with four mistakes: GRANT to a misspelled account (1410), the wrong host (1141), CREATE USER twice (1396), REVOKE at the wrong level (1147) (deliberately broken) | fast finishers / homework | As shipped: the four ERROR lines and `GRANT SELECT ON bookstore.*` still in place. Fixed: one column grant, `SELECT (email, first_name) ON bookstore.customers` |
| `l8_1-importing-exporting/new_titles_import_starter.sql` / `_solution.sql` (+ `new_titles.csv`) | A supplier's file through a staging table: European dates (`%d.%m.%Y`), an empty page count to NULL, a price `N/A` held back, a missing author, a book already sold; the copy in one transaction with `NOT EXISTS` | 15 min | Conversion without warnings; Animal Farm "already sold", The Two Towers "no price", Bram Stoker new; new books 12 Dracula, 13 Foundation, 14 Persuasion (pages NULL); 14 books, 11 authors |
| `l8_1-importing-exporting/backup_check_starter.sql` / `_solution.sql` | The SQL around a backup: what `secure_file_priv` / `local_infile` allow, a `kit_backup` account with exactly mysqldump's privileges and a proof that it cannot write, the restore test's reference counts, a report with a header row shaped for `INTO OUTFILE` | fast finishers / homework | `one folder only`; `GRANT SELECT, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER`; 0 write and 0 global privileges; books 11, customers 8, orders 12, order_items 18, revenue 237.29; header row, then Classic 10 96.90 ... Science Fiction 6 75.44 |
| `l8_1-importing-exporting/debug_import.sql` | `mysqldump` typed at `mysql>` (1064), `INTO OUTFILE '/tmp/...'` (1290), the wrong date pattern in a strict INSERT (1411), a decimal comma (1292) (deliberately broken) | fast finishers / homework | As shipped: four ERROR lines and an empty result. Fixed: Emma 8.49 1815-12-23, Frankenstein 7.49 1818-01-01 |

A starter runs without an error exactly as handed out and ends with an "Expected when done" comment that
quotes the solution's real output. `new_titles_import_starter.sql` prints warnings as shipped (1411, 1292):
reading them is TODO 1.

## How to run

```
mysql -u root -p bookstore
SOURCE labs/module-12/l7_4-user-management/warehouse_accounts_starter.sql
```

`new_titles_import` adds three books and an author: reload with `SOURCE labs/_states/bookstore.sql` before
running the finished file again or before another lab.

### Logging in as a demo account (Lesson 7.4: test both directions)

The account labs drop their accounts at the end. To test one: put `--` in front of the final `DROP USER`
line, SOURCE the file, then in a **second** terminal (your root window stays open):

```bash
mysql -u kit_warehouse -p bookstore          # password: CHANGE-ME-warehouse-1
```
```
UPDATE books SET in_stock = FALSE WHERE id = 1;   -- works: Query OK, 1 row affected
UPDATE books SET price = 0 WHERE id = 1;          -- ERROR 1143 ... for column 'price' in table 'books'
EXIT
```

(Do it before TODO 5 locks the account: a locked account gets `ERROR 3118` at login.) For the roles lab,
`mysql -u kit_ana -p bookstore` (`CHANGE-ME-ana-1`): `SELECT COUNT(*) FROM books;` works, an INSERT into
`orders` gives `ERROR 1142`. Then run the DROP USER (and DROP ROLE) lines by hand in the root window.

### The shell part of Lesson 8.1 (mysqldump is not SQL)

mysqldump is a program you run at the terminal (`$` or `PS>`), never at `mysql>` (that is `ERROR 1064`,
bug A of `debug_import.sql`). On MySQL 9.7, from the course folder:

```bash
# 1 back up (9.7 starts with GTIDs on: --set-gtid-purged=OFF, or the restore below fails with ERROR 3546)
mysqldump -u root -p --single-transaction --routines --events \
    --set-gtid-purged=OFF bookstore > bookstore_backup.sql
# 2 restore into a test database (a dump made without --databases needs the target named:
#   "mysql -u root -p < bookstore_backup.sql" stops with ERROR 1046 No database selected)
mysql -u root -p -e "CREATE DATABASE bookstore_test"
mysql -u root -p bookstore_test < bookstore_backup.sql
# 3 compare: both columns must say 18 (backup_check's step 4 has the full list of counts)
mysql -u root -p -t -e "SELECT (SELECT COUNT(*) FROM bookstore.order_items) AS items_original, (SELECT COUNT(*) FROM bookstore_test.order_items) AS items_copy"
mysql -u root -p -e "DROP DATABASE bookstore_test"
```

Windows PowerShell has no `<` and writes `>` as UTF-16: use `--result-file=bookstore_backup.sql` for the
dump and `mysql -u root -p bookstore_test --commands -e "SOURCE bookstore_backup.sql"` for the restore. As
the backup account (Lesson 8.1's project), add `--no-tablespaces --skip-masking-policies` (leave the last
one out on 8.4). MariaDB: `mariadb-dump`, without `--set-gtid-purged`.

To write `backup_check`'s report to a file, add this after its `ORDER BY part, category` (use your own
server's folder from `SHOW VARIABLES LIKE 'secure_file_priv';`):

```
INTO OUTFILE '/var/lib/mysql-files/sales_by_category.csv'
    FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
```

To load `new_titles.csv` for real instead of the INSERT, with `local_infile` ON (Lesson 8.1, an
administrator's setting) and the client started with `mysql -u root -p --local-infile=1 bookstore`, use
the `LOAD DATA LOCAL INFILE` statement in the lab's header comment.

## Checking everything

```bash
python3 labs/check_labs.py module-12        # 10 files, a few seconds
```

## On MySQL 8.4 and MariaDB

- **8.4:** everything here runs the same.
- **MariaDB:** `mysql.user` has no `account_locked` column and no `mysql.default_roles` table, a role is
  granted one per GRANT, `SET DEFAULT ROLE` takes one role (no `ALL`), `SHOW GRANTS ... USING` does not
  exist, and a GRANT to a missing account fails with 1133 instead of 1410: the 7.4 labs need edits there.
  `debug_import.sql`: a MariaDB Docker image has an empty `secure_file_priv` (anywhere), so bug B writes the
  file instead of failing.

## Timing in Session 12

| Clock | Lab |
|-------|-----|
| 0:50 | `warehouse_accounts_starter.sql` in pairs (15 min); fast finishers take `staff_roles_starter.sql`, then `debug_grants.sql` |
| 2:05 | `new_titles_import_starter.sql` in pairs (15 min); fast finishers take `backup_check_starter.sql`, then `debug_import.sql` |
