/* 

Generate high-order structures from detailed structures

The input is a table with US census blockgroups that looks like this:

  Name         Null?    Type
  ------------ -------- ------------------
  ID           NOT NULL NUMBER(38)
  GEOM                  SDO_GEOMETRY
  STATEFP               VARCHAR2(2)
  COUNTYFP              VARCHAR2(3)
  TRACTCE               VARCHAR2(6)
  BLKGRPCE              VARCHAR2(1)
  ALAND                 NUMBER(14)
  AWATER                NUMBER(14)

Each block group is uniquely identified by the combination of several columns:
- a state identifier: STATEFP  
- a county identifier within that state: COUNTYFP 
- a tract indentifier within the county: TRACTCE  
- a block group identifier within the tract: BLKGRPCE

We want to reconstruct the TRACT, COUNTY and STATE shapes from the block groups.

*/

alter session set spatial_vector_acceleration=true;

-- Generate the tracts from the block groups
create table us_tracts_g as
select statefp,countyfp,tractce, sdo_aggr_union(sdoaggrtype(geom,0.05)) geom
from us_blockgroups
group by statefp,countyfp,tractce;

-- Generate the counties from the tracts
create table us_counties_g as
select statefp,countyfp, sdo_aggr_union(sdoaggrtype(geom,0.05)) geom
from us_tracts_g
group by statefp,countyfp;

-- Generate the states from the counties
create table us_states_g as
select statefp, sdo_aggr_union(sdoaggrtype(geom,0.05)) geom
from us_counties_g
group by statefp;
