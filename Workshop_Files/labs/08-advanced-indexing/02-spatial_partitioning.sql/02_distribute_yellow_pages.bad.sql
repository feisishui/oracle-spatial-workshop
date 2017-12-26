-- Following method is very slow: it does a full scan of yellow pages
-- and a spatial search into the grid for each row
-- resulting into 360600 point in polygon searches!
UPDATE yellow_pages p
SET cell_id = (
  SELECT g.cell_id
    FROM partitioning_grid g
   where sdo_filter (g.cell_geom, p.location) = 'TRUE'
     and rownum = 1
);
 
-- Following method is also very slow. Like the first approach, it does
-- a full scan of yellow pages and a spatial search into the grid for
-- each row resulting into 360600 point in polygon searches!
begin
  SDO_SAM.BIN_LAYER(
    'YELLOW_PAGES','LOCATION',
    'PARTITIONING_GRID','CELL_GEOM',
    'CELL_ID'
  );
end;
/

-- Following method fails:
-- ORA-13249: ... Error in join: check spatial table/indexes
-- ORA-06512: at "MDSYS.MD", line 1723
-- ORA-06512: at "MDSYS.MDERR", line 17
-- ORA-06512: at "MDSYS.SDO_JOIN", line 511
-- ORA-06512: at line 1
-- ORA-01427: single-row subquery returns more than one rupdate yellow_pages p
SET cell_id = (
  SELECT g.cell_id
    FROM partitioning_grid g,
         TABLE(
           SDO_JOIN(
             'YELLOW_PAGES', 'LOCATION',
             'PARTITIONING_GRID', 'CELL_GEOM'
           )
         ) j
  WHERE j.rowid1 = p.rowid
    AND j.rowid2 = g.rowid
);




