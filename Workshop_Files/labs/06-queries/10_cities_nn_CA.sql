-- Get the five nearest cities to California
-- This actually returns 5 random cities in California
SELECT c.city, c.state_abrv
  FROM us_states s,
       us_cities c
 WHERE s.state_abrv = 'CA'
   AND sdo_nn(c.location, s.geom, 'sdo_num_res=5') = 'TRUE';

-- Get the five nearest cities to California (outside California)
-- The right way:

SELECT c.city, c.state_abrv
  FROM us_states s,
       us_cities c
 WHERE s.state_abrv = 'CA'
   AND sdo_nn(c.location, s.geom, 'sdo_batch_size=0', 1) = 'TRUE'
   AND sdo_nn_distance (1) > 0
   AND rownum <= 5;

