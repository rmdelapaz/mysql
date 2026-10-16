-- state: full
-- expect-error: 1050, 1288, 1369, 1356
-- =====================================================================
-- debug_views.sql: four view mistakes (deliberately broken handout)
-- Session 9 · Lesson 6.2 · MySQL Foundations instructor kit
--
-- Each section creates what it needs, then makes one mistake. Run the
-- file, read each ERROR line, and write the cause and the fix in your
-- workbook. Every change is refused, and the file removes its practice
-- views and table at the end, so you can run it again.
-- =====================================================================

DROP VIEW IF EXISTS v_dbg_cheap, v_dbg_counts, v_dbg_flyer_prices;
DROP TABLE IF EXISTS dbg_flyers;

-- A. Run a "create" twice
CREATE VIEW v_dbg_cheap AS
SELECT id, title, price FROM books WHERE price < 10
WITH CHECK OPTION;
CREATE VIEW v_dbg_cheap AS
SELECT id, title, price, in_stock FROM books WHERE price < 10
WITH CHECK OPTION;

-- B. Change a count through a grouped view
CREATE VIEW v_dbg_counts AS
SELECT author_id, COUNT(*) AS books FROM books GROUP BY author_id;
UPDATE v_dbg_counts SET books = 3 WHERE author_id = 1;

-- C. Raise 1984's price through the "cheap books" view
UPDATE v_dbg_cheap SET price = 12.99 WHERE id = 2;

-- D. Rename a column that a view uses
CREATE TABLE dbg_flyers (id INT PRIMARY KEY, headline VARCHAR(50), cost DECIMAL(6, 2));
INSERT INTO dbg_flyers VALUES (1, 'Summer sale', 0.15), (2, 'Author night', 0.20);
CREATE VIEW v_dbg_flyer_prices AS SELECT headline, cost FROM dbg_flyers;
ALTER TABLE dbg_flyers RENAME COLUMN cost TO unit_cost;
SELECT * FROM v_dbg_flyer_prices;

-- Nothing changed in books:
SELECT id, title, price FROM books WHERE id = 2;

DROP VIEW IF EXISTS v_dbg_cheap, v_dbg_counts, v_dbg_flyer_prices;
DROP TABLE IF EXISTS dbg_flyers;
