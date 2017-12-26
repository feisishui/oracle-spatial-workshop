-- Find the length (in miles) of the North Platte in each county it traverses
SELECT c.county, c.state,
       sdo_geom.sdo_length (
         sdo_geom.sdo_intersection (c.geom, r.geom, 0.5),
         0.5, 'unit=km') length
  FROM us_counties c, us_rivers r
 WHERE SDO_ANYINTERACT (c.geom, r.geom) = 'TRUE'
   AND r.name = 'North Platte';

SELECT c.state,
       sum(sdo_geom.sdo_length (
         sdo_geom.sdo_intersection (c.geom, r.geom, 0.5),
         0.5, 'unit=km')
       ) length
  FROM us_counties c, us_rivers r
 WHERE SDO_ANYINTERACT (c.geom, r.geom) = 'TRUE'
   AND r.name = 'North Platte'
GROUP BY rollup (c.state);



