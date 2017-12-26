#!/bin/bash -x
cd /usr/tmp
ogr2ogr -f "Mapinfo File" us_cities.tab         OCI:scott/tiger@orcl122:us_cities
ogr2ogr -f "Mapinfo File" us_counties.tab       OCI:scott/tiger@orcl122:us_counties
ogr2ogr -f "Mapinfo File" us_states.tab         OCI:scott/tiger@orcl122:us_states
ogr2ogr -f "Mapinfo File" us_interstates.tab    OCI:scott/tiger@orcl122:us_interstates
ogr2ogr -f "Mapinfo File" us_parks.tab          OCI:scott/tiger@orcl122:us_parks
ogr2ogr -f "Mapinfo File" us_rivers.tab         OCI:scott/tiger@orcl122:us_rivers
ogr2ogr -f "Mapinfo File" world_countries.tab   OCI:scott/tiger@orcl122:world_countries
ogr2ogr -f "Mapinfo File" world_continents.tab  OCI:scott/tiger@orcl122:world_continents
read -p "Hit return to continue... "

