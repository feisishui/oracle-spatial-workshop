#!/bin/bash -x
cd /usr/tmp

# Select rows to export
ogr2ogr us_cities_select_1.shp  OCI:scott/tiger@localhost:1521/orcl122:us_cities -where "pop90 > 500000" -progress -overwrite

# Select and rename columns to export
ogr2ogr us_cities_select_2.shp  OCI:scott/tiger@localhost:1521/orcl122:us_cities -select "id, city as city_name, state_abrv" -where "pop90 > 500000" -progress -overwrite

# Use pseudo-sql
ogr2ogr us_cities_select_3.shp  OCI:scott/tiger@localhost:1521/orcl122:us_cities -sql "select id, location from us_cities where pop90 > 500000" -progress -overwrite

read -p "Hit return to continue... "
