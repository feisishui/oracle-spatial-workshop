declare
  v_raster    sdo_georaster;
  v_status    varchar2(16);
  v_window    sdo_geometry;
begin
  -- Process rasters onne by one
  for g in (
    select *
    from us_rasters
  )
  loop
    -- Read the raster object (metadata only)
    v_raster := g.georaster;
    
    -- Generate the statistics for all layers, including layer 0
    v_status := sdo_geor.generateStatistics(
      georaster => v_raster,
      samplingFactor => 'samplingFactor=1',
      samplingWindow => v_window,
      histogram => 'FALSE',                   -- No histogram is generated
      layerNumbers => NULL                    -- Apply to all layers (0-N)
    );
    
    -- Update the raster object
    update us_rasters set
      georaster = v_raster
    where georid = g.georid;
  end loop;
  
end;
/
show errors