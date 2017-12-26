declare
  v_raster    sdo_georaster;
  v_start     timestamp;
  v_elapsed   interval day to second;
  v_duration  number;
  
begin

  -- Process rasters that have no pyramid yet
  for g in (
    select *
    from us_rasters_3857
    where sdo_geor.getpyramidtype(georaster) = 'NONE'
    order by georid
  )
  loop
    dbms_output.put_line ('Pyramiding raster '|| g.georid || ' ' || g.source_file);
    -- Read the raster object (metadata only)
    v_raster := g.georaster;

    -- Generate resolution pyramid
    v_start := current_timestamp;
    sdo_geor.generatePyramid(v_raster, 'resampling=NN');
    v_elapsed := current_timestamp - v_start;
    v_duration := 
      extract (hour from v_elapsed * 36000) + 
      extract (minute from v_elapsed) * 60 + 
      extract (second from v_elapsed);

    -- Update the raster object
    update us_rasters_3857 set
      georaster = v_raster,
      pyramid_duration = v_duration
    where georid = g.georid;

    -- Commit and continue with next one.
    commit;
    dbms_output.put_line ('Pyramiding raster '|| g.georid || ' completed in ' ||  v_duration || ' seconds');
    
  end loop;
end;
/
show errors
