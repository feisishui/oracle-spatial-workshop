--------------------------------------------------------------------------------
-- load Tiff files with temperature data and land mask to data preparation table
--------------------------------------------------------------------------------

declare
  RASTER_DIR        varchar2(256) := '/media/sf_Spatial-Workshop/labs/11-georaster/temperature';
  temperature_file  varchar2(256) := '/rss_tb_maps_ch_tlt_v3_3_temperature.tif';
  land_mask_file    varchar2(256) := '/WORLD_BORDERS.tif';
  gr1               sdo_georaster;
  gr99              sdo_georaster;

begin

  -- Delete any existing data
  delete from prep_temp_table;
  
  -- Initialize the temperature raster
  insert into prep_temp_table (
    id, name, begindate, enddate, raster
  )
  values( 
    1, 
    'Month Lower Troposphere Temperature in Kelvin',
    TO_DATE('1978-1-1','YYYY-MM-DD'), 
    TO_DATE('2012-12-31','YYYY-MM-DD'),
    sdo_geor.init('PREP_TEMP_RDT',1)
  ) 
  return RASTER into gr1;
  -- Import the temperature raster
  dbms_output.put_line('Importing '||RASTER_DIR||temperature_file);
  sdo_geor.importFrom(
    gr1, 
    'blocking=false', 
    'TIFF', 
    'file', 
    RASTER_DIR||temperature_file
  );
  -- Setup the NODATA value
  sdo_geor.addNODATA(gr1, 0, -9999);
  -- Setup internal identifier
  sdo_geor.setID(gr1, 'Temperature (1978-2012) - Original');
  -- Write it to the raster table
  update prep_temp_table set RASTER = gr1 where ID = 1;

  -- Initialize the world maks raster
  insert into prep_temp_table (
    id, name, begindate, enddate, raster
  )
  values( 
    99, 
    'Land Mask', 
    null, 
    null,
    sdo_geor.init('PREP_TEMP_RDT',99)
  ) 
  return RASTER into gr99;
  -- Import the world mask raster
  sdo_geor.importFrom(gr99, 'blocking=false', 'TIFF', 'file', RASTER_DIR||land_mask_file);
  -- Setup internal identifier
  sdo_geor.setID(gr99, 'Land Mask');
  -- Write it to the raster table
  update prep_temp_table set RASTER = gr99 where ID = 99;
  
end;
/
