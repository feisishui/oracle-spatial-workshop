declare
  gc sdo_geo_addr;
  segment_geom sdo_geometry;
  geocode_geom sdo_geometry;
begin
  -- Geocode the address
  gc := sdo_gcdr.geocode (
    user,
    sdo_keywordarray(
      '1350 Clay Street',
      'San Francisco, CA'
    ),
    'US',
    'default'
  );
  -- Get the segment we geocoded to
  select geometry
  into segment_geom
  from gc_road_segment_us
  where road_segment_id = gc.edgeid;
  -- Offset the result 10 meters from the centerline
  geocode_geom := offset_geocode (
    segment_geom, gc.percent, gc.side, 10);
  -- Compare result with original result
  dbms_output.put_line ('Result: edgeid:'||gc.edgeid||' percent:'||gc.percent||' side:'||gc.side);
  dbms_output.put_line ('Original point: '||gc.longitude||' '||gc.latitude);
  dbms_output.put_line ('Adjusted point: '||geocode_geom.sdo_point.x||' '||geocode_geom.sdo_point.y);
end;
/
show errors