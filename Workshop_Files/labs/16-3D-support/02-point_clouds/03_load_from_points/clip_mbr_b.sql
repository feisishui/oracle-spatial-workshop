truncate table lidar_points_clip;
DECLARE
  points_cursor sys_refcursor;
  TYPE points_list IS TABLE OF lidar_points%rowtype;
  points points_list;
BEGIN
  points_cursor :=
    SDO_PC_PKG.CLIP_PC_FLAT (
      geometry =>
        SDO_GEOMETRY (
          2003,
          32617,
          NULL,
          SDO_ELEM_INFO_ARRAY (1, 1003, 3),
          SDO_ORDINATE_ARRAY (
            289600, 4321100, 289700, 4321200
          )
        ),
      table_name    => 'LIDAR_POINTS',
      tolerance     => 0.05,
      other_dim_qry => null,
      mask          => null
    );
  LOOP
    FETCH points_cursor 
      BULK COLLECT INTO points 
      LIMIT 10000;
    FOR I in 1 .. points.COUNT LOOP
      insert into lidar_points_clip values points(i);
    END LOOP;
    EXIT WHEN points_cursor%NOTFOUND;
  END LOOP;
  CLOSE points_cursor;
END;
/
select count(*) from lidar_points_clip;
