#!/bin/bash
cd "$(dirname "$0")"

RASTER_INPUT=../tiff
RASTER_OUTPUT=../tiff_comp

gdalinfo --version

I=1
for G in $( ls $RASTER_INPUT/*.tif); do
  echo "***********************************************************"
  echo "Processing file $I: ${G##*/}" 
  echo "***********************************************************"
  time gdal_translate -of gtiff $G $RASTER_OUTPUT/${G##*/} -co compress=jpeg -co photometric=ycbcr
  let I=I+1
done
read -p "Hit return to continue... "

