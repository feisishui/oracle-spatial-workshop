#!/bin/bash
cd "`dirname "$0"`"

# Change the following to match your environment:
DB_CONNECT=127.0.0.1:1521/orcl122
DB_USER=scott
DB_PASS=tiger

# Skip the ESRI FileGDB driver (= force the use of the OpenFileGDB driver)
export GDAL_SKIP=FileGDB

# This loads all tables from the geodatabase
ogr2ogr -f OCI OCI:$DB_USER/$DB_PASS@$DB_CONNECT: us_data.gdb \
    -lco DIM=2 -lco SRID=4326 -lco GEOMETRY_NAME=geom -lco INDEX=NO \
    -lco DIMINFO_X="-180,180,1" -lco DIMINFO_Y="-90,90,1" \
    -lco ADD_LAYER_GTYPE=NO \
    -lco LAUNDER=YES

read -p "Hit return to continue... "


