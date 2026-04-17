# MySQL Foundations Course — Status

## Location: `\\wsl$\Ubuntu\home\practicalace\projects\mysql`
## Netlify URL: TBD (e.g., rays-mysql.netlify.app)
## Last Updated: 2026-04-16

---

## Overview

**MySQL Foundations** is a standalone database fundamentals course — no PHP dependency. It serves as the first step in the learning path:

```
MySQL Foundations → PHP Foundations → PHP & WordPress (existing, rays-php-wordpress.netlify.app)
```

### Rationale for Standalone Course
- MySQL fundamentals are their own discipline — useful for Python, JS, and PHP students alike
- PHP course can focus purely on language features without mixing in database concepts
- Students who already know SQL can skip straight to PHP
- Clean prerequisite chain mirrors the htmlcss → htmljs pattern

---

## Course Structure: 21 Lessons / 7 Modules

### Module 1: Getting Started (3 lessons)
| # | Lesson | File | Duration | Difficulty |
|---|--------|------|----------|------------|
| 1 | What Is a Database? | lesson_01.html | 30 min | beginner |
| 2 | Installing MySQL (LAMP Stack) | lesson_02.html | 45 min | beginner |
| 3 | MySQL CLI & phpMyAdmin | lesson_03.html | 45 min | beginner |

### Module 2: Tables & Data Types (3 lessons)
| # | Lesson | File | Duration | Difficulty |
|---|--------|------|----------|------------|
| 4 | Creating Databases & Tables | lesson_04.html | 45 min | beginner |
| 5 | Data Types & Constraints | lesson_05.html | 45 min | beginner |
| 6 | CRUD Operations (INSERT, SELECT, UPDATE, DELETE) | lesson_06.html | 50 min | beginner |

### Module 3: Querying Data (4 lessons)
| # | Lesson | File | Duration | Difficulty |
|---|--------|------|----------|------------|
| 7 | WHERE Clauses, Operators & Filtering | lesson_07.html | 45 min | beginner |
| 8 | Sorting & Limiting (ORDER BY, LIMIT, OFFSET) | lesson_08.html | 40 min | beginner |
| 9 | Aggregate Functions & GROUP BY / HAVING | lesson_09.html | 50 min | intermediate |
| 10 | Subqueries & Nested Queries | lesson_10.html | 50 min | intermediate |

### Module 4: Relationships & Joins (3 lessons)
| # | Lesson | File | Duration | Difficulty |
|---|--------|------|----------|------------|
| 11 | Table Relationships (1:1, 1:M, M:M) | lesson_11.html | 45 min | intermediate |
| 12 | Foreign Keys & Referential Integrity | lesson_12.html | 45 min | intermediate |
| 13 | Joins (INNER, LEFT, RIGHT, CROSS, Self) | lesson_13.html | 60 min | intermediate |

### Module 5: Database Design (3 lessons)
| # | Lesson | File | Duration | Difficulty |
|---|--------|------|----------|------------|
| 14 | Indexes & Query Optimization Basics | lesson_14.html | 45 min | intermediate |
| 15 | Views | lesson_15.html | 40 min | intermediate |
| 16 | Database Design & Normalization (1NF–3NF) | lesson_16.html | 50 min | intermediate |

### Module 6: Advanced Features (3 lessons)
| # | Lesson | File | Duration | Difficulty |
|---|--------|------|----------|------------|
| 17 | Stored Procedures & Functions | lesson_17.html | 50 min | intermediate |
| 18 | Transactions (BEGIN, COMMIT, ROLLBACK) | lesson_18.html | 45 min | intermediate |
| 19 | User Management & Permissions (GRANT, REVOKE) | lesson_19.html | 40 min | intermediate |

### Module 7: Real-World Skills (2 lessons)
| # | Lesson | File | Duration | Difficulty |
|---|--------|------|----------|------------|
| 20 | Importing & Exporting Data (mysqldump, CSV) | lesson_20.html | 45 min | intermediate |
| 21 | Next Steps & Best Practices | lesson_21.html | 30 min | beginner |

---

## Key Topics by Lesson

- **Lesson 1** — Relational databases, tables/rows/columns terminology, SQL overview
- **Lesson 2** — LAMP stack install on Ubuntu WSL, verifying MySQL service, setting root password
- **Lesson 3** — mysql CLI commands, phpMyAdmin navigation, running first queries
- **Lesson 4** — CREATE DATABASE, CREATE TABLE, DROP, ALTER TABLE
- **Lesson 5** — INT, VARCHAR, TEXT, DATE, DECIMAL, BOOLEAN; PRIMARY KEY, NOT NULL, UNIQUE, DEFAULT, AUTO_INCREMENT
- **Lesson 6** — INSERT INTO, SELECT *, UPDATE SET, DELETE FROM; basic CRUD workflow
- **Lesson 7** — WHERE, AND/OR, IN, BETWEEN, LIKE, IS NULL, comparison operators
- **Lesson 8** — ORDER BY ASC/DESC, LIMIT, OFFSET, pagination patterns
- **Lesson 9** — COUNT, SUM, AVG, MIN, MAX; GROUP BY, HAVING vs WHERE
- **Lesson 10** — Scalar subqueries, row subqueries, EXISTS, IN with subqueries
- **Lesson 11** — Relationship types explained with ER diagrams, junction tables for M:M
- **Lesson 12** — FOREIGN KEY syntax, ON DELETE/UPDATE (CASCADE, SET NULL, RESTRICT), referential integrity
- **Lesson 13** — INNER JOIN, LEFT/RIGHT JOIN, CROSS JOIN, self-joins; multi-table queries
- **Lesson 14** — CREATE INDEX, composite indexes, EXPLAIN for query plans, when to index
- **Lesson 15** — CREATE VIEW, updatable views, use cases, dropping views
- **Lesson 16** — Normalization theory (1NF, 2NF, 3NF), denormalization trade-offs, design exercises
- **Lesson 17** — CREATE PROCEDURE, parameters (IN/OUT/INOUT), CREATE FUNCTION, DELIMITER
- **Lesson 18** — ACID properties, BEGIN/START TRANSACTION, COMMIT, ROLLBACK, savepoints
- **Lesson 19** — CREATE USER, GRANT, REVOKE, SHOW GRANTS, principle of least privilege
- **Lesson 20** — mysqldump for backups, importing .sql files, CSV import/export (LOAD DATA, INTO OUTFILE)
- **Lesson 21** — Review of key concepts, where to go next (PHP PDO, Python connectors, ORMs), resources

---

## Development Environment

### Local: LAMP Stack
- Ubuntu (WSL)
- Apache2
- MySQL 8.x
- PHP 8.x (for phpMyAdmin)
- phpMyAdmin
- Students work locally; no deployment needed for a database course

### Course Template
- Uses established template from course_template
- Same CSS framework (styles/main.css), JS enhancements (js/course-enhancements.js, js/clipboard.js)
- Light/dark theme toggle, responsive nav, prev/next navigation
- Mermaid diagrams for ER diagrams and visual concepts
- Code blocks with language-sql class
- Exercises with hint/solution pattern, quizzes
- Breadcrumb: Home > Module X > Lesson N: Title

---

## Progress Tracker

- [x] Step 1 — Decide lesson counts and module breakdowns ✅
- [x] Step 2 — Scaffold course (index.html, course-config.json, copy template files) ✅
- [x] Step 3 — Build lessons sequentially (21 / 21) ✅
  - [x] Lesson 1: What Is a Database? ✅
  - [x] Lesson 2: Installing MySQL (LAMP Stack) ✅
  - [x] Lesson 3: MySQL CLI & phpMyAdmin ✅
  - [x] Lesson 4: Creating Databases & Tables ✅
  - [x] Lesson 5: Data Types & Constraints ✅
  - [x] Lesson 6: CRUD Operations ✅
  - [x] Lesson 7: WHERE Clauses, Operators & Filtering ✅
  - [x] Lesson 8: Sorting & Limiting Results ✅
  - [x] Lesson 9: Aggregate Functions & GROUP BY ✅
  - [x] Lesson 10: Subqueries & Nested Queries ✅
  - [x] Lesson 11: Table Relationships ✅
  - [x] Lesson 12: Foreign Keys & Referential Integrity ✅
  - [x] Lesson 13: Joins ✅
  - [x] Lesson 14: Indexes & Query Optimization ✅
  - [x] Lesson 15: Views ✅
  - [x] Lesson 16: Database Design & Normalization ✅
  - [x] Lesson 17: Stored Procedures & Functions ✅
  - [x] Lesson 18: Transactions ✅
  - [x] Lesson 19: User Management & Permissions ✅
  - [x] Lesson 20: Importing & Exporting Data ✅
  - [x] Lesson 21: Next Steps & Best Practices ✅
- [x] Step 4 — Supplementary pages (troubleshooting, glossary, cheat sheet, common errors) ✅
- [ ] Step 5 — Favicon creation
- [ ] Step 6 — Browser testing
- [ ] Step 7 — Verify prev/next navigation links
- [x] Step 8 — Update Ray's House of Fun with course link ✅

---

## What to Do Next

**All 21 lessons and supplementary pages are complete!** Remaining steps:
1. Step 5 — Create favicon
2. Step 6 — Browser testing
3. Step 7 — Verify prev/next navigation links across all 21 lessons
4. Step 8 — Update Ray's House of Fun with course link
