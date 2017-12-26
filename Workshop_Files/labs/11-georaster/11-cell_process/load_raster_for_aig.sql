connect / as sysdba

--
-- Do this only one time
--
EXECUTE MDSYS.enableGeoRaster;

exit;



connect aig/aig

DROP TABLE final_all;
DROP TABLE final_civ;
DROP TABLE final_trr;
DROP TABLE final_war;
DROP TABLE ea_spatial;

CREATE TABLE final_all (rid NUMBER, georaster SDO_GEORASTER);
CREATE TABLE final_civ (rid NUMBER, georaster SDO_GEORASTER);
CREATE TABLE final_trr (rid NUMBER, georaster SDO_GEORASTER);
CREATE TABLE final_war (rid NUMBER, georaster SDO_GEORASTER);
CREATE TABLE ea_spatial (rid NUMBER, georaster SDO_GEORASTER);


--
-- Create a raster data tables.
--
DROP TABLE final_all_rdt_01;
DROP TABLE final_civ_rdt_01;
DROP TABLE final_trr_rdt_01;
DROP TABLE final_war_rdt_01;
DROP TABLE ea_spatial_rdt_01;

CREATE TABLE final_all_rdt_01 OF SDO_RASTER
  (PRIMARY KEY (
     rasterId, 
     pyramidLevel, 
     bandBlockNumber,
     rowBlockNumber, 
     columnBlockNumber))
  LOB(rasterblock) STORE AS SECUREFILE final_all_lobseg (NOCACHE NOLOGGING PCTVERSION 0);

CREATE TABLE final_civ_rdt_01 OF SDO_RASTER
  (PRIMARY KEY (
     rasterId, 
     pyramidLevel, 
     bandBlockNumber,
     rowBlockNumber, 
     columnBlockNumber))
  LOB(rasterblock) STORE AS SECUREFILE final_civ_lobseg (NOCACHE NOLOGGING PCTVERSION 0);

CREATE TABLE final_trr_rdt_01 OF SDO_RASTER
  (PRIMARY KEY (
     rasterId, 
     pyramidLevel, 
     bandBlockNumber,
     rowBlockNumber, 
     columnBlockNumber))
  LOB(rasterblock) STORE AS SECUREFILE final_trr_lobseg (NOCACHE NOLOGGING PCTVERSION 0);

CREATE TABLE final_war_rdt_01 OF SDO_RASTER
  (PRIMARY KEY (
     rasterId, 
     pyramidLevel, 
     bandBlockNumber,
     rowBlockNumber, 
     columnBlockNumber))
  LOB(rasterblock) STORE AS SECUREFILE final_war_lobseg (NOCACHE NOLOGGING PCTVERSION 0);

CREATE TABLE ea_spatial_rdt_01 OF SDO_RASTER
  (PRIMARY KEY (
     rasterId, 
     pyramidLevel, 
     bandBlockNumber,
     rowBlockNumber, 
     columnBlockNumber))
  LOB(rasterblock) STORE AS SECUREFILE ea_spatial_lobseg (NOCACHE NOLOGGING PCTVERSION 0);

SET SERVEROUTPUT ON
DECLARE
  dimensionSize    sdo_number_array;
  blockSize        sdo_number_array;
BEGIN
  dimensionSize:=sdo_number_array(335,479,1);
  blockSize:=sdo_number_array(512,512,1);
  sdo_geor_utl.calcOptimizedBlockSize(dimensionSize,blockSize);
  dbms_output.put_line('Optimized rowBlockSize = '||blockSize(1));
  dbms_output.put_line('Optimized colBlockSize = '||blockSize(2));
  dbms_output.put_line('Optimized bandBlockSize = '||blockSize(3));
END;
/

exit;


--
-- The INSERT create option makes a call to SDO_GEOR.INIT to intialize the raster.
-- On windows, the continuation character is ^, on UNIX or Linux it's \.
--
gdal_translate -of georaster US_NJ_All.tif \
               georaster:aig/aig,,final_all,georaster \
               -co "INSERT=VALUES(1, SDO_GEOR.INIT('final_all_rdt_01',1))" \
               -co "BLOCKXSIZE=335" -co "BLOCKYSIZE=479" 


gdal_translate -of georaster US_NJ_Civ.tif \
               georaster:aig/aig,,final_civ,georaster \
               -co "INSERT=VALUES(1, SDO_GEOR.INIT('final_civ_rdt_01',1))" \
               -co "BLOCKXSIZE=335" -co "BLOCKYSIZE=479" 


gdal_translate -of georaster US_NJ_Trr.tif \
               georaster:aig/aig,,final_trr,georaster \
               -co "INSERT=VALUES(1, SDO_GEOR.INIT('final_trr_rdt_01',1))" \
               -co "BLOCKXSIZE=335" -co "BLOCKYSIZE=479" 


gdal_translate -of georaster US_NJ_War.tif \
               georaster:aig/aig,,final_war,georaster \
               -co "INSERT=VALUES(1, SDO_GEOR.INIT('final_war_rdt_01',1))" \
               -co "BLOCKXSIZE=335" -co "BLOCKYSIZE=479" 


sqlplus aig/aig

SELECT sdo_geor.validateGeoraster (georaster) FROM final_all;
SELECT sdo_geor.validateGeoraster (georaster) FROM final_civ;
SELECT sdo_geor.validateGeoraster (georaster) FROM final_trr;
SELECT sdo_geor.validateGeoraster (georaster) FROM final_war;


TRUNCATE TABLE ea_spatial;
-- Merge rasters into one layer
declare
 gr1 sdo_georaster;
 gr2 sdo_georaster;
begin
 -- Create 
 insert into ea_spatial(rid, georaster) values (1, sdo_geor.init('ea_spatial_rdt_01',1))
    returning georaster into gr1;

 select georaster into gr2 from final_all where rid=1;
 sdo_geor.copy (gr2, gr1);

 select georaster into gr2 from final_civ where rid=1;
 sdo_geor.mergelayers(gr1, gr2);

 select georaster into gr2 from final_trr where rid=1;
 sdo_geor.mergelayers(gr1, gr2);

 select georaster into gr2 from final_war where rid=1;
 sdo_geor.mergelayers(gr1, gr2);

 gr1.spatialextent := sdo_geor.generateSpatialExtent(gr1);

 update ea_spatial set georaster=gr1 where rid=1;
 commit;
end;
/


--
-- Populate metadata to creata a spatial index on the spatial extents
--
DELETE FROM user_sdo_geom_metadata 
  WHERE table_name = 'FINAL_ALL'
    AND column_name = 'GEORASTER.SPATIALEXTENT'; 
INSERT INTO user_sdo_geom_metadata VALUES
  ('FINAL_ALL', 'GEORASTER.SPATIALEXTENT',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', -180, 180, .05),
                  SDO_DIM_ELEMENT('Y', -90, 90, .05)),
    4326);
commit;

DELETE FROM user_sdo_geom_metadata 
  WHERE table_name = 'FINAL_CIV'
    AND column_name = 'GEORASTER.SPATIALEXTENT'; 
INSERT INTO user_sdo_geom_metadata VALUES
  ('FINAL_CIV', 'GEORASTER.SPATIALEXTENT',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', -180, 180, .05),
                  SDO_DIM_ELEMENT('Y', -90, 90, .05)),
    4326);
commit;

DELETE FROM user_sdo_geom_metadata 
  WHERE table_name = 'FINAL_TRR'
    AND column_name = 'GEORASTER.SPATIALEXTENT'; 
INSERT INTO user_sdo_geom_metadata VALUES
  ('FINAL_TRR', 'GEORASTER.SPATIALEXTENT',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', -180, 180, .05),
                  SDO_DIM_ELEMENT('Y', -90, 90, .05)),
    4326);
commit;

DELETE FROM user_sdo_geom_metadata 
  WHERE table_name = 'FINAL_WAR'
    AND column_name = 'GEORASTER.SPATIALEXTENT'; 
INSERT INTO user_sdo_geom_metadata VALUES
  ('FINAL_WAR', 'GEORASTER.SPATIALEXTENT',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', -180, 180, .05),
                  SDO_DIM_ELEMENT('Y', -90, 90, .05)),
    4326);
commit;

DELETE FROM user_sdo_geom_metadata 
  WHERE table_name = 'EA_SPATIAL'
    AND column_name = 'GEORASTER.SPATIALEXTENT'; 
INSERT INTO user_sdo_geom_metadata VALUES
  ('EA_SPATIAL', 'GEORASTER.SPATIALEXTENT',
    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', -180, 180, .05),
                  SDO_DIM_ELEMENT('Y', -90, 90, .05)),
    4326);
commit;


--
-- Create spatial indexes on the spatial extents
--
DROP INDEX final_all_sidx;
CREATE INDEX final_all_sidx ON final_all(georaster.spatialExtent)
  INDEXTYPE IS mdsys.spatial_index;

DROP INDEX final_civ_sidx;
CREATE INDEX final_civ_sidx ON final_civ(georaster.spatialExtent)
  INDEXTYPE IS mdsys.spatial_index;

DROP INDEX final_trr_sidx;
CREATE INDEX final_trr_sidx ON final_trr(georaster.spatialExtent)
  INDEXTYPE IS mdsys.spatial_index;

DROP INDEX final_war_sidx;
CREATE INDEX final_war_sidx ON final_war(georaster.spatialExtent)
  INDEXTYPE IS mdsys.spatial_index;

DROP INDEX ea_spatial_sidx;
CREATE INDEX ea_spatial_sidx ON ea_spatial(georaster.spatialExtent)
  INDEXTYPE IS mdsys.spatial_index;


--
-- Create and populate the epop_test_locs table.
--
DROP TABLE epop_test_locs;
CREATE TABLE epop_test_locs (locid NUMBER primary key, latitude NUMBER, longitude NUMBER);

DECLARE
  i NUMBER := 1;
BEGIN
  
  FOR r IN 1 .. 200 LOOP
    insert into EPOP_TEST_LOCS values (i, 41.041932, -74.653172);
    insert into EPOP_TEST_LOCS values (i+1, 39.92387,-75.025859);
    insert into EPOP_TEST_LOCS values (i+2, 39.664245,-74.427047);
    insert into EPOP_TEST_LOCS values (i+3, 40.166745,-74.519172);
    insert into EPOP_TEST_LOCS values (i+4, 40.903745,-74.636422);
    insert into EPOP_TEST_LOCS values (i+5, 39.03612,-74.908609);
    insert into EPOP_TEST_LOCS values (i+6, 41.259682,-74.661547);
    insert into EPOP_TEST_LOCS values (i+7, 40.782307,-74.058547);
    insert into EPOP_TEST_LOCS values (i+8, 40.937245,-73.974797);
    insert into EPOP_TEST_LOCS values (i+9, 39.944807,-75.122172);
    insert into EPOP_TEST_LOCS values (i+10, 39.400432,-74.766234);
    insert into EPOP_TEST_LOCS values (i+11, 40.706932,-75.176609);
    i := i + 12;
  END LOOP;
END;
/
COMMIT;



-------------------------------------------------------------------------
--
-- Create the parallel enabled pipelined table function
--
-------------------------------------------------------------------------


--
-- Create a type that contains the columns you want return.
--
DROP TYPE ea_score_table_type;
CREATE OR REPLACE TYPE ea_score_type AS OBJECT (
  locid        NUMBER,
  ea_score_all NUMBER,
  ea_score_civ NUMBER,
  ea_score_trr NUMBER,
  ea_score_war NUMBER)
/

CREATE OR REPLACE TYPE ea_score_table_type AS TABLE OF ea_score_type;
/

----------------------------
-- Package spec           --
----------------------------
CREATE OR REPLACE PACKAGE utils AS

  --
  -- Define a type that contains a record returned by source_table_cursor.
  --   This is an example of a strongly typed cursor.
  --   Strongly typed cursors parallelize better.
  --
  TYPE epop_test_locs_row_type IS RECORD (locid     NUMBER,
                                          latitude  NUMBER,
                                          longitude NUMBER);
  TYPE epop_test_locs_cursor_type IS REF CURSOR RETURN epop_test_locs_row_type; 


  --------------------------------------------------------------------------------
  --
  --------------------------------------------------------------------------------
  FUNCTION get_epop_results (source_table_cursor IN EPOP_TEST_LOCS_CURSOR_TYPE)
                             RETURN ea_score_table_type DETERMINISTIC
                             PIPELINED PARALLEL_ENABLE 
                                       (PARTITION source_table_cursor BY HASH (locid));

END;
/


----------------------------
-- Package body           --
----------------------------
CREATE OR REPLACE PACKAGE BODY utils AS

  TYPE num_table_type  IS TABLE OF NUMBER;
  TYPE geom_table_type IS TABLE OF SDO_GEOMETRY;

  --------------------------------------------------------------------------------
  --
  --------------------------------------------------------------------------------
  FUNCTION get_epop_results (source_table_cursor IN EPOP_TEST_LOCS_CURSOR_TYPE)
                             RETURN ea_score_table_type DETERMINISTIC
                             PIPELINED PARALLEL_ENABLE 
                                     (PARTITION source_table_cursor BY HASH (locid)) AS

    locid_table  NUM_TABLE_TYPE; 
    lat_table    NUM_TABLE_TYPE; 
    lon_table    NUM_TABLE_TYPE; 
    cell_values  SDO_NUMBER_ARRAY;
    gr           SDO_GEORASTER;
    
  BEGIN
    LOOP
      FETCH source_table_cursor 
      BULK COLLECT INTO locid_table,
                        lat_table,
                        lon_table
                        LIMIT 100;

      -- Exit when no rows were fetched.
      EXIT WHEN locid_table.count = 0;

      FOR i IN locid_table.first .. locid_table.last LOOP

        SELECT georaster 
        INTO gr
        FROM ea_spatial ea
        WHERE SDO_ANYINTERACT (ea.georaster.spatialextent, 
                               sdo_geometry(2001,4326,sdo_point_type(lon_table(i),lat_table(i),null),
                               null,null)) = 'TRUE';

        -- Get the cell values for all 4 layers in one call.
        cell_values := 
          sdo_geor.getCellValue (gr,
                                 0,
                                 sdo_geometry(2001,4326,sdo_point_type(lon_table(i),lat_table(i),null),null,null),
                                 '1-4');


        PIPE ROW (ea_score_type (locid_table(i),
                                 cell_values(1),
                                 cell_values(2),
                                 cell_values(3),
                                 cell_values(4)));

      END LOOP;

      -- Exit when less than LIMIT rows were fetched.
      EXIT WHEN source_table_cursor%NOTFOUND;

    END LOOP;

    CLOSE source_table_cursor;
  END;

END;
/


--
-- Run the query
--
SELECT /*+ parallel (16) */ 
      a.*,
      case
        when a.ea_score_all > 3.1 then 'Severe'
        when a.ea_score_all > 2.3 then 'High'
        when a.ea_score_all > 1.5 then 'Elevated'
        when a.ea_score_all > 0.7 then 'Moderate'
        else 'Low'
      end as ea_risk_category_all
FROM TABLE (utils.get_epop_results(CURSOR (SELECT locid, latitude, longitude FROM epop_test_locs))) a;



select count(*)
from (
SELECT /*+ parallel (16) */ 
      a.*,
      case
        when a.ea_score_all > 3.1 then 'Severe'
        when a.ea_score_all > 2.3 then 'High'
        when a.ea_score_all > 1.5 then 'Elevated'
        when a.ea_score_all > 0.7 then 'Moderate'
        else 'Low'
      end as ea_risk_category_all
FROM TABLE (utils.get_epop_results(CURSOR (SELECT locid, latitude, longitude FROM epop_test_locs))) a);

