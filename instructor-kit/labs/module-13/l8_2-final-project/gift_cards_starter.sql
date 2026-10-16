-- state: full
-- =====================================================================
-- gift_cards_starter.sql: a re-runnable build script with named rules
-- Session 13 · Lesson 8.2 · MySQL Foundations instructor kit
--
-- The bookstore starts selling gift cards: a card has a unique code,
-- belongs to a customer, holds an amount and expires; each time a card
-- pays for (part of) an order, a row goes into gift_card_uses. This is
-- Milestone 2 of your project in miniature, on the bookstore.
--
-- The script already runs: it drops and rebuilds the two tables, adds
-- three cards, and reads the constraints back from information_schema.
-- But several rules are missing. Each TODO adds ONE named constraint.
-- Edit, save, SOURCE again, and watch the constraint list grow.
--
-- How to run it (bookstore loaded, a client started in the folder that
-- holds labs/):
--   SOURCE labs/module-13/l8_2-final-project/gift_cards_starter.sql
-- Then prove your rules with debug_gift_card_proofs.sql.
-- =====================================================================

-- 1. Re-runnable: drop the child first, then the parent
DROP TABLE IF EXISTS gift_card_uses;
DROP TABLE IF EXISTS gift_cards;

-- 2. The parent: one row per card sold
CREATE TABLE gift_cards (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    code        CHAR(8)       NOT NULL,
    customer_id INT           NOT NULL,
    amount      DECIMAL(8, 2) NOT NULL,
    issued_on   DATE          NOT NULL,
    expires_on  DATE          NOT NULL,
    status      ENUM('active', 'used', 'void') NOT NULL DEFAULT 'active',
    -- TODO 1: no two cards may share a code. Add (with the comma above it):
    --   CONSTRAINT uq_gift_cards_code UNIQUE (code),
    -- TODO 2: a card must belong to a real customer. Add a foreign key
    --   named fk_gift_cards_customer on customer_id -> customers (id).
    -- TODO 3: a card must expire after the day it was issued. Add a CHECK
    --   named chk_gift_cards_dates (compare two columns of the row, never
    --   CURDATE(): MySQL refuses that with error 3814).
    CONSTRAINT chk_gift_cards_amount CHECK (amount > 0)
);

-- 3. The child: one row each time a card pays (part of) an order
CREATE TABLE gift_card_uses (
    gift_card_id INT           NOT NULL,
    order_id     INT           NOT NULL,
    amount_used  DECIMAL(8, 2) NOT NULL,
    -- TODO 4: the key is the PAIR (gift_card_id, order_id), and amount_used
    --   must be positive (name it chk_gcu_amount). Add both.
    CONSTRAINT fk_gcu_card  FOREIGN KEY (gift_card_id) REFERENCES gift_cards (id) ON DELETE CASCADE,
    CONSTRAINT fk_gcu_order FOREIGN KEY (order_id)     REFERENCES orders (id)
);

-- 4. Three cards and one use that every rule accepts
INSERT INTO gift_cards (id, code, customer_id, amount, issued_on, expires_on) VALUES
    (1, 'GC7Q2M4K', 1, 25.00, '2026-03-01', '2027-03-01'),
    (2, 'GC3X9P1T', 6, 50.00, '2026-04-15', '2027-04-15'),
    (3, 'GC8L5V2N', 7, 20.00, '2026-05-10', '2027-05-10');
INSERT INTO gift_card_uses (gift_card_id, order_id, amount_used) VALUES (2, 10, 18.98);

-- 5. Read the rules back: every constraint, its type and its table
SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN ('gift_cards', 'gift_card_uses')
ORDER BY TABLE_NAME, CONSTRAINT_TYPE, CONSTRAINT_NAME;

-- 6. And what each CHECK actually tests
SELECT CONSTRAINT_NAME, CHECK_CLAUSE
FROM information_schema.CHECK_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = DATABASE()
  AND CONSTRAINT_NAME LIKE 'chk_g%'
ORDER BY CONSTRAINT_NAME;

-- 7. TODO 5: the balance left on each card is amount minus the uses. It is
--    DERIVED: compute it, never store it. Replace the placeholder with a
--    LEFT JOIN from gift_cards to gift_card_uses, grouped per card, with
--    COALESCE(SUM(u.amount_used), 0) for cards never used.
SELECT 'TODO 5: balance per card' AS todo;

-- Expected when done: 9 constraints, 4 on gift_card_uses (chk_gcu_amount,
-- fk_gcu_card, fk_gcu_order, PRIMARY) and 5 on gift_cards
-- (chk_gift_cards_amount, chk_gift_cards_dates, fk_gift_cards_customer,
-- PRIMARY, uq_gift_cards_code); three CHECK clauses; balances
-- GC7Q2M4K 25.00 used 0.00 balance 25.00 · GC3X9P1T 50.00 used 18.98
-- balance 31.02 · GC8L5V2N 20.00 used 0.00 balance 20.00.

-- Cleanup: the practice tables leave the bookstore as it was
DROP TABLE gift_card_uses;
DROP TABLE gift_cards;
