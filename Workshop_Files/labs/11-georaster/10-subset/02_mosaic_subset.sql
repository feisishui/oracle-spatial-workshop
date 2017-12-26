declare
  gr sdo_georaster;
begin
  for c in (
    select * from crop_areas
  )
  loop
  
    -- Prepare new raster object
    insert into us_rasters (georid, description, georaster)
      values (1000+c.id, 'Crop area '||c.name, sdo_geor.init('us_rasters_rdt_01'))
    returning georaster into gr;

    -- Generate the subset
    sdo_geor_aggr.MosaicSubset(
      GEORASTERTABLENAMES   => 'US_RASTERS',
      GEORASTERCOLUMNNAMES  => 'GEORASTER',
      PYRAMIDLEVEL          => 0,
      OUTSRID               => 26943, 
      OUTMODELCOORDLOC      => null, 
      REFERENCEPOINT        => null,
      CROPAREA              => sdo_cs.transform(c.area,26943),
      POLYGONCLIP           => 'TRUE', 
      BOUNDARYCLIP          => null, 
      LAYERNUMBERS          => null, 
      OUTRESOLUTIONS        => null, 
      RESOLUTIONUNIT        => null,
      MOSAICPARAM           => 'commonPointRule=average',
      STORAGEPARAM          => 'blocksize=(512, 512, 3)', 
      OUTGEORASTER          => gr, 
      BGVALUES              => null, 
      PARALLELPARAM         => null
    );
  
    -- Save the subset
    update us_rasters set georaster = gr where georid=1000+c.id;
    
  end loop;
  
end;
/
