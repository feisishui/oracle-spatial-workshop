-- How much space does Yellowstone National Park occupy in each state ?
SELECT s.state,
       sdo_geom.sdo_area (
         sdo_geom.sdo_intersection (
           s.geom, p.geom, 0.5),
         0.5, 'unit=sq_km') area
  FROM us_states s, us_parks p
 WHERE SDO_ANYINTERACT (s.geom, p.geom) = 'TRUE'
   AND p.name = 'Yellowstone NP'
 ORDER by area desc;

-- What percentage of Yellowstone National Park lies in each state ?
WITH p AS (
  SELECT s.state,
         sdo_geom.sdo_area (
           sdo_geom.sdo_intersection (
             s.geom, p.geom, 0.5),
           0.5, 'unit=sq_km') area
    FROM us_states s, us_parks p
   WHERE SDO_ANYINTERACT (s.geom, p.geom) = 'TRUE'
     AND p.name = 'Yellowstone NP'
)
SELECT state, area,
       RATIO_TO_REPORT(area) OVER () * 100 AS pct
FROM p
ORDER BY pct DESC;

