declare
  v_raster              sdo_georaster;
  v_start               timestamp;
  v_elapsed             interval day to second;
  v_load_duration       number;
  v_pyramid_duration    number;
begin
  for g in (
    select *
    from us_rasters
    order by georid
  )
  loop
    v_raster := g.georaster;

    -- Generate resolution pyramid
    v_start := current_timestamp;
    sdo_geor.generatePyramid(v_raster, 'resampling=NN');
    v_elapsed := current_timestamp - v_start;
    v_pyramid_duration := extract (minute from v_elapsed) * 60 + extract (second from v_elapsed);

    -- Update the raster object
    update us_rasters set
      georaster = v_raster,
      pyramid_duration = v_pyramid_duration
    where georid = g.georid;

    commit;
  end loop;
end;
/
