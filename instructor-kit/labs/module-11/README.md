# Session 11 labs: Transactions and JSON

Lessons **7.2 Transactions** and **7.3 JSON Columns** (Part 2), plus **Checkpoint 2** (Modules 5 and 6).
Every lab is new practice on the lessons' ideas; none of them repeats a lesson project or exercise. All of
them start from `-- state: full`: the course database exactly as `labs/_states/bookstore.sql` builds it.

Hand out the `*_starter.sql` files, the two `debug_*.sql` files and `checkpoint-2/checkpoint2_starter.sql`
(at 0:10, not before). Keep every `*_solution.sql` for yourself until after the lab or the checkpoint.

## What is here

| File | Practices | In class | Expected output (solution) |
|------|-----------|---------:|----------------------------|
| `checkpoint-2/checkpoint2_starter.sql` / `_solution.sql` | Checkpoint 2, five parts: a CTE with `RANK()` (5.1, 5.2), a recursive CTE (5.1), a view (6.2), an index read with `EXPLAIN` (6.1); Part 5 (normalization, 6.3) is on paper in the workbook | 30 min (0:10) | Part 1 Classic 1984 4 · Dystopian 1984 4 · Fantasy The Hobbit 3 · Fiction 1984 4 · Science Fiction Dune 3. Part 2 level 1 Priya Nair, Marcus Hill; level 2 Tom Becker, Lena Park, Sofia Alvarez, Ben Carter. Part 3 Alice Johnson 3 orders 58.95, Dave Brown 45.96, Frank Miller 41.96, Grace Wilson 33.97, Bob Smith 33.47. Part 4 `Table scan on customers`, then `Index lookup on customers using idx_customers_city` |
| `l7_2-transactions/loyalty_points_starter.sql` / `_solution.sql` | A new `loyalty` table (points, `CHECK (points >= 0)`): a transfer with COMMIT, a rehearsed DELETE with ROLLBACK (the cascade to `order_items`), a savepoint, the implicit commit of CREATE TABLE, `@@autocommit` and `@@transaction_isolation` | 15 min | Frank 15 / Grace 25; inside the rehearsal 7 orders and 10 lines, after ROLLBACK 12 and 18; after the savepoint 1: 350, 2: 170, 4: 10, 6: 15, 7: 25; with the CREATE TABLE moved out, Bob stays 170 and `log_rows` is 0; `1`, `REPEATABLE-READ` |
| `l7_2-transactions/return_item_starter.sql` / `_solution.sql` | A procedure that takes back one order line: two DELETEs and a points credit in one transaction, `DECLARE EXIT HANDLER ... ROLLBACK; RESIGNAL;`, `ROW_COUNT()` | fast finishers / homework | Before 12 orders / 18 lines; after `CALL return_item(17)` and `CALL return_item(3)` 11 / 16; points 1: 307, 4: 18; order 2 gone, order 12 kept. At the prompt: `return_item(99)` and `return_item(13)` fail with `ERROR 1644` and the counts stay 11 / 16 |
| `l7_2-transactions/debug_lost_points.sql` | Three hand-typed transactions that go wrong: COMMIT after a failed statement (3819), a misspelled savepoint (1305), CREATE TABLE inside a transaction (silent) (deliberately broken) | fast finishers / homework | Before fixing: the two ERROR lines and the table 1: 0, 2: 340, 4: 20, 6: 80, 7: 0; fixed: 1: 300, 2: 120, 4: 10, 6: 40, 7: 0 |
| `l7_3-json-columns/reader_prefs_starter.sql` / `_solution.sql` | A `prefs` JSON column on customers: `->>` with a JSON `true`, `MEMBER OF`, arrays and a nested path, a missing key vs a missing document, `JSON_SET`, `JSON_ARRAY_APPEND` + `JSON_REMOVE` in one UPDATE, an indexed generated column | 15 min | Newsletter: Alice, Frank, Grace; Classic: Alice, Grace; `has_genres` 0 for Dave, NULL for Carol, Eve, Hank; Grace `{"genres": ["Fantasy", "Classic", "Science Fiction"], "newsletter": true}`; per flag NULL 3, false 1, true 4 |
| `l7_3-json-columns/order_documents_starter.sql` / `_solution.sql` | Rows to JSON (`JSON_OBJECT` with aggregates, `JSON_OBJECTAGG`) and JSON to rows (`JSON_TABLE` on a supplier's restock message, joined and used in an UPDATE) | fast finishers / homework | Alice's orders 1, 2, 8 as documents (order 1: 2 lines, 34.97); `{"1984": 4, "Dune": 3, "The Hobbit": 3}`; restock lines 4, 8 and an unknown 42; `still_out_of_stock` 0 |
| `l7_3-json-columns/debug_bad_json.sql` | A wishlist feature with five bugs: single-quoted JSON (3140), a path without `$` (3143), an index on the JSON column (3152), `->` inside CONCAT and a misspelled key (both silent) (deliberately broken) | fast finishers / homework | Before fixing: three ERROR lines, the label `Alice ("birthday")`, no Dune fans, two wishlists. Fixed: `Alice (birthday)`, Alice and Grace want Dune, three wishlists |

A starter runs without an error exactly as handed out: it shows its TODO placeholders (an `Empty set`, a
`TODO` line, a 0 or a NULL) and ends with an "Expected when done" comment that quotes the solution's real
output.

## How to run

Learners open a terminal **in the folder that holds `labs/`**, log in with the bookstore as the current
database and SOURCE a file:

```
mysql -u root -p bookstore
SOURCE labs/module-11/l7_2-transactions/loyalty_points_starter.sql
```

Every lab here rebuilds what it needs (`loyalty`, `wishlists`, the `prefs` column) at the start, so it can
be SOURCEd again after each edit. Three labs change the course data on purpose (`loyalty_points` and
`return_item` delete or credit rows, `order_documents` restocks two books) and the lesson projects change it
too: **reload before the next lab** with `SOURCE labs/_states/bookstore.sql`. A JSON lab that stopped
halfway (a typo in your edit) leaves its column behind; reloading fixes that too (MySQL has no
`DROP COLUMN IF EXISTS`).

`return_item`: a failing `CALL` is an error, so the failing tests are typed at the prompt, not kept in the
file (they are listed in its last comment).

### Two windows (Lesson 7.2's isolation demo, by hand)

Isolation needs two connections, which a single `.sql` file cannot show. After `loyalty_points` has run
(the `loyalty` table exists), open a **second** terminal, `mysql -u root -p bookstore`, and type:

| Window A | Window B |
|----------|----------|
| `START TRANSACTION;` `UPDATE loyalty SET points = points - 5 WHERE customer_id = 1;` | |
| | `SELECT points FROM loyalty WHERE customer_id = 1;` (the committed value: no waiting) |
| | `UPDATE loyalty SET points = points + 1 WHERE customer_id = 1;` (waits; `ERROR 1205` after 50 s on a default server) |
| `COMMIT;` | (if B was still waiting, its UPDATE now finishes) |
| | `SELECT points FROM loyalty WHERE customer_id = 1;` |

## Checking everything

```bash
python3 labs/check_labs.py module-11        # 12 files, a few seconds
```

## On MySQL 8.4 and MariaDB

- **8.4:** everything here runs the same (the `EXPLAIN` tree of Checkpoint Part 4 needs `\G` or
  `FORMAT=TREE` to look like 9.7's; 8.4 prints the classic table by default: look for `idx_customers_city`
  in the `key` column).
- **MariaDB:** the transactions labs behave the same, but CHECK violations are `ERROR 4025` instead of 3819.
  The JSON labs need changes: no `->` / `->>` (use `JSON_VALUE` or `JSON_UNQUOTE(JSON_EXTRACT(...))`), no
  `MEMBER OF` (use `JSON_CONTAINS`), invalid JSON fails with 4025, and keys keep the order you typed.

## Timing in Session 11

| Clock | Lab |
|-------|-----|
| 0:10 | `checkpoint2_starter.sql` (30 min, alone, open notes) |
| 1:15 | `loyalty_points_starter.sql` in pairs (15 min); fast finishers take `return_item_starter.sql`, then `debug_lost_points.sql` |
| 2:25 | `reader_prefs_starter.sql` (15 min); fast finishers take `order_documents_starter.sql`, then `debug_bad_json.sql` |

`return_item`, `order_documents` and both debug handouts are homework for anyone who did not reach them.
