CREATE OR REPLACE function reverse_geocode_pipelined (source_table_cursor IN SYS_REFCURSOR)
RETURN gc_result_table
  DETERMINISTIC
  PIPELINED
  PARALLEL_ENABLE (PARTITION source_table_cursor BY ANY)
IS
  TYPE number_table IS TABLE OF NUMBER;
  TYPE string_table IS TABLE OF VARCHAR2(256);
  FETCH_LIMIT      number := 1000;
  id_table         number_table;
  geometry_table   SDO_GEOMETRY_ARRAY;
  country_table    string_table;
  gc               gc_result := gc_result(0,null,0);
BEGIN
  LOOP
    -- Fetch a batch of locations to process
    FETCH source_table_cursor
      BULK COLLECT INTO id_table, geometry_table, country_table 
      LIMIT FETCH_LIMIT;
    EXIT WHEN id_table.count = 0;

    -- Process the batch of locations
    FOR i IN id_table.first .. id_table.last LOOP
      gc.id := id_table(i);
      gc.geo_addr := SDO_GCDR.REVERSE_GEOCODE(
        user, geometry_table(i), country_table(i)
      );      
    END LOOP;
    
  END LOOP;
  CLOSE source_table_cursor;
  RETURN;
END;
/
show errors
