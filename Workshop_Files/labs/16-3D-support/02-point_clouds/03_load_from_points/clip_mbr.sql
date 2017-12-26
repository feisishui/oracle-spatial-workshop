truncate table lidar_points_clip;
DECLARE
  points_cursor sys_refcursor;
  point lidar_points%rowtype;
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
    fetch points_cursor into point;
      exit when points_cursor%NOTFOUND;
    insert into lidar_points_clip values point;
  END LOOP;
  CLOSE points_cursor;
END;
/
select count(*) from lidar_points_clip;
