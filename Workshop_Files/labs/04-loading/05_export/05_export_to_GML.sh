#!/bin/bash -x
cd /usr/tmp
ogr2ogr -f GML us_cities.gml         OCI:scott/tiger@orcl122:us_cities
ogr2ogr -f GML us_counties.gml       OCI:scott/tiger@orcl122:us_counties
ogr2ogr -f GML us_states.gml         OCI:scott/tiger@orcl122:us_states
ogr2ogr -f GML us_interstates.gml    OCI:scott/tiger@orcl122:us_interstates
ogr2ogr -f GML us_parks.gml          OCI:scott/tiger@orcl122:us_parks
ogr2ogr -f GML us_rivers.gml         OCI:scott/tiger@orcl122:us_rivers
ogr2ogr -f GML world_countries.gml   OCI:scott/tiger@orcl122:world_countries
ogr2ogr -f GML world_continents.gml  OCI:scott/tiger@orcl122:world_continents
read -p "Hit return to continue... "

