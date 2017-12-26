declare
  v_raster              sdo_georaster;
begin
 
  -- Insert new raster object to receive the mosaic
  insert into us_rasters_mosaic (georid, georaster)
  values (
    1,
    sdo_geor.init ('US_RASTERS_MOSAIC_RDT_01',1)
  )
  returning georaster into v_raster;

  -- Generate the mosaic
  sdo_geor.mosaic(
    'US_RASTERS',
    'GEORASTER',
    v_raster,
    null
   -- 'blocksize=(550,550,1)'
  );

  -- Update the raster object
  update us_rasters_mosaic set
    georaster = v_raster
  where georid = 1;
end;
/

