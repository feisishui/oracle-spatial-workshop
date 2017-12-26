#!/bin/bash
cd "$(dirname "$0")"

RASTER_DATA=../../../../data/11-georaster

gdalbuildvrt $RASTER_DATA/tiff/sf.vrt $RASTER_DATA/tiff/*.tif
gdalinfo $RASTER_DATA/tiff/sf.vrt

read -p "Hit return to continue... "
