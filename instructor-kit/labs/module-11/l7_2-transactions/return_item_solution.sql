-- state: full
-- =====================================================================
-- return_item_solution.sql: a procedure that takes back one order line, all or nothing
-- Session 11 · Lesson 7.2 · MySQL Foundations instructor kit · instructor reference
--
-- A customer returns one order line. Three writes belong together: delete
-- the line, delete the order if it is now empty, and credit loyalty points
-- (one point per whole dollar). If any step fails, nothing may remain.
-- The good calls are below; the failing calls are tested at the prompt
-- (see the end of the file), because a failed CALL is an ERROR.
-- =====================================================================

DROP TABLE IF EXISTS loyalty;
CREATE TABLE loyalty (
    customer_id INT PRIMARY KEY,
    points      INT NOT NULL,
    CONSTRAINT chk_points CHECK (points >= 0),
    CONSTRAINT fk_loyalty_customer FOREIGN KEY (customer_id) REFERENCES customers (id)
);
INSERT INTO loyalty (customer_id, points) VALUES (1, 300), (2, 120), (4, 10), (6, 40), (7, 0);

DROP PROCEDURE IF EXISTS return_item;
DELIMITER //
CREATE PROCEDURE return_item(IN p_item_id INT)
BEGIN
    DECLARE v_order    INT;
    DECLARE v_customer INT;
    DECLARE v_points   INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;   -- undo every write this call made
        RESIGNAL;   -- and tell the caller what went wrong
    END;
    SELECT MIN(oi.order_id), MIN(o.customer_id), MIN(FLOOR(oi.quantity * oi.price_at_time))
      INTO v_order, v_customer, v_points
    FROM order_items AS oi
    JOIN orders AS o ON o.id = oi.order_id
    WHERE oi.id = p_item_id;
    IF v_order IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No such order line';
    END IF;
    START TRANSACTION;
    DELETE FROM order_items WHERE id = p_item_id;
    DELETE FROM orders
    WHERE id = v_order
      AND NOT EXISTS (SELECT 1 FROM order_items WHERE order_id = v_order);
    UPDATE loyalty SET points = points + v_points WHERE customer_id = v_customer;
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer has no loyalty account';
    END IF;
    COMMIT;
END //
DELIMITER ;

-- Before: order 12 (Dave, customer 4) has two lines, order 2 (Alice) has one
SELECT (SELECT COUNT(*) FROM orders) AS orders, (SELECT COUNT(*) FROM order_items) AS items;

-- 1 · Dave returns Animal Farm (order line 17, 8.49): 8 points, order 12 keeps its other line
CALL return_item(17);
-- 2 · Alice returns Pride and Prejudice (order line 3, 7.99): order 2 is now empty and goes too
CALL return_item(3);

SELECT (SELECT COUNT(*) FROM orders) AS orders, (SELECT COUNT(*) FROM order_items) AS items;
SELECT customer_id, points FROM loyalty WHERE customer_id IN (1, 4) ORDER BY customer_id;
SELECT id, customer_id FROM orders WHERE id IN (2, 12) ORDER BY id;

-- Then, at the prompt, the calls that must FAIL and change nothing:
--   CALL return_item(99);   -- ERROR 1644 (45000): No such order line
--   CALL return_item(13);   -- ERROR 1644 (45000): Customer has no loyalty account
--                              (Eve, customer 5, has none: the delete is rolled back)
--   SELECT (SELECT COUNT(*) FROM orders) AS orders, (SELECT COUNT(*) FROM order_items) AS items;
--                           -- still 11 and 16
