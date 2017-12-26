-- --------------------------------------------------------------
-- Full 3D queries
-- --------------------------------------------------------------

-- Get the 3D building interacting with a 3D point
SELECT building_id, (height - ground_height) height
FROM   buildings_ext
WHERE  SDO_ANYINTERACT (
         geom,
         SDO_GEOMETRY (
           3001, 7405, SDO_POINT_TYPE (442249, 111480, 8),
           null,null
         )
       ) = 'TRUE';

-- Same but the 3D point is in WGS84 (GPS) coordinates
SELECT building_id, (height - ground_height) height
FROM   buildings_ext
WHERE  sdo_anyinteract (
         geom,
         SDO_GEOMETRY(
           3001, 4327, SDO_POINT_TYPE (-1.400562, 50.9012567, 55.0693992),
           null,null
         )
       ) = 'TRUE';


-- Get all buildings withing 50 meters from one specific building
SELECT b1.building_id,
       SDO_GEOM.SDO_DISTANCE (
         b1.geom, b2.geom, 0.05) distance,
       (b1.height - b1.ground_height) height
FROM   buildings_ext b1,
       buildings_ext b2
WHERE  SDO_WITHIN_DISTANCE (
         b1.geom, b2.geom, 'distance=50 unit=m'
       ) = 'TRUE'
AND    b2.building_id = 42
ORDER BY distance;

-- Get the 5 nearest buildings from a 3D point
SELECT building_id,
       SDO_NN_DISTANCE (1) distance,
       (height - ground_height) height
FROM   buildings_ext
WHERE  SDO_NN (
         geom,
         SDO_GEOMETRY (
           3001, 7405, SDO_POINT_TYPE (442249, 111480, 8),
           null,null
         ),
         'sdo_num_res=5 unit=m', 1
       ) = 'TRUE'
ORDER BY distance;

-- Same but the 3D point is in WGS84 (GPS) coordinates
SELECT building_id,
       SDO_NN_DISTANCE (1) distance,
       (height - ground_height) height
FROM   buildings_ext
WHERE  SDO_NN (
         geom,
         SDO_GEOMETRY (
           3001, 4327, SDO_POINT_TYPE (-1.400562, 50.9012567, 55.0693992),
           null,null
         ),
         'sdo_num_res=5 unit=m', 1
       ) = 'TRUE'
ORDER BY distance;

-- Get the 5 nearest buildings from a selected building
SELECT b1.building_id,
       SDO_NN_distance (1) distance,
       (b1.height - b1.ground_height) height
FROM   buildings_ext b1,
       buildings_ext b2
WHERE  SDO_NN (
         b1.geom,
         b2.geom,
         'sdo_num_res=5 unit=m', 1
       ) = 'TRUE'
AND    b2.building_id = 42
ORDER BY distance;

-- Get the 4 nearest buildings from a selected building that are over 20 meters high
SELECT b1.building_id,
       SDO_NN_distance (1) distance,
       (b1.height - b1.ground_height) height
FROM   buildings_ext b1,
       buildings_ext b2
WHERE  SDO_NN (
         b1.geom,
         b2.geom,
         'sdo_batch_size=0 unit=m', 1
       ) = 'TRUE'
AND    b2.building_id = 42
AND    (b1.height - b1.ground_height) > 20
AND    rownum <= 4;

-- Get the building closest to selected building and that is over 2 meters taller
SELECT b1.building_id,
       SDO_NN_distance (1) distance,
       (b1.height - b1.ground_height) height
FROM   buildings_ext b1,
       buildings_ext b2
WHERE  SDO_NN (
         b1.geom,
         b2.geom,
         'sdo_batch_size=0 unit=m', 1
       ) = 'TRUE'
AND    b2.building_id = 42
AND    (b1.height - b1.ground_height) - (b2.height - b2.ground_height) > 2
AND    rownum <= 1;

-- --------------------------------------------------------------
-- Query 2D data using a 3D window
-- --------------------------------------------------------------

-- Get the building footprints (2D) interacting with a 3D point
-- NOTE:
--   In 11.1.0.6, this fails with:
--      "ORA-13243: specified operator is not supported for 3- or higher-dimensional R-tree"
--   In 11.1.0.7 AND later, it succeeds
SELECT building_id
FROM   building_footprints
WHERE  sdo_anyinteract (
         geom,
         SDO_GEOMETRY (
           3001, 7405, SDO_POINT_TYPE (442249, 111480, 8),
           null,null
         )
       ) = 'TRUE';

-- --------------------------------------------------------------
-- Query 3D data using a 2D window
-- --------------------------------------------------------------

-- Get the building (3D) interacting with a 2D point
-- NOTE:
--   In 11.1.0.6, this fails with:
--      "ORA-13030: Invalid dimension for the SDO_GEOMETRY object"
--   In 11.1.0.7 AND later, it completes but returns no result
--      Thhe 2D point is turned into a 3D point with Z = 0.
SELECT building_id
FROM   buildings_ext
WHERE  sdo_anyinteract (
         geom,
         SDO_GEOMETRY (
           2001, 27700, SDO_POINT_TYPE (442249, 111480, null),
           null,null
         )
       ) = 'TRUE';
