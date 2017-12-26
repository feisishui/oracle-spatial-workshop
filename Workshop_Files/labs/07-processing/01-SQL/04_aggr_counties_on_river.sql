-- Merge counties traversed by the North Platte in each state
SELECT c.state,
       sdo_aggr_union (sdoaggrtype(c.geom,0.5))
  FROM us_counties c, us_rivers r
 WHERE SDO_ANYINTERACT (c.geom, r.geom) = 'TRUE'
   AND r.name = 'North Platte'
 GROUP BY c.state;
