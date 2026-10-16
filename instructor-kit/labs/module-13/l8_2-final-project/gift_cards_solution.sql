-- state: full
-- =====================================================================
-- gift_cards_solution.sql: REFERENCE for gift_cards_starter.sql
-- Session 13 · Lesson 8.2 · MySQL Foundations instructor kit
--
-- The bookstore starts selling gift cards. A re-runnable build script for
-- the two new tables: dropped children first, created parents first,
-- every constraint named, then the constraint list read back from
-- information_schema. Instructor copy: do not hand out before the lab.
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
    CONSTRAINT uq_gift_cards_code     UNIQUE (code),
    CONSTRAINT fk_gift_cards_customer FOREIGN KEY (customer_id) REFERENCES customers (id),
    CONSTRAINT chk_gift_cards_amount  CHECK (amount > 0),
    CONSTRAINT chk_gift_cards_dates   CHECK (expires_on > issued_on)
);

-- 3. The child: one row each time a card pays (part of) an order
CREATE TABLE gift_card_uses (
    gift_card_id INT           NOT NULL,
    order_id     INT           NOT NULL,
    amount_used  DECIMAL(8, 2) NOT NULL,
    PRIMARY KEY (gift_card_id, order_id),
    CONSTRAINT fk_gcu_card  FOREIGN KEY (gift_card_id) REFERENCES gift_cards (id) ON DELETE CASCADE,
    CONSTRAINT fk_gcu_order FOREIGN KEY (order_id)     REFERENCES orders (id),
    CONSTRAINT chk_gcu_amount CHECK (amount_used > 0)
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

-- 7. Balance left on each card: amount minus what was used (derived, not stored)
SELECT g.code, g.amount, COALESCE(SUM(u.amount_used), 0) AS used,
       g.amount - COALESCE(SUM(u.amount_used), 0) AS balance
FROM gift_cards AS g
LEFT JOIN gift_card_uses AS u ON u.gift_card_id = g.id
GROUP BY g.id, g.code, g.amount
ORDER BY g.id;

-- Cleanup: the practice tables leave the bookstore as it was
DROP TABLE gift_card_uses;
DROP TABLE gift_cards;
