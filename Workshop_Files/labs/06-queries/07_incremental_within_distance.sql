-- Cities within 15 miles from interstate
SELECT c.city, c.state_abrv, sdo_geom.sdo_distance (c.location, i.geom, 0.5, 'unit=mile') distance
  FROM us_interstates i, us_cities c
 WHERE i.interstate = 'I275'
   AND sdo_within_distance (
         c.location, i.geom,'distance=15 unit=mile')
       = 'TRUE'
ORDER BY distance;

-- ------------------------------------------------------------
-- Option 1: Using MINUS set operator
-- NOTE: does not work when returning geometries.
-- Not very efficient since we perform two spatial searches
-- ------------------------------------------------------------

-- Cities within 15 miles and 30 miles from interstate
SELECT c.city, c.state_abrv, sdo_geom.sdo_distance (c.location, i.geom, 0.5, 'unit=mile') distance
  FROM us_interstates i, us_cities c
 WHERE i.interstate = 'I275'
   AND sdo_within_distance (
         c.location, i.geom,'distance=30 unit=mile')
       = 'TRUE'
MINUS
SELECT c.city, c.state_abrv, sdo_geom.sdo_distance (c.location, i.geom, 0.5, 'unit=mile') distance
  FROM us_interstates i, us_cities c
 WHERE i.interstate = 'I275'
   AND sdo_within_distance (
         c.location, i.geom,'distance=15 unit=mile')
       = 'TRUE'
ORDER BY distance;

-- Cities within 30 miles and 45 miles from interstate
SELECT c.city, c.state_abrv, sdo_geom.sdo_distance (c.location, i.geom, 0.5, 'unit=mile') distance
  FROM us_interstates i, us_cities c
 WHERE i.interstate = 'I275'
   AND sdo_within_distance (
         c.location, i.geom,'distance=45 unit=mile')
       = 'TRUE'
MINUS
SELECT c.city, c.state_abrv, sdo_geom.sdo_distance (c.location, i.geom, 0.5, 'unit=mile') distance
  FROM us_interstates i, us_cities c
 WHERE i.interstate = 'I275'
   AND sdo_within_distance (
         c.location, i.geom,'distance=30 unit=mile')
       = 'TRUE'
ORDER BY distance;

-- ------------------------------------------------------------
-- Option 2: Use minimum distance
-- NOTE: This works also when returning geometries
-- Only one spatial search
-- ------------------------------------------------------------

-- Cities within 15 miles and 30 miles from interstate
SELECT c.city, c.state_abrv, sdo_geom.sdo_distance (c.location, i.geom, 0.5, 'unit=mile') distance
  FROM us_interstates i, us_cities c
 WHERE i.interstate = 'I275'
   AND sdo_within_distance (
         c.location, i.geom,'distance=30 unit=mile')
       = 'TRUE'
   AND sdo_geom.sdo_distance (c.location, i.geom, 0.5, 'unit=mile')  >= 15
ORDER BY distance;

-- Cities within 30 miles and 45 miles from interstate
SELECT c.city, c.state_abrv, sdo_geom.sdo_distance (c.location, i.geom, 0.5, 'unit=mile') distance
  FROM us_interstates i, us_cities c
 WHERE i.interstate = 'I275'
   AND sdo_within_distance (
         c.location, i.geom,'distance=45 unit=mile')
       = 'TRUE'
   AND sdo_geom.sdo_distance (c.location, i.geom, 0.5, 'unit=mile')  >= 30
ORDER BY distance;

-- ------------------------------------------------------------
-- Make sure the distance function is called once only
-- ------------------------------------------------------------

-- Cities within 15 miles and 30 miles from interstate
SELECT *
  FROM (
    SELECT c.city, c.state_abrv, sdo_geom.sdo_distance (c.location, i.geom, 0.5, 'unit=mile') distance
      FROM us_interstates i, us_cities c
     WHERE i.interstate = 'I275'
       AND sdo_within_distance (
             c.location, i.geom,'distance=30 unit=mile')
           = 'TRUE'
)
 WHERE distance  >= 15
ORDER BY distance;

-- Cities within 30 miles and 45 miles from interstate
SELECT *
  FROM (
  SELECT c.city, c.state_abrv, sdo_geom.sdo_distance (c.location, i.geom, 0.5, 'unit=mile') distance
    FROM us_interstates i, us_cities c
   WHERE i.interstate = 'I275'
     AND sdo_within_distance (
           c.location, i.geom,'distance=45 unit=mile')
         = 'TRUE'
)
 WHERE distance  >= 30
ORDER BY distance;

