create or replace function reverse_geocode_on_router (point sdo_geometry)
return sdo_geo_addr
deterministic
as

/*
This function performs a simple reverse geocoding using the routing data (the EDGE table). It determines the EDGEID, PERCENT and SIDE values needed by the router as a pre-geocoded location.

It first uses the SDO_NN predicate to find the closest EDGE to the point passed as parameter. 
That search is limited to the nearest 100 meters. If no edge is found within that distance, then the function returns NULL.

It then converts the geometry of the selected edge to LRS with measures going from 0 to 1.

Using that LRS geometry, it extracts the measure (= distance of the point along the line) and the offset (distance between the point and the line).

The measure is a number between 0 and 1 and becomes the PERCENT value in the returned geo address structure.

Finally the sign of the offset determines the side (negative for right, positive for left).

Example of use:

select reverse_geocode_on_router(
  sdo_geometry(2001,8307,sdo_point_type(-122.4016,37.78415,null),null,null)
) 
from dual;

*/

  MAX_DISTANCE_IN_METERS number := 100;
  geo_addr sdo_geo_addr;
  edge_geom sdo_geometry;
  offset number;
begin
  -- Initialize geo address object
  geo_addr := sdo_geo_addr;

  -- Find the edge closest to the input point (within a chosen distance)
  -- If none is found within the chosen distance, return null
  begin
    select geometry, edge_id, name 
    into edge_geom, geo_addr.edgeid, geo_addr.streetname 
    from edge
    where sdo_nn(geometry,point,'sdo_num_res=1 distance='||MAX_DISTANCE_IN_METERS||' unit=meter') = 'TRUE';
  exception
    when no_data_found then
      return null;
  end;

  -- Make it LRS with measures from 0 to 1
  edge_geom := sdo_lrs.convert_to_lrs_geom (edge_geom, 0, 1);
  
  -- Get measure of the point on the LRS segment (between 0 and 1)
  geo_addr.percent := sdo_lrs.find_measure (
    geom_segment => edge_geom,
    point => point
  );
  
  -- Get the offset of the point
  offset := sdo_lrs.find_offset (
    geom_segment => edge_geom,
    point => point
  );
  
  -- Determine side from offset
  -- Positive offset means the left side
  -- Negative offset meand the right side
  -- Sides are based on the orientation of the geometry (first point to last point)
  if offset <0 then 
    geo_addr.side := 'R';
  else
    geo_addr.side := 'L';
  end if;
  
  -- Return the result
  return geo_addr;
end;
/
show errors
