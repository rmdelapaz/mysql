-- state: full
-- =====================================================================
-- loyalty_points_starter.sql: COMMIT, ROLLBACK, a savepoint and an implicit commit
-- Session 11 · Lesson 7.2 · MySQL Foundations instructor kit
--
-- The lesson moved store credit between accounts. This lab uses a new
-- loyalty table (points per customer, never below zero) and the real
-- orders. Every run rebuilds the loyalty table, so you can edit the file
-- and SOURCE it again as often as you like. It runs as shipped and shows
-- the unfinished results; each TODO is a small edit.
--
-- How to run it: open a terminal in the folder that holds labs/, log in
-- with  mysql -u root -p bookstore  and type
--   SOURCE labs/module-11/l7_2-transactions/loyalty_points_starter.sql
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

-- TODO 1 · COMMIT: Frank (6) gives 25 of his points to Grace (7).
-- Change both 0s to 25. Predict first: what do the two rows show?
START TRANSACTION;
UPDATE loyalty SET points = points - 0 WHERE customer_id = 6;
UPDATE loyalty SET points = points + 0 WHERE customer_id = 7;
COMMIT;
SELECT customer_id, points FROM loyalty WHERE customer_id IN (6, 7) ORDER BY customer_id;

-- TODO 2 · ROLLBACK: rehearse deleting every order placed before March.
-- Change '1900-01-01' to '2026-03-01'. How many order lines go with them
-- (fk_items_order cascades), and are they back after the ROLLBACK?
START TRANSACTION;
DELETE FROM orders WHERE order_date < '1900-01-01';
SELECT (SELECT COUNT(*) FROM orders)      AS orders_inside,
       (SELECT COUNT(*) FROM order_items) AS items_inside;
ROLLBACK;
SELECT (SELECT COUNT(*) FROM orders)      AS orders_after,
       (SELECT COUNT(*) FROM order_items) AS items_after;

-- TODO 3 · SAVEPOINT: double-points week for Alice (1) and Bob (2), then a
-- slip that sets EVERYONE to 0. As shipped, the slip is committed: look at
-- the zeros. Turn on the ROLLBACK TO line (remove the --) and fill in the
-- savepoint's name, so the bonus stays and the slip goes.
START TRANSACTION;
UPDATE loyalty SET points = points + 50 WHERE customer_id IN (1, 2);
SAVEPOINT bonus_given;
UPDATE loyalty SET points = 0;
-- ROLLBACK TO SAVEPOINT ___;
COMMIT;
SELECT customer_id, points FROM loyalty ORDER BY customer_id;

-- TODO 4 · The implicit commit. As shipped, the ROLLBACK does not take
-- Bob's 10 birthday points away again. Why not? Fix it by moving the CREATE TABLE line
-- ABOVE the START TRANSACTION line, then run again.
-- (Run TODO 3 first: this part starts from TODO 3's numbers.)
START TRANSACTION;
UPDATE loyalty SET points = points + 10 WHERE customer_id = 2;
CREATE TABLE loyalty_log (note VARCHAR(100));
INSERT INTO loyalty_log (note) VALUES ('Bob: +10 points, birthday');
ROLLBACK;
SELECT customer_id, points FROM loyalty WHERE customer_id = 2;
SELECT COUNT(*) AS log_rows FROM loyalty_log;

-- 5 · The two settings behind it all (nothing to change)
SELECT @@autocommit AS autocommit, @@transaction_isolation AS isolation;

DROP TABLE loyalty_log;

-- Expected when done: TODO 1 Frank (6) 15, Grace (7) 25. TODO 2 inside the
-- transaction 7 orders and 10 order lines; after the ROLLBACK 12 and 18.
-- TODO 3 the table reads 1: 350, 2: 170, 4: 10, 6: 15, 7: 25. TODO 4 Bob
-- (2) is back at 170 and log_rows is 0. Last: autocommit 1, REPEATABLE-READ.
