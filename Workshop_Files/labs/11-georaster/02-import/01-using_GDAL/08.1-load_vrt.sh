#!/bin/bash
cd "$(dirname "$0")"

# Change the following to match your environment:
DB_CONNECTION=scott/tiger@localhost:1521/orcl122

RASTER_DATA=../../../../data/11-georaster

gdalinfo --version

time gdal_translate -of georaster $RASTER_DATA/tiff/sf.vrt georaster:$DB_CONNECTION,us_rasters,georaster \
  -co insert="(GEORID, SOURCE_FILE, GEORASTER) values (1, 'sf.vrt', sdo_geor.init('us_rasters_rdt_01'))" \
  -co blocking=optimalpadding -co blockxsize=430 -co blockysize=430 -co blockbsize=3 -co interleave=bip 

read -p "Hit return to continue... "
