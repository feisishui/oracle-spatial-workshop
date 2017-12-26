/*

SDO_GEOR_RA.classify example

Take the average of the RED/GREEN/BLUE pixels, and classify in four categories. 
The output raster is single band, with a cell depth of 4 bits.

Input value   Output value     
-----------   ------------
   0 to  63              0
  64 to 127              1
 128 to 191              2
 192 to 255              3

*/

declare 
  gr1   SDO_GEORASTER; 
  gr2   SDO_GEORASTER; 
begin
  -- Clean out results from previous run
  delete from us_rasters where georid between 4000 and 5000;
  
  -- Process all rasters in sequence
  for r in (
    select * from us_rasters where georid in (1,2,3,4)
  ) 
  loop
    -- Get input raster
    gr1 := r.georaster;
    
    -- Initialize output raster
    insert into us_rasters (georid, georaster)
    values(4000 + r.georid, SDO_GEOR.init('us_rasters_rdt_01',4000 + r.georid)) 
    return georaster into gr2;
  
    -- Perform change
    sdo_geor_ra.classify (
      inGeoraster     => gr1,
      expression      => '({0}+{1}+{2})/3',
      rangeArray      => SDO_NUMBER_ARRAY(63,127,191),
      valueArray      => SDO_NUMBER_ARRAY(0,1,2,3),
      outGeoraster    => gr2,
      storageParam    => 'cellDepth=4BIT' 
    );
  
    -- Save to database
    update us_rasters set georaster = gr2 where georid = 4000 + r.georid;
  end loop;
end;
/
commit;