-- Create a function that produces a point object from a set of X and Y coordinates
create or replace function get_point (
  longitude in number,
  latitude  in number)
return sdo_geometry deterministic is
begin
  return
    sdo_geometry (
      2001, 8307,
      sdo_point_type (longitude, latitude, null),
      null, null
    );
end;
/
