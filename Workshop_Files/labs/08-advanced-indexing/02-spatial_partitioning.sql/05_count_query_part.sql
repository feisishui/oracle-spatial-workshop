-- 1) Count the number of restaurants within 8 miles of a location

SELECT count(*)
FROM   yellow_pages_part_spatial
WHERE  sdo_within_distance (
         location,
         sdo_geometry (2001, 8307,
           sdo_point_type (-73.8, 40.7, null), null, null),
         'distance=8 unit=mile') = 'TRUE'
AND    category = 1;

-- 2) Count the number of restaurants and hotels within 8 miles of a location

SELECT count(*)
FROM   yellow_pages_part_spatial
WHERE  sdo_within_distance (
         location,
         sdo_geometry (2001, 8307,
           sdo_point_type (-73.8, 40.7, null), null, null),
         'distance=8 unit=mile') = 'TRUE'
AND    category in (1,5);

-- 3) Count the number of businesses (any kind) within 8 miles of a location

SELECT count(*)
FROM   yellow_pages_part_spatial
WHERE  sdo_within_distance (
         location,
         sdo_geometry (2001, 8307,
           sdo_point_type (-73.8, 40.7, null), null, null),
         'distance=8 unit=mile') = 'TRUE';

-- 4) See how many cells we actually query

SELECT count(*) nrows, count(distinct cell_id) cells
FROM   yellow_pages_part_spatial
WHERE  sdo_within_distance (
         location,
         sdo_geometry (2001, 8307,
           sdo_point_type (-73.8, 40.7, null), null, null),
         'distance=8 unit=mile') = 'TRUE';

-- 5) Simulate a viewing query
SELECT count(*), count(distinct cell_id)
FROM   yellow_pages_part_spatial
WHERE  sdo_filter (
         location,
         sdo_geometry (2003, 8307, null,
           sdo_elem_info_array (1,1003,3),
           sdo_ordinate_array (-73.952, 40.585, -73.648, 40.815)
         )
       ) = 'TRUE';
