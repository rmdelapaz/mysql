# Session 4 labs: Filtering, Sorting and Limiting

Lessons **3.1 WHERE Clauses, Operators & Filtering** and **3.2 Sorting & Limiting Results** (Part 1), and
**Checkpoint 1** on Modules 1 and 2. Every lesson lab is new practice; none repeats a lesson project
(`saved_searches.sql`, `storefront.sql`) or exercise.

The lesson labs start from `-- state: flat`: `bookstore` with the Module 3 data (10 books with a text `author`
column, 8 customers, 5 categories), exactly what Lesson 3.1's setup script builds. They are **read-only** and
run inside `bookstore` (learners `USE bookstore;` once; the labs never say USE). Load the data with the lesson's
setup block or `SOURCE labs/_states/flat.sql` (it drops and rebuilds `bookstore`).

The checkpoint starts from `-- state: none`: it builds its own `kit_cp1_tradein` database and drops it at the end.

Hand out the `*_starter.sql` files and the two `debug_*.sql` files; hand out `checkpoint_starter.sql` only at the
start of the checkpoint. Keep every `*_solution.sql` for yourself.

## What is here

| File | Practices | In class | Expected output (solution) |
|------|-----------|---------:|----------------------------|
| `l3_1-where-clauses-operators-filtering/staff_requests_starter.sql` / `_solution.sql` | Seven staff requests, each a WHERE clause replacing `WHERE FALSE`: IN with AND, a date comparison, LIKE `'%son'`, LIKE `'____'`, `!=` plus `OR IS NULL`, BETWEEN with `!=`, a half-open date range | 20 min (pairs) | 1984, Fahrenheit 451, To Kill a Mockingbird · Brave New World, The Hobbit, 1984 · Johnson, Wilson · 1984, Dune · 6 customers (all but Alice and Frank) · Brave New World, 1984, Fahrenheit 451 · Grace, Hank |
| `l3_1-where-clauses-operators-filtering/null_detective_starter.sql` / `_solution.sql` | NULL logic made visible: conditions as columns (1, 0, NULL), counts that only add to 8 with IS NULL, the NULL inside NOT IN, `= NULL` versus `IS NULL` and `<=>` | fast finishers / homework | Eve and Hank show NULL in both tests and 1 in `no_city`; counts 2 + 4 + 2; 7 customers outside Houston; Eve and Hank. As shipped: `no_city` 0, and queries 3 and 4 return nothing |
| `l3_1-where-clauses-operators-filtering/debug_filters.sql` | Two filters that fail (1054 text without quotes, 1064 `pages > 300 AND < 500`) and three that silently return wrong rows (`= NULL`, `= 'The%'`, AND/OR without parentheses) (deliberately broken) | fast finishers | As shipped: the two ERROR lines, nothing for Bugs C and D, and Bug E lists The Catcher in the Rye (out of stock) |
| `l3_2-sorting-limiting-results/bestseller_board_starter.sql` / `_solution.sql` | Six orders for a display board, each replacing `ORDER BY id`: DESC, an expression alias with a tie-breaker, two keys with two directions, a top 3 with WHERE and LIMIT, CASE, NULLs on top with `city IS NOT NULL` | 15 min | Hank first (newest); The Catcher in the Rye (22 characters) first, 1984 before Dune at 4; authors A to Z with Tolkien's Lord of the Rings before The Hobbit; Fahrenheit 451, To Kill a Mockingbird, The Hobbit; Classic, Fiction, Dystopian, Fantasy, Science Fiction; Eve and Hank first, then New York down to Chicago |
| `l3_2-sorting-limiting-results/paging_starter.sql` / `_solution.sql` | OFFSET pagination, four per page by price then id; the page count with CEILING; a page past the end; keyset pagination with `price > x OR (price = x AND id > y)` | fast finishers / homework | Page 1 ids 5, 4, 8, 7; page 2 ids 2, 10, 6, 3; page 3 ids 1, 9; 10 books, 3 pages; page 4 prints nothing; the keyset page equals page 2 |
| `l3_2-sorting-limiting-results/debug_sorting.sql` | Three sorts that fail (1064 ORDER BY before WHERE, 1054 `ORDER BY 3` with two columns, 1064 a formula in OFFSET) and two that run wrong (`ORDER BY 'pages'` in quotes, `DESC` on one key only) (deliberately broken) | fast finishers | As shipped: the three ERROR lines; Bug D prints three arbitrary books (Dune, 1984, To Kill a Mockingbird on the test server; it can differ); Bug E puts the out-of-stock books first |
| `checkpoint-1/checkpoint_starter.sql` / `checkpoint_solution.sql` | **Checkpoint 1** (30 min, open notes): build a two-table trade-in database with types and constraints (Part A), fill and change it with INSERT, UPDATE, DELETE and an upsert (Part B), read it back (Part C); Part D is on paper | 30 min (2:20) | rows_paid 2; trade-ins 1 Dune 5.00 (credit 5.50, paid 1), 2 Emma 1.50 (1.65, paid 1), 3 The Hobbit 6.00 (6.60), 4 1984 3.50 (3.85); conditions like new, good, worn; Ivy now in Henderson |

A starter runs without an error exactly as handed out (`WHERE FALSE` and `Empty set`, `ORDER BY id`, a `TODO`
line, a 0) and ends with an "Expected when done" comment that quotes the solution's real output.

## How to run

```
mysql -u root -p
SOURCE labs/_states/flat.sql
SOURCE labs/module-04/l3_1-where-clauses-operators-filtering/staff_requests_starter.sql
```

(`flat.sql` ends inside `bookstore`.) The lesson labs only read, so they can run in any order and any number of
times. The checkpoint builds and drops its own database and can run anywhere.

Check everything in this session at once (12 files; a few seconds):

```bash
python3 labs/check_labs.py module-04
```

## On MySQL 8.4 and MariaDB (measured)

- **8.4:** the same answers and errors.
- **MariaDB 12.3:** the same rows; the checkpoint's B6 upsert fails at `AS new` (ERROR 1064): write
  `ON DUPLICATE KEY UPDATE city = VALUES(city)` there. Bug D of `debug_sorting.sql` may list other books (any
  order is "right" for a constant sort key).

## Timing in Session 4

| Clock | Lab |
|-------|-----|
| 0:45 | `staff_requests_starter.sql` in pairs (20 min); fast finishers take `null_detective_starter.sql`, then `debug_filters.sql` |
| 1:55 | `bestseller_board_starter.sql` (15 min); fast finishers take `paging_starter.sql`, then `debug_sorting.sql` |
| 2:20 | Checkpoint 1: `checkpoint_starter.sql` (30 min, open notes) |

`null_detective_starter.sql` and `paging_starter.sql` are homework for anyone who did not reach them in class.
