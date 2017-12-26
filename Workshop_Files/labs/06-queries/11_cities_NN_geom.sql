-- Get the 5 nearest cities from Washington DC
SELECT c1.id, c1.city, c1.state_abrv
  FROM us_cities c2,
       us_cities c1
 WHERE c2.city = 'Washington'
   AND sdo_nn (c1.location, c2.location,'sdo_num_res=5') = 'TRUE'
 ORDER BY c1.state_abrv, c1.city;

-- Get the 5 nearest cities  from Washington DC, within a region
-- Does not work: returns only 3 rows
SELECT c1.id, c1.city, c1.state_abrv
  FROM us_cities c2,
       us_cities c1
 WHERE c2.id=19
   AND sdo_nn (c1.location, c2.location,'sdo_num_res=5') = 'TRUE'
   AND sdo_inside (
         c1.location,
         sdo_geometry(2003, 8307, null,
           sdo_elem_info_array(1,1003,1),
           sdo_ordinate_array(
             -78.965,36.377, -75.341,36.377, -75.341,39.039, -78.965,39.039,-78.965,36.377
           )
         )
       ) = 'TRUE';

-- Get the N nearest cities from a city, that are within a selected region
-- Origin city is identified by name
-- Does not work: ORA-13249: SDO_NN cannot be evaluated without using index
-- This is because the optimizer chooses to use the spatial index for the SDO_INSIDE filter, but not for SDO_NN
SELECT c1.id, c1.city, c1.state_abrv
  FROM us_cities c2,
       us_cities c1
 WHERE c2.city = 'Washington'
   AND sdo_nn (c1.location, c2.location,'sdo_num_res=5') = 'TRUE'
   AND sdo_inside (
         c1.location,
         sdo_geometry(2003, 8307, null,
           sdo_elem_info_array(1,1003,1),
           sdo_ordinate_array(
             -78.965,36.377, -75.341,36.377, -75.341,39.039, -78.965,39.039,-78.965,36.377
           )
         )
       ) = 'TRUE';


-- Get the N nearest cities from a city, that are within a selected region
-- Origin city is identified by name
-- Still does not work: ORA-13249: SDO_NN cannot be evaluated without using index
-- This is because the optimizer again chooses to use the spatial index for the SDO_INSIDE filter, but not for SDO_NN
SELECT c1.id, c1.city, c1.state_abrv
  FROM us_cities c2,
       us_cities c1
 WHERE c2.city = 'Washington'
   AND sdo_nn (c1.location, c2.location) = 'TRUE'
   AND sdo_inside (
         c1.location,
         sdo_geometry(2003, 8307, null,
           sdo_elem_info_array(1,1003,1),
           sdo_ordinate_array(
             -78.965,36.377, -75.341,36.377, -75.341,39.039, -78.965,39.039,-78.965,36.377
           )
         )
       ) = 'TRUE'
   AND rownum <= 5;

-- Get the N nearest cities from a city, that are within a selected region
-- OK
SELECT c1.id, c1.city, c1.state_abrv
  FROM us_cities c2,
       us_cities c1
 WHERE c2.id = 19
   AND sdo_nn (c1.location, c2.location) = 'TRUE'
   AND sdo_inside (
         c1.location,
         sdo_geometry(2003, 8307, null,
           sdo_elem_info_array(1,1003,1),
           sdo_ordinate_array(
             -78.965,36.377, -75.341,36.377, -75.341,39.039, -78.965,39.039,-78.965,36.377
           )
         )
       ) = 'TRUE'
   AND rownum <= 5;

-- Get the N nearest cities from a city, that are within a selected region
-- Use an explicit secondary filter call
-- OK
SELECT c1.id, c1.city, c1.state_abrv
  FROM us_cities c2,
       us_cities c1
 WHERE c2.id = 19
   AND sdo_nn (c1.location, c2.location) = 'TRUE'
   AND sdo_geom.relate (
         c1.location,
         'inside',
         sdo_geometry(2003, 8307, null,
           sdo_elem_info_array(1,1003,1),
           sdo_ordinate_array(
             -78.965,36.377, -75.341,36.377, -75.341,39.039, -78.965,39.039,-78.965,36.377
           )
         ),
         0.05
       ) = 'INSIDE'
   AND rownum <= 5;

-- Get the N nearest cities from a city, that are within a selected region
-- Use an explicit secondary filter call
-- OK
SELECT c1.id, c1.city, c1.state_abrv
  FROM us_cities c2,
       us_cities c1
 WHERE c2.city = 'Washington'
   AND sdo_nn (c1.location, c2.location) = 'TRUE'
   AND sdo_geom.relate (
         c1.location,
         'inside',
         sdo_geometry(2003, 8307, null,
           sdo_elem_info_array(1,1003,1),
           sdo_ordinate_array(
             -78.965,36.377, -75.341,36.377, -75.341,39.039, -78.965,39.039,-78.965,36.377
           )
         ),
         0.05
       ) = 'INSIDE'
   AND rownum <= 5;


-- Get the N nearest cities from a city, that are within a state
-- Use an explicit secondary filter call
-- OK
SELECT c1.id, c1.city, c1.state_abrv
  FROM us_cities c2,
       us_cities c1
 WHERE c2.city = 'Washington'
   AND sdo_nn (c1.location, c2.location) = 'TRUE'
   AND sdo_geom.relate (
         c1.location,
         'inside',
         (select geom from us_states where state_abrv = 'VA'),
         0.05
       ) = 'INSIDE'
   AND rownum <= 5;
