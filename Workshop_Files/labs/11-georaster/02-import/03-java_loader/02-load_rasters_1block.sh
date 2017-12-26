#!/bin/bash -x
cd "$(dirname "$0")"
./load_rasters.sh "blocking=true,blockSize=(512,512,1),spatialExtent=true"
read -p "Hit return to continue... "

