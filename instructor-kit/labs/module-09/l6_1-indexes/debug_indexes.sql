-- state: full
-- expect-error: 1061, 1091, 1553, 1062
-- =====================================================================
-- debug_indexes.sql: four index statements MySQL refuses (deliberately broken handout)
-- Session 9 · Lesson 6.1 · MySQL Foundations instructor kit
--
-- Run it, read each ERROR line from the left, and write in your workbook
-- what is wrong and what you would do instead. Nothing is changed: every
-- statement fails. Start from a fresh bookstore (SOURCE bookstore.sql) so
-- the existing indexes are the ones the lesson lists.
-- =====================================================================

-- A. An index on books.price, with a name that is already taken
CREATE INDEX fk_books_author ON books (price);

-- B. Remove the index on books.price
DROP INDEX idx_books_price ON books;

-- C. "orders.customer_id has an index I never made, so I can drop it"
DROP INDEX fk_orders_customer ON orders;

-- D. "Two customers should never share a city": a unique index on city
CREATE UNIQUE INDEX uq_customers_city ON customers (city);

-- What the indexes look like afterward (unchanged)
SELECT TABLE_NAME, INDEX_NAME, COLUMN_NAME
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'bookstore' AND TABLE_NAME IN ('books', 'customers', 'orders')
ORDER BY TABLE_NAME, INDEX_NAME;
