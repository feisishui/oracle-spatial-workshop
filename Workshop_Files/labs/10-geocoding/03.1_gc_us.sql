--
-- NOTE: make sure to do SET SERVEROUTPUT ON before running the examples
-- 


-- No house number specified
select sdo_gcdr.geocode (user, sdo_keywordarray('Clay Street', 'San Francisco, CA'), 'US', 'default') from dual;
exec format_geo_addr(sdo_gcdr.geocode (user, sdo_keywordarray('Clay Street', 'San Francisco, CA'), 'US', 'default'))

-- House number specified, but not in address points table
select sdo_gcdr.geocode (user, sdo_keywordarray('1350 Clay Street', 'San Francisco, CA'), 'US', 'default') from dual;
exec format_geo_addr(sdo_gcdr.geocode (user, sdo_keywordarray('1350 Clay Street', 'San Francisco, CA'), 'US', 'default'))

-- House number specified, found in address points table
select sdo_gcdr.geocode (user, sdo_keywordarray('1357 Clay Street', 'San Francisco, CA'), 'US', 'default') from dual;
exec format_geo_addr(sdo_gcdr.geocode (user, sdo_keywordarray('1357 Clay Street', 'San Francisco, CA'), 'US', 'default'))

-- Street name error
select sdo_gcdr.geocode (user, sdo_keywordarray('100 van nust avenue', 'San Francisco, CA'), 'US', 'default') from dual;
exec format_geo_addr(sdo_gcdr.geocode (user, sdo_keywordarray('100 van nust avenue', 'San Francisco, CA'), 'US', 'default'))

-- Street not found at all
select sdo_gcdr.geocode (user, sdo_keywordarray('100 oracle place', 'San Francisco, CA'), 'US', 'default') from dual;
exec format_geo_addr(sdo_gcdr.geocode (user, sdo_keywordarray('100 oracle place', 'San Francisco, CA'), 'US', 'default'))

-- No zip code specified
select sdo_gcdr.geocode (user, sdo_keywordarray('1500 Clay Street', 'San Francisco, CA'), 'US', 'default') from dual;
exec format_addr_array(sdo_gcdr.geocode_all (user, sdo_keywordarray('1500 Clay Street', 'San Francisco, CA'), 'US', 'default'))

-- Wrong zip code
select sdo_gcdr.geocode_all (user, sdo_keywordarray('1500 Clay Street', 'San Francisco, CA 94150'), 'US', 'default') from dual;
exec format_addr_array(sdo_gcdr.geocode_all (user, sdo_keywordarray('1500 Clay Street', 'San Francisco, CA 94150'), 'US', 'default'))

-- POI match
select sdo_gcdr.geocode (user, sdo_keywordarray('Moscone Center', 'San Francisco, CA'), 'US', 'default') from dual;
exec format_addr_array(sdo_gcdr.geocode_all (user, sdo_keywordarray('Moscone Center', 'San Francisco, CA'), 'US', 'default'))

-- Street name has a suffix (E or W)
-- Specify the suffix (W and West are synonyms)
exec format_addr_array(sdo_gcdr.geocode_all (user, sdo_keywordarray('701 Buena Vista Ave W', 'San Francisco, CA'), 'US', 'default'))
exec format_addr_array(sdo_gcdr.geocode_all (user, sdo_keywordarray('701 Buena Vista Ave West', 'San Francisco, CA'), 'US', 'default'))
-- Specify the suffix (E and East are synonyms)
exec format_addr_array(sdo_gcdr.geocode_all (user, sdo_keywordarray('298 Buena Vista Ave E', 'San Francisco, CA'), 'US', 'default'))
exec format_addr_array(sdo_gcdr.geocode_all (user, sdo_keywordarray('298 Buena Vista Ave East', 'San Francisco, CA'), 'US', 'default'))
-- No suffix
exec format_addr_array(sdo_gcdr.geocode_all (user, sdo_keywordarray('701 Buena Vista Ave', 'San Francisco, CA'), 'US', 'default'))
exec format_addr_array(sdo_gcdr.geocode_all (user, sdo_keywordarray('298 Buena Vista Ave', 'San Francisco, CA'), 'US', 'default'))

-- Street name has a prefix (N or S)
-- Specify the prefix (N and North are synonyms)
exec format_addr_array(sdo_gcdr.geocode_all (user, sdo_keywordarray('201 N Lake Merced Hills', 'San Francisco, CA'), 'US', 'default'))
exec format_addr_array(sdo_gcdr.geocode_all (user, sdo_keywordarray('201 North Lake Merced Hills', 'San Francisco, CA'), 'US', 'default'))
-- Specify the prefix (S and South are synonyms)
exec format_addr_array(sdo_gcdr.geocode_all (user, sdo_keywordarray('198 S Lake Merced Hills', 'San Francisco, CA'), 'US', 'default'))
exec format_addr_array(sdo_gcdr.geocode_all (user, sdo_keywordarray('198 South Lake Merced Hills', 'San Francisco, CA'), 'US', 'default'))
-- No prefix
exec format_addr_array(sdo_gcdr.geocode_all (user, sdo_keywordarray('201 Lake Merced Hills', 'San Francisco, CA'), 'US', 'default'))
exec format_addr_array(sdo_gcdr.geocode_all (user, sdo_keywordarray('198 Lake Merced Hills', 'San Francisco, CA'), 'US', 'default'))

-- Structured input
call format_addr_array(
  sdo_gcdr.geocode_addr_all (
    user,
    sdo_geo_addr (
      'us',               -- country
      'default',          -- matchmode
      '1500 Clay Street', -- street
      'San Francisco',    -- settlement
      null,               -- municipality
      'CA',               -- region
      null                -- postalcode
    )
  )
);

-- Intersection geocoding: must use structured geocoding
SELECT SDO_GCDR.GEOCODE_ADDR(
  user, 
  SDO_GEO_ADDR(
    NULL,                  -- ID                 
    SDO_KEYWORDARRAY(),    -- ADDRESSLINES      
    NULL,                  -- PLACENAME         
    'Van Ness Avenue',     -- STREETNAME        
    'Sacramento Street',   -- INTERSECTSTREET   
    NULL,                  -- SECUNIT           
    'San Francisco',       -- SETTLEMENT        
    NULL,                  -- MUNICIPALITY      
    'CA',                  -- REGION            
    'US',                  -- COUNTRY           
    null,                  -- POSTALCODE        
    NULL,                  -- POSTALADDONCODE   
    NULL,                  -- FULLPOSTALCODE    
    NULL,                  -- POBOX             
    NULL,                  -- HOUSENUMBER       
    NULL,                  -- BASENAME          
    NULL,                  -- STREETTYPE        
    NULL,                  -- STREETTYPEBEFORE  
    NULL,                  -- STREETTYPEATTACHED
    NULL,                  -- STREETPREFIX      
    NULL,                  -- STREETSUFFIX      
    NULL,                  -- SIDE              
    NULL,                  -- PERCENT           
    NULL,                  -- EDGEID            
    NULL,                  -- ERRORMESSAGE      
    NULL,                  -- MATCHCODE         
    'default',             -- MATCHMODE         
    NULL,                  -- LONGITUDE         
    NULL                   -- LATITUDE          
  )
) from dual;

-- Use a wrapper to simplify usage
create or replace function sdo_geo_addr_intersect (
  streetname      varchar2,
  intersectstreet varchar2,
  settlement      varchar2,
  municipality    varchar2,
  postalcode      varchar2,
  region          varchar2,
  country         varchar2,
  matchmode       varchar2
) 
return sdo_geo_addr
as
  g sdo_geo_addr := new sdo_geo_addr();
begin
  g.streetname      := streetname;        
  g.intersectstreet := intersectstreet;        
  g.settlement      := settlement;    
  g.municipality    := municipality;  
  g.postalcode      := postalcode;    
  g.region          := region;        
  g.country         := country;       
  g.matchmode       := matchmode;
  return g;
end;
/
show errors

-- Try it out
exec format_geo_addr(sdo_gcdr.geocode_addr (user, sdo_geo_addr_intersect('Clay Street', 'Van Ness Avenue', 'San Francisco', null, null, 'CA', 'US', 'default')))
exec format_geo_addr(sdo_gcdr.geocode_addr (user, sdo_geo_addr_intersect('Clay', 'Van Ness', 'San Francisco', null, null, 'CA', 'US', 'default')))
exec format_geo_addr(sdo_gcdr.geocode_addr (user, sdo_geo_addr_intersect('Van Ness', 'Clay', 'San Francisco', null, null, 'CA', 'US', 'default')))


-- Reverse geocoding

-- Coordinates of interpolated coordinates (1350 Clay St, San Francisco, CA)
exec format_geo_addr (sdo_gcdr.reverse_geocode (user, -122.415311632653, 37.793117755102, 'US'))
exec format_geo_addr (sdo_gcdr.reverse_geocode (user, sdo_geometry(2001, 8307, sdo_point_type (-122.415311632653, 37.793117755102 , null), null, null), 'US'))
-- Coordinates of point address coordinates (1357 Clay St, San Francisco, CA)
exec format_geo_addr (sdo_gcdr.reverse_geocode (user, -122.4154, 37.79311, 'US'))
exec format_geo_addr (sdo_gcdr.reverse_geocode (user, sdo_geometry(2001, 8307, sdo_point_type (-122.4154, 37.79311 , null), null, null), 'US'))
