-- state: schema
-- =====================================================================
-- new_arrivals_starter.sql: insert, preview, update and delete with care
-- Session 3 · Lesson 2.3 · MySQL Foundations instructor kit
--
-- Six new books arrive in the (empty) books table. Steps 1 and 2 run as they
-- are. Steps 3 to 6 are written for you but turned off with -- at the start
-- of each line, with a ___ gap to fill. Before you turn one on, write down
-- what you expect (which rows, how many, which id). Then remove the -- (only
-- from the statement lines), fill the gap, save, and run the file again.
--
-- Run it inside bookstore (USE bookstore; first):
--   SOURCE labs/module-03/l2_3-crud-operations/new_arrivals_starter.sql
-- Every run starts by filling books and ends by emptying it (TRUNCATE), so
-- you can run it as often as you like.
-- =====================================================================

INSERT INTO books (title, author, price, pages, published) VALUES
    ('Emma', 'Jane Austen', 8.25, 474, '1815-12-23'),
    ('Frankenstein', 'Mary Shelley', 7.50, 280, '1818-01-01'),
    ('Dracula', 'Bram Stoker', 9.75, 418, '1897-05-26'),
    ('Moby Dick', 'Herman Melville', 12.40, 635, '1851-10-18'),
    ('Little Women', 'Louisa May Alcott', 10.20, 759, '1868-09-30'),
    ('The Time Machine', 'H.G. Wells', 6.95, 118, '1895-05-07');

-- 1 · The id MySQL gave the FIRST row of that multi-row INSERT
--     (predict: 1 or 6?)
SELECT LAST_INSERT_ID() AS first_new_id;

-- 2 · Preview: the books over $10
SELECT id, title, price FROM books WHERE price > 10 ORDER BY id;

-- TODO 3 · Five percent more for exactly the books the preview showed. Use
-- the SAME condition as the preview. How many rows should change?
-- UPDATE books SET price = ROUND(price * 1.05, 2) WHERE ___;
-- SELECT ROW_COUNT() AS rows_changed;

-- TODO 4 · Frankenstein (id 2) sells out and drops to 6.99, in ONE statement.
-- Careful: what separates two assignments in SET?
-- UPDATE books SET in_stock = FALSE___ price = 6.99 WHERE id = 2;
-- SELECT title, price, in_stock FROM books WHERE id = 2;

-- TODO 5 · The books published before 1820 leave the shop. Preview first,
-- then delete with the same condition, then count.
-- SELECT id, title, published FROM books WHERE published < '1820-01-01' ORDER BY id;
-- DELETE FROM books WHERE ___;
-- SELECT ROW_COUNT() AS rows_deleted;

-- TODO 6 · One more arrival. Which id will it get, after the deletes?
-- INSERT INTO books (title, author, price, pages, published)
-- VALUES ('Middlemarch', 'George Eliot', 11.10, 880, '1871-12-01');

SELECT id, title, price, in_stock FROM books ORDER BY id;

-- Expected when done: see the README (first_new_id 1; the preview shows Moby
-- Dick 12.40 and Little Women 10.20; rows_changed 2; Frankenstein 6.99,
-- in_stock 0; rows_deleted 2 (Emma, Frankenstein); Middlemarch gets id 7).

TRUNCATE TABLE books;
