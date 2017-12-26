CREATE OR REPLACE function score_pipelined (source_table_cursor IN SYS_REFCURSOR)
RETURN location_score_table
  DETERMINISTIC
  PIPELINED
  PARALLEL_ENABLE (PARTITION source_table_cursor BY ANY)
IS
  -- Declare custom exceptions
  -- ORA-13415: invalid or out of scope point specification
  point_out_of_scope EXCEPTION;
  PRAGMA EXCEPTION_INIT(point_out_of_scope, -13415); 

  TYPE number_table_type          IS TABLE OF NUMBER;
  TYPE sdo_geometry_table_type    IS TABLE OF SDO_GEOMETRY;
  FETCH_LIMIT  NUMBER := 10000;
  id_table     NUMBER_TABLE_TYPE;
  geom_table   SDO_GEOMETRY_TABLE_TYPE;
  cell_values  SDO_NUMBER_ARRAY;
  gr           SDO_GEORASTER;
BEGIN
  LOOP
    -- Fetch a batch of locations to score
    FETCH source_table_cursor
      BULK COLLECT INTO id_table, geom_table
      LIMIT FETCH_LIMIT;
    EXIT WHEN id_table.count = 0;
    dbms_output.put_line ('Rows fetched: '||id_table.count);
    dbms_output.put_line ('From: '||id_table.first);
    dbms_output.put_line ('To: '||id_table.last);
    -- Process the batch of locations
    FOR i IN id_table.first .. id_table.last LOOP
      dbms_output.put_line ('Processing row('||i||'): '||id_table(i));

      -- Locate the raster that contains the location
      -- Need to handle two possible anomalies here
      -- 1) The point does not match any raster
      --    => return NULL values
      -- 2) The point matches multiple rasters
      --    => pick the first raster returned by the query       
      BEGIN
        SELECT r.georaster 
        INTO gr
        FROM us_rasters r
        WHERE SDO_ANYINTERACT (
          r.georaster.spatialextent, 
          geom_table(i)
        ) = 'TRUE'
        AND rownum = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          gr := NULL;  
      END;
      
      IF gr is not null THEN
        -- Get the scores from the selected raster
        -- Need to handle the case where the point is actually outside the raster
        BEGIN
          cell_values := 
            sdo_geor.getCellValue (
              georaster    => gr,
              pyramidlevel => 0,
              ptgeom       => geom_table(i),
              layers       => '1-3'
          );
        EXCEPTION
          WHEN point_out_of_scope THEN
            cell_values := SDO_NUMBER_ARRAY (null,null,null);
        END;
      ELSE
        cell_values := SDO_NUMBER_ARRAY (null,null,null);
      END IF;
      
      -- Send the result
      PIPE ROW (
        location_score (
          id_table(i),
          cell_values(1),
          cell_values(2),
          cell_values(3)
        )
      );
      dbms_output.put_line ('Processed row('||i||'): '||id_table(i));

    END LOOP;
      
    -- Exit when less than LIMIT rows were fetched.
    -- EXIT WHEN source_table_cursor%NOTFOUND;

  END LOOP;
  
  CLOSE source_table_cursor;

END;
/
show errors
