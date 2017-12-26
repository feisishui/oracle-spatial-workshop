#!/bin/bash

# Load all cities
ogr2ogr -f OCI OCI:scott/tiger@orcl122 "WFS:http://v2.suite.opengeo.org/geoserver/ows" world:cities -lco DIM=2 -lco SRID=4326 -lco GEOMETRY_NAME=geometry

# Filter on attribute values
ogr2ogr -f OCI OCI:scott/tiger@orcl122 "WFS:http://v2.suite.opengeo.org/geoserver/ows" world:cities -where "Country='China' or Country='India'" -lco OVERWRITE=YES -lco DIM=2 -lco SRID=4326 -lco GEOMETRY_NAME=geometry

# Filter on spatial bounding box
ogr2ogr -f OCI OCI:scott/tiger@orcl122 "WFS:http://v2.suite.opengeo.org/geoserver/ows" world:cities -spat 6.5 50.4 13.2 52.94 -lco OVERWRITE=YES -lco DIM=2 -lco SRID=4326 -lco GEOMETRY_NAME=geometry

read -p "Hit return to continue... "
