declare
  gr     sdo_georaster;
  win    sdo_number_array := null;
  res    varchar2(100);
  
begin
  for i in 2 .. 2 loop
  
    select RASTER 
    into gr 
    from TEMPERATURE_table 
    where ID = i for update;
    
    res := sdo_geor.generateStatistics( 
      georaster      => gr,
      samplingFactor => 'samplingFactor=1',
      samplingWindow => win,
      histogram      => 'true',
      layerNumbers   => null,
      useBin         => null,
      binFunction    => null,
      nodata         => 'true' 
    );
    
    update TEMPERATURE_table 
    set RASTER = gr 
    where ID = i;

  end loop;

end;
/

select sdo_geor.getStatistics(raster, 1) from TEMPERATURE_table where ID in (1,2,3) order by ID;
