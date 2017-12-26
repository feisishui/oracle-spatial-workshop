#!/bin/bash
cd "$(dirname "$0")"

# Change the following to match your environment:
DB_CONNECTION=scott/tiger@localhost:1521/orcl122

# Compress to jpeg-f

RASTER_DATA=../../../../data/11-georaster/tiff

gdalinfo --version

I=1
for G in $( ls $RASTER_DATA/*.tif); do
  echo "***********************************************************"
  echo "Loading file $I: ${G##*/}" 
  echo "***********************************************************"
  time gdal_translate -of georaster $G georaster:$DB_CONNECTION,us_rasters,georaster \
    -co insert="(GEORID, SOURCE_FILE, GEORASTER) values ($I, '${G##*/}', sdo_geor.init('us_rasters_rdt_01'))" \
    -co blocking=optimalpadding -co blockxsize=550 -co blockysize=550 -co blockbsize=3 -co interleave=bip \
    -co compress=jpeg-f
  let I=I+1
done
read -p "Hit return to continue... "

