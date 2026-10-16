-- state: full
-- =====================================================================
-- add_item_rules_starter.sql: rules across rows in a procedure
-- Session 14 · Lesson 8.2 · MySQL Foundations instructor kit
--
-- Milestone 5 of your project in miniature, on the bookstore. A clerk
-- adds a book to an order by calling add_order_item(order, book, copies).
-- The shop's rules:
--   a. the order and the book must exist             (look at other rows)
--   b. the book must be in stock                     (another row)
--   c. the same book only once per order             (other rows)
--   d. at most 3 different books per order           (other rows: count)
--   e. 1 to 10 copies per line                       (THIS row only)
-- The procedure below runs but enforces only "the order exists". Each TODO
-- adds one rule. Rule e is different: it looks at one row, so it belongs
-- in a CHECK constraint (TODO 1), not in the procedure.
--
--   SOURCE labs/module-14/l8_2-final-project/add_item_rules_starter.sql
-- The two calls at the end must keep working. Then prove every rule with
-- debug_add_item_rules.sql: each of its bad calls must be refused.
-- =====================================================================

-- 1. TODO 1: the single-row rule as a named constraint. Remove the -- from
--    both lines (and from the matching line in the cleanup at the end).
-- ALTER TABLE order_items
--     ADD CONSTRAINT chk_items_quantity CHECK (quantity BETWEEN 1 AND 10);

-- 2. Rules that look at other rows belong in the procedure that writes
DROP PROCEDURE IF EXISTS add_order_item;

DELIMITER //

CREATE PROCEDURE add_order_item(IN p_order_id INT, IN p_book_id INT, IN p_quantity INT)
BEGIN
    DECLARE v_customer INT;
    DECLARE v_price    DECIMAL(8, 2);
    DECLARE v_in_stock TINYINT;
    DECLARE v_lines    INT;
    -- TODO 2a: a failed rule must undo everything and tell the caller why.
    --   Declare an EXIT HANDLER FOR SQLEXCEPTION whose body is
    --   ROLLBACK; RESIGNAL;  (Lesson 7.2's pattern)

    START TRANSACTION;

    -- TODO 2b: two clerks adding to the same order at once must not both
    --   pass the checks below. Add FOR UPDATE to this SELECT (it locks the
    --   order's row until COMMIT).
    SELECT customer_id INTO v_customer FROM orders WHERE id = p_order_id;
    IF v_customer IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No such order';
    END IF;

    SELECT price, in_stock INTO v_price, v_in_stock FROM books WHERE id = p_book_id;
    -- TODO 3: refuse a book that does not exist ('No such book') and a book
    --   that is not in stock ('Book is out of stock'): IF ... ELSEIF ... END IF;

    -- TODO 4: refuse a book that is already on this order
    --   ('Book is already on this order'): IF EXISTS (SELECT 1 FROM ...)

    -- TODO 5: an order holds at most 3 different books. Count the order's
    --   lines INTO v_lines, then SIGNAL 'An order holds at most 3 different books'.

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

-- Expected when done (the same as now, because both calls are allowed):
-- item 19 (1984, 9.99) and item 20 (The Hobbit, 10.99); order 3 then
-- lists 4 Dune 1 14.99, 19 1984 1 9.99, 20 The Hobbit 2 10.99; the
-- routine is a PROCEDURE with SECURITY_TYPE DEFINER. The difference shows
-- in debug_add_item_rules.sql: every bad call refused with its own message.

-- Cleanup: the bookstore as it was
DELETE FROM order_items WHERE order_id = 3 AND book_id IN (2, 6);
-- ALTER TABLE order_items DROP CHECK chk_items_quantity;   -- with TODO 1
DROP PROCEDURE add_order_item;
