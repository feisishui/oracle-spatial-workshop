create or replace function get_point (
  geom sdo_geometry, point_number number) return sdo_geometry
is
  i  number;            -- Index into ordinates array
  px number;            -- X of extracted point
  py number;            -- Y of extracted point
begin
  -- Get index into ordinates array
  i := (point_number-1) * geom.get_dims() + 1;
  -- Extract the X and Y coordinates of the desired point
  px := geom.sdo_ordinates(i);
  py := geom.sdo_ordinates(i+1);
  -- Construct and return the point
  return
    sdo_geometry (2001, geom.sdo_srid,
      sdo_point_type (px, py, null), null, null);
end;
/
