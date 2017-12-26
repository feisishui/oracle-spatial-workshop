--------------------------------------------------------------------------------
-- Calculate Temperature anomalies per Month
--------------------------------------------------------------------------------

declare
  gr1       sdo_georaster;
  gr2       sdo_georaster;
  gr3       sdo_georaster;
  beginDate date;
  endDate   date;
  operation sdo_string2_array := sdo_string2_array();
  bands     number := 0;
  i         number := 0;
  years     number := 0;
  plus      char := '';
  
begin

  -- Read global temperature raster
  select RASTER, BEGINDATE, ENDDATE, 
         sdo_geor.getBandDimSize(RASTER)
  into gr1, beginDate, endDate, bands 
  from TEMPERATURE_table where ID = 1;
  
  -- Read monthly averages raster
  select RASTER
  into gr2
  from TEMPERATURE_table where ID = 2;
  
  
  -- Initialize new raster with anomalies
  delete from TEMPERATURE_table where ID = 3;
  insert into TEMPERATURE_table (
    id, name, begindate, enddate, raster
  )
  values (
    3, 
    'Anomalies', 
    beginDate, 
    endDate, 
    sdo_geor.init('TEMPERATURE_RDT',3)
  )
  return RASTER into gr3;
  
  -- Generate the operations to compute the mean absolute deviation for each month
  -- One operation per month
  -- The operations look like this:
  --   (abs({1,0}-{0,0})+abs({1,0}-{0,12})+ ... +abs({1,0}-{0,384}))/33
  --   (abs({1,1}-{0,1})+abs({1,1}-{0,13})+ ... +abs({1,1}-{0,385}))/33
  --   ...
  --   (abs({1,11}-{0,11})+abs({1,11}-{0,23})+ ... +abs({1,11}-{0,395}))/33
  -- Where:
  -- {r,b} selects one band in one raster. 
  --   "r" is the id of the input raster (from 0)
  --   "b" is the band number in that raster (from 0)
  -- {0,0} is the value from band 0 of the first raster, i..e the temperature in January 1979
  -- {1,0} is the value from band 0 of the second raster, i.e. the mean for January
  -- abs({1,0}-{0,0}) is the absolute deviation from the mean.
  -- (abs({1,0}-{0,0})+ ... +abs({1,0}-{0,384}))/33 is the mean of all absolute deviations
  years := bands / 12;
  operation.extend(12);
  for m in 1 .. 12 loop
    operation(m) := null;
    plus := '';
    for y in 1 .. years loop
      i := ( ( y - 1 ) * 12 ) + m - 1;
      operation(m) := operation(m) || plus || 'abs({1,' || ( m - 1 ) || '}-{0,' || i || '})';
      plus := '+';
    end loop;
    operation(m) := '((' || operation(m) || ')/' || years || ')';
  end loop;
  
  -- Apply the operation
  -- The input is a collection of two rasters
  -- The output raster contains one band per operation (i.e. 12 bands)
  SDO_GEOR_RA.rasterMathOp(
    georArray    => sdo_georaster_array(gr1, gr2), 
    operation    => operation,
    storageParam => null, 
    outGeoraster => gr3,
    nodata       => 'TRUE'
  );

  -- Debug
  dbms_output.put('operation := sdo_string2_array(');
  for i in 1 .. operation.Count() loop
    dbms_output.put('"' || operation(i) || '", ');
  end loop;
  dbms_output.put_line(')');
  
  -- Save to database
  sdo_geor.setID(gr3, 'Anomalies');
  update TEMPERATURE_table set RASTER = gr3 where ID = 3;

end;
/
