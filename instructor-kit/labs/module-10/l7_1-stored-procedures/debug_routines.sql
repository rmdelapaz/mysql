-- state: full
-- expect-error: 1064, 1418, 1172, 1304, 1644
-- =====================================================================
-- debug_routines.sql: five routine mistakes (deliberately broken handout)
-- Session 10 · Lesson 7.1 · MySQL Foundations instructor kit
--
-- Run it, read each ERROR line (section A prints two), and write in your
-- workbook what is wrong and the fix. Nothing in bookstore's data changes.
-- The file removes its practice routines at the start and at the end.
-- Section B needs binary logging, which is ON by default in MySQL 8.0 and
-- later (MariaDB and servers started with --skip-log-bin accept it).
-- =====================================================================

DROP PROCEDURE IF EXISTS dbg_out_of_stock;
DROP FUNCTION IF EXISTS dbg_author_count;
DROP PROCEDURE IF EXISTS dbg_title_by;
DROP PROCEDURE IF EXISTS dbg_count_books;
DROP PROCEDURE IF EXISTS dbg_set_pages;

-- A. A two-statement body, typed without changing the delimiter
CREATE PROCEDURE dbg_out_of_stock()
BEGIN
    SELECT title FROM books WHERE in_stock = FALSE;
END;

-- B. A function that reads a table, with no characteristics
CREATE FUNCTION dbg_author_count()
RETURNS INT
RETURN (SELECT COUNT(*) FROM authors);

-- C. One variable for an author's titles
DELIMITER //
CREATE PROCEDURE dbg_title_by(IN p_author_id INT, OUT p_title VARCHAR(200))
BEGIN
    SELECT title INTO p_title FROM books WHERE author_id = p_author_id;
END //
DELIMITER ;
CALL dbg_title_by(6, @title);

-- D. The script is run a second time
CREATE PROCEDURE dbg_count_books()
    SELECT COUNT(*) AS books FROM books;
CREATE PROCEDURE dbg_count_books()
    SELECT COUNT(*) AS books FROM books;

-- E. A procedure that guards its input, called with bad input
DELIMITER //
CREATE PROCEDURE dbg_set_pages(IN p_book_id INT, IN p_pages INT)
BEGIN
    IF p_pages IS NULL OR p_pages < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pages must be a positive number';
    END IF;
    UPDATE books SET pages = p_pages WHERE id = p_book_id;
END //
DELIMITER ;
CALL dbg_set_pages(10, 0);

-- Fahrenheit 451 still has its 158 pages:
SELECT id, title, pages FROM books WHERE id = 10;

DROP PROCEDURE IF EXISTS dbg_out_of_stock;
DROP FUNCTION IF EXISTS dbg_author_count;
DROP PROCEDURE IF EXISTS dbg_title_by;
DROP PROCEDURE IF EXISTS dbg_count_books;
DROP PROCEDURE IF EXISTS dbg_set_pages;
