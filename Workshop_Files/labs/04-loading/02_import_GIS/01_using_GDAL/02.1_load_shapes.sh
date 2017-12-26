#!/bin/bash
cd "`dirname "$0"`"

# Change the following to match your environment:
DB_CONNECT=127.0.0.1:1521/orcl122
DB_USER=scott
DB_PASS=tiger

SHAPE_FILES="../../../../data/04-loading/shape"

#export CPL_DEBUG=ON

echo Loading shape files from $SHAPE_FILES

# The following works for all file names (including those with spaces)
find $SHAPE_FILES -name *.shp | while read g
do
  file_name=${g##*/}
  # Strip out extension from file name to form table name
  table_name=${file_name%.*}
  # Replace spaces in table name with underscores
  table_name=${table_name// /_}
  # Make table name upper case
  table_name=${table_name^^}
  echo Loading file: \"$file_name\" into $table_name
  time ogr2ogr -f OCI OCI:$DB_USER/$DB_PASS@$DB_CONNECT: "$g" \
    --config OCI_FID id\
    -nln $table_name\
    -overwrite \
    -progress \
    -lco DIM=2 -lco SRID=4326 -lco GEOMETRY_NAME=geom -lco INDEX=NO \
    -lco DIMINFO_X="-180,180,1" -lco DIMINFO_Y="-90,90,1" \
    -lco ADD_LAYER_GTYPE=NO \
    -lco LAUNDER=YES
done

read -p "Hit return to continue... "
