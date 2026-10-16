# Session 9 labs: Indexes and Views

Lessons **6.1 Indexes & Query Optimization** and **6.2 Views** (Part 2). Every lab is new practice on the
lesson's ideas; none repeats a lesson project or exercise. All of them start from `-- state: full` (a freshly
loaded `bookstore.sql`). The 6.1 labs build their own 100,000-row practice table, `visit_log`, on every run
(about a second) and drop it at the end. The 6.2 labs create views with CREATE OR REPLACE (rerunnable; they
stay in `bookstore` until the next `SOURCE bookstore.sql`), undo every data change with ROLLBACK, and drop
the one practice account they create.

Hand out the `*_starter.sql` files and the two `debug_*.sql` files. Keep every `*_solution.sql` for
yourself until after the lab.

## What is here

| File | Practices | In class | Expected output (solution) |
|------|-----------|---------:|----------------------------|
| `l6_1-indexes/plan_reading_starter.sql` / `_solution.sql` | Reading EXPLAIN before and after an index; a composite index (equality column first); a unique index; listing indexes from information_schema.STATISTICS | 15 min | 100,000 visits (2025-01-01 to 2026-05-15); Table scan → Index lookup, 200 visits on June 1; Covering index range scan using `idx_visits_customer_on`, 700 visits for customer 3 in June; Rows fetched before execution; four indexes |
| `l6_1-indexes/index_killers_starter.sql` / `_solution.sql` | Four habits that hide a column from its index (YEAR/MONTH, arithmetic, a number for a CHAR column, a leading %), each rewritten with the same answer | fast finishers / homework | 6000 / 6000 with Table scan → Index range scan; 200 / 200; 1 / 1 with warning 1739 → Rows fetched before execution; 100 tickets starting 0042, type ALL → range |
| `l6_1-indexes/debug_indexes.sql` | Four index statements MySQL refuses (deliberately broken): a taken name, a missing index, a foreign key's index, a UNIQUE index on duplicates | clinic | `ERROR 1061`, `ERROR 1091`, `ERROR 1553`, `ERROR 1062 ... Duplicate entry 'New York'`; the index list is unchanged |
| `l6_2-views/report_views_starter.sql` / `_solution.sql` | A grouped view with LEFT JOIN and COALESCE (every author, zero included), a join view with no grouping, CREATE OR REPLACE, SHOW FULL TABLES, IS_UPDATABLE | 20 min | Ten authors from J.R.R. Tolkien 64.95 down to three with 0.00; New York 5 orders, Chicago 4, Houston 2, (no city) 1; v_author_sales NO, v_city_orders YES |
| `l6_2-views/guarded_views_starter.sql` / `_solution.sql` | An updatable view with WITH CHECK OPTION (a write rolled back), a read-only window, an account that may read only that window (created and dropped) | fast finishers / homework | on_shelf 9; The Hobbit 11.99 then 10.99 after ROLLBACK; Chicago 2, New York 2, Houston 1, Los Angeles 1; two grant lines; v_shelf YES CASCADED |
| `l6_2-views/debug_views.sql` | Four view mistakes (deliberately broken): CREATE twice, UPDATE a grouped view, a write the check option refuses, a renamed column | clinic | `ERROR 1050`, `ERROR 1288`, `ERROR 1369`, `ERROR 1356`; 1984 still 9.99; the practice views and table are removed at the end |

A starter runs without an error exactly as handed out (the plans say Table scan until the TODOs add
indexes; the views run with a placeholder) and ends with an "Expected when done" comment that quotes the
solution's real output. **EXPLAIN estimates differ** (cost, rows): compare the plan shapes and the counts.

## How to run

From the folder that holds `labs/` and `bookstore.sql`, in the mysql client:

```
SOURCE bookstore.sql
SOURCE labs/module-09/l6_1-indexes/plan_reading_starter.sql
```

The labs run in the current database (no `USE` inside), so `bookstore` must be current. EXPLAIN lines end
with `\G` (vertical output); the client handles that in SOURCE. Docker users with no client on the laptop:
`docker exec -i mysql97 sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" --table bookstore' < labs/...`.

Check everything in this session at once (10 files; a few seconds):

```bash
python3 labs/check_labs.py module-09
```

Two lines show `WARN warning 1739` (index_killers): that warning is what the lab is about, not a problem.
The checker runs every file in a scratch database, so its messages and SHOW GRANTS lines name that database
instead of `bookstore`.

## On MySQL 8.4 and MariaDB

- **8.4:** every lab passes. Plain EXPLAIN prints the traditional table there (8.4's default
  `explain_format`), not the tree; `EXPLAIN FORMAT=TREE` gives the tree.
- **MariaDB** (measured on 12.3): every lab passes, but EXPLAIN always prints the traditional table (no
  tree, no EXPLAIN ANALYZE: use `ANALYZE SELECT ...`), so read `type`, `key` and `rows` instead of the plan
  words. Invisible indexes are `IGNORED` there. The view labs behave the same apart from message wording.

## Timing in Session 9

| Clock | Lab |
|-------|-----|
| 0:45 | `plan_reading_starter.sql` (15 min); fast finishers take `index_killers_starter.sql` |
| 1:50 | `SOURCE bookstore.sql` was done before the 6.2 demo; `report_views_starter.sql` (20 min); fast finishers take TODO 3, then `guarded_views_starter.sql` |
| 2:25 | Clinic: `debug_indexes.sql` and `debug_views.sql` in pairs (inside the 25-minute clinic) |

`index_killers_starter.sql` and `guarded_views_starter.sql` are homework for anyone who did not reach them.
