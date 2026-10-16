-- state: full
-- =====================================================================
-- orphan_audit_starter.sql: find orphans, fix them, then add the key
-- Session 6 · Lesson 4.2 · MySQL Foundations instructor kit
--
-- A gift-card table was created months ago without a foreign key, and some
-- cards now point at customers who do not exist. Your job: find the
-- orphans, decide what is true, fix them, add the key with the right rule,
-- and prove the rule. The file runs as handed out; each TODO tells you what
-- to change. The practice table kit_gift_cards is rebuilt on every run and
-- dropped at the end.
--
--   SOURCE labs/module-06/l4_2-foreign-keys/orphan_audit_starter.sql
-- =====================================================================

DROP TABLE IF EXISTS kit_gift_cards;
CREATE TABLE kit_gift_cards (
    id          INT PRIMARY KEY,
    customer_id INT,
    amount      DECIMAL(8, 2) NOT NULL
);
INSERT INTO kit_gift_cards VALUES
    (1, 1, 25.00), (2, 3, 10.00), (3, 12, 50.00), (4, 6, 15.00), (5, 15, 20.00);

-- TODO 1 · The orphans. Replace the placeholder condition (1 = 0) with
-- NOT EXISTS (SELECT 1 FROM customers AS c WHERE c.id = g.customer_id).
SELECT id, customer_id, amount
FROM kit_gift_cards AS g
WHERE 1 = 0
ORDER BY id;

-- TODO 2 · The fix. The cards are real money, but nobody knows whose they
-- are: keep them, unassigned. Turn this on (remove the --) and fill the gap
-- with the value that means "no customer".
-- UPDATE kit_gift_cards SET customer_id = ___ WHERE customer_id NOT IN (SELECT id FROM customers);

-- TODO 3 · Add the key. A card should outlive its customer: which ON DELETE
-- rule? Fill the gap, turn it on. (Run it BEFORE TODO 2 once: which error,
-- and why?) Then the check query below shows your rule.
-- ALTER TABLE kit_gift_cards
--     ADD CONSTRAINT fk_cards_customer
--         FOREIGN KEY (customer_id) REFERENCES customers(id)
--         ON DELETE ___
--         ON UPDATE CASCADE;
SELECT CONSTRAINT_NAME, REFERENCED_TABLE_NAME, DELETE_RULE, UPDATE_RULE
FROM information_schema.REFERENTIAL_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'bookstore'
  AND TABLE_NAME = 'kit_gift_cards';

-- TODO 4 · Prove the rule. Carol (3) never ordered, so she can be deleted.
-- Turn on the DELETE: what happens to card 2?
START TRANSACTION;
-- DELETE FROM customers WHERE id = 3;
SELECT id, customer_id, amount FROM kit_gift_cards ORDER BY id;
ROLLBACK;

-- The total card value must never change:
SELECT COUNT(*) AS cards, SUM(amount) AS total, COUNT(customer_id) AS assigned
FROM kit_gift_cards;

DROP TABLE kit_gift_cards;

-- Expected when done:
--   1: cards 3 (customer 12, 50.00) and 5 (customer 15, 20.00)
--   3: fk_cards_customer, customers, SET NULL, CASCADE
--      (before TODO 2 the ALTER fails with ERROR 1452: two orphans)
--   4: card 2's customer_id becomes NULL with Carol gone; cards 3 and 5 are NULL too
--   last: 5 cards, total 120.00, 3 assigned (ROLLBACK gave card 2 back to Carol)
