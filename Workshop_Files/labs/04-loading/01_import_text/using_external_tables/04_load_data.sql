TRUNCATE TABLE us_cities;

INSERT INTO us_cities (id, city, state_abrv, pop90, rank90, location)
SELECT rownum,
       city,
       state_abrv,
       pop90,
       rank90,
       SDO_GEOMETRY (2001, 8307,
         SDO_POINT_TYPE (longitude,latitude,null), null, null
       )
FROM   us_cities_ext;

COMMIT;
