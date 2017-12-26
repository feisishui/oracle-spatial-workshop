#!/bin/bash -x
cd "$(dirname "$0")"

RASTER_INPUT=../tiff
RASTER_OUTPUT=../jp2

gdalinfo --version

I=1
for G in $( ls $RASTER_INPUT/*.tif); do
  echo "***********************************************************"
  echo "Processing file $I: ${G##*/}" 
  echo "***********************************************************"
  time gdal_translate -of JP2OpenJPEG $G $RASTER_OUTPUT/${G##*/}.jp2
  let I=I+1
done
read -p "Hit return to continue... "

