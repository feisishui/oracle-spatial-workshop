declare
  v_raster    sdo_georaster;
  v_nbands    number;
  v_stats     sdo_number_array;
  v_window    sdo_geometry;
  i           number;
begin
  -- Process rasters onne by one
  for g in (
    select *
    from us_rasters
    order by georid
  )
  loop
    -- Read the raster object (metadata only)
    v_raster := g.georaster;
    -- Get the number of bands
    v_nbands := SDO_GEOR.getBandDimSize(v_raster);
    dbms_output.put_line('Raster '||g.georid || ' ('||v_nbands||' bands)');
    -- Get the statistigs for each band
    for i in 1..v_nbands loop
      v_stats := sdo_geor.generateStatistics(
        georaster => v_raster,
        pyramidLevel => 0,
        samplingFactor => 'samplingFactor=1',
        samplingWindow => v_window,
        bandNumbers => i-1
      );
      -- Show the statistics
      dbms_output.put_line('* Band '||(i-1));
      dbms_output.put_line('-  min='||v_stats(1));  
      dbms_output.put_line('-  max='||v_stats(2));
      dbms_output.put_line('-  mean='||v_stats(3));
      dbms_output.put_line('-  median='||v_stats(4));
      dbms_output.put_line('-  mode='||v_stats(5));
      dbms_output.put_line('-  std='||v_stats(6));
    end loop;
  end loop;
end;
/
show errors
