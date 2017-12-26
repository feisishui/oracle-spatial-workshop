CREATE OR REPLACE VIEW lidar_points_view
AS
SELECT * 
FROM LIDAR_POINTS
where x between 289600 and 289700
and y between 4321100 and 4321200;
select count(*) from lidar_points_view;