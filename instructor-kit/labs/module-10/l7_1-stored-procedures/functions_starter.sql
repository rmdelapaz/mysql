-- state: full
-- =====================================================================
-- functions_starter.sql: two stored functions and their characteristics
-- Session 10 · Lesson 7.1 · MySQL Foundations instructor kit
--
-- A stored function returns ONE value and is used inside a query, like a
-- built-in function. With binary logging on (the default since MySQL 8.0)
-- every function must say what it does: DETERMINISTIC, NO SQL or READS SQL
-- DATA, and the promise must be true. Rerunnable (DROP ... IF EXISTS):
--   SOURCE labs/module-10/l7_1-stored-procedures/functions_starter.sql
-- =====================================================================

-- TODO 1 · shipping_fee: 4.99 for one item, 1.00 more for each extra item,
-- free from 5 items. The function returns 4.99 whatever the count. Add the
-- free-shipping rule (IF p_items >= 5 THEN RETURN 0.00; END IF;) and change
-- the last RETURN to  4.99 + (p_items - 1) * 1.00
DROP FUNCTION IF EXISTS shipping_fee;
DELIMITER //
CREATE FUNCTION shipping_fee(p_items INT)
RETURNS DECIMAL(6, 2)
DETERMINISTIC
NO SQL
BEGIN
    RETURN 4.99;
END //
DELIMITER ;

SELECT o.id AS order_id,
       SUM(oi.quantity)               AS items,
       shipping_fee(SUM(oi.quantity)) AS shipping
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.id
WHERE o.customer_id IN (1, 4)
GROUP BY o.id
ORDER BY o.id;

-- TODO 2 · copies_sold reads order_items. Write it below, after the DROP line:
--   CREATE FUNCTION copies_sold(p_book_id INT) RETURNS INT
--   with the characteristic that is TRUE for it (not DETERMINISTIC: why?),
--   a local variable v_copies, SELECT COALESCE(SUM(quantity), 0) INTO v_copies
--   FROM order_items WHERE book_id = p_book_id; and RETURN v_copies.
-- Wrap it in DELIMITER // ... END // DELIMITER ; like shipping_fee.
-- Then remove the -- from the two queries that use it.
DROP FUNCTION IF EXISTS copies_sold;
SELECT 'TODO 2: create copies_sold' AS todo;
-- SELECT title, copies_sold(id) AS copies
-- FROM books
-- WHERE author_id IN (2, 4, 6)
-- ORDER BY copies DESC, title;
-- SELECT title
-- FROM books
-- WHERE copies_sold(id) = 0
-- ORDER BY title;

-- 4. What MySQL recorded about the functions
SELECT ROUTINE_NAME, IS_DETERMINISTIC, SQL_DATA_ACCESS
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'bookstore' AND ROUTINE_TYPE = 'FUNCTION'
  AND ROUTINE_NAME IN ('shipping_fee', 'copies_sold')
ORDER BY ROUTINE_NAME;

-- Expected when done:
-- TODO 1  orders 1, 2, 4, 8, 12 with 3, 1, 2, 1, 2 items: shipping 6.99, 4.99, 5.99, 4.99, 5.99
-- TODO 2  1984 4, The Hobbit 3, Animal Farm 2, Lord of the Rings 2, The Great Gatsby 0;
--         never sold: The Catcher in the Rye, The Great Gatsby
-- 4       copies_sold NO READS SQL DATA · shipping_fee YES NO SQL
