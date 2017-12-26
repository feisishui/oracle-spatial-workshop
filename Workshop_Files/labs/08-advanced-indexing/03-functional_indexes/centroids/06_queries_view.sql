SELECT *
FROM us_counties_centroids 
WHERE sdo_within_distance(
        centroid, 
        sdo_geometry(2001,8307, 
          sdo_point_type(-73,42,NULL),NULL,NULL), 
       'distance = 100 unit = MILE') = 'TRUE';

select id, county, state_abrv 
FROM us_counties_centroids 
WHERE sdo_within_distance(
        centroid, 
        sdo_geometry(2001,8307, 
          sdo_point_type(-73,42,NULL),NULL,NULL), 
       'distance = 100 unit = MILE') = 'TRUE';

