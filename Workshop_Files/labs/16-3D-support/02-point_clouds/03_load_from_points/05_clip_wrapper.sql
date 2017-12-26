CREATE OR REPLACE FUNCTION get_points (
  geometry        SDO_GEOMETRY,
  table_name      VARCHAR2,
  tolerance       NUMBER,
  other_dim_qry   SDO_MBR default NULL,
  mask            VARCHAR2 default NULL
)
RETURN points PIPELINED
AS
  points_cursor sys_refcursor;
  TYPE points_list IS TABLE OF lidar_points%rowtype;
  p points_list;
BEGIN
  points_cursor :=
    SDO_PC_PKG.CLIP_PC_FLAT (
      geometry,    
      table_name,
      tolerance,
      other_dim_qry,
      mask
    );
  LOOP
    FETCH points_cursor 
      BULK COLLECT INTO p 
      LIMIT 10000;
    FOR I in 1 .. p.COUNT LOOP
      PIPE ROW (
        point (
          p(i).x,
          p(i).y,
          p(i).z,
          p(i).intensity,
          p(i).return_number,
          p(i).number_of_returns,
          p(i).scan_direction,
          p(i).edge_of_flight_line,
          p(i).classification,
          p(i).scan_angle,
          p(i).user_data,
          p(i).point_source_id,
          p(i).gpstime
        )       
      );
    END LOOP;
    EXIT WHEN points_cursor%NOTFOUND;
  END LOOP;
END;
/
show errors
