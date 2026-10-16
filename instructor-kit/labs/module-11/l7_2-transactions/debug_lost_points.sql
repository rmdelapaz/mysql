-- state: full
-- expect-error: 3819, 1305
-- =====================================================================
-- debug_lost_points.sql: three transactions that go wrong (find-the-bug handout)
-- Session 11 · Lesson 7.2 · MySQL Foundations instructor kit
--
-- This file is broken ON PURPOSE. A clerk typed three transactions by hand.
-- Two of them raise an error, one goes wrong without any error at all, and
-- all three leave the wrong points in the table. Run it, then for each
-- transaction write in your workbook: what the clerk meant, what MySQL
-- actually kept, and the fix. Start values: 1: 300, 2: 120, 4: 10, 6: 40, 7: 0.
--
--   SOURCE labs/module-11/l7_2-transactions/debug_lost_points.sql
-- =====================================================================

DROP TABLE IF EXISTS loyalty_audit;
DROP TABLE IF EXISTS loyalty;
CREATE TABLE loyalty (
    customer_id INT PRIMARY KEY,
    points      INT NOT NULL,
    CONSTRAINT chk_points CHECK (points >= 0),
    CONSTRAINT fk_loyalty_customer FOREIGN KEY (customer_id) REFERENCES customers (id)
);
INSERT INTO loyalty (customer_id, points) VALUES (1, 300), (2, 120), (4, 10), (6, 40), (7, 0);

-- Transaction A: move 50 points from Grace (7) to Bob (2)
START TRANSACTION;
UPDATE loyalty SET points = points + 50 WHERE customer_id = 2;
UPDATE loyalty SET points = points - 50 WHERE customer_id = 7;
COMMIT;

-- Transaction B: double everyone's points, keeping a way back
START TRANSACTION;
SAVEPOINT before_bonus;
UPDATE loyalty SET points = points * 2;
ROLLBACK TO SAVEPOINT before_bonuses;
COMMIT;

-- Transaction C: try zeroing Alice's points, then think better of it
START TRANSACTION;
UPDATE loyalty SET points = 0 WHERE customer_id = 1;
CREATE TABLE loyalty_audit (note VARCHAR(100));
ROLLBACK;

SELECT customer_id, points FROM loyalty ORDER BY customer_id;

DROP TABLE loyalty_audit;
