-- state: full
-- =====================================================================
-- order_documents_solution.sql: build JSON from rows, and turn JSON back into rows
-- Session 11 · Lesson 7.3 · MySQL Foundations instructor kit · instructor reference
--
-- No new column this time: ordinary rows become JSON documents for an app,
-- and a supplier's JSON restock message becomes rows you can join and use.
-- The restock part changes books.in_stock; reload labs/_states/bookstore.sql
-- before the next lab.
-- =====================================================================

-- 1 · One document per order of Alice (customer 1): id, date, lines, total
SELECT JSON_OBJECT(
           'order_id', o.id,
           'date',     o.order_date,
           'lines',    COUNT(*),
           'total',    SUM(oi.quantity * oi.price_at_time)
       ) AS order_doc
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.id
WHERE o.customer_id = 1
GROUP BY o.id, o.order_date
ORDER BY o.id;

-- 2 · One object for the whole shop: title -> copies sold, for books sold
--     at least twice (JSON_OBJECTAGG; MySQL sorts the keys itself)
SELECT JSON_OBJECTAGG(title, sold) AS best_sellers
FROM (
    SELECT b.title, SUM(oi.quantity) AS sold
    FROM books AS b
    JOIN order_items AS oi ON oi.book_id = b.id
    GROUP BY b.id, b.title
    HAVING SUM(oi.quantity) >= 3
) AS s;

-- 3 · A supplier's restock message, as rows (a LEFT JOIN shows the unknown id)
SET @restock = '{"supplier": "Riverside Book Supply", "lines": [{"book_id": 4, "qty": 5}, {"book_id": 8, "qty": 3}, {"book_id": 42, "qty": 1}]}';
SELECT r.book_id, r.qty, b.title, b.in_stock
FROM JSON_TABLE(@restock, '$.lines[*]'
         COLUMNS (book_id INT PATH '$.book_id', qty INT PATH '$.qty')) AS r
LEFT JOIN books AS b ON b.id = r.book_id
ORDER BY r.book_id;

-- 4 · Use it: mark the restocked books as in stock again
UPDATE books AS b
JOIN JSON_TABLE(@restock, '$.lines[*]'
         COLUMNS (book_id INT PATH '$.book_id')) AS r ON r.book_id = b.id
SET b.in_stock = TRUE;
SELECT JSON_VALUE(@restock, '$.supplier') AS supplier,
       (SELECT COUNT(*) FROM books WHERE in_stock = FALSE) AS still_out_of_stock;
