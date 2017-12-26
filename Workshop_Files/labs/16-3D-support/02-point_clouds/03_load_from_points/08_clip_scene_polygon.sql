DROP TABLE lidar_points_clip PURGE;

CREATE TABLE lidar_points_clip
NOLOGGING
PARALLEL
AS
WITH parks AS (
  SELECT sdo_cs.transform (geom, 32617) geom
  FROM   us_parks
  WHERE  name = 'Serpent Mound State Memorial'
) 
SELECT p.* 
FROM 
TABLE (
  sdo_pointinpolygon (
    cursor (
      select * from lidar_points
    ), 
    (select geom from parks),
    0.05,
    null
  )
) P;
