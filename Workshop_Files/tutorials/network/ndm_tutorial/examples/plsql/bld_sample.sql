--- This sample is taken from Topology Manual 1.12.2

--- create spatial tables of geometry features
CREATE TABLE city_streets_geom (
  name VARCHAR2(30) PRIMARY KEY,
  geometry SDO_GEOMETRY);

--- Update the Spatial metadata (USER_SDO_GEOM_METADATA)
INSERT INTO user_sdo_geom_metadata
    (TABLE_NAME,
     COLUMN_NAME,
     DIMINFO,
     SRID)
  VALUES (
    'CITY_STREETS_GEOM',
    'GEOMETRY',
    SDO_DIM_ARRAY(
      SDO_DIM_ELEMENT('X', 0, 65, 0.005),
      SDO_DIM_ELEMENT('Y', 0, 45, 0.005)
      ),
    NULL -- SRID
  );
  
--- Load data into the spatial tables.
-- R1
INSERT INTO city_streets_geom VALUES('R1',
  SDO_GEOMETRY(2002, NULL, NULL, SDO_ELEM_INFO_ARRAY(1, 2, 1),
    SDO_ORDINATE_ARRAY(9,14, 21,14, 35,14, 47,14)));
 
-- R2
INSERT INTO city_streets_geom VALUES('R2',
  SDO_GEOMETRY(2002, NULL, NULL, SDO_ELEM_INFO_ARRAY(1, 2, 1),
    SDO_ORDINATE_ARRAY(36,38, 38,35, 41,34, 42,33, 45,32, 47,28, 50,28,
52,32,
57,33, 57,36, 59,39, 61,38, 62,41, 47,42, 45,40, 41,40)));
 
-- R3
INSERT INTO city_streets_geom VALUES('R3',
  SDO_GEOMETRY(2002, NULL, NULL, SDO_ELEM_INFO_ARRAY(1, 2, 1),
    SDO_ORDINATE_ARRAY(9,35, 13,35)));
 
-- R4
INSERT INTO city_streets_geom VALUES('R4',
  SDO_GEOMETRY(2002, NULL, NULL, SDO_ELEM_INFO_ARRAY(1, 2, 1),
    SDO_ORDINATE_ARRAY(25,30, 25,35)));
    
--- Validate the spatial data (validate the layers).
create table val_results (sdo_rowid ROWID, result VARCHAR2(2000));
call
SDO_GEOM.VALIDATE_LAYER_WITH_CONTEXT('CITY_STREETS_GEOM','GEOMETRY','VAL_RESUL
TS');
SELECT * from val_results;
drop table val_results;

--- Create the spatial indexes.
CREATE INDEX city_streets_geom_idx ON city_streets_geom(geometry)
  INDEXTYPE IS MDSYS.SPATIAL_INDEX; 
