-- Search for POIs within distance from an address
SELECT NAME, TELEPHONE_NUMBER
FROM US_POIS
WHERE SDO_WITHIN_DISTANCE (
  GEOMETRY,
  SDO_GCDR.GEOCODE_AS_GEOMETRY (user,
    SDO_KEYWORDARRAY('1350 Clay', 'San Francisco, CA'), 
   'US'),
  'DISTANCE=500 UNIT=M'
) = 'TRUE';

-- Search and order results by distance
-- Note the NO_MERGE() hint!
WITH GC AS (
  SELECT SDO_GCDR.GEOCODE_AS_GEOMETRY (user,
    SDO_KEYWORDARRAY('1350 Clay St', 'San Francisco, CA'), 
   'US') MY_LOCATION
  FROM DUAL
)
SELECT /*+ NO_MERGE(gc) */ NAME, TELEPHONE_NUMBER,
  SDO_GEOM.SDO_DISTANCE (
    GEOMETRY, MY_LOCATION, 0.005) DISTANCE
FROM US_POIS, GC
WHERE SDO_WITHIN_DISTANCE (
  GEOMETRY,
  MY_LOCATION,
  'DISTANCE=500 UNIT=M'
) = 'TRUE'
ORDER BY DISTANCE;

-- Use your own wrapper function
create or replace function geocode_address (
  house_number varchar2,
  street_name varchar2,
  city_name varchar2,
  region varchar2 default null
)
return sdo_geometry
deterministic
as
  gc_i sdo_geo_addr := sdo_geo_addr();
  gc_o sdo_geo_addr;
begin
  -- Format input address
  gc_i.housenumber := house_number;  
  gc_i.streetname := street_name;  
  gc_i.municipality := city_name;  
  gc_i.region := region;
  gc_i.country := 'US';
  -- Geocode
  gc_o := sdo_gcdr.geocode_addr ('SCOTT', gc_i);
  -- return result
  return sdo_geometry (2001, gc_o.srid,
    sdo_point_type (
      gc_o.longitude, gc_o.latitude, null),
    null, null
  );
end;
/

-- Use the function
WITH GC AS (
  SELECT geocode_address ('1350', 'Clay St', 'San Francisco', 'CA') MY_LOCATION
  FROM DUAL
)
SELECT /*+ NO_MERGE(gc) */ NAME, TELEPHONE_NUMBER,
  SDO_GEOM.SDO_DISTANCE (
    GEOMETRY, MY_LOCATION, 0.005) DISTANCE
FROM US_POIS, GC
WHERE SDO_WITHIN_DISTANCE (
  GEOMETRY,
  MY_LOCATION,
  'DISTANCE=5000 UNIT=M'
) = 'TRUE'
ORDER BY DISTANCE;

-- Try multiple combinations
/*+
Function deterministic ?    Using NO_MERGE hint ?   Duration
------------------------    ---------------------   --------
NO                          NO                         13.48
NO                          YES                         0.18
YES                         NO                          0.20
YES                         YES                         0.18
*/