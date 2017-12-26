create or replace function remove_attributes (geom_in sdo_geometry, new_dimension number := 3)
return sdo_geometry
is
  geom_out sdo_geometry;
  dimension number;
  num_points number;
  i number;
  j number;
  k number;
begin
  -- Extract information from the input geometry
  dimension := geom_in.get_dims();
  num_points := geom_in.sdo_ordinates.count / dimension;


  -- If geometry is already 3D or 2D, then just return it
  if dimension = new_dimension then
    return geom_in;
  end if;

  -- Initialize output geometry
  geom_out := sdo_geometry (
    new_dimension*1000+5,   -- SDO_GTYPE: 2 or 3D multi-point (2005 or 3005)
    geom_in.sdo_srid,       -- SDO_SRID: same as input
    null,                   -- SDO_POINT: not used
    geom_in.sdo_elem_info,  -- SDO_ELEM_INFO: same as input
    sdo_ordinate_array()    -- SDO_ORDINATES: empty
  );

  -- Setup the ordinate array
  geom_out.sdo_ordinates.extend(new_dimension * num_points);

  -- Copy the points
  j := 0;
  k := 0;
  for i in 1..num_points loop
    geom_out.sdo_ordinates (j+1) := geom_in.sdo_ordinates (k+1); -- Copy X
    geom_out.sdo_ordinates (j+2) := geom_in.sdo_ordinates (k+2); -- Copy Y
    geom_out.sdo_ordinates (j+3) := geom_in.sdo_ordinates (k+3); -- Copy Z
    j := j + new_dimension;
    k := k + dimension;
  end loop;

  -- Return the fixed geometry
  return geom_out;
end;
/
show errors
