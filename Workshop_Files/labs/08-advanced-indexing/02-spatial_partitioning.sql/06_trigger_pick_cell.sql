CREATE OR REPLACE TRIGGER yellow_pages_pick_cell
  BEFORE INSERT OR UPDATE OF location ON yellow_pages_part_spatial
  FOR EACH ROW
DECLARE
  v_cell_id NUMBER;
BEGIN
  -- Find matching cell
  SELECT cell_id INTO v_cell_id
  FROM   partitioning_grid
  WHERE  sdo_filter (cell_geom, :NEW.location) = 'TRUE'
  AND    ROWNUM = 1;
  -- Fill cell ID
  :NEW.cell_id := v_cell_id;
END;
/
show errors
