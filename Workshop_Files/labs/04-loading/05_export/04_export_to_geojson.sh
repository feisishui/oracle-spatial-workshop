#!/bin/bash -x
cd /usr/tmp
ogr2ogr -f GeoJSON us_cities.json         OCI:scott/tiger@orcl122:us_cities
ogr2ogr -f GeoJSON us_counties.json       OCI:scott/tiger@orcl122:us_counties
ogr2ogr -f GeoJSON us_states.json         OCI:scott/tiger@orcl122:us_states
ogr2ogr -f GeoJSON us_interstates.json    OCI:scott/tiger@orcl122:us_interstates
ogr2ogr -f GeoJSON us_parks.json          OCI:scott/tiger@orcl122:us_parks
ogr2ogr -f GeoJSON us_rivers.json         OCI:scott/tiger@orcl122:us_rivers
ogr2ogr -f GeoJSON world_countries.json   OCI:scott/tiger@orcl122:world_countries
ogr2ogr -f GeoJSON world_continents.json  OCI:scott/tiger@orcl122:world_continents
read -p "Hit return to continue... "

