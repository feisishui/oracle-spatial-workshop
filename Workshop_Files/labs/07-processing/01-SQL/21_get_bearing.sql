create or replace function get_bearing (p1 sdo_geometry, p2 sdo_geometry)
return number 
is
  bearing number;
  tilt number;
begin
  sdo_util.bearing_tilt_for_points (p1, p2, 0.05, bearing, tilt);
  return sdo_util.convert_unit(bearing,'RADIAN','DEGREE');
end;
/
show error
