-- File: us_cities.sql - Oracle version: 9.2
--
--   This script creates the spatial layer and populates the spatial metadata.
--
--   To load the table, run SQL*Loader with these parameters:
--       USERID=username/password CONTROL=us_cities.ctl
--
--   After the data is loaded in the us_cities table, 
--   create the spatial index by running script us_cities_sx.sql
--
-- Creation Date : Sat Dec 24 17:06:22 2005
-- Copyright 2003 Oracle Corporation
-- All rights reserved
--
DROP TABLE US_CITIES;

CREATE TABLE US_CITIES (
  ID 	NUMBER 
		CONSTRAINT US_CITIES_PK PRIMARY KEY, 
  CITY 	VARCHAR2(42), 
  STATE_ABRV 	VARCHAR2(2), 
  POP90 	NUMBER, 
  RANK90 	NUMBER, 
  LOCATION 	SDO_GEOMETRY
);

DELETE FROM USER_SDO_GEOM_METADATA 
WHERE TABLE_NAME = 'US_CITIES' AND COLUMN_NAME = 'LOCATION' ;

INSERT INTO USER_SDO_GEOM_METADATA (TABLE_NAME, COLUMN_NAME, DIMINFO, SRID) 
VALUES (
  'US_CITIES', 
  'LOCATION', 
  SDO_DIM_ARRAY (
    SDO_DIM_ELEMENT('X', -180, 180, 1), 
    SDO_DIM_ELEMENT('Y', -90, 90, 1)  
  ), 
  8307 
); 
COMMIT;
