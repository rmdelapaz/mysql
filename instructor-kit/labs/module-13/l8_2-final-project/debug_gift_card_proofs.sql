-- state: full
-- expect-error: 3819, 1452, 1062, 1265
-- =====================================================================
-- debug_gift_card_proofs.sql: a test file that MUST fail
-- Session 13 · Lesson 8.2 · MySQL Foundations instructor kit
--
-- In the project rubric, a constraint counts as "proven" when a statement
-- that breaks it is refused. This file builds the finished gift-card
-- tables from gift_cards_starter.sql, then tries six bad rows inside a
-- transaction. EVERY test INSERT must be refused with an error. If one is
-- accepted, the rule it tests is missing: the counts at the end show it.
--
-- Your job: before you run it, write next to each test the error number
-- you expect. Then run it and compare. Finally, copy the pattern into
-- your project as the tests at the end of 01_schema.sql (the lesson's
-- Milestone 2 does exactly this).
--   SOURCE labs/module-13/l8_2-final-project/debug_gift_card_proofs.sql
-- =====================================================================

DROP TABLE IF EXISTS gift_card_uses;
DROP TABLE IF EXISTS gift_cards;

CREATE TABLE gift_cards (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    code        CHAR(8)       NOT NULL,
    customer_id INT           NOT NULL,
    amount      DECIMAL(8, 2) NOT NULL,
    issued_on   DATE          NOT NULL,
    expires_on  DATE          NOT NULL,
    status      ENUM('active', 'used', 'void') NOT NULL DEFAULT 'active',
    CONSTRAINT uq_gift_cards_code     UNIQUE (code),
    CONSTRAINT fk_gift_cards_customer FOREIGN KEY (customer_id) REFERENCES customers (id),
    CONSTRAINT chk_gift_cards_amount  CHECK (amount > 0),
    CONSTRAINT chk_gift_cards_dates   CHECK (expires_on > issued_on)
);

CREATE TABLE gift_card_uses (
    gift_card_id INT           NOT NULL,
    order_id     INT           NOT NULL,
    amount_used  DECIMAL(8, 2) NOT NULL,
    PRIMARY KEY (gift_card_id, order_id),
    CONSTRAINT fk_gcu_card  FOREIGN KEY (gift_card_id) REFERENCES gift_cards (id) ON DELETE CASCADE,
    CONSTRAINT fk_gcu_order FOREIGN KEY (order_id)     REFERENCES orders (id),
    CONSTRAINT chk_gcu_amount CHECK (amount_used > 0)
);

-- The tests run inside a transaction, so nothing stays behind
START TRANSACTION;

-- one good row, so the duplicate test has something to collide with
INSERT INTO gift_cards (code, customer_id, amount, issued_on, expires_on)
VALUES ('GCTEST01', 1, 25.00, '2026-06-01', '2027-06-01');

-- Test A: a card worth nothing                     (expect: ______)
INSERT INTO gift_cards (code, customer_id, amount, issued_on, expires_on)
VALUES ('GCTEST02', 1, 0.00, '2026-06-01', '2027-06-01');

-- Test B: a card that expires before it is issued  (expect: ______)
INSERT INTO gift_cards (code, customer_id, amount, issued_on, expires_on)
VALUES ('GCTEST03', 1, 25.00, '2026-06-01', '2026-05-01');

-- Test C: a card for customer 99, who does not exist (expect: ______)
INSERT INTO gift_cards (code, customer_id, amount, issued_on, expires_on)
VALUES ('GCTEST04', 99, 25.00, '2026-06-01', '2027-06-01');

-- Test D: a second card with the same code          (expect: ______)
INSERT INTO gift_cards (code, customer_id, amount, issued_on, expires_on)
VALUES ('GCTEST01', 2, 10.00, '2026-06-01', '2027-06-01');

-- Test E: a status the ENUM does not list           (expect: ______)
INSERT INTO gift_cards (code, customer_id, amount, issued_on, expires_on, status)
VALUES ('GCTEST05', 1, 25.00, '2026-06-01', '2027-06-01', 'lost');

-- Test F: using a card for an order that does not exist (expect: ______)
INSERT INTO gift_card_uses (gift_card_id, order_id, amount_used)
VALUES (LAST_INSERT_ID(), 999, 5.00);

-- Inside the transaction only the good row exists
SELECT COUNT(*) AS cards_in_transaction FROM gift_cards;

ROLLBACK;

-- After ROLLBACK nothing is left
SELECT COUNT(*) AS cards_after_rollback FROM gift_cards;

DROP TABLE gift_card_uses;
DROP TABLE gift_cards;
