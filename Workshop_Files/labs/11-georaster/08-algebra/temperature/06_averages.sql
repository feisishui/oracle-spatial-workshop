--------------------------------------------------------------------------------
-- Calculate monthly average temperature
--------------------------------------------------------------------------------

declare
  gr1       sdo_georaster;
  gr2       sdo_georaster;
  ga1       sdo_georaster_array;
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
  
  -- Initialize new raster with averages
  delete from TEMPERATURE_table where ID = 2;
  insert into TEMPERATURE_table (
    id, name, begindate, enddate, raster
  )
  values (
    2, 
    'The average temperatures of each month', 
    beginDate, 
    endDate, 
    sdo_geor.init('TEMPERATURE_RDT',2)
  )
  return RASTER into gr2;
  
  -- Generate the operations to compute the monthly averages
  -- One operation per month
  -- The operations look like this:
  --   ({0}+{12}+{24}+{36}+{48}+{60}+...+{372}+{384})/33
  --   ({1}+{13}+{25}+{37}+{49}+{61}+...+{373}+{385})/33
  --   ...
  --   ({11}+{23}+{35}+{49}+{59}+{71}+...+{383}+{395})/33
  -- i.e. take the sum of temperatures of every 12th band
  years := bands / 12;
  operation.extend(12);
  for m in 1 .. 12 loop
    operation (m) := '';
    plus := '';
    for y in 1 .. years loop
      i := ( ( y - 1 ) * 12 ) + m - 1;
      operation(m) := operation(m) || plus || '{' || i || '}';
      plus := '+';
    end loop;
    operation(m) := '((' || operation(m) || ')/' || years || ')';
  end loop;
  
  -- Apply the operation
  -- The output raster contains one band per operation (i.e. 12 bands)
  sdo_geor_RA.rasterMathOp(
    inGeoRaster  => gr1, 
    operation    => operation,
    storageParam => null, 
    outGeoraster => gr2,
    nodata       => 'TRUE',
    nodataValue  => -9999
  );
  
  -- Debug
  dbms_output.put('operation := sdo_string2_array(');
  for i in 1 .. operation.Count() loop
    dbms_output.put('"' || operation(i) || '", ');
  end loop;
  dbms_output.put_line(')');

  -- Save to database
  sdo_geor.setID(gr2, 'Averages');
  update TEMPERATURE_table set RASTER = gr2 where ID = 2;
  
end;
/
