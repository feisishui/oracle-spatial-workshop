-- How much space does Yellowstone National Park occupy in each county ?
SELECT c.state, c.county,
       to_char (
         sdo_geom.sdo_area (
           sdo_geom.sdo_intersection (c.geom, p.geom, 0.5),
           0.5, 'unit=sq_km'),
         '9999.9') area
  FROM us_counties c, us_parks p
 WHERE SDO_ANYINTERACT (c.geom, p.geom) = 'TRUE'
   AND p.name = 'Yellowstone NP';
