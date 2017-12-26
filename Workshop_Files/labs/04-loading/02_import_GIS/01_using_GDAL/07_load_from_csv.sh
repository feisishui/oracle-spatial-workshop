#!/bin/bash
cd "$(dirname "$0")"

cd ../../../../data/04-loading/csv

ogrinfo -al -so us_cities.csv
ogrinfo -al -so us_cities.vrt

export OCI_FID=ID

ogr2ogr -f OCI OCI:scott/tiger@orcl122: us_cities.vrt -lco DIM=2 -lco SRID=4326 -lco GEOMETRY_NAME=location -overwrite -lco launder=yes -select "CITY,STATE_ABRV,POP90,RANK90"    


read -p "Hit return to continue... "
