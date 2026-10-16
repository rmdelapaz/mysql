-- state: none
-- =====================================================================
-- checkpoint_solution.sql: Checkpoint 1 (Modules 1 and 2), model answer
-- Session 4 · MySQL Foundations instructor kit · instructor reference
--
-- The bookstore's used-book trade-in desk. Part A builds the database from
-- nothing; Part B fills and changes it; Part C reads it back. Part D (the
-- three statements that must fail) is answered in writing and is NOT in
-- this file. Builds kit_cp1_tradein and drops it at the end.
-- =====================================================================

-- ---------- Part A · build (rerunnable) ----------
DROP DATABASE IF EXISTS kit_cp1_tradein;
CREATE DATABASE kit_cp1_tradein
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE kit_cp1_tradein;

-- People who bring books in. email is how the desk finds them again.
CREATE TABLE sellers (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    name   VARCHAR(80)  NOT NULL,
    email  VARCHAR(100) NOT NULL UNIQUE,
    city   VARCHAR(50)
);

-- One row per book brought in. seller_id says whose it is (Module 4 makes it a foreign key).
CREATE TABLE trade_ins (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    seller_id       INT NOT NULL,
    title           VARCHAR(200) NOT NULL,
    book_condition  ENUM('like new', 'good', 'worn') NOT NULL DEFAULT 'good',
    offer           DECIMAL(5, 2) NOT NULL,
    received        DATE NOT NULL,
    paid            BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT chk_offer CHECK (offer BETWEEN 0.50 AND 20.00)
);

-- ---------- Part B · fill and change ----------
-- B1 · three sellers
INSERT INTO sellers (name, email, city) VALUES
    ('Mo Rahman', 'mo@example.com', 'Reno'),
    ('Ivy Chen', 'ivy@example.com', NULL),
    ('Sam Okoro', 'sam@example.com', 'Sparks');

-- B2 · five trade-ins (paid is left to its default)
INSERT INTO trade_ins (seller_id, title, book_condition, offer, received) VALUES
    (1, 'Dune', 'good', 4.00, '2026-05-01'),
    (1, 'Emma', 'worn', 1.50, '2026-05-01'),
    (2, 'The Hobbit', 'like new', 6.00, '2026-05-03'),
    (3, '1984', 'good', 3.50, '2026-05-04'),
    (3, 'Dracula', 'worn', 1.00, '2026-05-04');

-- B3 · Dune's offer goes up by one dollar (it is id 1)
UPDATE trade_ins SET offer = offer + 1.00 WHERE id = 1;

-- B4 · Mo is paid for all his books: preview, then the same WHERE
SELECT id, title, paid FROM trade_ins WHERE seller_id = 1 ORDER BY id;
UPDATE trade_ins SET paid = TRUE WHERE seller_id = 1;
SELECT ROW_COUNT() AS rows_paid;

-- B5 · Dracula (id 5) was turned down
DELETE FROM trade_ins WHERE id = 5;

-- B6 · Ivy sends her details again, now with a city: insert her, or update her
INSERT INTO sellers (name, email, city)
VALUES ('Ivy Chen', 'ivy@example.com', 'Henderson') AS new
ON DUPLICATE KEY UPDATE city = new.city;

-- ---------- Part C · read ----------
-- C1 · every trade-in, with 10% extra if taken as store credit
SELECT id, title, book_condition, offer,
       ROUND(offer * 1.10, 2) AS store_credit, paid
FROM trade_ins
ORDER BY id;

-- C2 · the conditions that occur, each once
SELECT DISTINCT book_condition FROM trade_ins ORDER BY book_condition;

-- C3 · the sellers now
SELECT id, name, city FROM sellers ORDER BY id;

DROP DATABASE kit_cp1_tradein;
