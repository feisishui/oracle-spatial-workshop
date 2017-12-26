/* 

NAME:         gc_areas.sql

LAST UPDATE:  08-Sep-2016
    
VERSION:      1.6

DESCRIPTION:

This package provide the functions used to extract the full set of area names that 
correspond to a geocoding result, i.e. return the area names at all administrative levels 
related to a given road returned by a geocode operation.
segment.

The package provides the following functions:

1) Function GET_NAMES

First variant: single geocoding result (from GEOCODE or GEOCODE_ADDR)

FUNCTION GET_NAMES RETURNS GC_AREA_NAMES
Argument Name                  Type                    In/Out Default?
------------------------------ ----------------------- ------ --------
GEO_ADDR                       SDO_GEO_ADDR            IN

This function takes a geocoding result as input (an SDO_GEO_ADDR object) and collects
the names of all administrative areas related to the geocoding result. 

It returns the names in a new object of type GC_AREA_NAMES:

 Name                                     Null?    Type
 ---------------------------------------- -------- ----------------------------
 AREA_NAME_1                                       VARCHAR2(200)
 AREA_NAME_2                                       VARCHAR2(200)
 AREA_NAME_3                                       VARCHAR2(200)
 AREA_NAME_4                                       VARCHAR2(200)
 AREA_NAME_5                                       VARCHAR2(200)
 AREA_NAME_6                                       VARCHAR2(200)
 AREA_NAME_7                                       VARCHAR2(200)
 
Second variant: multiple geocoding results (from GEOCODE_ALL or GEOCODE_ADDR_ALL)

FUNCTION GET_NAMES RETURNS GC_AREA_NAMES_ARRAY
Argument Name                  Type                    In/Out Default?
------------------------------ ----------------------- ------ --------
ADDR_ARRAY                     SDO_ADDR_ARRAY          IN

This variant returns an array of GC_AREA_NAMES: one element for each geocoding result (=
each element in the SDO_ADDR_ARRAY).

2) Function SET_NAMES

First variant: single geocoding result (from GEOCODE or GEOCODE_ADDR)

FUNCTION SET_NAMES RETURNS SDO_GEO_ADDR
Argument Name                  Type                    In/Out Default?
------------------------------ ----------------------- ------ --------
GEO_ADDR                       SDO_GEO_ADDR            IN

This function takes a geocoding result as input and completes it with the names of the 
administrative areas: it stores the names in the array ADDRESSLINES, currently
unused.

Second variant: multiple geocoding results (from GEOCODE_ALL or GEOCODE_ADDR_ALL)

FUNCTION SET_NAMES RETURNS SDO_ADDR_ARRAY
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 ADDR_ARRAY                     SDO_ADDR_ARRAY          IN

The second variant takes an SDO_ADDR_ARRAY object returned by a GEOCODE_ALL call, and
adds the administrative area names in each of the results in the array.

EXAMPLES OF USE:

1) A geocoding call:

SQL> select SDO_GCDR.GEOCODE(user, SDO_KEYWORDARRAY('altplatz', 'Heidelberg'), 'DE', 'DEFAULT') from dual;

SDO_GCDR.GEOCODE(USER,SDO_KEYWORDARRAY('ALTPLATZ','HEIDELBERG'),'DE','DEFAULT')
-------------------------------------------------------------------------------
SDO_GEO_ADDR(0, SDO_KEYWORDARRAY(), NULL, NULL, NULL, NULL, 'Heidelberg', NULL,
 'SACHSEN', 'DE', '09548', NULL, NULL, NULL, NULL, NULL, NULL, 'F', 'F', NULL,
NULL, 'L', 0, 554798592, '??????????B281CP?', 4, 'DEFAULT', 13.47275, 50.64326,
 '???11131310??404?', 8307)

2) Get the area names for that result:

SQL> select gc_areas.get_names(SDO_GCDR.GEOCODE(user, SDO_KEYWORDARRAY('altplatz', 'Heidelberg'), 'DE', 'DEFAULT')) from dual;

GC_AREAS.GET_NAMES(SDO_GCDR.GEOCODE(USER,SDO_KEYWORDARRAY('ALTPLATZ','HEIDELBER
-------------------------------------------------------------------------------
GC_AREA_NAMES('Deutschland', 'Sachsen', 'Erzgebirgskreis', 'Seiffen/Erzgeb.', '
Heidelberg', NULL, NULL)

3) Complete the geocoding with the area names:

SQL> select gc_areas.set_names(SDO_GCDR.GEOCODE(user, SDO_KEYWORDARRAY('altplatz', 'Heidelberg'), 'DE', 'DEFAULT')) from dual;

GC_AREAS.SET_NAMES(SDO_GCDR.GEOCODE(USER,SDO_KEYWORDARRAY('ALTPLATZ','HEIDELBER
-------------------------------------------------------------------------------
SDO_GEO_ADDR(0, SDO_KEYWORDARRAY('Deutschland', 'Sachsen', 'Erzgebirgskreis', '
Seiffen/Erzgeb.', 'Heidelberg', NULL, NULL), NULL, NULL, NULL, NULL, 'Heidelber
g', NULL, 'SACHSEN', 'DE', '09548', NULL, NULL, NULL, NULL, NULL, NULL, 'F', 'F
', NULL, NULL, 'L', 0, 554798592, '??????????B281CP?', 4, 'DEFAULT', 13.47275,
50.64326, '???11131310??404?', 8307)

SQL> select gc_areas.set_names(SDO_GCDR.GEOCODE(user, SDO_KEYWORDARRAY('20 rue robert soleau', 'antibes'), 'FR', 'DEFAULT')) from dual;

GC_AREAS.SET_NAMES(SDO_GCDR.GEOCODE(USER,SDO_KEYWORDARRAY('20RUEROBERTSOLEAU','
-------------------------------------------------------------------------------
SDO_GEO_ADDR(0, SDO_KEYWORDARRAY('France', 'Provence-Alpes-Côte d''Azur', 'Alpe
s-Maritimes', 'Antibes', 'Antibes', NULL, NULL), NULL, 'Avenue Robert Soleau',
NULL, NULL, 'Antibes', 'Antibes', 'PROVENCE-ALPES-CÔTE D''AZUR', 'FR', '06600',
 NULL, '06600', NULL, '20', 'ROBERT SOLEAU', 'AVENUE', 'T', 'F', NULL, NULL, 'R
', .52, 58336347, '??X?#ENU??B281CP?', 2, 'DEFAULT', 7.12057, 43.58198, '??0101
01210??404?', 8307)

SQL> select gc_areas.set_names(SDO_GCDR.GEOCODE(user, SDO_KEYWORDARRAY('50 rue de la paix', 'Paris'), 'FR', 'DEFAULT')) from dual;

GC_AREAS.SET_NAMES(SDO_GCDR.GEOCODE(USER,SDO_KEYWORDARRAY('50RUEDELAPAIX','PARI
-------------------------------------------------------------------------------
SDO_GEO_ADDR(0, SDO_KEYWORDARRAY('France', 'Île-de-France', 'Paris', 'Paris', '
2e Arrondissement', NULL, NULL), NULL, 'Rue de la Paix', NULL, NULL, NULL, 'Par
is', 'ÎLE-DE-FRANCE', 'FR', '75002', NULL, '75002', NULL, '25', 'PAIX', 'RUE DE
 LA', 'T', 'F', NULL, NULL, 'L', 0, 56240870, '?????ENUT?B281CP?', 3, 'DEFAULT'
, 2.33153, 48.86957, '???12101010??404?', 8307)


IMPLEMENTATION:

The process first matches the road segment whose identifier is returned in the
geocoding result, with its parent road. Then it matches the road with the 
settlement associated with that road.

Finally, it matches the settlement area with all the parent areas of that settlement.

The tables used:

GC_ROAD_SEGMENT_xxx
--------------------------
ROAD_ID             NUMBER
ROAD_SEGMENT_ID     NUMBER
...

GC_ROAD_xxx
--------------------------
ROAD_ID             NUMBER
SETTLEMENT_ID       NUMBER
MUNICIPALITY_ID     NUMBER
PARENT_AREA_ID      NUMBER
LANG_CODE           VARCHAR2(3)
....

GC_AREA_xxx
--------------------------
AREA_ID             NUMBER
AREA_NAME           VARCHAR2(64 CHAR)
LANG_CODE           VARCHAR2(3)
ADMIN_LEVEL         NUMBER
LEVEL1_AREA_ID      NUMBER
LEVEL2_AREA_ID      NUMBER
LEVEL3_AREA_ID      NUMBER
LEVEL4_AREA_ID      NUMBER
LEVEL5_AREA_ID      NUMBER
LEVEL6_AREA_ID      NUMBER
LEVEL7_AREA_ID      NUMBER
...

ISSUES

(1) Languages

A road segment can be present in multiple copies, each with a different road (different
ROAD_ID). This is incorrect according to our specification.

Roads can have multiple names in different languages, i.e. multiple rows with the same
ROAD_ID but different languages.

Areas also can have multiple names in different languages, i.e. multiple rows with the same
AREA_ID but different languages.

Solution:

Only return those area names in the same language as the language of the parent 
road. For multi-lingual countries, in the case a road exists with multiple names (in
different languages), the actual language of the geocoding result is detected by picking the
road record whose BASE_NAME matches the BASENAME of the geocoding result.

(2) Multiple names

Areas can also have multiple names in the same language. Some are real names, some are aliases
(identified as IS_ALIAS='T').

Solution: 

It appears that only one name exists per language that is a real name (IS_ALIAS='F'). Only 
select those names. If multiple names still exist, just pick one at random

(3) Roads without names

When the input to the geocoder is a postal code and/or city name only, or when the geocoder
does not find any match at all for the road name, then the result does not contain any road
information: no road name, no base name. The same may also happen for a reverse geocode when 
the coordinates fall close to an unnamed road. In those cases, finding the correct road record
by matching it with BASE_NAME is not possible.

Solution: 

Pick any of the matching road records solely based on ROAD_ID.

(4) Dynamic table names

The solution uses static SQL and assumes the geocoding tables are in the current schema.

In reality it should use dynamic SQL and build the table names from the proper suffix: 
find out the country code from the geocoding result, then lookup GC_COUNTRY_PROFILE for 
the proper suffix and use that to generate the table names.

CHANGE HISTORY:

  MODIFIED     (DD-MON-YYYY)  DESCRIPTION
  agodfrin      09-Sep-2016   Handle case where the geocoder returns a NULL result
  agodfrin      19-Aug-2016   Geocode result may not have a BASE_NAME
  agodfrin      19-Aug-2016   A road may be only in a municipality (but not in a settlement)
  agodfrin      19-Aug-2016   Added support for GEOCODE_ALL in GET_NAMES
  agodfrin      17-Aug-2016   Added support for GEOCODE_ALL in SET_NAMES
  agodfrin      17-Aug-2016   Add exception handling in GET_NAMES
  agodfrin      11-Aug-2016   Included BASE_NAME in road match
  agodfrin      10-Aug-2016   Included LANG_CODE in result
  agodfrin      09-Aug-2016   Created
  
TODO:

  (1) Use dynamic tables
  (2) Implement a more generic language handling

*/

create or replace type gc_area_names as
object (
  lang_code   varchar2(3),
  area_name_1 varchar2(200),
  area_name_2 varchar2(200),
  area_name_3 varchar2(200),
  area_name_4 varchar2(200),
  area_name_5 varchar2(200),
  area_name_6 varchar2(200),
  area_name_7 varchar2(200)
);
/

create or replace type gc_area_names_array as
varray (1000) of gc_area_names;
/

create or replace package gc_areas 
as 

function get_names (
  geo_addr sdo_geo_addr
)
return gc_area_names
deterministic;

function get_names (
  addr_array sdo_addr_array
)
return gc_area_names_array
deterministic;

function set_names (
  geo_addr sdo_geo_addr
)
return sdo_geo_addr
deterministic;

function set_names (
  addr_array sdo_addr_array
)
return sdo_addr_array
deterministic;

end;
/ 
show errors

create or replace package body gc_areas 
as 

function get_names (
  geo_addr sdo_geo_addr
)
return gc_area_names
deterministic
is
  a gc_area_names := null;
begin
  -- If no input, return nothing right away
  if geo_addr is null then
    return null;
  end if;
  -- Process the input
  begin
    -- Fetch the names for the road segment returned by the geocoder
    select gc_area_names(lang_code, area_name_1, area_name_2, area_name_3, area_name_4, area_name_5, area_name_6, area_name_7)
    into a
    from ( 
      select distinct
            r.lang_code,
            a1.real_name area_name_1,
            a2.real_name area_name_2,
            a3.real_name area_name_3,
            a4.real_name area_name_4,
            a5.real_name area_name_5,
            a6.real_name area_name_6,
            a7.real_name area_name_7
      from  gc_road_segment_nvt s,
            gc_road_nvt r,
            gc_area_nvt a,
            gc_area_nvt a1, 
            gc_area_nvt a2, 
            gc_area_nvt a3, 
            gc_area_nvt a4, 
            gc_area_nvt a5, 
            gc_area_nvt a6,
            gc_area_nvt a7
      where r.road_id = s.road_id
      and   r.base_name = nvl(geo_addr.basename,r.base_name)
      and   a.area_id = coalesce(r.settlement_id,r.municipality_id)
      and   a1.area_id (+) = nvl(a.level1_area_id,-1) 
      and   a2.area_id (+) = nvl(a.level2_area_id,-1) 
      and   a3.area_id (+) = nvl(a.level3_area_id,-1) 
      and   a4.area_id (+) = nvl(a.level4_area_id,-1) 
      and   a5.area_id (+) = nvl(a.level5_area_id,-1) 
      and   a6.area_id (+) = nvl(a.level6_area_id,-1) 
      and   a7.area_id (+) = nvl(a.level7_area_id,-1) 
      and   r.lang_code = nvl(a1.lang_code,r.lang_code)
      and   r.lang_code = nvl(a2.lang_code,r.lang_code)
      and   r.lang_code = nvl(a3.lang_code,r.lang_code)
      and   r.lang_code = nvl(a4.lang_code,r.lang_code)
      and   r.lang_code = nvl(a5.lang_code,r.lang_code)
      and   r.lang_code = nvl(a6.lang_code,r.lang_code)
      and   r.lang_code = nvl(a7.lang_code,r.lang_code)
      and   nvl(a1.is_alias,'F') = 'F'
      and   nvl(a2.is_alias,'F') = 'F'
      and   nvl(a3.is_alias,'F') = 'F'
      and   nvl(a4.is_alias,'F') = 'F'
      and   nvl(a5.is_alias,'F') = 'F'
      and   nvl(a6.is_alias,'F') = 'F'
      and   nvl(a7.is_alias,'F') = 'F'
      and   s.road_segment_id = geo_addr.edgeid
    )
    where rownum = 1;
  exception
    when no_data_found then
      a := null;
  end;
  -- Return the result
  return a;
end;

function get_names (
  addr_array sdo_addr_array
)
return gc_area_names_array
deterministic
is
  a gc_area_names_array := gc_area_names_array();
begin
  -- If no input, return nothing right away
  if addr_array is null then
    return null;
  end if;
  -- Construct an array of the proper size
  a.extend(addr_array.count());
  -- Process each result in the array
  for i in 1..addr_array.count() loop
    a(i) := get_names(addr_array(i));
  end loop;
  -- Return the result
  return a;
end;

function set_names (
  geo_addr sdo_geo_addr
)
return sdo_geo_addr
deterministic
is
  a gc_area_names;
  g sdo_geo_addr;
begin
  -- If no input, return nothing right away
  if geo_addr is null then
    return null;
  end if;
  -- Copy the geocoding result
  g := geo_addr;
  -- Get the area names for the result
  a := get_names (geo_addr);
    -- Copy the names in the ADDRESSLINES array
  if a is not null then 
    g.addresslines.extend(8);
    g.addresslines(1) := a.area_name_1;
    g.addresslines(2) := a.area_name_2;
    g.addresslines(3) := a.area_name_3;
    g.addresslines(4) := a.area_name_4;
    g.addresslines(5) := a.area_name_5;
    g.addresslines(6) := a.area_name_6;
    g.addresslines(7) := a.area_name_7;
    g.addresslines(8) := a.lang_code;
  end if;
  -- Return the updated geocoding result
  return g;
end;

function set_names (
  addr_array sdo_addr_array
)
return sdo_addr_array
deterministic
is
  a sdo_addr_array := sdo_addr_array();
begin
  -- If no input, return nothing right away
  if addr_array is null then
    return null;
  end if;
  -- Construct an address array of the proper size
  a.extend(addr_array.count());
  -- Process each result in the array
  for i in 1..addr_array.count() loop
    a(i) := set_names(addr_array(i));
  end loop;
  -- Return the result
  return a;
end;

end;
/
show errors

