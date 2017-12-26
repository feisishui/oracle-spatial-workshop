set serveroutput on
declare
  v_raster    sdo_georaster;
  v_max       number;
  v_window    sdo_geometry;
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
    -- Get the max value for all bands
    v_max := sdo_geor.generateStatisticsMax(
      georaster => v_raster,
      pyramidLevel => 0,
      samplingFactor => 'samplingFactor=1',
      samplingWindow => v_window
    );
    -- Show the statistic
    dbms_output.put_line('Raster '||g.georid||' max='||v_max);  
  end loop;
end;
/
show errors
