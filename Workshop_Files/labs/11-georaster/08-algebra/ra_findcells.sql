/*

SDO_GEOR_RA.findCells example

Extract green pixels from a set of orthophotos

Create a copy of the four rasters in US_RASTERS, only retaining the green pixels.
The green pixels are defined as those having a GREEN value larger than the RED or BLUE
values.

*/

declare 
  gr1   SDO_GEORASTER; 
  gr2   SDO_GEORASTER; 
begin
  -- Clean out results from previous run
  delete from us_rasters where georid between 1000 and 2000;
  
  -- Process all rasters in sequence
  for r in (
    select * from us_rasters where georid in (1,2,3,4)
  ) 
  loop
    -- Get input raster
    gr1 := r.georaster;
    
    -- Initialize output raster
    insert into us_rasters (georid, georaster)
    values(1000 + r.georid, SDO_GEOR.init('us_rasters_rdt_01',1000 + r.georid)) 
    return georaster into gr2;
  
    -- Select cells
    sdo_geor_ra.findCells (
      inGeoraster   => gr1,
      condition     => '{1}>={0}&{1}>={2}',
      storageParam  => null, 
      outGeoraster  => gr2,
      bgValues      => sdo_number_array (255,255,255)
    );
  
    -- Save to database
    update us_rasters set georaster = gr2 where georid = 1000 + r.georid;
  end loop;
end;
/
commit;