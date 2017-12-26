#!/bin/bash -x
cd "$(dirname "$0")"
./load_rasters.sh "blocking=false,compression=jpeg-f,spatialExtent=true"
read -p "Hit return to continue... "
