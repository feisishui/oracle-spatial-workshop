-- Which parks are inside the state of Wyoming ?
SELECT p.id, p.name
  FROM us_parks p, us_states s
 WHERE s.state = 'Wyoming'
   AND SDO_INSIDE (p.geom, s.geom) = 'TRUE';

-- Which parks overlap the state of Wyoming ?
SELECT p.id, p.name
  FROM us_parks p, us_states s
 WHERE s.state = 'Wyoming'
   AND SDO_OVERLAPS (p.geom, s.geom) = 'TRUE';

-- Which parks interact with the state of Wyoming ?
SELECT p.id, p.name
  FROM us_parks p, us_states s
 WHERE s.state = 'Wyoming'
   AND SDO_ANYINTERACT (p.geom, s.geom) = 'TRUE';

-- Using ISO-SQL join syntax
SELECT p.id, p.name
  FROM us_parks p JOIN us_states s
    ON SDO_ANYINTERACT (p.geom, s.geom) = 'TRUE'
 WHERE s.state = 'Wyoming';

-- Which parks interact with the state of Wyoming ?
-- The correct way:
SELECT p.id, p.name FROM us_parks p, us_states s WHERE s.state = 'Wyoming' AND SDO_ANYINTERACT (p.geom, s.geom) = 'TRUE';
-- The incorrect way:
SELECT p.id, p.name FROM us_parks p, us_states s WHERE s.state = 'Wyoming' AND SDO_ANYINTERACT (s.geom, p.geom) = 'TRUE';

