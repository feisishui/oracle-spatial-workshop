-- -------------------------------------------------------
-- Match up cities and counties
-- -------------------------------------------------------

-- Decompose the query
-- Invoke SDO_JOIN() function:
select
  SDO_JOIN (
    'US_CITIES', 'LOCATION',
    'US_COUNTIES', 'GEOM',
    'MASK=ANYINTERACT'
  )
from dual;

-- Cast result to TABLE():
select * 
from
  TABLE (
    SDO_JOIN (
      'US_CITIES', 'LOCATION',
      'US_COUNTIES', 'GEOM',
      'MASK=ANYINTERACT'
    ) 
  );

-- Match up cities and counties using SDO_JOIN
-- Elapsed: 0.1 
SELECT ci.city, ci.state_abrv, co.county
  FROM us_cities ci,
       us_counties co,
       TABLE(SDO_JOIN(
             'US_CITIES', 'LOCATION',
             'US_COUNTIES', 'GEOM',
             'MASK=ANYINTERACT') 
       ) j
WHERE j.rowid1 = ci.rowid
  AND j.rowid2 = co.rowid
ORDER BY ci.city, ci.state_abrv;

-- Match up cities and counties using SDO_RELATE
-- For each city, get the matching county
-- Elapsed: 0.4 seconds (0.2 VPA)
SELECT ci.city, ci.state_abrv, co.county
  FROM us_cities ci,
       us_counties co
WHERE sdo_anyinteract (co.geom, ci.location) = 'TRUE'
ORDER BY ci.city, ci.state_abrv;

-- Match up cities and counties using SDO_RELATE
-- For each county, get the matching city
-- Elapsed: 5.5 seconds (2.5 VPA)
SELECT ci.city, ci.state_abrv, co.county
  FROM us_cities ci,
       us_counties co
WHERE sdo_anyinteract (ci.location, co.geom) = 'TRUE'
ORDER BY ci.city, ci.state_abrv;

-- -------------------------------------------------------
-- Match up cities and interstates
-- -------------------------------------------------------

-- Match up cities and interstates less than 10 miles apart
-- Elapsed: 1 second (0.45 seconds VPA)
SELECT c.city, i.interstate
  FROM us_cities c,
       us_interstates i,
       TABLE(SDO_JOIN(
             'US_CITIES', 'LOCATION',
             'US_INTERSTATES', 'GEOM',
             'DISTANCE=10 UNIT=MILE')) j
WHERE j.rowid1 = c.rowid
  AND j.rowid2 = i.rowid
ORDER BY c.city;

-- Match up cities and interstates using sdo_relate
-- Elapsed: 4.35 seconds (VPA: same)
SELECT c.city, i.interstate
  FROM us_cities c,
       us_interstates i
WHERE sdo_within_distance (
        i.geom, c.location,
        'DISTANCE=10 UNIT=MILE'
      ) = 'TRUE'
ORDER BY c.city;

SELECT c.city, i.interstate
  FROM us_cities c,
       us_interstates i
WHERE sdo_within_distance (
        c.location, i.geom, 
        'DISTANCE=10 UNIT=MILE'
      ) = 'TRUE'
ORDER BY c.city;
-- -------------------------------------------------------
-- Match up counties and parks
-- -------------------------------------------------------

-- Match up counties and parks using SDO_JOIN
-- Elapsed: 40 seconds (7 seconds VPA)
SELECT c.county, c.state_abrv, p.id, p.name
  FROM us_parks p,
       us_counties c,
       TABLE(SDO_JOIN(
             'US_PARKS', 'GEOM',
             'US_COUNTIES', 'GEOM',
             'MASK=ANYINTERACT') ) j
WHERE j.rowid1 = p.rowid
  AND j.rowid2 = c.rowid
ORDER BY c.county, c.state_abrv;

-- -------------------------------------------------------
-- Match up cities and cities
-- -------------------------------------------------------

-- Couples of cities that are less than 10 miles apart
-- Elapsed: 0.05 seconds (VPA: same)
SELECT c1.city, c2.city
  FROM us_cities c1,
       us_cities c2,
       TABLE(SDO_JOIN(
             'US_CITIES', 'LOCATION',
             'US_CITIES', 'LOCATION',
             'DISTANCE=10 UNIT=MILE')) j
WHERE j.rowid1 = c1.rowid
  AND j.rowid2 = c2.rowid
  AND c1.rowid < c2.rowid
ORDER BY c1.city, c2.city;

-- -------------------------------------------------------
-- Match up counties and counties
-- -------------------------------------------------------

-- Match up counties and counties using SDO_JOIN
-- NOTE: Printing the 18000+ results takes 3 to 4 seconds
-- Elapsed: 23 seconds (10.5 seconds VPA)
SELECT c1.county, c1.state_abrv, c2.county, c2.state_abrv
  FROM us_counties c1,
       us_counties c2,
       TABLE(SDO_JOIN(
             'US_COUNTIES', 'GEOM',
             'US_COUNTIES', 'GEOM',
             'MASK=TOUCH') ) j
WHERE j.rowid1 = c1.rowid
  AND j.rowid2 = c2.rowid;
