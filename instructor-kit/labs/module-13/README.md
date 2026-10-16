# Session 13 labs: Final Project Kickoff and Studio I

Lesson **8.2 Final Project: Design and Build a Database** (first half, Milestones 1 to 3; Part 2). The
project itself (the Maple Street Tool Library, `tool_library`) is built by each learner in their own
`tool-library` folder from the lesson page; these labs are NEW practice of the same skills on the
bookstore (or on a small practice database), never the project.

Hand out the two `*_starter.sql` files and the two `debug_*.sql` files. Keep every `*_solution.sql`
for yourself until after the lab.

## What is here

| File | Practices | In class | Expected output (solution) |
|------|-----------|---------:|----------------------------|
| `l8_2-final-project/gift_cards_starter.sql` / `_solution.sql` (state: full) | Milestone 2 in miniature: a re-runnable build script for two new bookstore tables (gift cards and their uses), dropped children first, created parents first, every constraint named, read back from `information_schema.TABLE_CONSTRAINTS` and `CHECK_CONSTRAINTS`; a derived balance with LEFT JOIN and COALESCE | 15 min (guided lab) | 9 constraints (gift_card_uses: chk_gcu_amount, fk_gcu_card, fk_gcu_order, PRIMARY; gift_cards: chk_gift_cards_amount, chk_gift_cards_dates, fk_gift_cards_customer, PRIMARY, uq_gift_cards_code); 3 CHECK clauses; balances GC7Q2M4K 25.00, GC3X9P1T 31.02 (18.98 used on order 10), GC8L5V2N 20.00. The tables are dropped at the end |
| `l8_2-final-project/debug_gift_card_proofs.sql` (state: full) | The constraint-test pattern of Milestone 2: six statements that MUST be refused, inside a transaction, then ROLLBACK (a test file that must fail) | guided lab (second half) | ERROR 3819, 3819, 1452, 1062, 1265, 1452 in that order; `cards_in_transaction` 1, `cards_after_rollback` 0 |
| `l8_2-final-project/edge_cases_starter.sql` / `_solution.sql` (state: full) | Milestone 3/4 thinking: four report queries that only edge cases can test (inner JOIN for "never", a right-table condition in WHERE, ROW_NUMBER dropping a tie); fixed report date `@today = '2026-06-30'`; read-only | homework | 1. Carol Williams, Hank Taylor; 2. The Great Gatsby, The Catcher in the Rye; 3. eight customers (five with 1 recent order, Bob, Carol, Hank 0); 4. seven rows, ties in Fantasy (Lord of the Rings, The Hobbit, 2 orders) and Fiction (1984, Dune, 3) |
| `l8_2-final-project/debug_build_order.sql` (state: none) | The lesson's four build mistakes in a new script (a bike-share): a reserved word, a foreign-key type mismatch, CURDATE() in a CHECK, a child table before its parent (deliberately broken; builds and drops `kit_s13_bikes`) | fast finishers / homework | ERROR 1064 (`range`), 3780 (BIGINT vs INT), 3814 (curdate), 1824 (`parts`); SHOW TABLES: parts, riders. Fixed: six tables, no ERROR lines |

A starter runs without an error exactly as handed out (its TODO placeholders give a short or obviously
unfinished result) and ends with an "Expected when done" comment that quotes the solution's real output.

## How to run

Learners open a terminal **in the folder that holds `labs/`**, log in and SOURCE a file. The three
`state: full` files need the course database; reload it first (each file leaves the bookstore as it
found it, but a learner's half-finished edit may not):

```
mysql -u root -p
SOURCE labs/_states/bookstore.sql
SOURCE labs/module-13/l8_2-final-project/gift_cards_starter.sql
```

**The project is different.** Learners keep their project scripts in a `tool-library` folder and start
the client INSIDE it (`cd tool-library`, then `mysql -u root -p`): `02_data.sql` begins with
`SOURCE 01_schema.sql`, and SOURCE resolves a path from the folder the client was started in, not from
the folder of the file that contains the SOURCE line (measured on 9.7: started elsewhere, the client
prints `Failed to open file '01_schema.sql', error: 2`).

Check everything in this session at once (6 files; a few seconds):

```bash
python3 labs/check_labs.py module-13
```

## On MySQL 8.4 and MariaDB

- **8.4:** everything behaves as on 9.7 (CHECK constraints, `information_schema.CHECK_CONSTRAINTS`,
  window functions, error numbers).
- **MariaDB** (from the lesson's version notes): a mismatched or missing foreign-key target is
  `ERROR 1005 ... errno: 150 "Foreign key constraint is incorrectly formed"` (instead of 3780 and 1824),
  `CURDATE()` in a CHECK is error 1901 (instead of 3814) and a violated CHECK is error 4025 (instead of
  3819), so `debug_gift_card_proofs.sql` and `debug_build_order.sql` show other numbers there. MariaDB's
  1062 names the key without the table. The fixes are the same.

## Timing in Session 13

| Clock | Lab |
|-------|-----|
| 1:30 | `gift_cards_starter.sql` (TODOs 1 to 4, 8 min), then `debug_gift_card_proofs.sql` (5 min) |
| home | `edge_cases_starter.sql` (before Milestone 4); optional `debug_build_order.sql` |
