-- Plain OLTP compression
CREATE TABLE us_cities_c   	COMPRESS AS SELECT * FROM us_cities;
CREATE TABLE us_counties_c 	COMPRESS AS SELECT * FROM us_counties;
CREATE TABLE us_states_c   	COMPRESS AS SELECT * FROM us_states;
CREATE TABLE us_interstates_c  	COMPRESS AS SELECT * FROM us_interstates;
CREATE TABLE us_parks_c 	COMPRESS AS SELECT * FROM us_parks;
CREATE TABLE us_rivers_c 	COMPRESS AS SELECT * FROM us_rivers;
CREATE TABLE world_countries_c 	COMPRESS AS SELECT * FROM world_countries;
CREATE TABLE world_continents_c COMPRESS AS SELECT * FROM world_continents;

-- LOB compression
CREATE TABLE us_cities_cb
VARRAY location.SDO_ORDINATES
  STORE AS SECUREFILE LOB (COMPRESS HIGH)
COMPRESS 
AS SELECT * FROM us_cities;
CREATE TABLE us_counties_cb
VARRAY geom.SDO_ORDINATES
  STORE AS SECUREFILE LOB (COMPRESS HIGH)
COMPRESS 
AS SELECT * FROM us_counties;

CREATE TABLE us_states_cb
VARRAY geom.SDO_ORDINATES
  STORE AS SECUREFILE LOB (COMPRESS HIGH)
COMPRESS 
AS SELECT * FROM us_states;

CREATE TABLE us_interstates_cb
VARRAY geom.SDO_ORDINATES
  STORE AS SECUREFILE LOB (COMPRESS HIGH)
COMPRESS 
AS SELECT * FROM us_interstates;

CREATE TABLE us_parks_cb
VARRAY geom.SDO_ORDINATES
  STORE AS SECUREFILE LOB (COMPRESS HIGH)
COMPRESS 
AS SELECT * FROM us_parks;

CREATE TABLE us_rivers_cb
VARRAY geom.SDO_ORDINATES
  STORE AS SECUREFILE LOB (COMPRESS HIGH)
COMPRESS 
AS SELECT * FROM us_rivers;

CREATE TABLE world_countries_cb
VARRAY geometry.SDO_ORDINATES
  STORE AS SECUREFILE LOB (COMPRESS HIGH)
COMPRESS 
AS SELECT * FROM world_countries;

CREATE TABLE world_continents_cb
VARRAY geometry.SDO_ORDINATES
  STORE AS SECUREFILE LOB (COMPRESS HIGH)
COMPRESS 
AS SELECT * FROM world_continents;

-- Check results
select t.table_name,
  (select s.bytes/1024/1024 from user_segments s where s.segment_name = t.table_name) base_mb,
  (select sum(s.bytes)/1024/1024 from user_lobs l, user_segments s where l.table_name = t.table_name and l.segment_name = s.segment_name) lob_mb
from user_tables t
where table_name like 'US_%'
or table_name like 'WORLD_%'
order by table_name;


