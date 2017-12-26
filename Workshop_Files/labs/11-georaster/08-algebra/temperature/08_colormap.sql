--------------------------------------------------------------------------------
-- Apply colormap
--------------------------------------------------------------------------------

create or replace function generateColorRamp (
  firstIndex   number,
  firstColor   sdo_number_array,
  lastIndex    number,
  lastColor    sdo_number_array,
  colorMap     sdo_geor_colormap default null
) 
return sdo_geor_colormap
as

  colors   number;
  cm       sdo_geor_colormap;
  total    number;
  item     number;
  
  -- Linear interpolation function ( x = 0 .. 1 )
  function Lerp( y1 number, y2 number, x number ) return number as
  begin
    return ( y1 * ( 1 - x ) + y2 * x );
  end;
  
begin
  -- Number of colors
  colors   := lastIndex - firstIndex;

  -- Validate number of color index
  if colors < 1 then
    dbms_output.put_line( 'error: not enough colors indexes' );
    return null;
  end if;

  -- Validate range of color index
  if lastColor(1) < firstColor(1) then
    dbms_output.put_line( 'error: first color index greater than last color index' );
    return null;
  end if;

  -- Initialize colormap object
  if colorMap is null then
    cm := sdo_geor_colormap( 
      sdo_number_array(), 
      sdo_number_array(), 
      sdo_number_array(),
      sdo_number_array(), 
      sdo_number_array()
    );
  else
    cm := colorMap;
  end if;

  -- Resize colormap arrays
  if cm.cellValue.Count() < lastIndex then
    total  := lastIndex - cm.cellValue.Count();
    cm.cellValue.Extend(total);
    cm.red.Extend(total);
    cm.green.Extend(total);
    cm.blue.Extend(total);
    cm.alpha.Extend(total);
  end if;

  -- Calculate linear interpolation on cellValue and individuals colors
  item := 0;
  for i in firstIndex .. lastIndex loop
    cm.cellValue(i)  := Round( Lerp( firstColor(1), lastColor(1), item / colors ) );
    cm.red(i)        := Round( Lerp( firstColor(2), lastColor(2), item / colors ) );
    cm.green(i)      := Round( Lerp( firstColor(3), lastColor(3), item / colors ) );
    cm.blue(i)       := Round( Lerp( firstColor(4), lastColor(4), item / colors ) );
    cm.alpha(i)      := Round( Lerp( firstColor(5), lastColor(5), item / colors ) );
    item := item + 1;
  end loop;

  -- Return new colormap
  return cm;
end;
/
show errors;

create or replace function fc (x number)
return number
as
begin
  return (x-32)/9*5;
end;
/
create or replace function cf (x number)
return number
as
begin
  return x/5*9+32;
end;
/

declare
  gr     sdo_georaster;
  cmp    sdo_geor_colormap;
begin

  -- Initialize the color map with the NODATA value
  cmp  := sdo_geor_colormap( 
    sdo_number_array(-9999),     -- NODATA value
    sdo_number_array(255),       -- RED
    sdo_number_array(255),       -- GREEN
    sdo_number_array(255),       -- BLUE
    sdo_number_array(255)        -- ALPHA
  );
  
  -- Add the colors for the first temperature range
  cmp  := generateColorRamp(   2, sdo_number_array( -59, 180,   0, 255, 255), 
                              30, sdo_number_array( -31,  60,  99, 255, 255), cmp );
  
  -- Add the colors for the second temperature range
  cmp  := generateColorRamp(  31, sdo_number_array( -30,  60,  99, 255, 255), 
                              60, sdo_number_array(   0, 255, 255,   0, 255), cmp );
  
  -- Add the colors for the third temperature range
  cmp  := generateColorRamp(  61, sdo_number_array(   1, 255, 255,   0, 255), 
                              90, sdo_number_array(  30, 230,   0,   0, 255), cmp );
  
  -- Add the colors for the fourth temperature range
  cmp  := generateColorRamp(  91, sdo_number_array(  31, 230,   5,   0, 255), 
                             120, sdo_number_array(  60, 255, 255, 255, 255), cmp );
  
  -- Debug
  for i in  1 .. cmp.Red.Count() loop
    dbms_output.put_line(
      i                || ': ' ||
      cmp.CellValue(i) || ', ' ||
      cmp.Red(i)       || ', ' ||
      cmp.Green(i)     || ', ' ||
      cmp.Blue(i)      || ', ' ||
      cmp.Alpha(i)
    );
  end loop;
  
  -- Apply the colormap on the three rasters:
  
  -- 1) Detailed monthly temperatures
  select RASTER into gr from TEMPERATURE_table where ID = 1 for update;
  sdo_geor.setColorMap( gr, 0, cmp );
  sdo_geor.setDefaultColorLayer(gr, sdo_number_array(1,1,1,1));
  update TEMPERATURE_table set RASTER = gr where ID = 1;

  -- 2) Monthly averages
  select RASTER into gr from TEMPERATURE_table where ID = 2 for update;
  sdo_geor.setColorMap( gr, 0, cmp );
  sdo_geor.setDefaultColorLayer(gr, sdo_number_array(1,1,1,1));
  update TEMPERATURE_table set RASTER = gr where ID = 2;

  -- 3) Anomalies
  select RASTER into gr from TEMPERATURE_table where ID = 3 for update;
  sdo_geor.setColorMap( gr, 0, cmp );
  sdo_geor.setDefaultColorLayer(gr, sdo_number_array(1,1,1,1));
  update TEMPERATURE_table set RASTER = gr where ID = 3;

end;
/
