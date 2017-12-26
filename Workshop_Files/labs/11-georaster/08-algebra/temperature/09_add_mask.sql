--------------------------------------------------------------------------------
-- Apply the land mask
--------------------------------------------------------------------------------

declare
  gr99      sdo_georaster;
  gr100     sdo_georaster;
  gr        sdo_georaster;
  beginDate date;
  endDate   date;
begin

  ---------------------------------------------------------------
  -- Transform land mask raster into a simple bit map
  ---------------------------------------------------------------
  -- Read raster 99 (world map)
  select RASTER into gr99 from PREP_TEMP_table where ID = 99;
  -- Initialize new raster
  delete from PREP_TEMP_table where ID = 100;
  insert into PREP_TEMP_table (
    id, name, raster
  )
  values( 
    100, 
    'Land Mask (bitmap)',         
    sdo_geor.init('PREP_TEMP_rdt',100)
  )
  return RASTER into gr100;
  -- Transform original land mask into a bit map
  sdo_geor.changeFormatCopy(gr99, 'cellDepth=1BIT', gr100);
  -- Save to database
  sdo_geor.setID(gr100, 'Land Mask');
  update PREP_TEMP_table set raster = gr100 where ID = 100;

  -- Apply the land mask on all rasters:
  
  -- 1) Detailed monthly temperatures
  select RASTER into gr from TEMPERATURE_table where ID = 1;
  sdo_geor.setBitmapMask(gr, 0, gr100, 'true');
  update TEMPERATURE_table set raster = gr where ID = 1;
  
  -- 2) Monthly averages
  select RASTER into gr from TEMPERATURE_table where ID = 2;
  sdo_geor.setBitmapMask(gr, 0, gr100, 'true');
  update TEMPERATURE_table set raster = gr where ID = 2;
  
  -- 3) Anomalies
  select RASTER into gr from TEMPERATURE_table where ID = 3;
  sdo_geor.setBitmapMask(gr, 0, gr100, 'true');
  update TEMPERATURE_table set raster = gr where ID = 3;
  
end;
/
