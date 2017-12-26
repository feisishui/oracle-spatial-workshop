#!/bin/bash
cd "$(dirname "$0")"

for G in $( ls ../../../../data/11-georaster/tiff/*.tif); do
  echo "***********************************************************"
  echo "Information for file: ${G##*/}"
  echo "***********************************************************"
  gdalinfo $G
done

read -p "Hit return to continue... "
