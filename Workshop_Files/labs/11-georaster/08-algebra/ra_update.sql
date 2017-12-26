/*

SDO_GEOR_RA.rasterUpdate example

Maximize colors

Create a copy of the four rasters in US_RASTERS, then update the pixels:
- set to RED when RED dominates (RED > GREEN and RED > BLUE)
- set to GREEN when GREEN dominates
- set to BLUE when BLUE dominates

*/

declare 
  gr1   SDO_GEORASTER; 
  gr2   SDO_GEORASTER; 
begin
  -- Clean out results from previous run
  delete from us_rasters where georid between 3000 and 4000;
  
  -- Process all rasters in sequence
  for r in (
    select * from us_rasters where georid in (1,2,3,4)
  ) 
  loop
    -- Get input raster
    gr1 := r.georaster;
    
    -- Initialize output raster
    insert into us_rasters (georid, georaster)
    values(3000 + r.georid, SDO_GEOR.init('us_rasters_rdt_01',3000 + r.georid)) 
    return georaster into gr2;
  
    -- Copy input raster to output raster
    sdo_geor.copy (gr1, gr2);
  
    -- Perform update on output raster
    sdo_geor_ra.rasterUpdate (
      georaster     =>  gr2,
      pyramidLevel  =>  null,
      conditions    =>  sdo_string2_array(
                          '({0}>{1})&({0}>{2})', 
                          '({1}>{0})&({1}>{2})', 
                          '({2}>{0})&({2}>{1})'
                        ),
      vals          =>  sdo_string2_arrayset (
                          sdo_string2_array('255','0','0'),
                          sdo_string2_array('0','255','0'),
                          sdo_string2_array('0','0','255')
                        )
    );
  
    -- Save to database
    update us_rasters set georaster = gr2 where georid = 3000 + r.georid;
  end loop;
end;
/
commit;
