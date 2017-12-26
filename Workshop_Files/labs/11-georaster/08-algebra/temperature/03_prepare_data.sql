declare

--------------------------------------------------------------------------------
-- Swap hemispheres, retain data for 1979-2011, clip north/south
--------------------------------------------------------------------------------

/*

The origin (left) meridian of the temperature raster is the Greenwich meridian. 
This means that the eastern and western hemisphere are reversed, compared to 
the usual view of the globe, centered on the Greenwich meridian:

+-------------------------+-------------------------+
|                         |                         |
+ - - - - - - - - - - - - + - - - - - - - - - - - - +
|                         |                         |
|                         |                         |
|        Eastern          |         Western         |
|      Hemisphere         |       Hemisphere        |
|                         |                         |
|                         |                         |
|                         |                         |
+ - - - - - - - - - - - - + - - - - - - - - - - - - +
|                         |                         |
+-------------------------+-------------------------+

So, we need to swap the two hemispheres so they fall back to their usual position.

The raster contains 420 bands, where each band contains the temperature recordings
for one month. The first month is January 1978. The last one is December 2012. However
measurements only exist between January 1979 and December 2011. We will therefore 
remove the first and last 12 bands - i.e. only retain bands 13 (January 1979) 
to 408 (December 2011).

Finally we remove North and South borders.

We do this in several steps:

1) Clip out each hemisphere as separate news rasters (georid 1 and 2)
2) Georeference them correctly (the input raster is not georeferenced)
3) Mosaic them into a new raster (georid 3)
4) Clip out the bands for January 1979 and December 2011

*/

  gr1        sdo_georaster;
  gr2        sdo_georaster;
  gr3        sdo_georaster;
  gr4        sdo_georaster;
  gr5        sdo_georaster;
  
  cursor hemispheres is
    select * from prep_temp_table
    where id in (2,3);

begin

  -- Remove existing data
  delete from prep_temp_table where ID between 2 and 5;
  
  -- Load the original temperature raster
  select RASTER into gr1 from prep_temp_table where ID = 1;

  ---------------------------------------------------------------------
  -- Extract Eastern Hemisphere
  ---------------------------------------------------------------------
  
  -- Initialize
  insert into prep_temp_table (
    id, name, begindate, enddate, raster
  )
  values( 
    2, 
    'Temperature in Kelvin - East hemisphere',
    TO_DATE('1978-1-1', 'YYYY-MM-DD'),
    TO_DATE('2012-12-31', 'YYYY-MM-DD'),
    SDO_GEOR.init('PREP_TEMP_RDT', 2)
  ) 
  return RASTER into gr2;
  
  -- Clip
  sdo_geor.subset( 
    inGeoRaster  => gr1,
    pyramidLevel => 0,
    cropArea     => sdo_number_array(0, 0, 71, 71),
    bandNumbers  => null,
    storageParam => null,
    outGeoRASTER => gr2
  );

  -- Georeference
  sdo_geor.setUlTCoordinate(gr2, sdo_number_array(0, 0, 0));
  sdo_geor.georeference( 
    georaster => gr2, 
    srid => 4326, 
    modelCoordinateLocation => 0, 
    xCoefficients => sdo_number_array(2.5, 0.0,  0.0),
    yCoefficients => sdo_number_array(0.0,-2.5, 90.0)
  );
  sdo_geor.setModelCoordLocation(gr2, 'UPPERLEFT');
  
  -- Save to database
  sdo_geor.setID(gr2, 'Temperature (1978-2012) - East hemisphere');
  update prep_temp_table set RASTER = gr2 where ID = 2;
  
  ---------------------------------------------------------------------
  -- Extract Western Hemisphere
  ---------------------------------------------------------------------
  
  -- Initialize
  insert into prep_temp_table (
    id, name, begindate, enddate, raster
  )
  values( 
    3, 
    'Temperature in Kelvin - West hemisphere',
    TO_DATE('1978-1-1', 'YYYY-MM-DD'),
    TO_DATE('2012-12-31', 'YYYY-MM-DD'),
    SDO_GEOR.init('PREP_TEMP_RDT', 3)
  ) 
  return RASTER into gr3;
  
  -- Clip
  sdo_geor.subset( 
    inGeoRaster  => gr1,
    pyramidLevel => 0,
    cropArea     => sdo_number_array(0, 71, 71, 143),
    bandNumbers  => null,
    storageParam => null,
    outGeoRASTER => gr3
  );
  
  -- Georeference
  sdo_geor.setUlTCoordinate(gr3, sdo_number_array(0, 0, 0));
  sdo_geor.georeference( 
    georaster => gr3, 
    srid => 4326, 
    modelCoordinatelocation => 0, 
    xCoefficients => sdo_number_array(2.5, 0.0, -180.0),
    yCoefficients => sdo_number_array(0.0,-2.5,   90.0)
  );
  sdo_geor.setModelCoordLocation(gr3, 'UPPERLEFT');

  -- Save to database
  sdo_geor.setID(gr3, 'Temperature (1978-2012) - West hemisphere');
  update prep_temp_table set RASTER = gr3 where ID = 3;

  ---------------------------------------------------------------------
  -- Assemble Eastern and Western hemispheres
  ---------------------------------------------------------------------
  -- Initialize
  insert into prep_temp_table (
    id, name, begindate, enddate, raster
  )
  values( 
    4, 
    'Temperature in Kelvin - Globe',
    TO_DATE('1978-1-1', 'YYYY-MM-DD'),
    TO_DATE('2012-12-31', 'YYYY-MM-DD'),
    SDO_GEOR.init('PREP_TEMP_RDT', 4)
  ) 
  return RASTER into gr4;
  
  -- Create a view
  execute immediate 
    'create or replace view prep_temp_table_v as select * from prep_temp_table where id in (2,3)';
  
  -- Mosaic
  sdo_geor.mosaic (
    georasterTableName => 'PREP_TEMP_TABLE_V',
    georasterColumnName => 'RASTER',
    georaster => gr4,
    storageParam => null
  );

  -- Save to database
  sdo_geor.setID(gr4, 'Temperature (1978-2012) - Globe');
  update prep_temp_table set RASTER = gr4 where ID = 4;

  ---------------------------------------------------------------------
  -- Remove unnecessary bands and clip north/south extremes
  ---------------------------------------------------------------------
  -- Initialize
  insert into prep_temp_table (
    id, name, begindate, enddate, raster
  )
  values( 
    5, 
    'Temperature in Kelvin - Globe (Clipped)',
    TO_DATE('1979-1-1', 'YYYY-MM-DD'),
    TO_DATE('2011-12-31', 'YYYY-MM-DD'),
    SDO_GEOR.init('PREP_TEMP_RDT', 5)
  ) 
  return RASTER into gr5;

  -- Clip  
  sdo_geor.subset( 
    inGeoRaster  => gr4,
    pyramidLevel => 0,
    cropArea     => sdo_number_array(3, 0, 61, 143),
    bandNumbers  => '13-408',
    storageParam => 'blockSize=(32,32,1)',
    outGeoRASTER => gr5
  );

  -- Save to database
  sdo_geor.setID(gr5, 'Temperature (1979-2011) - Globe (Clipped)');
  update prep_temp_table set RASTER = gr5 where ID = 5;

end;
/
show errors
