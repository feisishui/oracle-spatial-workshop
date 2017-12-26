CREATE OR REPLACE VIEW lidar_points_view
AS
SELECT * 
FROM TABLE (
  get_points (
    SDO_GEOMETRY (
      2003,
      32617,
      NULL,
      SDO_ELEM_INFO_ARRAY (1, 1003, 3),
      SDO_ORDINATE_ARRAY (
        289600, 4321100,    
        289700, 4321200
      )
    ),    
    'LIDAR_POINTS',
    0.05,
    null,
    null
  )
);
select count(*) from lidar_points_view;