-- state: flat
-- expect-error: 1140, 1055, 1111, 1064
-- =====================================================================
-- debug_group_by.sql: four broken summary queries (find-the-bug handout)
-- Session 5 · Lesson 3.3 · MySQL Foundations instructor kit
--
-- This file is broken ON PURPOSE. Each query below wants a sensible
-- answer about the customers or the books, and each one is refused with a
-- numbered error. Run it (SOURCE keeps going after each error), then for
-- each ERROR line write in your workbook:
--   the error number · what MySQL could not decide · the fixed query.
-- Fixed, the file prints four result tables and no ERROR lines.
--
--   SOURCE labs/module-05/l3_3-aggregate-functions/debug_group_by.sql
-- =====================================================================

-- Bug A · "How many customers, and who are they?"
SELECT first_name, COUNT(*) AS customers
FROM customers;

-- Bug B · "Customers per city, with a name from each city"
SELECT city, last_name, COUNT(*) AS customers
FROM customers
GROUP BY city;

-- Bug C · "Authors with more than one book"
SELECT author, COUNT(*) AS books
FROM books
WHERE COUNT(*) > 1
GROUP BY author;

-- Bug D · "Cities with at least two customers"
SELECT city, COUNT(*) AS customers
FROM customers
HAVING COUNT(*) >= 2
GROUP BY city;
