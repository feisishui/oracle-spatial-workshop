#!/bin/bash -x
cd /usr/tmp
rm *.{shp,dbf,shx}
# The -f "ESRI Shapefile" parameter is not necessary
# By default OGR assumnes the output to be shapefile
ogr2ogr us_cities.shp         OCI:scott/tiger@localhost:1521/orcl122:us_cities
ogr2ogr us_counties.shp       OCI:scott/tiger@localhost:1521/orcl122:us_counties
ogr2ogr us_states.shp         OCI:scott/tiger@localhost:1521/orcl122:us_states
ogr2ogr us_interstates.shp    OCI:scott/tiger@localhost:1521/orcl122:us_interstates
ogr2ogr us_parks.shp          OCI:scott/tiger@localhost:1521/orcl122:us_parks
ogr2ogr us_rivers.shp         OCI:scott/tiger@localhost:1521/orcl122:us_rivers
ogr2ogr world_countries.shp   OCI:scott/tiger@localhost:1521/orcl122:world_countries
ogr2ogr world_continents.shp  OCI:scott/tiger@localhost:1521/orcl122:world_continents

# Export multiple tables to a directory
# Each table becomes a separate shapefile
ogr2ogr us_data OCI:scott/tiger@localhost:1521/orcl122:us_cities,us_counties,us_states,us_interstates,us_parks,us_rivers,world_countries,world_continents

read -p "Hit return to continue... "

