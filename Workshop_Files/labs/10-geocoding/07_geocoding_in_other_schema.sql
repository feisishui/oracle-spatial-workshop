-- Connect to schema that owns the geocoding tables
connect scott/tiger 
-- Do local geocode. Result is good (address point is used)
select sdo_gcdr.geocode ('SCOTT', sdo_keywordarray('1357 Clay Street', 'San Francisco, CA'), 'US', 'default') from dual;
-- Grant access rights on geocoding tables to WORK
grant select on GC_COUNTRY_PROFILE to work;
grant select on GC_PARSER_PROFILEAFS to work;
grant select on GC_PARSER_PROFILES to work;
grant select on GC_ADDRESS_POINT_US to work;
grant select on GC_AREA_US to work;
grant select on GC_INTERSECTION_US to work;
grant select on GC_POI_US to work;
grant select on GC_POSTAL_CODE_US to work;
grant select on GC_ROAD_SEGMENT_US to work;
grant select on GC_ROAD_US to work; 

-- Connect to other schema
connect work/work
-- Do remote  geocode. Result is still good (address point is used)
select sdo_gcdr.geocode ('SCOTT', sdo_keywordarray('1357 Clay Street', 'San Francisco, CA'), 'US', 'default') from dual;

-- Connect to schema that owns the geocoding tables
connect scott/tiger
-- remove access to address point table
revoke select on GC_ADDRESS_POINT_US from work;

-- Connect to other schema
connect work/work
-- Do remote  geocode. This time we interpolate as expected
select sdo_gcdr.geocode ('SCOTT', sdo_keywordarray('1357 Clay Street', 'San Francisco, CA'), 'US', 'default') from dual;

-- Connect to schema that owns the geocoding tables
connect scott/tiger
-- Revoke all rights.
revoke select on GC_COUNTRY_PROFILE from work;
revoke select on GC_PARSER_PROFILEAFS from work;
revoke select on GC_PARSER_PROFILES from work;
revoke select on GC_ADDRESS_POINT_US from work;
revoke select on GC_AREA_US from work;
revoke select on GC_INTERSECTION_US from work;
revoke select on GC_POI_US from work;
revoke select on GC_POSTAL_CODE_US from work;
revoke select on GC_ROAD_SEGMENT_US from work;
revoke select on GC_ROAD_US from work;
