#!/bin/bash -x
cd /usr/tmp
rm -r us_data.gdb
# Note: must use an explicit setting for the output geometry type
# -nlt NONE, GEOMETRY, POINT, LINESTRING, POLYGON, GEOMETRYCOLLECTION, 
#      MULTIPOINT, MULTIPOLYGON or MULTILINESTRING. And CIRCULARSTRING, 
#      COMPOUNDCURVE, CURVEPOLYGON, MULTICURVE and MULTISURFACE
ogr2ogr -f FileGDB us_data.gdb         -append OCI:scott/tiger@orcl122:us_cities -nlt POINT
ogr2ogr -f FileGDB us_data.gdb       -append OCI:scott/tiger@orcl122:us_counties -nlt POLYGON
ogr2ogr -f FileGDB us_data.gdb         -append OCI:scott/tiger@orcl122:us_states -nlt POLYGON
ogr2ogr -f FileGDB us_data.gdb    -append OCI:scott/tiger@orcl122:us_interstates -nlt LINESTRING
ogr2ogr -f FileGDB us_data.gdb          -append OCI:scott/tiger@orcl122:us_parks -nlt POLYGON
ogr2ogr -f FileGDB us_data.gdb         -append OCI:scott/tiger@orcl122:us_rivers -nlt LINESTRING
ogr2ogr -f FileGDB us_data.gdb   -append OCI:scott/tiger@orcl122:world_countries -nlt POLYGON
ogr2ogr -f FileGDB us_data.gdb  -append OCI:scott/tiger@orcl122:world_continents -nlt POLYGON
read -p "Hit return to continue... "

