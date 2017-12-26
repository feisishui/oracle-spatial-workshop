--
-- NOTE: make sure to do SET SERVEROUTPUT ON before running the examples
--

-- No house number specified
select sdo_gcdr_ws.geocode (sdo_keywordarray('Clay Street', 'San Francisco, CA'), 'US', 'default') from dual;
exec format_geo_addr(sdo_gcdr_ws.geocode (sdo_keywordarray('Clay Street', 'San Francisco, CA'), 'US', 'default'))

-- House number specified, but not in address points table
select sdo_gcdr_ws.geocode (sdo_keywordarray('1350 Clay Street', 'San Francisco, CA'), 'US', 'default') from dual;
exec format_geo_addr(sdo_gcdr_ws.geocode (sdo_keywordarray('1350 Clay Street', 'San Francisco, CA'), 'US', 'default'))

-- House number specified, found in address points table
select sdo_gcdr_ws.geocode (sdo_keywordarray('1357 Clay Street', 'San Francisco, CA'), 'US', 'default') from dual;
exec format_geo_addr(sdo_gcdr_ws.geocode (sdo_keywordarray('1357 Clay Street', 'San Francisco, CA'), 'US', 'default'))

-- Street name error
select sdo_gcdr_ws.geocode (sdo_keywordarray('100 van nust avenue', 'San Francisco, CA'), 'US', 'default') from dual;
exec format_geo_addr(sdo_gcdr_ws.geocode (sdo_keywordarray('100 van nust avenue', 'San Francisco, CA'), 'US', 'default'))

-- Street not found at all
select sdo_gcdr_ws.geocode (sdo_keywordarray('100 oracle place', 'San Francisco, CA'), 'US', 'default') from dual;
exec format_geo_addr(sdo_gcdr_ws.geocode (sdo_keywordarray('100 oracle place', 'San Francisco, CA'), 'US', 'default'))

-- No zip code specified
select sdo_gcdr_ws.geocode (sdo_keywordarray('1500 Clay Street', 'San Francisco, CA'), 'US', 'default') from dual;
exec format_addr_array(sdo_gcdr_ws.geocode_all (sdo_keywordarray('1500 Clay Street', 'San Francisco, CA'), 'US', 'default'))

-- Wrong zip code
select sdo_gcdr_ws.geocode_all (sdo_keywordarray('1500 Clay Street', 'San Francisco, CA 94150'), 'US', 'default') from dual;
exec format_addr_array(sdo_gcdr_ws.geocode_all (sdo_keywordarray('1500 Clay Street', 'San Francisco, CA 94150'), 'US', 'default'))

-- POI match
select sdo_gcdr_ws.geocode (sdo_keywordarray('Moscone Center', 'San Francisco, CA'), 'US', 'default') from dual;
exec format_addr_array(sdo_gcdr_ws.geocode_all (sdo_keywordarray('Moscone Center', 'San Francisco, CA'), 'US', 'default'))

-- Geocode as geometry
select sdo_gcdr_ws.geocode_as_geometry(sdo_keywordarray('1500 Clay Street', 'San Francisco, CA 94150'), 'US') from dual;ß

-- Street name has a suffix (E or W)
-- Specify the suffix (W and West are synonyms)
exec format_addr_array(sdo_gcdr_ws.geocode_all (sdo_keywordarray('701 Buena Vista Ave W', 'San Francisco, CA'), 'US', 'default'))
exec format_addr_array(sdo_gcdr_ws.geocode_all (sdo_keywordarray('701 Buena Vista Ave West', 'San Francisco, CA'), 'US', 'default'))
-- Specify the suffix (E and East are synonyms)
exec format_addr_array(sdo_gcdr_ws.geocode_all (sdo_keywordarray('298 Buena Vista Ave E', 'San Francisco, CA'), 'US', 'default'))
exec format_addr_array(sdo_gcdr_ws.geocode_all (sdo_keywordarray('298 Buena Vista Ave East', 'San Francisco, CA'), 'US', 'default'))
-- No suffix
exec format_addr_array(sdo_gcdr_ws.geocode_all (sdo_keywordarray('701 Buena Vista Ave', 'San Francisco, CA'), 'US', 'default'))
exec format_addr_array(sdo_gcdr_ws.geocode_all (sdo_keywordarray('298 Buena Vista Ave', 'San Francisco, CA'), 'US', 'default'))

-- Street name has a prefix (N or S)
-- Specify the prefix (N and North are synonyms)
exec format_addr_array(sdo_gcdr_ws.geocode_all (sdo_keywordarray('201 N Lake Merced Hills', 'San Francisco, CA'), 'US', 'default'))
exec format_addr_array(sdo_gcdr_ws.geocode_all (sdo_keywordarray('201 North Lake Merced Hills', 'San Francisco, CA'), 'US', 'default'))
-- Specify the prefix (S and South are synonyms)
exec format_addr_array(sdo_gcdr_ws.geocode_all (sdo_keywordarray('198 S Lake Merced Hills', 'San Francisco, CA'), 'US', 'default'))
exec format_addr_array(sdo_gcdr_ws.geocode_all (sdo_keywordarray('198 South Lake Merced Hills', 'San Francisco, CA'), 'US', 'default'))
-- No prefix
exec format_addr_array(sdo_gcdr_ws.geocode_all (sdo_keywordarray('201 Lake Merced Hills', 'San Francisco, CA'), 'US', 'default'))
exec format_addr_array(sdo_gcdr_ws.geocode_all (sdo_keywordarray('198 Lake Merced Hills', 'San Francisco, CA'), 'US', 'default'))

-- International examples:
-- This is an address in french
exec format_addr_array(sdo_gcdr_ws.geocode_all (sdo_keywordarray('Avenue du Bois Soleil, 62', 'Kraainem'), 'BE', 'default'))
-- The exact same place, using the flemish name.
exec format_addr_array(sdo_gcdr_ws.geocode_all (sdo_keywordarray('Zonneboslaan, 62', 'Kraainem'), 'BE', 'default'))

-- Structured input
call format_addr_array(
  sdo_gcdr_ws.geocode_addr_all (
    sdo_geo_addr (
      'us',               -- country
      'default',          -- matchmode
      'Clay Street', -- street
      'San Francisco',    -- settlement
      null,               -- municipality
      'CA',               -- region
      null                -- postalcode
    )
  )
);

call format_geo_addr(
  sdo_gcdr_ws.geocode_addr (
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

-- Reverse geocoding
-- geometry, country
exec format_geo_addr (sdo_gcdr_ws.reverse_geocode (sdo_geometry(2001, 8307, sdo_point_type (-122.415311632653, 37.793117755102 , null), null, null), 'US'))
-- geometry, language, country,
exec format_geo_addr (sdo_gcdr_ws.reverse_geocode (sdo_geometry(2001, 8307, sdo_point_type (-122.415311632653, 37.793117755102 , null), null, null), 'ENG', 'US'))
-- longitude, latitude, country
exec format_geo_addr (sdo_gcdr_ws.reverse_geocode (-122.415311632653, 37.793117755102, 'US'))
-- longitude, latitude, srid, country
exec format_geo_addr (sdo_gcdr_ws.reverse_geocode (-122.415311632653, 37.793117755102, 8307, 'US'))
-- longitude, latitude, language, country
exec format_geo_addr (sdo_gcdr_ws.reverse_geocode (-122.415311632653, 37.793117755102, 'ENG', 'US'))
-- longitude, latitude, srid, language, country
exec format_geo_addr (sdo_gcdr_ws.reverse_geocode (-122.415311632653, 37.793117755102, 8307, 'ENG', 'US'))
