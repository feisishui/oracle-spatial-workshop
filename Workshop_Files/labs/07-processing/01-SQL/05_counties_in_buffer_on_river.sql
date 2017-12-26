-- 1) Find counties within 10km of the North Platte
SELECT c.county, c.state_abrv
  FROM us_counties c, us_rivers r
 WHERE SDO_within_distance (c.geom, r.geom, 'distance=10 unit=km') = 'TRUE'
   AND r.name = 'North Platte';

-- 2) Compute the area of the section of each county within 10km of the river
SELECT c.county, c.state_abrv,
       sdo_geom.sdo_area (
         sdo_geom.sdo_intersection (
           c.geom,
           sdo_geom.sdo_buffer (r.geom, 10, 0.5, 'unit=km'),
           0.5
         ),
         0.5,
         'unit=sq_km'
       ) section_area
  FROM us_counties c, us_rivers r
 WHERE SDO_within_distance (c.geom, r.geom, 'distance=10 unit=km') = 'TRUE'
   AND r.name = 'North Platte';

-- 3) Also show the total area of each county
SELECT c.county, c.state_abrv,
       sdo_geom.sdo_area (
         sdo_geom.sdo_intersection (
           c.geom,
           sdo_geom.sdo_buffer (r.geom, 10, 0.5, 'unit=km'),
           0.5
         ),
         0.5,
         'unit=sq_km'
       ) section_area,
       sdo_geom.sdo_area (
         c.geom,
         0.5,
         'unit=sq_km'
       ) county_area
  FROM us_counties c, us_rivers r
 WHERE SDO_within_distance (c.geom, r.geom, 'distance=10 unit=km') = 'TRUE'
   AND r.name = 'North Platte';

-- 4) Now also show the percentage of the area of each county within 10km of North Platte
SELECT county, state_abrv, county_area, section_area, section_area/county_area*100 pct
  FROM (
    SELECT c.county, c.state_abrv,
           sdo_geom.sdo_area (
             sdo_geom.sdo_intersection (
               c.geom,
               sdo_geom.sdo_buffer (r.geom, 10, 0.5, 'unit=km'),
               0.5
             ),
             0.5,
             'unit=sq_km'
           ) section_area,
           sdo_geom.sdo_area (
             c.geom,
             0.5,
             'unit=sq_km'
           ) county_area
      FROM us_counties c, us_rivers r
     WHERE SDO_within_distance (c.geom, r.geom, 'distance=10 unit=km') = 'TRUE'
       AND r.name = 'North Platte'
  )
ORDER BY pct DESC;

