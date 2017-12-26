DECLARE
  my_cursor sys_refcursor;
  TYPE rec IS RECORD(x NUMBER, y NUMBER, z number);
  TYPE lst IS TABLE OF rec;
  result_list lst;
BEGIN
  my_cursor :=
    SDO_PC_PKG.CLIP_PC_FLAT (
      geometry =>
        SDO_GEOMETRY (
        2003,
        32617,
        NULL,
        SDO_ELEM_INFO_ARRAY (1, 1003, 1),
        SDO_ORDINATE_ARRAY (
          289650, 4321200,    
          289600, 4321150,
          289650, 4321100,    
          289700, 4321150,
          289650, 4321200
        )
      ),
      table_name    => 'LIDAR_POINTS',
      tolerance     => 0.05,
      other_dim_qry => null,
      mask          => null
    );
 
  FETCH my_cursor BULK COLLECT INTO result_list;
  FOR I in 1 .. result_list.COUNT LOOP
    dbms_output.put_line(
      '(' || result_list(i).x || ', ' ||
             result_list(i).y || ', ' ||
             result_list(i).z || ')');
  END LOOP;
  CLOSE my_cursor;
END;
/
