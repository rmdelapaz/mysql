-- state: full
-- =====================================================================
-- orphan_audit_solution.sql: REFERENCE SOLUTION (instructor copy)
-- Session 6 · Lesson 4.2 · MySQL Foundations instructor kit
--
-- A gift-card table was created months ago without a foreign key, and two
-- cards now point at customers who do not exist. Find the orphans, decide
-- what is true, fix them, add the key with the right rule, prove it works,
-- and clean up. The practice table kit_gift_cards is dropped at the end.
--
--   SOURCE labs/module-06/l4_2-foreign-keys/orphan_audit_solution.sql
-- =====================================================================

DROP TABLE IF EXISTS kit_gift_cards;
CREATE TABLE kit_gift_cards (
    id          INT PRIMARY KEY,
    customer_id INT,
    amount      DECIMAL(8, 2) NOT NULL
);
INSERT INTO kit_gift_cards VALUES
    (1, 1, 25.00), (2, 3, 10.00), (3, 12, 50.00), (4, 6, 15.00), (5, 15, 20.00);

-- 1 · The orphans: customer ids with no customer behind them.
SELECT id, customer_id, amount
FROM kit_gift_cards AS g
WHERE NOT EXISTS (SELECT 1 FROM customers AS c WHERE c.id = g.customer_id)
ORDER BY id;

-- 2 · The fix that tells the truth: the cards are real money, but nobody
--     knows whose they are. Keep them, unassigned.
UPDATE kit_gift_cards
SET customer_id = NULL
WHERE customer_id NOT IN (SELECT id FROM customers);

-- 3 · Now the key can be added. SET NULL: a card outlives its customer.
ALTER TABLE kit_gift_cards
    ADD CONSTRAINT fk_cards_customer
        FOREIGN KEY (customer_id) REFERENCES customers(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE;
SELECT CONSTRAINT_NAME, REFERENCED_TABLE_NAME, DELETE_RULE, UPDATE_RULE
FROM information_schema.REFERENTIAL_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'bookstore'
  AND TABLE_NAME = 'kit_gift_cards';

-- 4 · Prove the rule: Carol (3) never ordered, so she can be deleted; her
--     card stays, unassigned. Undo with ROLLBACK.
START TRANSACTION;
DELETE FROM customers WHERE id = 3;
SELECT id, customer_id, amount FROM kit_gift_cards ORDER BY id;
ROLLBACK;

-- 5 · The total card value never changed.
SELECT COUNT(*) AS cards, SUM(amount) AS total, COUNT(customer_id) AS assigned
FROM kit_gift_cards;

DROP TABLE kit_gift_cards;
