create or replace function snap_to_ground (geom sdo_geometry, ground_height number)
  return sdo_geometry
  deterministic
is
  i number;
  g sdo_geometry;
  current_ground_height number;
  offset number;
begin
  g := geom;
  current_ground_height :=  sdo_geom.sdo_min_mbr_ordinate(g,3);
  offset := current_ground_height - ground_height;
  i := 0;
  while i < g.sdo_ordinates.count loop
    g.sdo_ordinates(i+3) := g.sdo_ordinates(i+3) - offset;
    i := i + 3;
  end loop;
  return g;
end;
/
show errors
