--------------------------------------------------------------------------------
-- Create pyramids and spatial reference
--------------------------------------------------------------------------------

declare
  gr sdo_georaster;
begin

  select RASTER into gr 
  from TEMPERATURE_table 
  where id = 5 
  for update;
  
  sdo_geor.generatePyramid(gr,'resampling=cubic');
  gr.spatialextent = sdo_geor.generateSpatialExtent(gr);
  
  update TEMPERATURE_table t 
  set t.RASTER = gr 
  where id = 5;
end;
/

