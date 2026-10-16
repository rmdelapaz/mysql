-- state: full
-- =====================================================================
-- functions_solution.sql: two stored functions and their characteristics (reference solution)
-- Session 10 · Lesson 7.1 · MySQL Foundations instructor kit
--
-- shipping_fee() is pure arithmetic (DETERMINISTIC, NO SQL); copies_sold()
-- reads tables whose rows change (READS SQL DATA, not DETERMINISTIC).
-- Binary logging is on by default in MySQL 8.0 and later, so a function
-- without one of those characteristics is refused (error 1418).
-- Both are used inside ordinary queries. Rerunnable (DROP ... IF EXISTS).
-- =====================================================================

-- 1. Shipping: 4.99 for one item, 1.00 more for each extra item, free from 5 items
DROP FUNCTION IF EXISTS shipping_fee;
DELIMITER //
CREATE FUNCTION shipping_fee(p_items INT)
RETURNS DECIMAL(6, 2)
DETERMINISTIC
NO SQL
BEGIN
    IF p_items >= 5 THEN
        RETURN 0.00;
    END IF;
    RETURN 4.99 + (p_items - 1) * 1.00;
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

-- 2. Copies sold of one book: reads order_items, so READS SQL DATA
DROP FUNCTION IF EXISTS copies_sold;
DELIMITER //
CREATE FUNCTION copies_sold(p_book_id INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_copies INT;
    SELECT COALESCE(SUM(quantity), 0) INTO v_copies
    FROM order_items
    WHERE book_id = p_book_id;
    RETURN v_copies;
END //
DELIMITER ;

SELECT title, copies_sold(id) AS copies
FROM books
WHERE author_id IN (2, 4, 6)
ORDER BY copies DESC, title;

-- 3. A function works anywhere an expression does: here in WHERE
SELECT title
FROM books
WHERE copies_sold(id) = 0
ORDER BY title;

-- 4. What MySQL recorded about both
SELECT ROUTINE_NAME, IS_DETERMINISTIC, SQL_DATA_ACCESS
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'bookstore' AND ROUTINE_TYPE = 'FUNCTION'
  AND ROUTINE_NAME IN ('shipping_fee', 'copies_sold')
ORDER BY ROUTINE_NAME;
