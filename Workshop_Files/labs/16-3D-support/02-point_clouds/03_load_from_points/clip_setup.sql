DROP TABLE lidar_points_clip PURGE;

CREATE TABLE lidar_points_clip AS 
SELECT * FROM lidar_points
where 0 = 1;

