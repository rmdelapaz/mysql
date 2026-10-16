# Session 3 labs: Data Types, Constraints and CRUD

Lessons **2.2 Data Types & Constraints** and **2.3 CRUD Operations** (Part 1). Every lab is new practice on
the lesson's ideas; none of them repeats a lesson project (`employees.sql`, `load_bookstore_data.sql`) or
exercise. All of them start from `-- state: schema`: the `bookstore` database as Lesson 2.1's build script
leaves it, with three empty tables (books, customers, categories).

Labs run **inside `bookstore`**: learners type `USE bookstore;` once, then SOURCE the files. The labs never say
`USE` themselves. Each one leaves `bookstore` as it found it: the 2.2 labs create a `kit_...` table and drop it
again; the 2.3 labs fill one table and empty it again with `TRUNCATE` at the end. If a learner's `bookstore` is
missing or broken, rerun their `create_bookstore.sql`, or `SOURCE labs/_states/schema.sql` (the same three
empty tables).

Hand out the `*_starter.sql` files and the two `debug_*.sql` files. Keep every `*_solution.sql` for yourself
until after the lab.

## What is here

| File | Practices | In class | Expected output (solution) |
|------|-----------|---------:|----------------------------|
| `l2_2-data-types-constraints/types_matter_starter.sql` / `_solution.sql` | Why types matter: a delivery list pasted with copies as text, cost as FLOAT and dates as MM/DD/YYYY text gives wrong sorts, a FLOAT total and a wrong "latest"; fixed with INT UNSIGNED, DECIMAL(6, 2), DATE and `STR_TO_DATE` | 20 min (pairs) | As shipped: copies sorted 9, 15, 120; total 556.9499866962433; dates in text order; last delivery `12/01/2026`. Solution: Dune 120, Emma 15, 1984 9; total **556.95**; 2026-03-10, 2026-12-01, 2027-01-15; last delivery 2027-01-15 |
| `l2_2-data-types-constraints/membership_rules_starter.sql` / `_solution.sql` | Five written rules become NOT NULL, UNIQUE, ENUM + DEFAULT, DEFAULT 0 and a named CHECK; information_schema.TABLE_CONSTRAINTS and SHOW COLUMNS show what MySQL knows | fast finishers / homework | As shipped: Ana and Ben have NULL tier and points; one constraint (PRIMARY). Solution: Ana and Ben `reader`, 0; Cleo patron 250; constraints chk_points CHECK, PRIMARY PRIMARY KEY, email UNIQUE; Null NO for email, first_name, tier, points |
| `l2_2-data-types-constraints/debug_bad_rows.sql` | Six sign-ups the finished table refuses: 1048 (NULL email), 1062 (shared email), 1265 (tier not on the ENUM list), 1292 (Feb 29, 1995), 1364 (first name left out), 3819 (negative points) (deliberately broken) | fast finishers | Before fixing: the six ERROR lines and three members (ids 1, 2 and **4**: the refused duplicate used up id 3). Fixed: nine members, no ERROR lines |
| `l2_3-crud-operations/new_arrivals_starter.sql` / `_solution.sql` | INSERT six books in one statement, `LAST_INSERT_ID()` after a multi-row insert, SELECT preview then UPDATE with the same WHERE, `ROW_COUNT()`, two assignments in one SET, preview then DELETE, an id that is not reused | 20 min | first_new_id **1** (the first row of the batch); preview Moby Dick 12.40 and Little Women 10.20; rows_changed 2; Frankenstein 6.99, in_stock 0; Emma and Frankenstein previewed, rows_deleted 2; Middlemarch gets id 7; final prices Moby Dick 13.02, Little Women 10.71 |
| `l2_3-crud-operations/category_feed_starter.sql` / `_solution.sql` | One multi-row upsert (`AS new ON DUPLICATE KEY UPDATE`) handles new, changed and unchanged rows; `ROW_COUNT()` adds up 2 + 0 + 1; INSERT IGNORE (warning 1062, nothing stored) and REPLACE (new id, description lost) | fast finishers / homework | affected **3**; Poetry's new text, Cooking id 5; `Warning 1062 Duplicate entry 'History'`; after REPLACE Fiction is id **9** with a NULL description (ids 6 to 8 were reserved by the upsert's and IGNORE's attempts and never used) |
| `l2_3-crud-operations/debug_crud_slips.sql` | Five CRUD slips: 1136 (two values for three columns), 1054 (text without quotes), 1062 (an email already used), 1175 (safe-updates refuses a WHERE on a non-key column), 1292 (AND instead of a comma in SET: with text values strict mode refuses it) (deliberately broken) | fast finishers | Before fixing: the five ERROR lines and the three customers unchanged. Fixed: five customers, Nina and Paula in Aurora, Omar in Chicago with omar.h@example.com |

A starter runs without an error exactly as handed out (turned-off statements, placeholder types) and ends with
an "Expected when done" comment that quotes the solution's real output.

## How to run

```
mysql -u root -p
USE bookstore;
SOURCE labs/module-03/l2_3-crud-operations/new_arrivals_starter.sql
```

Each lab can be run again and again: the 2.2 labs drop and recreate their table, the 2.3 labs fill and empty
theirs. Do not run a 2.3 lab while you are halfway through the lesson project: the lab's `TRUNCATE`
empties the table your project just loaded (rerun `load_bookstore_data.sql` afterward).

Note on `debug_crud_slips.sql` Bug D: `SET SQL_SAFE_UPDATES = 1;` changes only the learner's own session, and
the next line turns it off again. Learners who stop the file early keep safe-updates on until they log out:
that is harmless (Lesson 2.3 recommends it).

Check everything in this session at once (10 files; a few seconds):

```bash
python3 labs/check_labs.py module-03
```

## On MySQL 8.4 and MariaDB (measured)

- **8.4:** every file gives the same answers and the same errors.
- **MariaDB 12.3:** `category_feed_solution.sql` fails at the row alias (`AS new` is ERROR 1064 there: Lesson
  2.3's version note); write `ON DUPLICATE KEY UPDATE description = VALUES(description)` instead, which MariaDB
  runs without a warning. REPLACE then gives Fiction id 6, not 9 (MariaDB reserves ids differently). In
  `debug_bad_rows.sql` the CHECK error is `ERROR 4025 (23000): CONSTRAINT chk_points failed` instead of 3819,
  and 1062 names the key `'email'`; in `debug_crud_slips.sql` 1054 says `in 'VALUES'`. Everything else matches.

## Timing in Session 3

| Clock | Lab |
|-------|-----|
| 0:45 | `types_matter_starter.sql` in pairs (20 min); fast finishers take `membership_rules_starter.sql`, then `debug_bad_rows.sql` |
| 2:05 | `new_arrivals_starter.sql` (20 min); fast finishers take `category_feed_starter.sql`, then `debug_crud_slips.sql` |

`membership_rules_starter.sql` and `category_feed_starter.sql` are homework for anyone who did not reach them
in class.
