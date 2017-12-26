#!/bin/bash
cd "$(dirname "$0")"

RASTER_INPUT=../tiff
RASTER_OUTPUT=../tiff16

gdalinfo --version

I=1
for G in $( ls $RASTER_INPUT/*.tif); do
  echo "***********************************************************"
  echo "Processing file $I: ${G##*/}" 
  echo "***********************************************************"
  time gdal_translate -of gtiff $G $RASTER_OUTPUT/${G##*/} -ot Uint16 -scale 0 255 0 65535
  let I=I+1
done
read -p "Hit return to continue... "

