-- state: none
-- =====================================================================
-- checkpoint_starter.sql: Checkpoint 1 (Modules 1 and 2)
-- Session 4 · MySQL Foundations instructor kit
--
-- 30 minutes, open notes (your workbook, your scripts, the lesson pages).
-- The task is on the workbook's Checkpoint 1 page; this file is where you
-- write Parts A to C. Part D is answered on paper.
--
-- The bookstore is opening a used-book trade-in desk. Write the SQL under
-- each TODO. The file runs as it is (it only creates an empty database), so
-- run it after each part:
--   SOURCE labs/module-04/checkpoint-1/checkpoint_starter.sql
-- It rebuilds kit_cp1_tradein from nothing every time and drops it at the end.
-- =====================================================================

-- ---------- Part A · build (rerunnable) ----------
DROP DATABASE IF EXISTS kit_cp1_tradein;
CREATE DATABASE kit_cp1_tradein
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE kit_cp1_tradein;

-- TODO A1 · sellers: an id MySQL numbers; a name (up to 80 characters,
-- required); an email (up to 100, required, never shared by two sellers);
-- a city (up to 50, may be unknown).

-- TODO A2 · trade_ins: an id MySQL numbers; seller_id (a whole number,
-- required); title (up to 200, required); the book's condition: like new,
-- good or worn, good unless given (careful: CONDITION is a reserved word,
-- call the column book_condition); offer (money, required, from 0.50 to
-- 20.00, enforced by a CHECK named chk_offer); received (a date, required);
-- paid (yes/no, no unless given).

-- ---------- Part B · fill and change ----------
-- TODO B1 · the three sellers (workbook table), in one INSERT
-- TODO B2 · the five trade-ins (workbook table), in one INSERT; leave paid out
-- TODO B3 · Dune's offer goes up by one dollar (Dune is trade-in 1)
-- TODO B4 · Mo (seller 1) is paid for all his books: preview, then update, then count
-- TODO B5 · Dracula (trade-in 5) was turned down: remove it
-- TODO B6 · Ivy sends her details again (Ivy Chen, ivy@example.com, Henderson):
--           ONE statement that inserts her, or updates her city if her email exists

-- ---------- Part C · read ----------
-- TODO C1 · every trade-in by id: id, title, condition, offer, a column
--           store_credit = the offer plus 10%, rounded to cents, and paid
SELECT 'TODO C1' AS todo;
-- TODO C2 · the conditions that occur, each once
SELECT 'TODO C2' AS todo;
-- TODO C3 · the sellers by id: id, name, city
SELECT 'TODO C3' AS todo;

DROP DATABASE kit_cp1_tradein;
