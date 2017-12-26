-- 1) Count the number of restaurants within 8 miles of a location

SELECT count(*)
FROM   yellow_pages
WHERE  sdo_within_distance (
         location,
         sdo_geometry (2001, 8307,
           sdo_point_type (-73.8, 40.7, null), null, null),
         'distance=8 unit=mile') = 'TRUE'
AND    category = 1;

-- (same, but disable the category index)

SELECT /*+  no_index (yellow_pages YP_CATEGORY_IDX)*/ count(*)
FROM   yellow_pages
WHERE  sdo_within_distance (
         location,
         sdo_geometry (2001, 8307,
           sdo_point_type (-73.8, 40.7, null), null, null),
         'distance=8 unit=mile') = 'TRUE'
AND    category = 1;

--  2) Count the number of restaurants and hotels within 8 miles of a location

SELECT count(*)
FROM   yellow_pages
WHERE  sdo_within_distance (
         location,
         sdo_geometry (2001, 8307,
           sdo_point_type (-73.8, 40.7, null), null, null),
         'distance=8 unit=mile') = 'TRUE'
AND    category in (1,5);

-- 3) Count the number of businesses (any kind) within 8 miles of a location

SELECT count(*)
FROM   yellow_pages
WHERE  sdo_within_distance (
         location,
         sdo_geometry (2001, 8307,
           sdo_point_type (-73.8, 40.7, null), null, null),
         'distance=8 unit=mile') = 'TRUE';
