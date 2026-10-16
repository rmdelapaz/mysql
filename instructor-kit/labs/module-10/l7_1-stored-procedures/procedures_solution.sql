-- state: full
-- =====================================================================
-- procedures_solution.sql: three procedures for the store's admin page (reference solution)
-- Session 10 · Lesson 7.1 · MySQL Foundations instructor kit
--
-- A procedure that returns a result set (IN), one that hands values back
-- (OUT), and one that changes data only after checking its input (SIGNAL).
-- Every routine is preceded by DROP ... IF EXISTS, so the file can be run
-- again after every edit. The price change is made inside a transaction
-- and rolled back. The routines stay in bookstore until you reload it.
-- =====================================================================

-- 1. IN: the books of one category, cheapest first
DROP PROCEDURE IF EXISTS category_shelf;
DELIMITER //
CREATE PROCEDURE category_shelf(IN p_category VARCHAR(50))
BEGIN
    SELECT b.title, b.price
    FROM categories AS c
    JOIN book_categories AS bc ON bc.category_id = c.id
    JOIN books           AS b  ON b.id = bc.book_id
    WHERE c.name = p_category
    ORDER BY b.price, b.title;
END //
DELIMITER ;

CALL category_shelf('Dystopian');

-- 2. OUT: two answers about one author, through user variables
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
    SELECT COALESCE(SUM(oi.quantity), 0) INTO p_copies
    FROM order_items AS oi
    JOIN books AS b ON b.id = oi.book_id
    WHERE b.author_id = p_author_id;
END //
DELIMITER ;

CALL author_stats(2, @orwell_books, @orwell_copies);
CALL author_stats(10, @asimov_books, @asimov_copies);
SELECT @orwell_books AS orwell_books, @orwell_copies AS orwell_copies,
       @asimov_books AS asimov_books, @asimov_copies AS asimov_copies;

-- 3. Check, then change: raise a book's price by a percentage between 1 and 50
DROP PROCEDURE IF EXISTS raise_price;
DELIMITER //
CREATE PROCEDURE raise_price(IN p_book_id INT, IN p_percent INT)
BEGIN
    IF p_percent IS NULL OR p_percent < 1 OR p_percent > 50 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Percent must be between 1 and 50';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM books WHERE id = p_book_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No book with that id';
    END IF;
    UPDATE books
    SET price = ROUND(price * (100 + p_percent) / 100, 2)
    WHERE id = p_book_id;
END //
DELIMITER ;

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
