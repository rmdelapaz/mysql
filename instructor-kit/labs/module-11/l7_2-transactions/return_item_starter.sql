-- state: full
-- =====================================================================
-- return_item_starter.sql: a procedure that takes back one order line, all or nothing
-- Session 11 · Lesson 7.2 · MySQL Foundations instructor kit
--
-- A customer returns one order line. Three writes belong together: delete
-- the line, delete the order if it is now empty, and credit loyalty points
-- (one point per whole dollar). If any step fails, nothing may remain.
-- The procedure below runs, but it is not safe yet: it has no transaction,
-- no error handler, and it never credits the points. Each TODO adds one
-- piece. Run the file as shipped first and read the results.
--
--   SOURCE labs/module-11/l7_2-transactions/return_item_starter.sql
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
    -- TODO 1 · The error handler: turn on these five lines (remove the --).
    -- DECLARE EXIT HANDLER FOR SQLEXCEPTION
    -- BEGIN
    --     ROLLBACK;
    --     RESIGNAL;
    -- END;
    SELECT MIN(oi.order_id), MIN(o.customer_id), MIN(FLOOR(oi.quantity * oi.price_at_time))
      INTO v_order, v_customer, v_points
    FROM order_items AS oi
    JOIN orders AS o ON o.id = oi.order_id
    WHERE oi.id = p_item_id;
    IF v_order IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No such order line';
    END IF;
    -- TODO 2 · Put START TRANSACTION; here, and COMMIT; after TODO 3.
    DELETE FROM order_items WHERE id = p_item_id;
    DELETE FROM orders
    WHERE id = v_order
      AND NOT EXISTS (SELECT 1 FROM order_items WHERE order_id = v_order);
    -- TODO 3 · Credit the points: an UPDATE of loyalty that adds v_points for
    -- v_customer, then: IF ROW_COUNT() = 0 THEN SIGNAL SQLSTATE '45000'
    -- SET MESSAGE_TEXT = 'Customer has no loyalty account'; END IF;
END //
DELIMITER ;

-- Before: order 12 (Dave, customer 4) has two lines, order 2 (Alice) has one
SELECT (SELECT COUNT(*) FROM orders) AS orders, (SELECT COUNT(*) FROM order_items) AS items;

-- 1 · Dave returns Animal Farm (order line 17, 8.49)
CALL return_item(17);
-- 2 · Alice returns Pride and Prejudice (order line 3, 7.99): order 2 is now empty
CALL return_item(3);

SELECT (SELECT COUNT(*) FROM orders) AS orders, (SELECT COUNT(*) FROM order_items) AS items;
SELECT customer_id, points FROM loyalty WHERE customer_id IN (1, 4) ORDER BY customer_id;
SELECT id, customer_id FROM orders WHERE id IN (2, 12) ORDER BY id;

-- TODO 4 · Try to break it, at the prompt (not in this file: a failed CALL is
-- an ERROR). After each one, count orders and items again: nothing may change.
--   CALL return_item(99);   -- an order line that does not exist
--   CALL return_item(13);   -- Eve's line: Eve (customer 5) has no loyalty account
-- Without TODOs 1 to 3, the second call deletes Eve's line and THEN fails.

-- Expected when done: before 12 orders and 18 items; after the two good calls
-- 11 orders and 16 items; points 1: 307 and 4: 18; only order 12 (customer 4)
-- is left of orders 2 and 12. At the prompt: ERROR 1644 (45000): No such order
-- line, then ERROR 1644 (45000): Customer has no loyalty account, and the
-- counts are still 11 and 16.
