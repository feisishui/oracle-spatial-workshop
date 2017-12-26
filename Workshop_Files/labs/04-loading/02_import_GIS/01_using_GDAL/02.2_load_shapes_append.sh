#!/bin/bash
cd "`dirname "$0"`"

# Change the following to match your environment:
DB_CONNECT=127.0.0.1:1521/orcl122
DB_USER=scott
DB_PASS=tiger

SHAPE_FILES="../../../../data/04-loading/shape"

echo Loading shape files from $SHAPE_FILES

for g in $( ls $SHAPE_FILES/*.shp); do
  full_file_name=${g%.*}
  file_name=${g##*/}
  table_name=${file_name%.*}
  echo Loading file: $file_name into $table_name
  ogr2ogr -f OCI OCI:$DB_USER/$DB_PASS@$DB_CONNECT $g -nln $table_name -append -progress --config OCI_FID id
done

read -p "Hit return to continue... "


