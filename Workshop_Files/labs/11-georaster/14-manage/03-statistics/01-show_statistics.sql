set serveroutput on
declare
  v_raster    sdo_georaster;
  v_stats     sdo_number_array;
  v_window    sdo_geometry;
begin
  -- Process rasters one by one
  for g in (
    select *
    from us_rasters
    order by georid
  )
  loop
    -- Read the raster object (metadata only)
    v_raster := g.georaster;
    -- Get the statistics for all layers combined
    v_stats := sdo_geor.generateStatistics(
      georaster => v_raster,
      pyramidLevel => 0,
      samplingFactor => 'samplingFactor=1',
      samplingWindow => v_window
    );
    -- Show the statistics
    dbms_output.put_line('Raster '||g.georid);
    dbms_output.put_line('-  min='||v_stats(1));  
    dbms_output.put_line('-  max='||v_stats(2));
    dbms_output.put_line('-  mean='||v_stats(3));
    dbms_output.put_line('-  median='||v_stats(4));
    dbms_output.put_line('-  mode='||v_stats(5));
    dbms_output.put_line('-  std='||v_stats(6));
  end loop;
end;
/
show errors
