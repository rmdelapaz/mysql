-- state: full
-- =====================================================================
-- add_item_rules_solution.sql: REFERENCE for add_item_rules_starter.sql
-- Session 14 · Lesson 8.2 · MySQL Foundations instructor kit
--
-- Milestone 5 in miniature, on the bookstore: rules that look at OTHER
-- rows live in a procedure, inside a transaction, with a row lock; the
-- single-row rule lives in a CHECK. Instructor copy.
-- =====================================================================

-- 1. A single-row rule belongs in a constraint: 1 to 10 copies per line
ALTER TABLE order_items
    ADD CONSTRAINT chk_items_quantity CHECK (quantity BETWEEN 1 AND 10);

-- 2. Rules that look at other rows belong in the procedure that writes
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

-- 3. Two calls every rule accepts: order 3 (Bob, one book so far) gets two more
CALL add_order_item(3, 2, 1);
CALL add_order_item(3, 6, 2);

SELECT oi.id, b.title, oi.quantity, oi.price_at_time
FROM order_items AS oi
JOIN books AS b ON b.id = oi.book_id
WHERE oi.order_id = 3
ORDER BY oi.id;

-- 4. The rules, as the server stores them
SELECT ROUTINE_NAME, ROUTINE_TYPE, SECURITY_TYPE
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = DATABASE() AND ROUTINE_NAME = 'add_order_item';

-- Every rule also needs a call that MUST fail: debug_add_item_rules.sql.

-- Cleanup: the bookstore as it was
DELETE FROM order_items WHERE order_id = 3 AND book_id IN (2, 6);
ALTER TABLE order_items DROP CHECK chk_items_quantity;
DROP PROCEDURE add_order_item;
