-- state: schema
-- =====================================================================
-- new_arrivals_solution.sql: insert, preview, update and delete with care
-- Session 3 · Lesson 2.3 · MySQL Foundations instructor kit · instructor reference
--
-- Six new books arrive in the (empty) books table; then a price rise, a
-- sold-out book, a clear-out and one more arrival, each change previewed
-- first and counted with ROW_COUNT(). Runs inside bookstore (schema state)
-- and empties books again at the end with TRUNCATE.
-- =====================================================================

INSERT INTO books (title, author, price, pages, published) VALUES
    ('Emma', 'Jane Austen', 8.25, 474, '1815-12-23'),
    ('Frankenstein', 'Mary Shelley', 7.50, 280, '1818-01-01'),
    ('Dracula', 'Bram Stoker', 9.75, 418, '1897-05-26'),
    ('Moby Dick', 'Herman Melville', 12.40, 635, '1851-10-18'),
    ('Little Women', 'Louisa May Alcott', 10.20, 759, '1868-09-30'),
    ('The Time Machine', 'H.G. Wells', 6.95, 118, '1895-05-07');

-- 1 · The id MySQL gave the FIRST row of that multi-row INSERT
SELECT LAST_INSERT_ID() AS first_new_id;

-- 2 · Preview: the books over $10
SELECT id, title, price FROM books WHERE price > 10 ORDER BY id;

-- 3 · Five percent more for exactly those books, then count the changed rows
UPDATE books SET price = ROUND(price * 1.05, 2) WHERE price > 10;
SELECT ROW_COUNT() AS rows_changed;

-- 4 · Frankenstein (id 2) sells out and drops to 6.99, in one statement
UPDATE books SET in_stock = FALSE, price = 6.99 WHERE id = 2;
SELECT title, price, in_stock FROM books WHERE id = 2;

-- 5 · Preview, then remove, the books published before 1820
SELECT id, title, published FROM books WHERE published < '1820-01-01' ORDER BY id;
DELETE FROM books WHERE published < '1820-01-01';
SELECT ROW_COUNT() AS rows_deleted;

-- 6 · One more arrival: which id does it get?
INSERT INTO books (title, author, price, pages, published)
VALUES ('Middlemarch', 'George Eliot', 11.10, 880, '1871-12-01');
SELECT id, title, price, in_stock FROM books ORDER BY id;

TRUNCATE TABLE books;
