--------------------------------------------------------------------------------
-- Convert temperature values from Kelvin to Celsius
--------------------------------------------------------------------------------

declare
  gr5    		sdo_georaster;
  gr7       sdo_georaster;
  beginDate date;
  endDate   date;
  operation sdo_string2_array := sdo_string2_array();
  numBands  number;
begin

  -- Read global temperature raster
  select RASTER, BEGINDATE, ENDDATE, 
         sdo_geor.getBandDimSize(RASTER)
  into gr5, beginDate, endDate, numBands
  from PREP_TEMP_table 
  where ID = 5;
  
  -- Initialize new raster
  delete from PREP_TEMP_table where ID = 7;
  insert into PREP_TEMP_table (
    id, name, begindate, enddate, raster
  )
  values (
    7, 
    'Temperature in Celsius', 
    beginDate, 
    endDate, 
    SDO_GEOR.init('PREP_TEMP_RDT',7)
  )
  return RASTER into gr7;
  
  -- Generate raster algebra operations to convert all bands from Kelvin to Fahrenheit
  -- One operation per band b
  -- Each operation looks like this:
  --   ({b}-273.15)*9/5+32
  -- where b is the band number, from 0 to 395
  operation.Extend(numBands);
  for i in 1 .. numBands loop
    operation(i) := '{' || ( i - 1 ) || '}-273.15';
  end loop;
  
  -- Apply the raster algebra operation
  SDO_GEOR_RA.rasterMathOp(
    inGeoRaster   => gr5, 
    operation     => operation,
    storageParam  => null, 
    outGeoraster  => gr7,
    nodata        => 'TRUE',
    nodataValue   => -9999
  );
  
  -- Debug
  dbms_output.put('operation := sdo_string2_array(');
  for i in 1 .. operation.Count() loop
    dbms_output.put('"' || operation(i) || '", ');
  end loop;
  dbms_output.put_line(')');

  -- Save to database
  sdo_geor.setID(gr7, 'Temperature (1979-2011) - Celsius');
  update PREP_TEMP_table set RASTER = gr7 where ID = 7;

end;
/
