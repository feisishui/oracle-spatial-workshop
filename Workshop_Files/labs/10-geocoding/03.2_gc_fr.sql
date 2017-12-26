-- No postal code specified
exec format_addr_array(sdo_gcdr.geocode_all (user, sdo_keywordarray('12 rue de l''Arcade', 'Paris'), 'FR', 'default'))
-- Wrong spelling of road name, wrong postal code
select * from table (sdo_gcdr.geocode_all (user, sdo_keywordarray('151 Bd Hausman', '75009 Paris'), 'FR', 'default'));
exec format_addr_array(sdo_gcdr.geocode_all (user, sdo_keywordarray('151 Bd Hausman', '75009 Paris'), 'FR', 'default'))

-- Structured input: using the simple constructor
call format_addr_array(
  sdo_gcdr.geocode_addr_all (
    user,
    sdo_geo_addr (
      'france',           -- country
      'default',          -- matchmode
      '151 Bd Haussmann', -- street
      null,               -- settlement
      'Paris',            -- municipality
      null,               -- region
      '75008'             -- postalcode
    )
  )
);

-- Structured input: using the full constructor. House number is isolated
call format_addr_array(
  sdo_gcdr.geocode_addr_all (
    user,
    sdo_geo_addr(
      1,                        -- ID
      null,                     -- ADDRESSLINES
      null,                     -- PLACENAME
      'Bd Haussmann',           -- STREETNAME
      null,                     -- INTERSECTSTREET
      null,                     -- SECUNIT
      null,                     -- SETTLEMENT
      'paris',                  -- MUNICIPALITY
      null,                     -- REGION
      'france',                 -- COUNTRY
      '75008',                  -- POSTALCODE
      null,                     -- POSTALADDONCODE
      null,                     -- FULLPOSTALCODE
      null,                     -- POBOX
      '151',                    -- HOUSENUMBER
      null,                     -- BASENAME
      null,                     -- STREETTYPE
      null,                     -- STREETTYPEBEFORE
      null,                     -- STREETTYPEATTACHED
      null,                     -- STREETPREFIX
      null,                     -- STREETSUFFIX
      null,                     -- SIDE
      null,                     -- PERCENT
      null,                     -- EDGEID
      null,                     -- ERRORMESSAGE
      null,                     -- MATCHCODE
      'default',                -- MATCHMODE
      null,                     -- LONGITUDE
      null                      -- LATITUDE
    )
  )
);

-- Extracting results from geocodes
-- GEOCODE or GEOCODE_ADDR
SELECT G.GC.LONGITUDE, G.GC.LATITUDE, G.GC.MATCHCODE, G.GC.SETTLEMENT, 
       G.GC.REGION, G.GC.COUNTRY, G.GC.POSTALCODE, G.GC.HOUSENUMBER, G.GC.STREETNAME, 
       G.GC.INTERSECTSTREET, G.GC.MUNICIPALITY  
FROM (
  SELECT SDO_GCDR.GEOCODE(
    user, 
    SDO_KEYWORDARRAY('151 Boulevard Haussmann',null,null,null,null,'Paris',null,null,null,'75008'),
    'France',
    'DEFAULT'
  ) GC 
  FROM DUAL
) G;

-- GEOCODE_ALL or GEOCODE_ADDR_ALL 
SELECT longitude, latitude, matchcode, settlement, 
       region, country, postalcode, housenumber, streetname, 
       intersectstreet, municipality  
FROM TABLE (
  SDO_GCDR.GEOCODE_ALL(
    user, 
    SDO_KEYWORDARRAY('151 Boulevard Haussmann',null,null,null,null,'Paris',null,null,null,'75008'),
   'France',
   'DEFAULT',
   10
  )
);

-- Reverse geocode
exec format_geo_addr (sdo_gcdr.reverse_geocode(user, sdo_geometry (2001, 8307, sdo_point_type(2.310384, 48.875084, null), null, null), 'FR'))
exec format_geo_addr (sdo_gcdr.reverse_geocode(user, sdo_geometry (2001, 54004, sdo_point_type(257358.418, 6221499.41, null), null, null), 'FR'))
