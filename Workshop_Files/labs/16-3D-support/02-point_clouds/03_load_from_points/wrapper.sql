CREATE OR REPLACE FUNCTION get_points (
  points_cursor sys_refcursor
)
RETURN points PIPELINED
AS
  TYPE points_list IS TABLE OF lidar_points%rowtype;
  p points_list;
BEGIN
  FETCH points_cursor BULK COLLECT INTO p;
  FOR i IN 1..p.count
  LOOP 
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
END;
/
show errors
