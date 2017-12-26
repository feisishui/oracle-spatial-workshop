#!/bin/bash
# Show a summary of all loaded rasters
echo Summary of all loaded rasters
gdalinfo georaster:scott/tiger@localhost:1521/orcl122,us_rasters,georaster

# Show details for each raster 
echo Details for each raster
gdalinfo georaster:scott/tiger@localhost:1521/orcl122,us_rasters,georaster,georid=1
gdalinfo georaster:scott/tiger@localhost:1521/orcl122,us_rasters,georaster,georid=2
gdalinfo georaster:scott/tiger@localhost:1521/orcl122,us_rasters,georaster,georid=3
gdalinfo georaster:scott/tiger@localhost:1521/orcl122,us_rasters,georaster,georid=4
read -p "Hit return to continue... "
