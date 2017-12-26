create or replace function make_line (
  point_cursor sys_refcursor,
  srid number default 4326
)
return sdo_geometry
as
  line_geom sdo_geometry;
  longitude number;
  latitude number;
  i number;
begin
  -- Initialize line geometry object
  line_geom := sdo_geometry (
    2002, srid, null, 
    sdo_elem_info_array (1,2,1),
    sdo_ordinate_array()
  );
  -- Fetch points and load into ordinate array
  i := 0;
  loop
    fetch point_cursor into longitude, latitude;
      exit when point_cursor%NOTFOUND;
    line_geom.sdo_ordinates.extend(2);
    line_geom.sdo_ordinates(i+1) := longitude;
    line_geom.sdo_ordinates(i+2) := latitude;
    i := i + 2;
  end loop;
  close point_cursor;
  -- If the line has no points, then return NULL
  if i = 0 then
    line_geom := NULL;
  end if;
  -- Return the line
  return line_geom; 
end;
/
show errors
