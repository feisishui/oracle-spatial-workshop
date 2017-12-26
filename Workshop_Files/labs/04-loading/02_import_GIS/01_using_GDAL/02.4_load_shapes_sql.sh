#!/bin/bash
cd "`dirname "$0"`"

# Change the following to match your environment:
DB_CONNECT=127.0.0.1:1521/orcl122
DB_USER=scott
DB_PASS=tiger

SHAPE_FILES="../../../../data/04-loading/shape"

ogr2ogr -f OCI OCI:$DB_USER/$DB_PASS@$DB_CONNECT: $SHAPE_FILES/world_countries.shp \
  --config OCI_FID id\
  -overwrite -progress \
  -nln world_countries_select \
  -sql "select iso_2digit as cc, cntry_name as name, pop_cntry as population from world_countries where landlocked = 'Y'" \
  -lco DIM=2 -lco SRID=4326 -lco GEOMETRY_NAME=geom -lco INDEX=YES \
  -lco DIMINFO_X="-180,180,1" -lco DIMINFO_Y="-90,90,1" \
  -lco LAUNDER=YES \
  -lco ADD_LAYER_GTYPE=NO

read -p "Hit return to continue... "
