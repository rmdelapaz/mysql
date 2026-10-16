# Session 6 labs: Relationships and Foreign Keys

Lessons **4.1 Table Relationships** and **4.2 Foreign Keys & Referential Integrity** (Part 1). Every lab is new
practice on the lesson's ideas; none of them repeats a lesson project or exercise.

**Two starting states this session.** Lesson 4.1 turns the flat bookstore into the relational one; from
Lesson 4.2 on, every lesson starts from `bookstore.sql`.

- `publisher_split_*` declares `-- state: flat` but works only on two practice tables of its own
  (`kit_editions`, `kit_publishers`), which it rebuilds on every run and drops at the end. It runs in either
  shape of the bookstore.
- Every other lab declares `-- state: full`: the relational bookstore (8 tables). Load it first, from the
  folder that holds `labs/`:

```
SOURCE labs/_states/bookstore.sql
```

The `full` labs never change the data for good: every destructive test sits inside
`START TRANSACTION ... ROLLBACK`, and practice tables (`kit_gift_cards`, `kit_signings`, ...) are dropped at the
end. Hand out the `*_starter.sql` files and the two `debug_*.sql` files; keep every `*_solution.sql`.

## What is here

| File | Practices | In class | Expected output (solution) |
|------|-----------|---------:|----------------------------|
| `l4_1-table-relationships/publisher_split_starter.sql` / `_solution.sql` | The lesson's four-step migration on new data: six (fictional) editions with the publisher's name and city typed in every row; parent table, key column, `UPDATE ... JOIN`, the NULL check (a typo is planted), lock-in, lookups | 15 min (pairs) | Anomalies: Harbor Lane Press in Boston and Cambridge; `North Star Book` vs `North Star Books` · one unmatched row (5, Fahrenheit 451), 0 after the fix · each publisher 2 editions |
| `l4_1-table-relationships/navigate_links_starter.sql` / `_solution.sql` | Following the keys of the relational bookstore with subqueries (before joins): the key map from information_schema, a junction table counted per book, zero-or-many, a self-reference with NOT EXISTS, two links | fast finishers / homework | 7 keys · 1984, Brave New World, Fahrenheit 451 in 3 categories · Alice 3 orders ... Carol and Hank 0 · Tom, Lena, Sofia, Nina, Ben manage nobody · order 4: Lord of the Rings, The Hobbit |
| `l4_1-table-relationships/debug_relationships.sql` | Three relationship mistakes on new tables (deliberately broken): 1824 (misspelled parent), 1062 (a link that exists), 1138 (NOT NULL before filling) | fast finishers | The three ERROR lines; the practice tables are dropped |
| `l4_2-foreign-keys/delete_rules_starter.sql` / `_solution.sql` | Predict, then watch each rule act, on rows the lesson did not use: CASCADE (category → links; order → lines), SET NULL (a manager leaves), RESTRICT with nothing to protect, ON UPDATE CASCADE; all rolled back | 20 min | links 25 → 22 · Sofia's manager NULL · 7 customers left · orders 6 and 11 say customer 70 · lines 18 → 16 · final row unchanged: 5, 25, 8, 12, 18, 6 |
| `l4_2-foreign-keys/orphan_audit_starter.sql` / `_solution.sql` | A table created without a key: find the orphans (NOT EXISTS), fix them truthfully (NULL), add the key with SET NULL, prove it in a transaction | fast finishers / homework | orphans: cards 3 (customer 12) and 5 (customer 15) · `fk_cards_customer` SET NULL / CASCADE · Carol deleted: card 2 unassigned · 5 cards, 120.00, 3 assigned after ROLLBACK |
| `l4_2-foreign-keys/debug_fk_errors.sql` | Five statements a foreign key refuses (deliberately broken): 1452, 1451, 3780 (INT UNSIGNED vs INT), 1830 (SET NULL on NOT NULL), 6125 (a key to a non-unique column) | fast finishers | The five ERROR lines; 12 orders and 11 books afterwards (nothing changed) |

A starter runs without an error exactly as handed out (TODO statements are turned off with `--`, or a
placeholder such as `1 = 0` gives an empty result) and ends with an "Expected when done" comment that quotes
the solution's real output. Learners turn on one TODO at a time and SOURCE the file again.

## How to run

```
mysql -u root -p
USE bookstore;
SOURCE labs/module-06/l4_2-foreign-keys/delete_rules_starter.sql
```

The labs never say `USE bookstore` themselves. Check everything in this session at once (10 files):

```bash
python3 labs/check_labs.py module-06
```

## On MySQL 8.4 and MariaDB (measured)

- **8.4:** same results and the same error numbers (6125 exists from 8.4 on).
- **MariaDB:** every lab runs. In the debug handouts, the badly formed keys all come back as
  `ERROR 1005 (HY000): Can't create table ... (errno: 150 "Foreign key constraint is incorrectly formed")`
  (instead of 1824, 3780, 1830 and 6125); the NOT NULL change in `debug_relationships.sql` is
  `ERROR 1265 Data truncated for column 'author_id'` instead of 1138; 1062 names the key `'PRIMARY'`
  without the table.

## Timing in Session 6

| Clock | Lab |
|-------|-----|
| 0:50 | `publisher_split_starter.sql` (15 min, pairs) in the flat or the relational bookstore |
| 1:05 | Everyone loads `bookstore.sql` (the 4.1 project start) |
| 2:00 | `delete_rules_starter.sql` (20 min); fast finishers take `orphan_audit_starter.sql`, then `debug_fk_errors.sql` |

`navigate_links_starter.sql`, `orphan_audit_starter.sql` and `debug_relationships.sql` are homework for anyone
who did not reach them.
