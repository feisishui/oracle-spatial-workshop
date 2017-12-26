SELECT c1.city,
       SDO_GEOM.SDO_DISTANCE (
         c1.location, c2.location,
         0.5, 'unit=mile') distance
  FROM us_cities c1, us_cities c2
 WHERE c2.city = 'Boston'
   AND SDO_WITHIN_DISTANCE(
        c1.location, c2.location,
        'distance=100 unit=mile'
       ) = 'TRUE'
   AND c1.city <> c2.city
 ORDER BY distance desc;
