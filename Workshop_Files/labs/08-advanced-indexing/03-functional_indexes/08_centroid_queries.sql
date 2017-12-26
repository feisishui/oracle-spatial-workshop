SELECT county, state_abrv, 
       sdo_geom.sdo_centroid(geom,0.5)
FROM   us_counties
WHERE  sdo_within_distance(
         sdo_geom.sdo_centroid(geom,0.5), 
           sdo_geometry(2001,8307, 
             sdo_point_type(-73,42,NULL),NULL,NULL
         ), 
         'distance = 100 unit = MILE'
) = 'TRUE';

