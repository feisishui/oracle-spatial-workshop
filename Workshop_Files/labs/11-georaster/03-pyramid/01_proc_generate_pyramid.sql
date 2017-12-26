create or replace procedure generate_pyramid (
  start_id number,
  end_id number
)
is
  v_raster sdo_georaster;
begin
  for g in (
    select *
    from us_rasters 
    where sdo_geor.getpyramidtype(georaster) = 'NONE'
    and georid between start_id and end_id
  )
  loop
    v_raster := g.georaster;

    -- Generate resolution pyramid
    sdo_geor.generatePyramid(v_raster, 'resampling=NN');

    -- Update the raster object
    update us_rasters set
      georaster = v_raster
    where georid = g.georid;
    
    -- Commit so we can easily restart
    commit;
    
  end loop;
end;
/
show errors
