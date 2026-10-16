-- state: full
-- expect-error: 1452, 1451, 3780, 1830, 6125
-- =====================================================================
-- debug_fk_errors.sql: five statements a foreign key refuses (find-the-bug)
-- Session 6 · Lesson 4.2 · MySQL Foundations instructor kit
--
-- This file is broken ON PURPOSE. Each statement below is refused with a
-- numbered error: two because of the bookstore's existing keys, three
-- because the key itself is badly formed. Run it, then for each ERROR line
-- write in your workbook:
--   the error number · child or parent, insert or delete or create · the fix.
-- Nothing is changed: every refused statement leaves the data as it was.
--
--   SOURCE labs/module-06/l4_2-foreign-keys/debug_fk_errors.sql
-- =====================================================================

-- Bug A · A phone order for customer 42.
INSERT INTO orders (customer_id, order_date) VALUES (42, '2026-07-01');

-- Bug B · Take 1984 (book 2) off the catalog.
DELETE FROM books WHERE id = 2;

-- Bug C · A shelf map: which book stands on which shelf.
CREATE TABLE kit_shelf_map (
    id      INT PRIMARY KEY,
    book_id INT UNSIGNED NOT NULL,
    shelf   VARCHAR(10),
    CONSTRAINT fk_shelf_book FOREIGN KEY (book_id) REFERENCES books(id)
);

-- Bug D · Staff notes about customers, kept when a customer leaves.
CREATE TABLE kit_customer_notes (
    id          INT PRIMARY KEY,
    customer_id INT NOT NULL,
    note        VARCHAR(255),
    CONSTRAINT fk_notes_customer FOREIGN KEY (customer_id)
        REFERENCES customers(id) ON DELETE SET NULL
);

-- Bug E · City events, linked to the customers' city column.
CREATE TABLE kit_city_events (
    id    INT PRIMARY KEY,
    city  VARCHAR(50),
    CONSTRAINT fk_events_city FOREIGN KEY (city) REFERENCES customers(city)
);

SELECT COUNT(*) AS orders, (SELECT COUNT(*) FROM books) AS books FROM orders;
