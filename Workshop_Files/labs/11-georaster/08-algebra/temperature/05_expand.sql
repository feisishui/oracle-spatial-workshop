--------------------------------------------------------------------------------
-- Expand the image
--------------------------------------------------------------------------------

declare
  gr6 			sdo_georaster;
  gr1 			sdo_georaster;
  beginDate date;
  endDate   date;
begin

  -- Read global temperature raster in Fahrenheit
  select RASTER, BEGINDATE, ENDDATE 
  into gr6, beginDate, endDate
  from PREP_TEMP_table where ID = 6;
  
  -- Initialize final raster 
  delete from TEMPERATURE_table where ID = 1;
  insert into TEMPERATURE_table (
    id, name, begindate, enddate, raster
  )
  values (
    1, 
    'Temperature in Fahrenheit (expanded)',
    beginDate, 
    endDate, 
    sdo_geor.init('TEMPERATURE_rdt',1)
  )
  return RASTER into gr1;

  -- Enlarge the raster by a factor 5
  sdo_geor.scaleCopy(
    inGeoRaster   => gr6,
    scaleParam    => 'scaleFactor=5',
    resampleParam => 'resampling=cubic nodata=true',
    storageParam  => 'blockSize=(128,128,1)',
    outGeoraster  => gr1
  );

  -- Save to database
  sdo_geor.setID( gr1, 'Temperature (1979-2011) - Expanded');
  update TEMPERATURE_table set raster = gr1 where ID = 1;

end;
/
