------------------------------------------------------------------------------
-- Creating a dblink
------------------------------------------------------------------------------

-- Public dblinks
-- (Connect as SYSTEM)
CREATE PUBLIC DATABASE LINK orcl112_scott CONNECT TO scott IDENTIFIED BY tiger USING 'orcl112';
CREATE PUBLIC DATABASE LINK orcl112 USING 'orcl112';

-- Private dblinks
-- (Connect as SCOTT)
-- (needs right CREATE DATABASE LINK)
CREATE DATABASE LINK orcl112_scott CONNECT TO scott IDENTIFIED BY tiger USING 'localhost:1521/orcl112';
CREATE DATABASE LINK orcl112 USING 'localhost:1521/orcl112';

-- To remove the dblink
DROP DATABASE LINK orcl112_scott;

------------------------------------------------------------------------------
-- Using a dblink
------------------------------------------------------------------------------

-- Those work:
SELECT * FROM us_cities@orcl112_scott;

SELECT * FROM us_cities@orcl112_scott WHERE pop90>1000000;

SELECT c.city, s.state, c.location
FROM us_cities c,
     us_states@orcl112_scott s
WHERE c.state_abrv = s.state_abrv
AND c.pop90>1000000
ORDER BY s.state, c.city;

-- This does not work:
-- ORA-13226: interface not supported without a spatial index
SELECT c.city, s.state, c.location
FROM us_cities@orcl112_scott c,
     us_states s
WHERE c.state_abrv = s.state_abrv
AND c.pop90>1000000
ORDER BY s.state, c.city;

-- This does not work:
-- ORA-13226: interface not supported without a spatial index
SELECT county, totpop, geom
FROM us_counties_p@orcl112_scott
WHERE sdo_filter (
        geom,
        sdo_geometry (2003, 32775, null,
          sdo_elem_info_array (1,1003,3),
          sdo_ordinate_array (
            1420300,1805461, 1820000,2210000))
        ) = 'TRUE';

-- This does not work:
-- ORA-22804: remote operations not permitted on object tables or user-defined type columns
SELECT p.id, p.name
  FROM us_parks@orcl112_scott p, us_states s
 WHERE s.state = 'Wyoming'
   AND SDO_INSIDE (
         p.geom, s.geom
       ) = 'TRUE';

-- But this works:
SELECT p.id, p.name
  FROM us_parks p, us_states@orcl112_scott s
 WHERE s.state = 'Wyoming'
   AND SDO_INSIDE (
         p.geom, s.geom
       ) = 'TRUE';

-- This does not work:
-- ORA-22804: remote operations not permitted on object tables or user-defined type columns
INSERT INTO us_cities@orcl112_scott (id, city, state_abrv, location )
   VALUES (196, 'Bismarck', 'ND',
     SDO_GEOMETRY (
       2001, 8307,
       SDO_POINT_TYPE (-100.74869, 46.7666667, null),
       null, null)
    );

-- But this works:
CREATE TABLE us_cities_copy AS
SELECT * FROM us_cities@orcl112_scott;

UPDATE us_cities c1
SET location = (
  SELECT location
  FROM us_cities@orcl112_scott
  WHERE id = c1.id
);

