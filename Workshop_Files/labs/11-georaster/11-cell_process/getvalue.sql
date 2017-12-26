alter table us_pois add red_flag number;

-------------------------------------------------------------------------------------
-- Physical queries
-------------------------------------------------------------------------------------

-- Get single band value for one raster
SELECT sdo_geor.getcellvalue(georaster,0,15,132,1) v
  FROM us_rasters 
 WHERE georid=1;

         V
----------
        38

1 row selected.

-- Get values for selected bands: a range
SELECT sdo_geor.getcellvalue(georaster,0,15,132,'0-2') v
  FROM us_rasters 
 WHERE georid=1;

V
---------------------------
SDO_NUMBER_ARRAY(9, 38, 8)

1 row selected.

-- Get values for selected bands: a list
SELECT sdo_geor.getcellvalue(georaster,0,15,132,'2,1,0') v
  FROM us_rasters 
 WHERE georid=1;

V
---------------------------
SDO_NUMBER_ARRAY(8, 38, 9)

1 row selected.

-- Get values for selected bands: a mix of ranges and lists
SELECT sdo_geor.getcellvalue(georaster,0,15,132,'2,0-2') v
  FROM us_rasters 
 WHERE georid=1;

SELECT sdo_geor.getcellvalue(georaster,0,15,132) v
  FROM us_rasters 
 WHERE georid=1;
 
-- Location outside the raster 
SELECT sdo_geor.getcellvalue(georaster,0,10000,10000,0)
  FROM us_rasters 
 WHERE georid=1;

ERROR at line 1:
ORA-13415: invalid or out of scope point specification
ORA-06512: at "MDSYS.SDO_GEOR_INT", line 6297
ORA-06512: at "MDSYS.SDO_GEOR", line 2627

-------------------------------------------------------------------------------------
-- Logical queries
-------------------------------------------------------------------------------------

-- Get single layer value 
SELECT sdo_geor.getcellvalue(georaster,0,sdo_geometry(2001, 4326, sdo_point_type(-122.44712, 37.79789, null), null, null), 1) v
  FROM us_rasters 
 WHERE georid=1;
 
         V
----------
        92

-- Get multiple layer values 
SELECT sdo_geor.getcellvalue(georaster,0,sdo_geometry(2001, 4326, sdo_point_type(-122.44712, 37.79789, null), null, null), '1-3') v
  FROM us_rasters 
 WHERE georid=1;

V
----------------------------
SDO_NUMBER_ARRAY(92, 82, 81)

1 row selected.

SELECT sdo_geor.getcellvalue(georaster,0,sdo_geometry(2001, 4326, sdo_point_type(-122.44712, 37.79789, null), null, null), '-') v FROM us_rasters WHERE georid=1;

