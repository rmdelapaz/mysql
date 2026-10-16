# Session 5 labs: Aggregates and Subqueries

Lessons **3.3 Aggregate Functions & GROUP BY** and **3.4 Subqueries & Nested Queries** (Part 1). Every lab is
new practice on the lesson's ideas; none of them repeats a lesson project or exercise. All of them start from
`-- state: flat`: the Module 3 bookstore that Lesson 3.1's setup script builds (10 books with a text `author`
column, 8 customers, 5 categories). They only read data, so they can run in any order.

If a learner's data has drifted (or they loaded the Module 4 `bookstore.sql` too early: 11 books, no `author`
column), reload the flat bookstore first, from the folder that holds `labs/`:

```
SOURCE labs/_states/flat.sql
```

Hand out the `*_starter.sql` files and the two `debug_*.sql` files. Keep every `*_solution.sql` for yourself
until after the lab.

## What is here

| File | Practices | In class | Expected output (solution) |
|------|-----------|---------:|----------------------------|
| `l3_3-aggregate-functions/customer_summary_starter.sql` / `_solution.sql` | The lesson summarized the books; this summarizes the customers: COUNT three ways, NULL counting, MIN/MAX of a DATETIME, GROUP BY an expression (`DATE_FORMAT`), HAVING, COALESCE for the NULL group | 15 min (pairs) | 8 customers, 6 with a city, 2 missing, 4 cities, first 2026-01-04 10:15:00, latest 2026-02-10 19:12:00 · 2026-01 6, 2026-02 2 · New York and Chicago, 2 each · January signups: New York 2, then (no city), Chicago, Houston, Los Angeles with 1 |
| `l3_3-aggregate-functions/page_report_starter.sql` / `_solution.sql` | Length bands with CASE sorted by `MIN(pages)`, pages per author with LIMIT, books per century, WHERE plus HAVING | fast finishers / homework | Short 3 / 9.49, Medium 4 / 10.62, Long 3 / 12.99 · Tolkien 1488 first · century 19: 1, century 20: 9 · six authors over 200 in-stock pages (Salinger only without the WHERE) |
| `l3_3-aggregate-functions/debug_group_by.sql` | Four broken summaries (deliberately broken): errors 1140, 1055, 1111, 1064 | error clinic | The four ERROR lines; fixed: four result tables |
| `l3_4-subqueries/page_checks_starter.sql` / `_solution.sql` | Replace every hand-typed number with a subquery: the row behind MIN(published), two scalar subqueries in one WHERE, an IN list, `> ALL` against `> MAX` | 10 min (pairs) | Pride and Prejudice 1813-01-28 · five quick reads (Fahrenheit 451 to 1984) · The Great Gatsby and The Catcher in the Rye · four books after every out-of-stock book; `same_with_max` 4 |
| `l3_4-subqueries/city_neighbors_starter.sql` / `_solution.sql` | Correlated subqueries (in SELECT and in WHERE), a derived table, the NOT IN / NULL trap and NOT EXISTS, on new questions | 15 min (pairs) | neighbors 1,1,0,0,0,1,1,0 · first signups Alice, Bob, Carol, Dave · 5 authors over 300 pages, longest 1488 · Carol and Dave (4a prints nothing until the IS NOT NULL is added) |
| `l3_4-subqueries/debug_subqueries.sql` | Four broken subqueries, one per shape (deliberately broken): errors 1242, 1241, 1248, 1235 | error clinic | The four ERROR lines; fixed: four result tables |

A starter runs without an error exactly as handed out: it shows its TODO placeholders (a 0, a NULL, an
`Empty set` or a `TODO` line) and ends with an "Expected when done" comment that quotes the solution's real
output.

## How to run

Learners open a terminal **in the folder that holds `labs/`**, log in, select the database and SOURCE a file:

```
mysql -u root -p
USE bookstore;
SOURCE labs/module-05/l3_3-aggregate-functions/customer_summary_starter.sql
```

The labs never say `USE bookstore` themselves: they run in the learner's current database. Docker users with
no client on the laptop: `docker exec -i mysql97 sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" --table bookstore' < labs/...`.

Check everything in this session at once (10 files; a few seconds):

```bash
python3 labs/check_labs.py module-05
```

## On MySQL 8.4 and MariaDB

- **8.4:** same results and the same error numbers.
- **MariaDB** (XAMPP, some hosts): no `ONLY_FULL_GROUP_BY`, so `debug_group_by.sql` Bug B runs without an error
  (it silently picks a last name per city): a good moment to show why MySQL refuses. Groups come back sorted
  by the grouped column even without ORDER BY. `debug_subqueries.sql` Bug C is `ERROR 1064 ... near ''`
  instead of 1248. Error 1140 does not appear either (Bug A returns one arbitrary first name).

## Timing in Session 5

| Clock | Lab |
|-------|-----|
| 0:45 | `customer_summary_starter.sql` (15 min, TODO 1 together); fast finishers take `page_report_starter.sql`, then `debug_group_by.sql` |
| 2:00 | `page_checks_starter.sql` (10 min), then `city_neighbors_starter.sql` (15 min); fast finishers take `debug_subqueries.sql` |
| 2:40 | Error clinic: half the room on each debug handout (10 min) |

`page_report_starter.sql` and `city_neighbors_starter.sql` are homework for anyone who did not reach them.
