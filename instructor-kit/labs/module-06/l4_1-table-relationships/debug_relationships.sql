-- state: full
-- expect-error: 1824, 1062, 1138
-- =====================================================================
-- debug_relationships.sql: three relationship mistakes (find-the-bug handout)
-- Session 6 · Lesson 4.1 · MySQL Foundations instructor kit
--
-- This file is broken ON PURPOSE. Three statements below make one of the
-- lesson's mistakes, on new tables, and MySQL refuses each with a
-- numbered error. Run it, then for each ERROR line write in your workbook:
--   the error number · the mistake · the fixed statement (or the step
--   that should have come first).
-- The practice tables are dropped at the end.
--
--   SOURCE labs/module-06/l4_1-table-relationships/debug_relationships.sql
-- =====================================================================

-- Bug A · A wishlist: each row is one book a customer wants.
CREATE TABLE kit_wishlist (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    book_id     INT NOT NULL,
    CONSTRAINT fk_wishlist_customer FOREIGN KEY (customer_id) REFERENCES customer(id),
    CONSTRAINT fk_wishlist_book     FOREIGN KEY (book_id)     REFERENCES books(id)
);

-- Bug B · Tag Lord of the Rings (book 9) as Fantasy (category 4).
INSERT INTO book_categories (book_id, category_id) VALUES (9, 4);

-- Bug C · Book signings: every signing must name an author.
CREATE TABLE kit_signings (
    id         INT PRIMARY KEY,
    author_id  INT,
    city       VARCHAR(50)
);
INSERT INTO kit_signings VALUES (1, 6, 'Chicago'), (2, NULL, 'Houston');
ALTER TABLE kit_signings MODIFY COLUMN author_id INT NOT NULL;

DROP TABLE IF EXISTS kit_wishlist;
DROP TABLE kit_signings;
