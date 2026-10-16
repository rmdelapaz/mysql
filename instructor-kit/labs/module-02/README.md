# Session 2 labs: The MySQL Client and Your First Tables

Lessons **1.3 MySQL CLI & phpMyAdmin** and **2.1 Creating Databases & Tables** (Part 1). Every lab is new
practice on the lesson's ideas; none of them repeats a lesson project (`explore.sql`, `create_bookstore.sql`)
or exercise. All of them start from `-- state: none`: each builds a small practice database of its own
(`kit_s2_...`) and drops it again at the end, so they never touch the `bookstore` database learners build in
Lesson 2.1 today.

Hand out the `*_starter.sql` files and the two `debug_*.sql` files. Keep every `*_solution.sql` for yourself
until after the lab.

## What is here

| File | Practices | In class | Expected output (solution) |
|------|-----------|---------:|----------------------------|
| `l1_3-mysql-cli-phpmyadmin/find_your_way_starter.sql` / `_solution.sql` | Exploring a database you have never seen: `SELECT DATABASE()`, `SHOW TABLES`, `DESCRIBE`, `SHOW COLUMNS ... LIKE`, `SHOW TABLES FROM other_db LIKE`, `\G`, `SHOW CREATE TABLE ...\G`. The setup part builds `kit_s2_cafe` (three tables) | 20 min (pairs) | `current_db` kit_s2_cafe; tables cafe_orders, menu_items, staff_notes; menu_items: `id` PRI, `name` UNI, `name` and `price` required (Null NO); `ordered_at` (NO) and `paid_at` (YES); five `time_zone...` tables; item 3 = Oat Latte 4.10, vegan 1, 2026-02-14; staff_notes `ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci` |
| `l1_3-mysql-cli-phpmyadmin/system_tour_starter.sql` / `_solution.sql` | information_schema as "data about data": counting and reading columns and tables of the `mysql` system database; `SHOW TABLES FROM information_schema LIKE` (read-only) | fast finishers / homework | 51 columns in `mysql.user`, 31 of them `_priv`; Host char(255), User char(32), plugin char(64), password_last_changed timestamp (IS_NULLABLE YES); help_category / help_keyword / help_relation / help_topic (row estimates 53, 922, 2265, 706); COLUMNS, COLUMNS_EXTENSIONS, COLUMN_PRIVILEGES, COLUMN_STATISTICS |
| `l1_3-mysql-cli-phpmyadmin/debug_lost.sql` | Four statements that fail at the prompt: errors 1049 (typo in a database name), 1146 (`users` instead of `user`), 1064 (`current_date` as an alias), 1064 (missing semicolon between two statements in a file) (deliberately broken, read-only) | fast finishers | Before fixing: the four ERROR lines and the four accounts; fixed: no ERROR lines. Leaves the session in `mysql` |
| `l2_1-creating-databases-tables/events_build_starter.sql` / `_solution.sql` | A build script from nothing: `DROP DATABASE IF EXISTS`, `CREATE DATABASE ... CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`, two `CREATE TABLE` from a written spec, `IF NOT EXISTS` + `SHOW WARNINGS`, an information_schema self-check | 20 min | Note 1050 `Table 'rooms' already exists`; readings and rooms, both utf8mb4_unicode_ci, 7 and 3 columns; DESCRIBE readings with `ticket_price decimal(6,2)` default 0.00 and `sold_out tinyint(1)` default 0 |
| `l2_1-creating-databases-tables/change_request_starter.sql` / `_solution.sql` | ALTER TABLE on a table with rows: ADD ... AFTER, RENAME COLUMN, MODIFY that keeps NOT NULL, ADD + DROP in one statement, then CREATE TABLE ... LIKE, TRUNCATE (id back to 1), RENAME TABLE, DROP TABLE | fast finishers / homework | Columns id, email (UNI), first_name varchar(60) NO, city, joined_on, source (default website); Maya and Omar both `website`; Again gets id 1 after TRUNCATE; SHOW TABLES lists only newsletter_signups |
| `l2_1-creating-databases-tables/debug_build_script.sql` | A coworker's build script: errors 1007 (database exists), 1046 (no database selected after dropping the current one), 1064 (comma after the last column), 1050 (table exists on a rerun), 1146 (misspelled table) (deliberately broken) | fast finishers | Before fixing: the five ERROR lines. Fixed (USE moved up or the stray CREATE removed, the comma removed, `IF NOT EXISTS`, `shelves`): no ERROR lines, DESCRIBE shows four columns |

A starter runs without an error exactly as handed out: it shows its TODO placeholders (a `TODO` line, an
`Empty set` or nothing for a self-check that finds no tables yet) and ends with an "Expected when done"
comment that quotes the solution's real output.

## How to run

Learners open a terminal **in the folder that holds `labs/`**, log in and SOURCE a file (Lesson 1.3 teaches
SOURCE properly today):

```
mysql -u root -p
SOURCE labs/module-02/l1_3-mysql-cli-phpmyadmin/find_your_way_starter.sql
```

Each lab rebuilds its practice database on every run and drops it at the end, so learners edit the file in a
text editor and SOURCE it again as often as they like. After a lab has dropped the database it was using,
the session has no current database (`SELECT DATABASE();` says NULL): `USE bookstore;` to go back once
Lesson 2.1 has created it. `debug_lost.sql` leaves the session in `mysql`.

`\G` and `SOURCE` are client commands: they work at the prompt and in SOURCEd files. Run from the shell
(`mysql -u root -p < file.sql`) the MySQL 9.x client ignores them unless started with `--commands`
(Lesson 1.3's version note), so `find_your_way_*.sql` and `debug_lost.sql` need
`mysql --commands -u root -p --table < file`. Docker users with no client on the laptop:
`docker exec -i mysql97 sh -c 'exec mysql --commands -uroot -p"$MYSQL_ROOT_PASSWORD" --table' < labs/...`.

Check everything in this session at once (10 files; a few seconds):

```bash
python3 labs/check_labs.py module-02
```

## On MySQL 8.4 and MariaDB

- **8.4** (measured): everything passes with the same answers, except the help tables' row estimates
  (help_keyword 1071, help_relation 2239, help_topic 415) and, on Docker, a second `root` account with host `%`.
- **MariaDB** (measured on 12.3): `mysql.user` is a compatibility view: 47 columns, 30 of them `_priv`,
  `User` char(128), `plugin` longtext and no `password_last_changed` (system_tour questions 1 to 3 differ);
  DESCRIBE prints `int(11)`; the error messages in both debug files are the same numbers (1064 says "your
  MariaDB server version"). The default collation there is `utf8mb4_uca1400_ai_ci`, which is why every lab
  names `utf8mb4_unicode_ci` explicitly.

## Timing in Session 2

| Clock | Lab |
|-------|-----|
| 0:45 | `find_your_way_starter.sql` in pairs (20 min); fast finishers take `system_tour_starter.sql`, then `debug_lost.sql` |
| 2:10 | `events_build_starter.sql` (20 min); fast finishers take `change_request_starter.sql`, then `debug_build_script.sql` |

`system_tour_starter.sql` and `change_request_starter.sql` are homework for anyone who did not reach them in
class.
