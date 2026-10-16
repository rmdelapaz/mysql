-- state: full
-- =====================================================================
-- order_documents_starter.sql: build JSON from rows, and turn JSON back into rows
-- Session 11 · Lesson 7.3 · MySQL Foundations instructor kit
--
-- No new column this time: ordinary rows become JSON documents for an app,
-- and a supplier's JSON restock message becomes rows you can join and use.
-- The file runs as shipped; each TODO is one small edit. The restock part
-- changes books.in_stock: reload labs/_states/bookstore.sql before you run
-- the file again and before the next lab.
--
--   SOURCE labs/module-11/l7_3-json-columns/order_documents_starter.sql
-- =====================================================================

-- TODO 1 · One document per order of Alice (customer 1). Add a fourth
-- key, 'total', whose value is SUM(oi.quantity * oi.price_at_time).
SELECT JSON_OBJECT(
           'order_id', o.id,
           'date',     o.order_date,
           'lines',    COUNT(*)
       ) AS order_doc
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.id
WHERE o.customer_id = 1
GROUP BY o.id, o.order_date
ORDER BY o.id;

-- TODO 2 · One object for the whole shop: title -> copies sold, for books
-- sold at least three times. As shipped the HAVING asks for 99, no book
-- qualifies and the object is NULL. Change 99 to 3. Which key comes first,
-- and why not alphabetical?
SELECT JSON_OBJECTAGG(title, sold) AS best_sellers
FROM (
    SELECT b.title, SUM(oi.quantity) AS sold
    FROM books AS b
    JOIN order_items AS oi ON oi.book_id = b.id
    GROUP BY b.id, b.title
    HAVING SUM(oi.quantity) >= 99
) AS s;

-- TODO 3 · A supplier's restock message, as rows. The row path '$.todo[*]'
-- matches nothing (Empty set). Point it at the array of lines.
SET @restock = '{"supplier": "Riverside Book Supply", "lines": [{"book_id": 4, "qty": 5}, {"book_id": 8, "qty": 3}, {"book_id": 42, "qty": 1}]}';
SELECT r.book_id, r.qty, b.title, b.in_stock
FROM JSON_TABLE(@restock, '$.todo[*]'
         COLUMNS (book_id INT PATH '$.book_id', qty INT PATH '$.qty')) AS r
LEFT JOIN books AS b ON b.id = r.book_id
ORDER BY r.book_id;

-- TODO 4 · Use it: mark the restocked books as in stock again. Same fix to
-- the row path. Predict still_out_of_stock before and after.
UPDATE books AS b
JOIN JSON_TABLE(@restock, '$.todo[*]'
         COLUMNS (book_id INT PATH '$.book_id')) AS r ON r.book_id = b.id
SET b.in_stock = TRUE;
SELECT JSON_VALUE(@restock, '$.supplier') AS supplier,
       (SELECT COUNT(*) FROM books WHERE in_stock = FALSE) AS still_out_of_stock;

-- Expected when done: TODO 1 three documents, for orders 1, 2 and 8, e.g.
-- {"date": "2026-01-15", "lines": 2, "total": 34.97, "order_id": 1}.
-- TODO 2 {"1984": 4, "Dune": 3, "The Hobbit": 3} (shortest keys first).
-- TODO 3 book 4 The Great Gatsby 0, book 8 The Catcher in the Rye 0, book
-- 42 NULL NULL (no such book: the supplier made a mistake). TODO 4
-- Riverside Book Supply, still_out_of_stock 0 (it was 2).
