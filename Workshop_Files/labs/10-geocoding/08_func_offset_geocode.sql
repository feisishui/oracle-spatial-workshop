create or replace function offset_geocode (
  segment_geom  sdo_geometry,
  percent       number,
  side          char,
  offset        number
)
return sdo_geometry
is
  segment_geom_lrs sdo_geometry;
  geocode_geom_lrs sdo_geometry;
  geocode_geom sdo_geometry;

begin
  -- Convert segment geometry to lrs
  segment_geom_lrs := sdo_lrs.convert_to_lrs_geom (
    standard_geom => segment_geom,
    start_measure => 0,
    end_measure => 1
  );
  -- Locate the geocoded result
  geocode_geom_lrs := sdo_lrs.locate_pt (
    geom_segment => segment_geom_lrs,
    measure => percent,
    offset =>
      case side
        when 'R' then offset
        when 'L' then -offset
      end
  );
  -- Convert result point to regular (non-LRS) point
  geocode_geom := sdo_lrs.convert_to_std_geom (geocode_geom_lrs);
  -- Return the result
  return geocode_geom;
end;
/
show errors
