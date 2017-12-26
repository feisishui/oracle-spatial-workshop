#!/bin/bash
cd "`dirname "$0"`"

# Change the following to match your environment:
DB_CONNECT=127.0.0.1:1521/orcl122
DB_USER=scott
DB_PASS=tiger

TAB_FILES="../../../../data/04-loading/tab"

echo Loading TAB files from $TAB_FILES

for g in $( ls $TAB_FILES/*.tab); do
  full_file_name=${g%.*}
  file_name=${g##*/}
  table_name=${file_name%.*}
  echo Loading file: $file_name into $table_name
  ogr2ogr -f OCI OCI:$DB_USER/$DB_PASS@$DB_CONNECT: $g \
    --config OCI_FID id\
    -overwrite \
    -progress \
    -lco DIM=2 -lco SRID=8307 -lco GEOMETRY_NAME=geom -lco INDEX=NO \
    -lco DIMINFO_X="-180,180,1" -lco DIMINFO_Y="-90,90,1" \
    -lco LAUNDER=YES \
    -lco ADD_LAYER_GTYPE=NO
done

read -p "Hit return to continue... "


