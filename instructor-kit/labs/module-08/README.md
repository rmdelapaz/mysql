# Session 8 labs: CTEs and Window Functions

Lessons **5.1 CTEs & Recursive Queries** and **5.2 Window Functions**, the first session of **Part 2**.
Every lab is new practice on the lesson's ideas; none repeats a lesson project or exercise. All of them
start from `-- state: full`: a freshly loaded course database (`SOURCE bookstore.sql`), and all of them
only read, so learners can run them in any order and as often as they like without reloading.

Hand out the `*_starter.sql` files, `check_environment.*` and the two `debug_*.sql` files.
Keep every `*_solution.sql` for yourself until after the lab.

## What is here

| File | Practices | In class | Expected output (solution) |
|------|-----------|---------:|----------------------------|
| `l5_0-part2-start/check_environment.sql` (+ `.sh` for macOS/Linux, `.ps1` for Windows) | A tool, not an exercise: Session 1's check, with the full bookstore REQUIRED (8 base tables, fresh row counts). The helpers also check the `mysql` client version | 5 min (opening) | Last table `READY for Part 2`; `OK     fresh row counts: 11 books, 8 customers, 12 orders, 10 employees`. Without bookstore or with a ninth table: `NOT READY`. On 8.4 / MariaDB: `READY WITH NOTES` |
| `l5_0-part2-start/refresher_starter.sql` / `_solution.sql` | Part 1 in four queries: an inner join over four tables, LEFT JOIN with `COUNT(o.id)`, a derived table, a self-join. For programs that start with Part 2, and for anyone who missed two or more refresher questions | homework / pre-work | January lines (Alice 1984 2, Alice Dune 1, Dave Lord of the Rings, Dave The Hobbit); Alice 3 orders ... Carol 0, Hank 0; Alice 58.95, Dave 45.96, Frank 41.96; Ben, Lena, Tom report to Priya, Priya to Daniel |
| `l5_1-ctes/staff_tree_starter.sql` / `_solution.sql` | Recursive CTEs: a 12-month series with empty months, then a division (the level-2 manager) carried down the staff tree, then aggregated in the main query | 15 min (pairs) | Copies 5, 5, 3, 3, 3, 2, then six 0s; Daniel's division of 7, James's of 2; Daniel 7 people 310500.00, James 2 people 88500.00 |
| `l5_1-ctes/category_steps_starter.sql` / `_solution.sql` | Non-recursive CTEs: a step tested on its own, a second CTE reading the first, one CTE read three times | fast finishers / homework | Fiction 21 copies 237.29 ... Fantasy 5 64.95; only Fiction beats the average category (109.00); months 1 to 6 with busiest 3, `is_busiest` 1 for month 2 |
| `l5_1-ctes/debug_ctes.sql` | Three broken CTEs (deliberately broken): RECURSIVE forgotten, no stop condition, an anchor column too narrow | debug clinic | `ERROR 1146`, `ERROR 3636 ... after 1001 iterations`, `ERROR 1406 ... column 'path'`; fixed: 3 2 1, 365, ten paths |
| `l5_2-window-functions/leaderboards_starter.sql` / `_solution.sql` | ROW_NUMBER, RANK, DENSE_RANK on data with ties; top 2 per category with PARTITION BY; a window SUM per department and each salary's share | 20 min | Dave 4 · 2 2 2, Frank 4 · 3 2 2, Eve 2 · 6 6 4; ten rows, two per category; sales 158500.00, inventory 84000.00 |
| `l5_2-window-functions/order_trends_starter.sql` / `_solution.sql` | A running total over orders (ROWS frame, unique order), LAG per customer with a named WINDOW, every customer's first order (top 1 per group) | fast finishers / homework | Running total 34.97 ... 237.29; every customer's first change is NULL, Alice -26.98 then 8.00; first orders Alice 1, Dave 4, Frank 5, Grace 6, Bob 3, Eve 9 |
| `l5_2-window-functions/debug_windows.sql` | Three ways to fail at "the three most expensive books" (deliberately broken): a window in WHERE, `AS rank`, QUALIFY | debug clinic | `ERROR 3593`, `ERROR 1064 ... near 'rank`, `ERROR 6037 ... hypergraph optimizer` |

A starter runs without an error exactly as handed out: it shows its TODO placeholders (a 0, an empty
result, a `TODO` line or a wrong-but-legal result) and ends with an "Expected when done" comment that
quotes the solution's real output.

## How to run

Learners open a terminal **in the folder that holds `labs/` and `bookstore.sql`**, log in and load the
course database once, then SOURCE a lab:

```
mysql -u root -p
SOURCE bookstore.sql
SOURCE labs/module-08/l5_1-ctes/staff_tree_starter.sql
```

Every lab runs in the current database (no `USE` inside the files), so `bookstore` must be the current
database: `SOURCE bookstore.sql` leaves you in it; otherwise `USE bookstore;` first. Docker users with no
client on the laptop: `docker exec -i mysql97 sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" --table bookstore' < labs/...`.

The Part 2 environment check, from the same folder:

```bash
bash labs/module-08/l5_0-part2-start/check_environment.sh                          # macOS, Linux, WSL
powershell -ExecutionPolicy Bypass -File labs\module-08\l5_0-part2-start\check_environment.ps1   # Windows
```

Check everything in this session at once (13 files; a few seconds):

```bash
python3 labs/check_labs.py module-08
```

## On MySQL 8.4 and MariaDB

- **8.4:** behaves like 9.7 for every lab here (window functions, recursive CTEs, QUALIFY's error 6037);
  `check_environment.sql` says `READY WITH NOTES`.
- **MariaDB** (XAMPP, some hosts): `debug_ctes.sql` query B does not fail: MariaDB stops at
  `max_recursive_iterations` and returns 1001 with warning 1931 (always write the stop condition);
  `debug_windows.sql` A is error 4015 (not 3593), B runs (MariaDB still accepts `AS rank`), C is 1064.
  `LAG(x, n, default)` with a third argument is a 1064 there (the lesson's version note); no lab here uses it.

## Timing in Session 8

| Clock | Lab |
|-------|-----|
| 0:00 | `SOURCE bookstore.sql`, then `check_environment` on every machine (5 min, inside the 20-minute opening) |
| 0:50 | `staff_tree_starter.sql` in pairs (15 min); fast finishers take TODO 3, then `category_steps_starter.sql` |
| 2:00 | `leaderboards_starter.sql` (20 min); fast finishers take `order_trends_starter.sql` |
| 2:35 | Debug clinic: `debug_ctes.sql` and `debug_windows.sql` in pairs (15 min) |

`refresher_starter.sql` is pre-work for programs that start with Part 2, and homework for anyone who missed
two or more refresher questions. `category_steps_starter.sql` and `order_trends_starter.sql` are homework
for anyone who did not reach them in class.
