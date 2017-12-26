-----------------------------------------------------------------
-- 1. Add a CELL_ID column to the YELLOW_PAGES table
-----------------------------------------------------------------

ALTER TABLE yellow_pages
  ADD cell_id NUMBER;

-----------------------------------------------------------------
-- 2. Populate the cell ids from the partitioning grid
-----------------------------------------------------------------
 
-- Note: this can be long (30 seconds or more)
-- Elapsed: 00:00:32.08    

BEGIN
  FOR g IN (
    SELECT * FROM partitioning_grid
  )
  LOOP
    UPDATE yellow_pages p
    SET p.cell_id = g.cell_id
    WHERE sdo_filter (p.location, g.cell_geom) = 'TRUE';
  END LOOP;
END;
/
COMMIT;

-----------------------------------------------------------------
-- 3. See the results of the spatial distribution
-----------------------------------------------------------------

SELECT cell_id, count(*)
FROM yellow_pages
GROUP BY cell_id
ORDER BY cell_id;
