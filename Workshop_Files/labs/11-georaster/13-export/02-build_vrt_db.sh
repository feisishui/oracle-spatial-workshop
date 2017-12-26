#!/bin/bash
cd "$(dirname "$0")"
gdalbuildvrt /tmp/sf.vrt georaster:scott/tiger@localhost:1521/orcl122,us_rasters,georaster
gdalinfo /tmp/sf.vrt
read -p "Hit return to continue... "
