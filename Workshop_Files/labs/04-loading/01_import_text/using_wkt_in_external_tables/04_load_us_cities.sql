TRUNCATE TABLE us_cities;

INSERT INTO us_cities (id, city, state_abrv, pop90, rank90, location)
SELECT id,
       city,
       state_abrv,
       pop90,
       rank90,
       SDO_GEOMETRY (wkt, 8307)
FROM   us_cities_ext;

COMMIT;
