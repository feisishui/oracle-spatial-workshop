/*

SDO_GEOR_RA.rasterMathOp example

Transform a set of RGB orthophotos into gray scale images.

Create a copy of the four rasters in US_RASTERS, taking the average of the three RED,
GREEN and BLUE pixels. This produces single-band rasters.

*/

declare 
  gr1   SDO_GEORASTER; 
  gr2   SDO_GEORASTER; 
begin
  -- Clean out results from previous run
  delete from us_rasters where georid between 2000 and 3000;
  
  -- Process all rasters in sequence
  for r in (
    select * from us_rasters where georid in (1,2,3,4)
  ) 
  loop
    -- Get input raster
    gr1 := r.georaster;
    
    -- Initialize output raster
    insert into us_rasters (georid, georaster)
    values(2000 + r.georid, SDO_GEOR.init('us_rasters_rdt_01',2000 + r.georid)) 
    return georaster into gr2;
  
    -- Perform change
    sdo_geor_ra.rasterMathOp (
      inGeoraster   => gr1,
      operation     => sdo_string2_array('({0}+{1}+{2})/3'),
      outGeoraster  => gr2,
      storageParam  => null 
    );
  
    -- Save to database
    update us_rasters set georaster = gr2 where georid = 2000 + r.georid;
  end loop;
end;
/
commit;