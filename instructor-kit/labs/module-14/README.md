# Session 14 labs: Final Project Studio II, Showcase and Next Steps

Lessons **8.2 Final Project: Design and Build a Database** (second half, Milestones 5 to 7) and
**8.3 Next Steps & Best Practices** (Part 2, the last session). The project (`tool_library`) is each
learner's own work in their `tool-library` folder; these labs are NEW practice of the same skills on the
bookstore, for learners who are stuck on a milestone's shape, for fast finishers and for homework.

Hand out the `*_starter.sql` files and the `debug_*.sql` files. Keep every `*_solution.sql` for
yourself until after the lab. All files start from `-- state: full` (the course database).

## What is here

| File | Practices | In class | Expected output (solution) |
|------|-----------|---------:|----------------------------|
| `l8_2-final-project/add_item_rules_starter.sql` / `_solution.sql` | Milestone 5's shape on the bookstore: `add_order_item(order, book, copies)` with a transaction, `SELECT ... FOR UPDATE` on the order, one SIGNAL per rule, the EXIT HANDLER (ROLLBACK, RESIGNAL); the one-row rule (1 to 10 copies) as a named CHECK instead | stuck learners (15 min) / homework | Two allowed calls: item 19 (1984, 9.99) and item 20 (The Hobbit, 10.99); order 3 then lists Dune, 1984, The Hobbit; SECURITY_TYPE DEFINER. The cleanup removes the lines, the CHECK and the procedure |
| `l8_2-final-project/debug_add_item_rules.sql` | One call per rule that MUST be refused (a test file that must fail) | with the pair | ERROR 1644 No such order · No such book · Book is out of stock · Book is already on this order · An order holds at most 3 different books; ERROR 3819 `chk_items_quantity`; `order_items_now` 20 |
| `l8_2-final-project/least_privilege_starter.sql` / `_solution.sql` | Milestone 6's shape: a role per job (`kit_shop_till`, `kit_shop_owner`), an account per program or person with SET DEFAULT ROLE, EXECUTE on a procedure instead of a write privilege, an audit from `information_schema.SCHEMA_PRIVILEGES` / `TABLE_PRIVILEGES`; everything dropped at the end | homework | SHOW GRANTS: 5 lines for `kit_till_app`; audit 4 rows (owner SELECT; till SELECT, customers INSERT and UPDATE); `delete_privileges` 0 (as shipped: ALL PRIVILEGES, 22 audit rows, 2) |
| `l8_3-next-steps/health_check_starter.sql` / `_solution.sql` | Lesson 8.3's information_schema audit, extended: tables without a primary key, FLOAT/non-utf8mb4 columns, `..._id` columns no foreign key protects, CASCADE/SET NULL delete rules; a planted legacy table (dropped at the end) | fast finishers / homework | `kit_legacy_refunds` without PK; its `amount float` and `reason varchar(100) latin1`; its `order_id`; four delete rules (fk_bc_book, fk_bc_category CASCADE; fk_employees_manager SET NULL; fk_items_order CASCADE) |
| `l8_3-next-steps/safe_search_starter.sql` / `_solution.sql` | SQL injection by string-building, then `PREPARE ... EXECUTE ... USING` with one and with three placeholders; read-only | fast finishers / homework | Part 1 leaks all 8 customers; by_city: Empty set, then Bob Smith and Grace Wilson; orders_between: orders 2 (2026-02-20) and 8 (2026-04-05), then Empty set |
| `l8_3-next-steps/debug_unsafe_habits.sql` | Safe-update mode (`SQL_SAFE_UPDATES = 1`): an UPDATE without WHERE and one on a non-key column are refused, a DELETE on an indexed column gets through (deliberately broken; all inside a rolled-back transaction) | fast finishers | ERROR 1175 twice; Dune 14.99, Bob in Chicago, `gatsby_lines` 0 |

A starter runs without an error exactly as handed out and ends with an "Expected when done" comment that
quotes the solution's real output.

## How to run

From a client started in the folder that holds `labs/`:

```
mysql -u root -p
SOURCE labs/_states/bookstore.sql
SOURCE labs/module-14/l8_2-final-project/add_item_rules_starter.sql
```

Every file leaves the bookstore as it found it (the procedure labs delete what they add and drop their
procedures, CHECKs, accounts and roles; the debug file rolls back). Reload the bookstore anyway if a
learner's edited file stopped halfway. The project itself runs from a client started INSIDE the
`tool-library` folder (see Session 13's README: nested SOURCE paths).

Check everything in this session at once (10 files; a few seconds):

```bash
python3 labs/check_labs.py module-14
```

Note on the checker: it loads the bookstore into a scratch database (`kitlab_check`), so in its output
`least_privilege_*` shows grants on both `bookstore`.* and `kitlab_check`; a learner's server shows
`bookstore` everywhere (that is what the Answer Key prints).

## On MySQL 8.4 and MariaDB

- **8.4:** the same results (roles, CHECK constraints, `SHOW GRANTS ... USING`, safe-update mode).
- **MariaDB:** roles exist, but the default-role statement is `SET DEFAULT ROLE kit_shop_till FOR
  'kit_till_app'@'localhost'` and CREATE ROLE takes one role per statement (the lesson's version note), so
  `least_privilege_*` needs those two edits; a violated CHECK is error 4025 instead of 3819;
  `information_schema.CHECK_CONSTRAINTS` and the other checks work.

## Timing in Session 14

| Clock | Lab |
|-------|-----|
| 0:25 | (stuck learners) `add_item_rules_starter.sql`, then `debug_add_item_rules.sql`, during the Milestone 5 studio |
| 2:35 | (fast finishers) `health_check_starter.sql` during the 8.3 project start |
| home | `least_privilege_starter.sql`, `safe_search_starter.sql`, `debug_unsafe_habits.sql` |
