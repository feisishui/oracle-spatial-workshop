-- Which states does Yellowstone National Park overlap ?SELECT s.state  FROM us_states s, us_parks p WHERE SDO_ANYINTERACT (s.geom, p.geom) = 'TRUE'   AND p.name = 'Yellowstone NP';
-- Which states does Yellowstone National Park overlap ?-- The correct way:
SELECT s.state  FROM us_states s, us_parks p WHERE SDO_ANYINTERACT (s.geom, p.geom) = 'TRUE' AND p.name = 'Yellowstone NP';
-- The incorrect way:
SELECT s.state  FROM us_states s, us_parks p WHERE SDO_ANYINTERACT (p.geom, s.geom) = 'TRUE' AND p.name = 'Yellowstone NP';

