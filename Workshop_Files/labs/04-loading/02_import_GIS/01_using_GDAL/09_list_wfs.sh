#!/bin/bash

# List the feature types served by a WFS
ogrinfo -ro  "WFS:http://v2.suite.opengeo.org/geoserver/ows"

# with details
ogrinfo -ro  "WFS:http://v2.suite.opengeo.org/geoserver/ows" WFSLayerMetadata

# XML capabilities
ogrinfo -ro  "WFS:http://v2.suite.opengeo.org/geoserver/ows" WFSGetCapabilities

# List one feature class
ogrinfo -ro  "WFS:http://v2.suite.opengeo.org/geoserver/ows" world:cities

# Filter on attribute values
ogrinfo -ro  "WFS:http://v2.suite.opengeo.org/geoserver/ows" world:cities -where "Country='China' or Country='India'"

# Filter on spatial bounding box
ogrinfo -ro  "WFS:http://v2.suite.opengeo.org/geoserver/ows" world:cities -spat 6.5 50.4 13.2 52.94

# Advanced techniques

# List the feature types served by a WFS with debug
ogrinfo -ro  "WFS:http://v2.suite.opengeo.org/geoserver/ows" --debug on

# Specify HTTP proxy
ogrinfo "WFS:http://v2.suite.opengeo.org/geoserver/ows" --config GDAL_HTTP_PROXY www-proxy.us.oracle.com:80

# Using a configuration file
ogrinfo wfs_access.xml

read -p "Hit return to continue... "
