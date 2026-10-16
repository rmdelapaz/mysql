# Labs

All hands-on SQL labs for the **MySQL Foundations** instructor kit (14 sessions, Modules 1 to 8), grouped by session (one folder per
3-hour session; `module-04` = Session 4). Each session folder has its own `README.md` with the exact
files, what each lab practices, how long it takes and what "done" looks like. This file is the map and the
rules.

```
labs/
├─ check_labs.py    runs every lab file against a real MySQL server and reports PASS/FAIL
├─ _states/         the starting databases: bookstore.sql (the course download), flat.sql, schema.sql
├─ module-01/       Session 1 · lessons 1.1 + 1.2
│   ├─ README.md
│   ├─ l1_0-orientation/        (Session 1 only: environment check, diagnostic)
│   ├─ l1_1-<slug>/       one folder per lesson: l<module>_<lesson>-<slug>
│   │   ├─ <name>_starter.sql    the handout
│   │   ├─ <name>_solution.sql   the instructor's reference
│   │   └─ debug_<name>.sql      (optional) a deliberately broken "find the bug" handout
├─ module-02/ ... module-14/     (Part 1 = module-01 to module-07, Part 2 = module-08 to module-14)
```

## How learners run a lab

Labs are plain `.sql` files. Learners open a terminal **in the folder that holds `labs/`**, log in, and
SOURCE the file at the `mysql>` prompt:

```
mysql -u root -p
SOURCE labs/module-03/l2_3-crud-operations/fix_prices_starter.sql
```

(On Windows `SOURCE` takes forward slashes or backslashes; Docker users either install a client on the
laptop and connect with `-h 127.0.0.1 -P 3306`, or copy the file in and SOURCE it inside the container.)
SOURCE prints the boxed result tables, keeps going after an error, and shows each statement's result in
order: exactly what the answer key shows. A starter is edited in any text editor (VS Code works well)
and SOURCEd again; "Expected when done" at its end quotes the solution's real output.

## The starting state: one comment line

Every lab file says in its header which database it starts from:

| Header | Meaning | Learner's setup |
|---|---|---|
| `-- state: none` | No course database needed. The lab builds its own small practice database (`kit_...`) and drops it at the end. | nothing |
| `-- state: schema` | `bookstore` as it is at the end of Lesson 2.1: three empty tables | `SOURCE labs/_states/schema.sql` |
| `-- state: flat` | `bookstore` with the Module 3 data (`books.author` is text) | `SOURCE labs/_states/flat.sql` |
| `-- state: full` | the course database, `bookstore.sql` (Lesson 4.2 onward) | `SOURCE labs/_states/bookstore.sql` |

Each state file throws away the old `bookstore` and rebuilds it, so it is always safe to reload one.
Labs that use `bookstore` never say `USE bookstore` themselves: they run in the learner's current
database. Labs never touch the root account or server-wide settings.

## Naming rules

| File | Meaning | Run by the checker |
|---|---|---|
| `<name>_starter.sql` | The handout. **Runs without an error exactly as shipped**: TODOs in comments, placeholder values that give an empty or obviously unfinished result, and an "Expected when done" comment at the end. | yes |
| `<name>_solution.sql` | The reference. Complete; its SELECTs print the answers. Do not hand out before the lab. | yes |
| `debug_<name>.sql` | A deliberately broken handout. It MUST fail, and only with the errors its header declares: `-- expect-error: 1062, 1364`. | yes, with `--force` |
| `check_environment.sql` and other support scripts | Tools, not exercises. They carry a state header too. | yes |
| `*.sh`, `*.ps1`, `README.md` | Helpers and notes. | no |

- Starters and solutions come in **pairs** with the same `<name>`.
- Lesson folders are `l<module>_<lesson>-<slug>`: `l2_3-crud-operations`, `l4_3-joins`.
- A lab that creates a database, a table outside `bookstore`, an account or a role removes it again
  before it ends (`DROP DATABASE kit_...;`, `DROP USER ...;`). The checker fails a file that leaves one
  behind.
- Keep example data ASCII (the client pads tables by bytes) and fictional (people) or real classics (books).
- Always `ORDER BY` when more than one row comes back: MySQL does not promise any other order.

## Checking the labs

From this kit's folder (any folder works):

```bash
python3 labs/check_labs.py                 # all sessions
python3 labs/check_labs.py module-03       # one session (also 03 or 3; several allowed)
python3 labs/check_labs.py module-03 -v    # also show what each file printed
python3 labs/check_labs.py --file labs/module-03/l2_3-crud-operations/fix_prices_solution.sql -v
python3 labs/check_labs.py --strict        # all sessions; a session with no labs counts as a failure
```

For every lab file it: loads the declared state into a **scratch database** (`kitlab_check`; your own
`bookstore` is never touched), runs the file through the real `mysql` client (`--table --commands
--show-warnings`, plus `--force` for `debug_*.sql`), and prints one `PASS` / `FAIL` line per file, then
`N passed, M failed`. A file fails on any SQL error (a debug file: on no error, or an undeclared one), on
a timeout (60 s), on a database or account it leaves behind, or, without being run, if it would change the
root account or a server setting (`ALTER USER root`, `SET GLOBAL`, `SET PERSIST`, ...).

**Which server:** set these environment variables to point the checker at your own MySQL 9.7 (any
account that may create and drop databases and users):

```bash
export MYSQL_LABS_HOST=127.0.0.1 MYSQL_LABS_PORT=3306 MYSQL_LABS_USER=root
export MYSQL_LABS_PASSWORD='your-password'        # kept in a private temporary option file
python3 labs/check_labs.py
```

(`MYSQL_LABS_SOCKET` instead of host and port; `MYSQL_LABS_CLIENT` for a client that is not on your PATH;
`MYSQL_LABS_SCRATCH` for another scratch database name.) Without these variables the checker uses the
course author's MySQL 9.7 test server when it exists, else `mysql` on your PATH as root without a
password. The expected outputs were produced on **MySQL 9.7**; 8.4 matches almost everywhere, MariaDB
differs in places (the session READMEs say where).

**How the documents refer to labs:** the facilitator guide, workbook and answer key use paths like
`labs/module-03/l2_3-crud-operations/`, relative to this kit's folder (where the combined books live).
Keep the whole kit folder together so those pointers hold.
