# Session 7 labs: Joins and the Part 1 Assessment

Lesson **4.3 Joins** (Part 1) and the **Part 1 assessment**. The 4.3 labs are new practice on the lesson's
ideas (none repeats the lesson project or exercises) and start from `-- state: full`, the relational bookstore
(`bookstore.sql`). They only read data. The assessment builds a database of its own (`-- state: none`).

Load the bookstore first if needed, from the folder that holds `labs/`:

```
SOURCE labs/_states/bookstore.sql
```

**Hand out:** the two 4.3 `*_starter.sql` files, `debug_joins.sql` and `part1-assessment/part1_assessment_starter.sql`.
**Keep:** every `*_solution.sql`, above all `part1-assessment/part1_assessment_solution.sql` (the assessment's
reference; share it only after scoring, if at all). The rubric and the instructor answer notes are in
`final-assessment.html` at the kit root (Part 1 assessment section).

## What is here

| File | Practices | In class | Expected output (solution) |
|------|-----------|---------:|----------------------------|
| `l4_3-joins/catalog_joins_starter.sql` / `_solution.sql` | An INNER JOIN through three tables; LEFT JOIN with GROUP BY and `COUNT(b.id)`; an anti-join on the self-reference (Session 6 used NOT EXISTS); a self-join with a computed column | 20 min (pairs) | order 7: 1984, Animal Farm; order 12: Animal Farm, Fahrenheit 451 · Orwell 2 / 8.49, Tolkien 2 / 10.99, ..., Asimov 0 / NULL · Tom, Lena, Sofia, Nina, Ben manage nobody · Sofia 5 years after Marcus, Tom 3 after Priya, ... |
| `l4_3-joins/city_sales_starter.sql` / `_solution.sql` | Revenue per city with two LEFT JOINs, COUNT(DISTINCT) and the `(no city)` group; DISTINCT after a fan-out; the WHERE-versus-ON trap on a new question | fast finishers / homework | New York 2 / 5 / 100.91, Chicago 2 / 4 / 67.44, Houston 1 / 2 / 45.96, (no city) 2 / 1 / 22.98, Los Angeles 1 / 0 / 0.00 · 1984, Animal Farm, Dune, To Kill a Mockingbird · eight customers since March (Bob 2, Carol and Hank 0) |
| `l4_3-joins/debug_joins.sql` | Three refused joins (deliberately broken): 1052 (ambiguous `id`), 1054 (table name after an alias), 1066 (self-join without aliases), and one silent fan-out count | fast finishers | The three ERROR lines; Bug D prints Alice 4, Bob 3 (orders: 3 and 2) |
| `part1-assessment/part1_assessment_starter.sql` / `_solution.sql` | **The Part 1 assessment** (60 min, open book, alone): the Riverside Cooking School (fictional; database `kit_riverside`). Part A: create `enrollments` with keys, rules and a CHECK, load it, two refused statements, one UPDATE, one DELETE. Part B: eight queries (filters, GROUP BY, HAVING, NULL-aware averages, a subquery, a four-table join, an anti-join, LEFT JOIN with GROUP BY) | 60 min (Session 7, 1:35) | 15 enrollments, 12 rated · B1 Sourdough 45.00, Tacos 50.00 · B2 Italian 65.00 ... Mexican 50.00 · B3 Ana, Chloe, Emma 3 · B5 French Pastry, Fresh Pasta, Sushi · B7 Gina Russo, Hugo Weber · B8 Marco Rossi 330.00 ... Nadia Haddad 0.00 |

Every 4.3 starter runs without an error as handed out (a placeholder such as `0 AS books` or `1 = 0`, or a
`TODO` line) and ends with an "Expected when done" comment that quotes the solution's real output. The
assessment starter runs too: it builds the three given tables, prints its TODO lines and drops `kit_riverside`
at the end (learners may comment out that last line while exploring at the prompt, and put it back before
they hand in).

## How to run

```
mysql -u root -p
USE bookstore;
SOURCE labs/module-07/l4_3-joins/catalog_joins_starter.sql
SOURCE labs/module-07/part1-assessment/part1_assessment_starter.sql
```

The assessment does not need `USE bookstore`: it creates, uses and drops `kit_riverside`. To check a learner's
file quickly: `python3 labs/check_labs.py --file <file> -v` (add `-- state: none` as its first line if the
learner removed it); it runs the file in a fresh session and fails on the first error.

Check everything in this session at once (7 files):

```bash
python3 labs/check_labs.py module-07
```

## On MySQL 8.4 and MariaDB (measured)

- **8.4:** same results and the same error numbers.
- **MariaDB:** every file runs. `debug_joins.sql` says "in SELECT" where MySQL says "in field list" (same
  numbers). In the assessment, a rating of 6 is refused with `ERROR 4025 ... CONSTRAINT
  chk_enrollments_rating failed` instead of `ERROR 3819`, and 1452's message omits `ON DELETE RESTRICT`.

## Timing in Session 7

| Clock | Lab |
|-------|-----|
| 0:45 | `catalog_joins_starter.sql` (20 min, TODO 1 together); fast finishers take `city_sales_starter.sql`, then `debug_joins.sql` |
| 1:15 | Break: everyone copies `part1-assessment/part1_assessment_starter.sql` into the course folder |
| 1:25 | Assessment setup (10 min): one run of the starter on every laptop |
| 1:35 | **Part 1 assessment** (60 min); files handed in at 2:35 |

`catalog_joins_starter.sql`, `city_sales_starter.sql` and `debug_joins.sql` are homework for anyone who did
not reach them.
