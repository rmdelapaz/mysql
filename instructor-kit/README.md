# MySQL Foundations: Instructor Kit ("Course-in-a-Box")

A ready-to-teach package that lets another instructor deliver **MySQL Foundations: Master the World's
Most Popular Database** in a classroom without building it from scratch. The live course site
(<https://rays-mysql.netlify.app/>) is the learner's textbook: 25 lessons, each with real output under
every SQL block (run on MySQL 9.7), a project in steps, exercises with hidden solutions, a quiz and a
journal prompt. This kit is everything the instructor needs around it.

**Scope:** the whole course, Modules 1 to 8, 25 lessons, from "what is a database?" and installing
MySQL to joins, CTEs and window functions, indexes and views, normalization, stored programs,
transactions, JSON, users and permissions, backups and a final project. No prior SQL or programming is
needed: Session 1 opens with a short, ungraded diagnostic on the spreadsheet and file skills SQL builds on.

**Format:** **14 sessions × 3 hours = 42 class hours** in two parts, two lessons per session (Sessions 7
and 13 teach one lesson and use the rest of the time for an assessment or a studio).

- **Part 1: SQL Foundations** (Sessions 1 to 7, Modules 1 to 4, **21 hours**) takes a beginner from an
  empty laptop to designing tables with keys and constraints, changing data safely, filtering,
  summarizing, nesting and joining. It **runs on its own as a short course** and ends with the
  **Part 1 assessment** (Session 7, second half).
- **Part 2: Beyond the Basics** (Sessions 8 to 14, Modules 5 to 8, 21 hours) ends with the
  **final project**: a database designed and built for a client brief, secured, backed up and presented.

Run it weekly (14 weeks; Part 1 alone: 7 weeks), twice a week (about 7 weeks), or as intensive days
(two sessions a day). In the file layout a session is called a "module": `source/module-07/` is
Session 7. In prose, "Module 4" always means a course module (relationships and joins).

Learners start each lesson project in the room and finish it at home, so "leave with" below means
"have started in class and finish before the next session".

| Session | Lessons | Learners leave with |
|---------|---------|---------------------|
| **Part 1: SQL Foundations** | | |
| S1 · What Databases Are and Installing MySQL | 1.1 What Is a Database? · 1.2 Installing MySQL (+ welcome, environment check, 6-item diagnostic, install clinic) | A working MySQL 9.7 (`check_environment` says READY); a paper sketch of the bookstore database; an installation health check in the journal |
| S2 · The MySQL Client and Your First Tables | 1.3 MySQL CLI & phpMyAdmin · 2.1 Creating Databases & Tables | `explore.sql`, a server report script; `create_bookstore.sql`, which builds `bookstore` with three tables |
| S3 · Data Types, Constraints and CRUD | 2.2 Data Types & Constraints · 2.3 CRUD Operations | An `employees` table with chosen types and rules; `load_bookstore_data.sql`, which stocks the bookstore |
| S4 · Filtering, Sorting and Limiting | 3.1 WHERE Clauses, Operators & Filtering · 3.2 Sorting & Limiting Results + **Checkpoint 1** (30 min) | `saved_searches.sql`; `storefront.sql`; a checkpoint scored with its rubric (returned in Session 5) |
| S5 · Aggregates and Subqueries | 3.3 Aggregate Functions & GROUP BY · 3.4 Subqueries & Nested Queries | `inventory_report.sql`; `price_review.sql` |
| S6 · Relationships and Foreign Keys | 4.1 Table Relationships · 4.2 Foreign Keys & Referential Integrity | The flat bookstore migrated to related tables (orders, order items, staff), then `bookstore.sql`; a reviews table with two delete rules, each proved by a test |
| S7 · Joins and the Part 1 Assessment | 4.3 Joins + the **Part 1 assessment** (60 min) and review | `sales_report.sql` (six joined queries); a scored Part 1 assessment. Part 1 alone: the course closes here |
| **Part 2: Beyond the Basics** | | |
| S8 · CTEs and Window Functions | 5.1 CTEs & Recursive Queries · 5.2 Window Functions (+ Part 2 environment check and Part 1 refresher) | `org_report.sql` (a recursive org chart); `sales_dashboard.sql` (ranks, running totals, neighbors) |
| S9 · Indexes and Views | 6.1 Indexes & Query Optimization · 6.2 Views | `tune_sales.sql` (measured before and after, on a 100,000-row table); `reporting_views.sql` |
| S10 · Normalization and Stored Programs | 6.3 Database Design & Normalization · 7.1 Stored Procedures & Functions | `book_club.sql` (a sheet normalized to 3NF); `bookstore_routines.sql` |
| S11 · Transactions and JSON | 7.2 Transactions · 7.3 JSON Columns + **Checkpoint 2** (30 min) | `checkout.sql` (all-or-nothing, with an error handler); `catalog_feed.sql`; a checkpoint scored with its rubric (returned in Session 12) |
| S12 · Users, Permissions and Backups | 7.4 User Management & Permissions · 8.1 Importing & Exporting Data (+ final-project brief) | `team_access.sql` (roles, least privilege); a backup kit with a tested restore; the final-project brief and a Milestone 1 draft on paper |
| S13 · Final Project Kickoff and Studio I | 8.2 Final Project: Design and Build a Database (design, schema, data) | A checked design for the Maple Street Tool Library; `01_schema.sql` with constraint tests; `02_data.sql` with edge cases |
| S14 · Final Project Studio II, Showcase and Next Steps | 8.2 (logic, security, backup) · 8.3 Next Steps & Best Practices | Procedures, roles and a tested backup for the project; a three-minute showcase; a dated learning plan. Submit within a week |

**Why this shape (and the timing trade-off):** the lessons were written and timed honestly for a solo
learner at 75 to 110 minutes each (the final project, 240), so two of them come to more than the
roughly 150 room minutes left once the warm-up, break and wrap-up are out. They do not fit whole, and the
kit does not pretend they do. The room protects what is hardest alone: the **mental model**, a **live
demo** learners type along with, the **guided lab** (new practice on the bookstore, never the lesson's own
project), and **starting** each lesson project together. Home gets the rest: finishing the two projects,
the lesson's exercises, quiz and journal, about two to three hours between sessions. Every facilitator
guide says, for its session, what is done in the room, what goes home, what to protect and what to cut
first if you run long.

Every session runs 0:00 to 3:00: warm-up (five retrieval questions and a homework check, 10 minutes;
Session 1 opens with a 30-minute welcome, environment check and diagnostic, Session 8 with a 20-minute
Part 2 environment check and Part 1 refresher, Session 13 with a 30-minute warm-up and project kickoff),
Lesson A (frame, demo, guided lab, project start), a 10-minute break, Lesson B, and a 10-minute wrap-up
(exit ticket, homework, the next session's bring list). Checkpoint 1 sits at 2:20 in Session 4,
Checkpoint 2 at 0:10 in Session 11.

### Teaching Part 1 only

Part 1 (Sessions 1 to 7) is a complete short course of 7 × 3 hours = 21 hours. Nothing in it depends on
Part 2. Session 7's facilitator guide has two closes: **Version A** ends the course (completion rule,
next steps, evaluation) and **Version B** bridges to Session 8. The Part 1 assessment, its rubric and
answer notes are in `final-assessment.html`. The sell sheet prices the full program and the Part 1 option
separately.

Programs can also run **Part 2 on its own** for learners who already write SQL: Session 8's guide has a
"Starting with Part 2?" note (send the setup guide, `bookstore.sql`, the Part 2 environment check and the
refresher lab a week ahead).

### Primary documents: the combined books (start here)

| File | Audience | Contents |
|------|----------|----------|
| `participant-workbook.{html,pdf}` | Learner | The complete workbook: all 14 sessions as chapters with Part dividers (goals, key ideas, a new worked example per lesson, guided-lab steps, predict-then-run items, a 12-item self-check, homework checklist, glossary; Start Here pages in Sessions 1 and 8; the checkpoint pages; the milestone tracker for the final project) |
| `facilitator-guide.{html,pdf}` | Instructor | The complete teaching manual: per session, Before the Session (prep checklist, files, known environment traps), the 0:00–3:00 agenda, warm-up with answers, lesson plans with live-demo scripts (every SQL statement run, with its real output), the three mistakes to expect, checks for understanding, closing (exit ticket, homework, next bring list) and "If you run long or short" |
| `answer-key.{html,pdf}` | Instructor | Every self-check item answered with reasons (including why each wrong option is wrong), lab solution notes with the solutions' real output, the lesson pages' own quiz answers, warm-up, diagnostic, exit-ticket and checkpoint answers with rubrics (confidential) |

**Self-check items:** 12 per session, 14 × 12 = **168**, every one answered in the answer key. The
workbook quiz, the answer key and the guide's compact answers are generated from one item list per
session and are checked to match word for word, with the correct letters balanced across A to D.

The editable per-session docs live in `source/module-NN/`. **They are generated** (see "Editing and
building"): change a session through its generator, then run `python3 build-combined.py` to regenerate
the three books and re-render their PDFs.

### Kit-wide documents

| File | Audience | Purpose |
|------|----------|---------|
| `setup-guide.html` | Learner (+ a facilitator page) | Before-you-begin sheet: MySQL 9.7 LTS on Windows (MSI + MySQL Configurator), macOS (`brew install mysql@9.7` or the DMG), Linux (MySQL's APT or Yum repository) or Docker (`mysql:9.7`); the course folder `~/mysql-course` and where `labs/` goes; the environment check; common install problems; a room-setup checklist with a USB fallback. Send it a week before Session 1 with the `l1_0-orientation` check files |
| `final-assessment.html` | Instructor | The **Part 1 assessment** (the Riverside Cooking School: 60 minutes, open book, five-row rubric, scoring sheet, answer notes with the reference run) and the **final project** (Lesson 8.2's Maple Street Tool Library: brief, timeline, the lesson's 100-point rubric, scoring guidance, submission rules and reference numbers for every milestone, measured on MySQL 9.7) (confidential) |
| `sell-sheet.html` | Prospective instructors | One-page overview: who it is for, outcomes, format (full program and Part 1 only), what is included, prerequisites, license tiers |
| `README.md` · `LICENSE.md` | — | This overview and the tiered license template |

**Slide decks:** one per session in `slides/` (`module-NN-<slug>.html`), 468 slides in all (28 to 40 per
session). Each deck is one self-contained file: open it in a browser, arrow keys or space to advance.
Every SQL slide shows the real result table and fits a 1280×720 projector without scrolling.

**Labs:** 57 starter/solution pairs plus 27 `debug_*.sql` "find the bug" handouts across
`labs/module-01/` … `labs/module-14/` (143 SQL files), each session with its own `README.md` (files, what
each lab practices, timing, what "done" looks like, MySQL 8.4 and MariaDB differences). Session 1 adds
the environment check (`check_environment.sql` + `.sh` / `.ps1`) and the diagnostic pair; Session 4 the
Checkpoint 1 pair (`labs/module-04/checkpoint-1/`); Session 7 the Part 1 assessment
(`labs/module-07/part1-assessment/`); Session 8 the Part 2 environment check and a refresher
(`labs/module-08/l5_0-part2-start/`); Session 11 the Checkpoint 2 pair (`labs/module-11/checkpoint-2/`).
Starters run without an error as handed out (TODOs in comments, placeholder results) and end with an
"Expected when done" comment that quotes the solution's real output; solutions print the answers.

The public **syllabus** lives in the course root, one level up from `instructor-kit/`, so it stays
public: `syllabus.html` (screen, light/dark), `syllabus-print.html` (print-first, with the Part 1 option
noted) and `MySQL-Foundations-Syllabus-14-sessions.pdf`. They are generated (see "Editing and building").

**Still to do before selling:** `LICENSE.md` is a plain-language **template**: have it reviewed by a
lawyer before commercial distribution. Pricing in the sell sheet and the license is a **suggested
anchor**: the bracketed prices are placeholders set at point of sale.

---

## Folder layout

```
instructor-kit/
├─ participant-workbook.{html,pdf}   ← canonical hand-out books (all 14 sessions, Part dividers)
├─ facilitator-guide.{html,pdf}
├─ answer-key.{html,pdf}
├─ setup-guide / final-assessment / sell-sheet  (.html + .pdf)
├─ slides/            one self-contained deck per session: module-NN-<slug>.html (NN = 01 … 14)
├─ labs/              check_labs.py, README.md, _states/ (bookstore.sql, flat.sql, schema.sql),
│                     and module-01/ … module-14/: per lesson a folder lM_N-<slug>/ with
│                     *_starter.sql + *_solution.sql pairs and debug_*.sql handouts;
│                     module-01/l1_0-orientation/ = environment check + diagnostic;
│                     module-04/checkpoint-1/, module-07/part1-assessment/,
│                     module-08/l5_0-part2-start/, module-11/checkpoint-2/
├─ source/            module-01/ … module-14/ per-session docs (generated; they build the books)
├─ _parts/            part1_assessment.html (the fragment final-assessment.html includes)
├─ kit.css            shared print-first stylesheet
├─ build-combined.py  regenerate the 3 books from source/
└─ README.md · LICENSE.md
```

Every document is print-ready (a **Print / Save as PDF** button and a tuned print layout, US Letter)
and readable on a phone.

The whole `instructor-kit/` folder is kept **off the live site**: the course root's `_redirects`
returns 404 for `/instructor-kit/*`. It lives in the repository only.

## How to teach from it

1. **A week before Session 1**, send learners the **setup guide** with the three files from
   `labs/module-01/l1_0-orientation/` (`check_environment.sql`, `.sh`, `.ps1`); ask each learner to reply
   with the last table it prints (`READY for MySQL Foundations`). No reply means an install risk: chase it.
2. **Hand out** the `labs/` folder **without the `*_solution.sql` files** (also on a USB stick, with the
   platform installers, in case the venue network fails). Learners put `labs/` inside their course
   folder `mysql-course` in their home folder and always start the `mysql` client from there, so
   `SOURCE labs/...` works. Hold back the checkpoint and assessment folders until the moment they are used.
3. **Before each session**, read that session's facilitator guide: Before the Session (files, data state,
   known environment traps), the agenda, each lesson's live-demo script, the three mistakes to expect, and
   "If you run long or short". Run `python3 labs/check_labs.py module-NN` once on your own server.
4. **Present** from the session's deck in `slides/`; type the demos live in the `mysql` client from your
   own course folder (font 18 pt or more).
5. Learners work in the **participant workbook** and keep a **learning journal**.
6. Check self-checks, warm-ups and exit tickets with the **answer key**; score Checkpoints 1 and 2, the
   Part 1 assessment and the final project with their rubrics.

### The data a session starts from

Every lesson uses one **fictional online bookstore**, `bookstore`. It grows with the course, so a
session's labs declare which version they start from (`-- state:` in each file's header), and
`labs/_states/` holds each one: `schema.sql` (three empty tables, end of Lesson 2.1), `flat.sql` (the
Module 3 data, Sessions 4 and 5) and `bookstore.sql` (the course download, eight related tables: Lesson
4.2 on, Sessions 6 to 14). Each file drops and rebuilds `bookstore`, so reloading is always safe. The
hand-offs between sessions (Session 2 ends with `create_bookstore.sql`, Session 3 with
`load_bookstore_data.sql`, Session 4 loads `flat.sql`, Session 6 moves to `bookstore.sql`) are spelled
out in each guide's Before the Session and bring list.

Other practice data is fictional too: the Riverside Cooking School (Part 1 assessment) and the Maple
Street Tool Library (final project). Book titles and authors are real classics; every customer, order,
employee, member and account is invented.

## Checkpoints and assessments

- **Checkpoint 1 (Session 4, 2:20, 30 minutes):** an individual, open-notes task on Modules 1 and 2:
  build, fill and read a small database from nothing (`labs/module-04/checkpoint-1/`). Five-row rubric and
  model answer in the answer key. Returned at the start of Session 5.
- **Part 1 assessment (Session 7, 1:25, 60 minutes + review):** alone, open book, one SQL file on a
  database learners have never seen: build and protect the enrollments table, change data safely, answer
  eight questions with filters, aggregates, subqueries and joins. Rubric, scoring sheet and answer notes in
  `final-assessment.html`. When Part 1 runs alone, it is the course's final assessment.
- **Checkpoint 2 (Session 11, 0:10, 30 minutes):** Modules 5 and 6 (a CTE with a window function, a
  recursive CTE, a view, an EXPLAIN before and after an index, a normalization on paper). Rubric in the
  answer key; returned in the Session 12 warm-up.
- **Final project:** the brief (Lesson 8.2's Maple Street Tool Library) is handed out at the end of
  **Session 12** with a paper Milestone 1 draft as homework. **Session 13** is design, schema and test data
  (Milestones 1 to 3) in a studio with check-ins; **Session 14** is logic, security and backup
  (Milestones 5 to 7), then a showcase. Learners submit numbered scripts that rebuild the database, a tested
  backup and a README within a week. `final-assessment.html` holds the rubric (100 points) and reference
  numbers for every milestone; learners may also propose their own brief (rules in the Session 13 guide).

## Requirements

- **MySQL 9.7 LTS** (Community Server, free) with its `mysql` command-line client, on Windows 10/11,
  macOS, Linux, or in Docker (`mysql:9.7`). Every output in the kit was produced on MySQL 9.7.2.
  - **MySQL 8.4 LTS** runs the course almost everywhere (a few outputs differ; the lessons' version notes
    and the session READMEs say where).
  - **MariaDB** (XAMPP, some Linux distributions and hosts) runs the basic SQL but differs in places:
    error numbers and wording, no `->>` operator, no `EXPLAIN ANALYZE`, no `ONLY_FULL_GROUP_BY` by
    default. The environment check reports it as `READY WITH NOTES`. Recommend MySQL 9.7.
  - After 9.7, MySQL switched to calendar version numbers: innovation releases are numbered like **26.x**,
    and "latest" (`brew install mysql`, `mysql:latest`) means one of those. Fine to experiment with, but
    ask learners for 9.7 so outputs match.
- **A plain-text editor** for `.sql` files (VS Code works well). Optional: phpMyAdmin 5.2 (Lesson 1.3's
  tour) or MySQL Workbench / DBeaver.
- About 1.5 GB of free disk space (Lesson 1.2) and administrator rights, or Docker Desktop. No accounts, no paid tools; after installation the course needs no downloads except
  `bookstore.sql` (a few KB, from the course site; also in `labs/_states/`).
- **For the facilitator's lab check:** Python 3.8 or newer (standard library only) and a `mysql` client on
  the machine that runs `check_labs.py`.

## Checking the labs (`labs/check_labs.py`)

```bash
cd instructor-kit
python3 labs/check_labs.py                 # every session
python3 labs/check_labs.py module-07       # one session (also 07 or 7; several allowed)
python3 labs/check_labs.py module-07 -v    # also show what each file printed
python3 labs/check_labs.py --file labs/module-07/l4_3-joins/catalog_joins_solution.sql -v
```

For every lab file it loads the declared starting state into a **scratch database** (`kitlab_check`;
your own `bookstore` is never touched), runs the file through the real `mysql` client, and prints one
`PASS` / `FAIL` line per file. A file fails on any SQL error (a `debug_*.sql` file: on no error, or an
error it does not declare in its `-- expect-error:` header), on a timeout, on a database or account it
leaves behind, or, without being run, if it would change the root account or a server setting.

**Point it at your own server** with environment variables (any account that may create and drop
databases and users; a practice server, not production):

```bash
export MYSQL_LABS_HOST=127.0.0.1 MYSQL_LABS_PORT=3306 MYSQL_LABS_USER=root
export MYSQL_LABS_PASSWORD='your-password'     # written to a private temporary option file, never on the command line
python3 labs/check_labs.py
```

`MYSQL_LABS_SOCKET` instead of host and port; `MYSQL_LABS_CLIENT` for a client that is not on your PATH;
`MYSQL_LABS_SCRATCH` for another scratch database name (it is dropped and re-created). A Docker server:
publish its port (`-p 3306:3306`) and use `MYSQL_LABS_HOST=127.0.0.1` with a client installed on the
laptop. On PowerShell, set the variables with `$env:MYSQL_LABS_PASSWORD = '...'`. Without any of these
variables the checker uses the course author's test server when it exists, else `mysql` on your PATH as
root without a password. The expected outputs were produced on MySQL 9.7; on 8.4 everything passes but a
few printed values differ; on MariaDB some files fail by design (see each session README).

## Editing and building

```bash
cd instructor-kit
python3 build-combined.py                 # regenerate the 3 books from source/ (with Part dividers)
python3 labs/check_labs.py                # run every lab file against MySQL
```

The author's tools in `~/projects/_kit_tools/mysql/` (not shipped with a licensed kit):

```bash
python3 check_kit_mysql.py --all          # per-session consistency: one sheet/foot, agenda sums to 180 with
                                          # contiguous clocks and one Break, checkpoint rows, lesson titles
                                          # match course-config.json, quiz identical across workbook/key/guide,
                                          # lesson-quiz letters match the pages, lab paths and states exist,
                                          # decks fit 1280x720, nothing wider than 390 px, no console errors
python3 gen_syllabus_mysql.py             # rebuild ../syllabus{,-print}.html from each session's agenda
python3 render_pdfs_mysql.py              # render the six kit PDFs + the syllabus PDF, print page counts,
                                          # and phone-check every page at 390 px
bash verify_all.sh                        # the course itself: every lesson's SQL run on 9.7 and compared
                                          # with its printed output
```

**The generators are the source of truth.** Each session's three documents and deck are generated: the
generator for Session N is `~/projects/_kit_tools/mysql/kit_generators/SNN/gen_SNN.py`, with every SQL
block it shows in `blocks_SNN.py`, run for real on MySQL 9.7 through `kitlib_mysql.py` (results cached
next to the generator). `final-assessment.html` comes from `kit_generators/final/gen_final.py`. To change
a session, edit its generator, run it from its own folder (`python3 -I gen_SNN.py`), then rebuild the
books, the syllabus and the PDFs; hand edits to the generated HTML are lost the next time the generator
runs. The lab files, their READMEs and the kit-wide documents (this file, `LICENSE.md`, the setup guide,
the sell sheet) are edited directly.

Or open any document and use **Print / Save as PDF** (Letter, 0.5 in margins, background graphics on).

---

## License

See `LICENSE.md`. Short version: licensed to a **single instructor or organization** to teach the
kit; **not** for resale; the facilitator guide, answer key and final assessment are **not** for
learner distribution. The bookstore, cooking-school and tool-library data are part of the licensed
materials. Tiers (Solo / Organization / White-label, for the full program or Part 1 only, plus an
optional updates add-on) are set at point of sale. MySQL itself is not part of the kit: learners install
it from Oracle under its own license.

© 2026 Ray de la Paz. MySQL Foundations. All rights reserved.
