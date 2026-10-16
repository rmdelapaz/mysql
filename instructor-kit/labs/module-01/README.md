# Session 1 labs: What Databases Are and Installing MySQL

Lessons **1.1 What Is a Database?** and **1.2 Installing MySQL** (Part 1). Every lab is new practice on the
lesson's ideas; none of them repeats a lesson project or exercise. All of them start from `-- state: none`:
nobody has a `bookstore` database yet (Lesson 2.1 creates it in Session 2), so each lab builds a small
practice database of its own (`kit_...`) and drops it again at the end.

Hand out the `*_starter.sql` files, `check_environment.*` and the two `debug_*.sql` files.
Keep every `*_solution.sql` for yourself until after the lab.

## What is here

| File | Practices | In class | Expected output (solution) |
|------|-----------|---------:|----------------------------|
| `l1_0-orientation/check_environment.sql` (+ `.sh` for macOS/Linux, `.ps1` for Windows) | A tool, not an exercise: which server answered (9.7, 8.4 or MariaDB), utf8mb4, the default strict SQL mode, the account and its login plugin, permission to create a database, whether `bookstore` exists yet. The `.sh`/`.ps1` helpers first check that the `mysql` client is on the PATH and is 9.7 or newer | 12 min (opening) | Last table `READY for MySQL Foundations`. On 8.4 or MariaDB: `READY WITH NOTES` and CHECK lines; `bookstore_check` says `INFO   no bookstore database yet` in Session 1 (that is expected) |
| `l1_0-orientation/diagnostic_starter.sql` / `_solution.sql` | The six Start Here questions (spreadsheet moves) done in SQL: filter → `WHERE`, sort → `ORDER BY`, AND/OR, a formula column, COUNTA → `COUNT(column)` | homework (optional) | D1 orders 1002 and 1003 (Chicago); D2 Dune 14.99; D3 one row, 1005 Frank Miller; D4 total 44.97; D5 6 rows, 5 cities filled in |
| `l1_1-what-is-a-database/order_sheet_starter.sql` / `_solution.sql` | Why one big sheet fails: three spellings of one customer, a city that disagrees with itself, a list in a cell that matches the wrong book, a total that is not a number; then the two-table fix in miniature | 15 min (pairs) | Alice spelled three ways (orders 1, 2, 6); Bob in Chicago AND Boston; `LIKE '%Dune%'` finds orders 1, 3, 4, 5, and order 4 is Dune Messiah; `about 26` sits in the total column; after the fix, one UPDATE changes Alice's email for all three orders |
| `l1_1-what-is-a-database/crud_tour_starter.sql` / `_solution.sql` | INSERT, SELECT, UPDATE, DELETE on a small `books` table (the lesson's taste used customers) | fast finishers / homework | Under $10: The Great Gatsby 8.99; final table 2 The Great Gatsby 8.99 in_stock 0 · 3 The Hobbit 9.99 · 4 Fahrenheit 451 10.49 |
| `l1_1-what-is-a-database/debug_rules.sql` | Four INSERTs that break a rule: errors 1062 (duplicate key), 1364 (missing NOT NULL value), 1366 (text in a DECIMAL), 1406 (too long for VARCHAR(13)) (deliberately broken) | fast finishers | Before fixing: the four ERROR lines and three books; fixed: six books, no ERROR lines |
| `l1_2-installing-mysql/server_facts_starter.sql` / `_solution.sql` | Reading server settings with `@@` names: version, edition, MySQL or MariaDB, character set and collation, storage engine, `lower_case_table_names`, `max_connections`, the four system databases | 15 min | `9.7.2` (any 9.7.x), `MySQL Community Server - GPL`, 1 / 0, `utf8mb4` / `utf8mb4_0900_ai_ci`, `InnoDB` / 0 (Windows 1, macOS 2), 151, four system databases |
| `l1_2-installing-mysql/accounts_check_starter.sql` / `_solution.sql` | Who may log in: `USER()` vs `CURRENT_USER()`, `mysql.user` with plugin and `account_locked`, the three locked helper accounts, no `mysql_native_password` | fast finishers / homework | `root@localhost` twice; four accounts, all `caching_sha2_password`, root not locked (N), `mysql.infoschema` / `mysql.session` / `mysql.sys` locked (Y); last query `Empty set`. Docker adds `root` with host `%` |
| `l1_2-installing-mysql/debug_old_advice.sql` | Two pieces of old forum advice that fail on 9.7 (deliberately broken; nothing is changed) | fast finishers | `ERROR 1524 ... Plugin 'mysql_native_password' is not loaded`; `ERROR 1193 ... Unknown system variable 'default_authentication_plugin'`; the check query: `Empty set` (no account was created) |

A starter runs without an error exactly as handed out: it shows its TODO placeholders (an `Empty set`, a
`TODO` line or a 0) and ends with an "Expected when done" comment that quotes the solution's real output.

## How to run

Learners open a terminal **in the folder that holds `labs/`**, log in and SOURCE a file:

```
mysql -u root -p
SOURCE labs/module-01/l1_1-what-is-a-database/order_sheet_starter.sql
```

`SOURCE` is formally taught in Lesson 1.3 (Session 2); in Session 1 show it as "the command that runs a
file" and write it on the board. Each lab rebuilds its practice database on every run and drops it at the
end, so learners edit the file in a text editor and SOURCE it again as often as they like. Docker users
with no client on the laptop: `docker exec -i mysql97 sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" --table' < labs/...` (macOS, Linux;
PowerShell: `Get-Content labs\... | docker exec -i mysql97 sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" --table'`).

The environment check, from the same folder:

```bash
bash labs/module-01/l1_0-orientation/check_environment.sh                          # macOS, Linux, WSL
powershell -ExecutionPolicy Bypass -File labs\module-01\l1_0-orientation\check_environment.ps1   # Windows
```

Both accept the client's connection options when the default `-u root -p` is not right
(`-h 127.0.0.1 -P 3307 -u root -p` for a Docker container on port 3307).

Check everything in this session at once (13 files; a few seconds):

```bash
python3 labs/check_labs.py module-01
```

## On MySQL 8.4 and MariaDB (measured)

- **8.4:** everything passes; `check_environment.sql` says `READY WITH NOTES`; Docker images show a second
  `root` account with host `%`.
- **MariaDB** (XAMPP, some hosts): `accounts_check_*` fails with `ERROR 1054 ... Unknown column
  'account_locked'` (leave that column out there); `debug_old_advice.sql` raises `ERROR 1064` (MariaDB
  spells it `IDENTIFIED VIA`) instead of 1524; the SQL mode check says CHECK (no `ONLY_FULL_GROUP_BY`);
  the collation is `utf8mb4_uca1400_ai_ci`; error 1062 names the key `'PRIMARY'` without the table.

## Timing in Session 1

| Clock | Lab |
|-------|-----|
| 0:10 | `check_environment.sh` / `.ps1` on every machine (12 min, inside the 30-minute opening) |
| 1:00 | `order_sheet_starter.sql` in pairs (15 min); fast finishers take `crud_tour_starter.sql`, then `debug_rules.sql` |
| 1:45 | Install clinic: machines that were NOT READY at 0:10 (25 min); ready learners help, then run `check_environment` again with them |
| 2:25 | `server_facts_starter.sql` (15 min); fast finishers take `accounts_check_starter.sql`, then `debug_old_advice.sql` |

`diagnostic_starter.sql` is optional homework for anyone who missed two or more of the six diagnostic
questions on the workbook's Start Here page. `crud_tour_starter.sql` and `accounts_check_starter.sql` are
homework for anyone who did not reach them in class.
