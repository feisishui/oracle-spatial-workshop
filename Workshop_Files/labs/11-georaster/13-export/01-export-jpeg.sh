#!/bin/bash
# Find out about loaded rasters
gdalinfo georaster:scott/tiger@localhost:1521/orcl122,us_rasters,georaster

# Export each loaded raster as jpeg
gdal_translate -of jpeg georaster:scott/tiger@localhost:1521/orcl122,us_rasters,georaster,georid=1 /tmp/r1.jpeg
gdal_translate -of jpeg georaster:scott/tiger@localhost:1521/orcl122,us_rasters,georaster,georid=2 /tmp/r3.jpeg
gdal_translate -of jpeg georaster:scott/tiger@localhost:1521/orcl122,us_rasters,georaster,georid=3 /tmp/r3.jpeg
gdal_translate -of jpeg georaster:scott/tiger@localhost:1521/orcl122,us_rasters,georaster,georid=4 /tmp/r4.jpeg
read -p "Hit return to continue... "
