-- state: flat
-- expect-error: 1064, 1054
-- =====================================================================
-- debug_sorting.sql: five sorted lists that go wrong (find-the-bug handout)
-- Session 4 · Lesson 3.2 · MySQL Foundations instructor kit
--
-- This file is broken ON PURPOSE. Three queries fail with an ERROR; two run
-- without one and give the wrong list. For each, write in your workbook:
-- what was asked · what MySQL did · the fixed query.
--
-- Read-only. Run it inside bookstore with the Module 3 data:
--   SOURCE labs/module-04/l3_2-sorting-limiting-results/debug_sorting.sql
-- =====================================================================

-- Bug A: "in-stock books, cheapest first"
SELECT title, price FROM books ORDER BY price WHERE in_stock = TRUE;

-- Bug B: "titles with their page counts, sorted by price"
SELECT title, pages FROM books ORDER BY 3;

-- Bug C: "page 3 of the title list, 4 per page"
SELECT title FROM books ORDER BY title LIMIT 4 OFFSET 2 * 4;

-- Bug D: "the three longest books" (expects Lord of the Rings first)
SELECT title, pages FROM books ORDER BY 'pages' DESC LIMIT 3;

-- Bug E: "in-stock books first, and within each group the MOST pages first"
SELECT title, in_stock, pages FROM books ORDER BY in_stock, pages DESC;
