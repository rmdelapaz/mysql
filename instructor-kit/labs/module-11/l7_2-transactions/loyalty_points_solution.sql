-- state: full
-- =====================================================================
-- loyalty_points_solution.sql: COMMIT, ROLLBACK, a savepoint and an implicit commit
-- Session 11 · Lesson 7.2 · MySQL Foundations instructor kit · instructor reference
--
-- The lesson moved store credit between accounts. This lab uses a new
-- loyalty table (points per customer, never below zero) and the real
-- orders. Every run rebuilds the loyalty table, so the numbers are always
-- the same. Run it inside the bookstore database (labs/_states/bookstore.sql).
-- =====================================================================

DROP TABLE IF EXISTS loyalty_log;
DROP TABLE IF EXISTS loyalty;
CREATE TABLE loyalty (
    customer_id INT PRIMARY KEY,
    points      INT NOT NULL,
    CONSTRAINT chk_points CHECK (points >= 0),
    CONSTRAINT fk_loyalty_customer FOREIGN KEY (customer_id) REFERENCES customers (id)
);
INSERT INTO loyalty (customer_id, points) VALUES (1, 300), (2, 120), (4, 10), (6, 40), (7, 0);

-- 1 · COMMIT: Frank (6) gives 25 of his points to Grace (7), both changes or neither
START TRANSACTION;
UPDATE loyalty SET points = points - 25 WHERE customer_id = 6;
UPDATE loyalty SET points = points + 25 WHERE customer_id = 7;
COMMIT;
SELECT customer_id, points FROM loyalty WHERE customer_id IN (6, 7) ORDER BY customer_id;

-- 2 · ROLLBACK: rehearse deleting every order placed before March
START TRANSACTION;
DELETE FROM orders WHERE order_date < '2026-03-01';
SELECT (SELECT COUNT(*) FROM orders)      AS orders_inside,
       (SELECT COUNT(*) FROM order_items) AS items_inside;
ROLLBACK;
SELECT (SELECT COUNT(*) FROM orders)      AS orders_after,
       (SELECT COUNT(*) FROM order_items) AS items_after;

-- 3 · SAVEPOINT: double-points week for Alice and Bob, then a slip that zeroes everyone
START TRANSACTION;
UPDATE loyalty SET points = points + 50 WHERE customer_id IN (1, 2);
SAVEPOINT bonus_given;
UPDATE loyalty SET points = 0;
ROLLBACK TO SAVEPOINT bonus_given;
COMMIT;
SELECT customer_id, points FROM loyalty ORDER BY customer_id;

-- 4 · The implicit commit, fixed: the CREATE TABLE runs BEFORE the transaction
CREATE TABLE loyalty_log (note VARCHAR(100));
START TRANSACTION;
UPDATE loyalty SET points = points + 10 WHERE customer_id = 2;
INSERT INTO loyalty_log (note) VALUES ('Bob: +10 points, birthday');
ROLLBACK;
SELECT customer_id, points FROM loyalty WHERE customer_id = 2;
SELECT COUNT(*) AS log_rows FROM loyalty_log;

-- 5 · The two settings behind it all
SELECT @@autocommit AS autocommit, @@transaction_isolation AS isolation;

DROP TABLE loyalty_log;
