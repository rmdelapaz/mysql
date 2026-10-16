# Session 10 labs: Normalization and Stored Programs

Lessons **6.3 Database Design & Normalization** and **7.1 Stored Procedures & Functions** (Part 2). Every
lab is new practice on the lesson's ideas; none repeats a lesson project or exercise.

- The **6.3 labs** start from `-- state: none`: like the lesson's `normalize_lab`, they need no bookstore.
  Each builds its own practice database (`kit_s10_sheet`, `kit_s10_debug`) on every run and drops it at
  the end, so learners edit the file and SOURCE it again as often as they like.
- The **7.1 labs** start from `-- state: full` (a freshly loaded `bookstore.sql`). Every routine is
  preceded by `DROP PROCEDURE/FUNCTION IF EXISTS`, so the files rerun after every edit; the routines stay in
  `bookstore` until the next `SOURCE bookstore.sql`. The one price change is rolled back.

Hand out the `*_starter.sql` files and the two `debug_*.sql` files. Keep every `*_solution.sql` for
yourself until after the lab.

## What is here

| File | Practices | In class | Expected output (solution) |
|------|-----------|---------:|----------------------------|
| `l6_3-normalization/anomalies_starter.sql` / `_solution.sql` | A new flat sheet (workshop sign-ups): the update and delete anomalies inside rolled-back transactions; dependency tests with GROUP BY ... HAVING COUNT(DISTINCT ...) > 1; finding the key | 15 min | Bookbinding Basics with two dates; 0 rows about Speed Reading; one date/room/host/fee per workshop; host_email → host_name: no counterexample; host_email → workshop: Lena hosts 2; 6 rows, 6 (attendee, workshop) pairs, 5 attendees |
| `l6_3-normalization/normalize_starter.sql` / `_solution.sql` | The same sheet in 3NF (attendees, hosts, workshops, signups): INSERT ... SELECT DISTINCT parents first, the junction table, EXCEPT in both directions, the update anomaly gone | homework / fast finishers | 5 attendees, 2 hosts, 3 workshops, 6 signups; both EXCEPT queries Empty set; one UPDATE moves all three Bookbinding attendees to 2026-07-12 |
| `l6_3-normalization/debug_design.sql` | Three refusals that are the design working (deliberately broken): a lookup table loaded twice, a BIGINT foreign key to an INT id, deleting a parent row | clinic | `ERROR 1062 ... 'hosts.email'`, `ERROR 3780 ... are incompatible`, `ERROR 1451 ... a foreign key constraint fails`; 2 hosts, 2 workshops afterward |
| `l7_1-stored-procedures/procedures_starter.sql` / `_solution.sql` | An IN procedure returning a result set, OUT parameters into user variables, a SIGNAL guard before an UPDATE (called inside a rolled-back transaction) | 20 min | Dystopian: Brave New World 9.49, 1984 9.99, Fahrenheit 451 10.49; Orwell 2 books 6 copies, Asimov 0 and 0; The Hobbit 12.09, then 10.99 after ROLLBACK; `CALL raise_price(6, 80);` → `ERROR 1644 (45000): Percent must be between 1 and 50` |
| `l7_1-stored-procedures/functions_starter.sql` / `_solution.sql` | A DETERMINISTIC NO SQL function (shipping fee) and a READS SQL DATA function (copies sold), used in SELECT and in WHERE; information_schema.ROUTINES | homework / fast finishers | Shipping 6.99, 4.99, 5.99, 4.99, 5.99; 1984 4, The Hobbit 3, Animal Farm 2, Lord of the Rings 2, The Great Gatsby 0; never sold: The Catcher in the Rye, The Great Gatsby; copies_sold NO READS SQL DATA, shipping_fee YES NO SQL |
| `l7_1-stored-procedures/debug_routines.sql` | Five routine mistakes (deliberately broken): no DELIMITER, a function without characteristics, SELECT ... INTO two rows, CREATE twice, a SIGNAL guard tripped | clinic | `ERROR 1064` twice, `ERROR 1418`, `ERROR 1172`, `ERROR 1304`, `ERROR 1644 (45000): Pages must be a positive number`; Fahrenheit 451 still 158 pages |

A starter runs without an error exactly as handed out (TODO placeholders: a commented-out statement, a
`TODO` line, a stub like `SET p_copies = -1`) and ends with an "Expected when done" comment that quotes the
solution's real output.

## How to run

From the folder that holds `labs/` and `bookstore.sql`, in the mysql client:

```
SOURCE labs/module-10/l6_3-normalization/anomalies_starter.sql     -- no bookstore needed
SOURCE bookstore.sql
SOURCE labs/module-10/l7_1-stored-procedures/procedures_starter.sql
```

The 7.1 files contain `DELIMITER //` ... `DELIMITER ;` lines: the mysql client and SOURCE understand them.
In phpMyAdmin, paste one routine at a time and set the SQL tab's Delimiter box to `//` instead.
Docker users with no client on the laptop: `docker exec -i mysql97 sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" --table bookstore' < labs/...`
(the 6.3 files need no database name).

Check everything in this session at once (10 files; a few seconds):

```bash
python3 labs/check_labs.py module-10
```

**Binary logging:** `debug_routines.sql` section B (error 1418) fails only while binary logging is on, which
is the default on MySQL 8.0 and later. On a server started with `--skip-log-bin`, and on MariaDB, the
function is created instead and `check_labs.py` reports the file as a failure (1418 missing): that is the
lesson's point about servers without a binary log, not a broken lab.

## On MySQL 8.4 and MariaDB

- **8.4:** every lab passes, with the same errors.
- **MariaDB** (measured on 12.3): every starter and solution passes. `debug_routines.sql` raises 1064
  twice, 1172, 1304 and 1644, but not 1418 (no binary log by default); `debug_design.sql` reports the
  foreign-key type mismatch as 1005 (`Foreign key constraint is incorrectly formed`) instead of 3780.

## Timing in Session 10

| Clock | Lab |
|-------|-----|
| 0:40 | `anomalies_starter.sql` (15 min); fast finishers start `normalize_starter.sql` |
| 1:05 | Break: everyone runs `SOURCE bookstore.sql` before the 7.1 demo |
| 1:50 | `procedures_starter.sql` (20 min); fast finishers take `functions_starter.sql` |
| 2:25 | Clinic: `debug_design.sql` and `debug_routines.sql` in pairs (inside the 25-minute clinic) |

`normalize_starter.sql` and `functions_starter.sql` are homework for anyone who did not reach them.
