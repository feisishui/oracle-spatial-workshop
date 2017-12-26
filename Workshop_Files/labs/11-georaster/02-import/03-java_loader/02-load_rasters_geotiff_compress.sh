#!/bin/bash -x
cd "$(dirname "$0")"
./load_rasters.sh "blocking=true blockSize=(550,550,3),spatialExtent=true,geotiff=true,compression=jpeg-f"
read -p "Hit return to continue... "
