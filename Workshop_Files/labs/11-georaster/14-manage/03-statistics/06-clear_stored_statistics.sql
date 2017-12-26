declare
  v_raster    sdo_georaster;
  v_status    varchar2(16);
  v_window    sdo_geometry;
  v_nbands    number;
begin
  -- Process rasters onne by one
  for g in (
    select *
    from us_rasters
  )
  loop
    -- Read the raster object (metadata only)
    v_raster := g.georaster;
    
    -- Get the number of bands
    v_nbands := SDO_GEOR.getBandDimSize(v_raster);
    
    -- Clear the statistics for all bands. Need
    for i in 0..v_nbands loop
      sdo_geor.setStatistics(
        georaster => v_raster,
        layerNumber => i,                      
        statistics => NULL                     
      );
    end loop;
    
    -- Update the raster object
    update us_rasters set
      georaster = v_raster
    where georid = g.georid;
    
  end loop;
end;
/
show errors
