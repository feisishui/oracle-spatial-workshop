-- Cities within distance from interstate
SELECT c.city, c.state_abrv, c.location
  FROM us_interstates i, us_cities c
 WHERE i.interstate = 'I275'
   AND sdo_within_distance (
         c.location, i.geom,'distance=15 unit=mile')
       = 'TRUE';

-- Cities NOT within distance from interstate: correct results, but inefficient
SELECT c.city, c.state_abrv, c.location
  FROM us_interstates i, us_cities c
 WHERE i.interstate = 'I275'
   AND sdo_within_distance (
         c.location, i.geom,'distance=15 unit=mile')
       <> 'TRUE';

-- Cities NOT within distance from interstate: better
SELECT c.city, c.state_abrv, c.location
  FROM us_cities c
 WHERE ROWID NOT IN (
  SELECT c.rowid
    FROM us_interstates i, us_cities c
   WHERE i.interstate = 'I275'
     AND sdo_within_distance (
           c.location, i.geom,'distance=15 unit=mile')
         = 'TRUE'
 );
