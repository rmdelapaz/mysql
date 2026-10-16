-- state: full
-- expect-error: 1644, 3819
-- =====================================================================
-- debug_add_item_rules.sql: every rule gets a call that MUST fail
-- Session 14 · Lesson 8.2 · MySQL Foundations instructor kit
--
-- The finished add_order_item procedure (from add_item_rules_solution.sql)
-- and its CHECK, then one bad call per rule. Every bad call must be
-- refused with its OWN message; a call that succeeds means a missing rule.
-- Before you run it, write next to each call the message you expect.
-- At the end, the count proves that the refused calls left nothing behind
-- (the EXIT HANDLER rolled each one back).
--   SOURCE labs/module-14/l8_2-final-project/debug_add_item_rules.sql
-- =====================================================================

ALTER TABLE order_items
    ADD CONSTRAINT chk_items_quantity CHECK (quantity BETWEEN 1 AND 10);

DROP PROCEDURE IF EXISTS add_order_item;

DELIMITER //

CREATE PROCEDURE add_order_item(IN p_order_id INT, IN p_book_id INT, IN p_quantity INT)
BEGIN
    DECLARE v_customer INT;
    DECLARE v_price    DECIMAL(8, 2);
    DECLARE v_in_stock TINYINT;
    DECLARE v_lines    INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- lock the order's row: a second call for the same order waits here
    SELECT customer_id INTO v_customer FROM orders WHERE id = p_order_id FOR UPDATE;
    IF v_customer IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No such order';
    END IF;

    SELECT price, in_stock INTO v_price, v_in_stock FROM books WHERE id = p_book_id;
    IF v_price IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No such book';
    ELSEIF NOT v_in_stock THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book is out of stock';
    END IF;

    IF EXISTS (SELECT 1 FROM order_items WHERE order_id = p_order_id AND book_id = p_book_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book is already on this order';
    END IF;

    SELECT COUNT(*) INTO v_lines FROM order_items WHERE order_id = p_order_id;
    IF v_lines >= 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'An order holds at most 3 different books';
    END IF;

    -- the price is copied on purpose: it is the price at the time of sale
    INSERT INTO order_items (order_id, book_id, quantity, price_at_time)
    VALUES (p_order_id, p_book_id, p_quantity, v_price);

    COMMIT;

    SELECT LAST_INSERT_ID() AS item_id, v_price AS price_at_time;
END //

DELIMITER ;

-- Two allowed calls first: order 3 now holds three different books
CALL add_order_item(3, 2, 1);
CALL add_order_item(3, 6, 2);

CALL add_order_item(99, 1, 1);   -- rule a: (expect: ____________________)
CALL add_order_item(2, 77, 1);   -- rule a: (expect: ____________________)
CALL add_order_item(2, 4, 1);    -- rule b: The Great Gatsby (expect: ____)
CALL add_order_item(2, 5, 1);    -- rule c: Pride and Prejudice (expect: _)
CALL add_order_item(3, 9, 1);    -- rule d: a fourth book (expect: _______)
CALL add_order_item(2, 11, 0);   -- rule e: zero copies (expect: _________)

-- 18 lines in the course data + the 2 allowed calls = 20
SELECT COUNT(*) AS order_items_now FROM order_items;

-- Cleanup: the bookstore as it was
DELETE FROM order_items WHERE order_id = 3 AND book_id IN (2, 6);
ALTER TABLE order_items DROP CHECK chk_items_quantity;
DROP PROCEDURE add_order_item;
