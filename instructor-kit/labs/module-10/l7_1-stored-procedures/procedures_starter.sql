-- state: full
-- =====================================================================
-- procedures_starter.sql: three procedures for the store's admin page
-- Session 10 · Lesson 7.1 · MySQL Foundations instructor kit
--
-- A procedure that returns a result set (IN), one that hands values back
-- (OUT), and one that changes data only after checking its input (SIGNAL).
-- DELIMITER // ... // ... DELIMITER ; lets the client send a whole body at
-- once. Every routine is preceded by DROP ... IF EXISTS, so you can edit,
-- save and SOURCE this file as often as you like:
--   SOURCE labs/module-10/l7_1-stored-procedures/procedures_starter.sql
-- =====================================================================

-- TODO 1 · category_shelf works, but for every category at once. Add the
-- condition that keeps only the category named in the parameter:
--   WHERE c.name = p_category    (above the ORDER BY line)
-- and delete the LIMIT 3 line (it only keeps the output short until then).
DROP PROCEDURE IF EXISTS category_shelf;
DELIMITER //
CREATE PROCEDURE category_shelf(IN p_category VARCHAR(50))
BEGIN
    SELECT b.title, b.price
    FROM categories AS c
    JOIN book_categories AS bc ON bc.category_id = c.id
    JOIN books           AS b  ON b.id = bc.book_id
    ORDER BY b.price, b.title
    LIMIT 3;
END //
DELIMITER ;

CALL category_shelf('Dystopian');

-- TODO 2 · author_stats fills p_books. Add the second OUT parameter's query:
--   SELECT COALESCE(SUM(oi.quantity), 0) INTO p_copies
--   FROM order_items AS oi JOIN books AS b ON b.id = oi.book_id
--   WHERE b.author_id = p_author_id;
-- (Why COALESCE? Try author 10, Isaac Asimov, without it.)
DROP PROCEDURE IF EXISTS author_stats;
DELIMITER //
CREATE PROCEDURE author_stats(
    IN  p_author_id INT,
    OUT p_books     INT,
    OUT p_copies    INT
)
BEGIN
    SELECT COUNT(*) INTO p_books
    FROM books
    WHERE author_id = p_author_id;
    SET p_copies = -1;   -- TODO 2: replace this line
END //
DELIMITER ;

CALL author_stats(2, @orwell_books, @orwell_copies);
CALL author_stats(10, @asimov_books, @asimov_copies);
SELECT @orwell_books AS orwell_books, @orwell_copies AS orwell_copies,
       @asimov_books AS asimov_books, @asimov_copies AS asimov_copies;

-- TODO 3 · raise_price changes a price by a percentage. It already refuses a
-- missing book. Add the first guard, BEFORE the other one: if p_percent is
-- NULL, below 1 or above 50, SIGNAL SQLSTATE '45000' with the message
-- 'Percent must be between 1 and 50'. Then test it at the mysql> prompt:
--   CALL raise_price(6, 80);    -- expect ERROR 1644 and no change
DROP PROCEDURE IF EXISTS raise_price;
DELIMITER //
CREATE PROCEDURE raise_price(IN p_book_id INT, IN p_percent INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM books WHERE id = p_book_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No book with that id';
    END IF;
    UPDATE books
    SET price = ROUND(price * (100 + p_percent) / 100, 2)
    WHERE id = p_book_id;
END //
DELIMITER ;

-- A good call, inside a transaction we roll back (predict both prices)
START TRANSACTION;
CALL raise_price(6, 10);
SELECT id, title, price FROM books WHERE id = 6;
ROLLBACK;
SELECT id, title, price FROM books WHERE id = 6;

-- 4. What this file built
SELECT ROUTINE_NAME, ROUTINE_TYPE
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'bookstore'
  AND ROUTINE_NAME IN ('category_shelf', 'author_stats', 'raise_price')
ORDER BY ROUTINE_NAME;

-- Expected when done:
-- TODO 1  Dystopian: Brave New World 9.49, 1984 9.99, Fahrenheit 451 10.49
--         (as shipped: the three cheapest books of ANY category; remove LIMIT 3 when you add the WHERE)
-- TODO 2  orwell_books 2, orwell_copies 6, asimov_books 0, asimov_copies 0
-- TODO 3  CALL raise_price(6, 80); prints ERROR 1644 (45000): Percent must be between 1 and 50
-- 3       The Hobbit 12.09 inside the transaction, 10.99 after ROLLBACK
-- 4       author_stats, category_shelf, raise_price: all PROCEDURE
