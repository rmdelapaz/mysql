-- state: full
-- expect-error: 3140, 3143, 3152
-- =====================================================================
-- debug_bad_json.sql: a wishlist feature with five JSON bugs (find-the-bug handout)
-- Session 11 · Lesson 7.3 · MySQL Foundations instructor kit
--
-- This file is broken ON PURPOSE. A developer added wishlists: one JSON
-- array of book ids per customer. Three statements fail with an error;
-- two more run without any error and give a wrong answer. Run it, then for
-- each bug (A to E) write in your workbook: the error number or the wrong
-- result, the cause, and the fixed statement. Fixed, the file shows Bob's
-- list, the label Alice (birthday) without extra quotes, two customers who
-- want Dune (book 1), and three wishlists at the end.
--
--   SOURCE labs/module-11/l7_3-json-columns/debug_bad_json.sql
-- =====================================================================

DROP TABLE IF EXISTS wishlists;
CREATE TABLE wishlists (
    customer_id INT PRIMARY KEY,
    owner       VARCHAR(50) NOT NULL,
    items       JSON NOT NULL
);
INSERT INTO wishlists VALUES (1, 'Alice', '{"book_ids": [1, 9], "occasion": "birthday", "public": true}');
INSERT INTO wishlists VALUES (7, 'Grace', '{"book_ids": [1, 6], "public": false}');

-- Bug A
INSERT INTO wishlists VALUES (2, 'Bob', "{'book_ids': [2, 11], 'public': true}");

-- Bug B
SELECT owner, items->>'book_ids' AS books FROM wishlists ORDER BY customer_id;

-- Bug C
CREATE INDEX idx_wishlists_items ON wishlists (items);

-- Bug D (no error)
SELECT CONCAT(owner, ' (', items->'$.occasion', ')') AS label FROM wishlists WHERE customer_id = 1;

-- Bug E (no error)
SELECT owner FROM wishlists WHERE 1 MEMBER OF (items->'$.bookIds') ORDER BY owner;

SELECT customer_id, owner, items FROM wishlists ORDER BY customer_id;

DROP TABLE wishlists;
