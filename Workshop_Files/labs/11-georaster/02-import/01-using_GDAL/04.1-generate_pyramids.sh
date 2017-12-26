#!/bin/bash

gdaladdo -r nearest georaster:scott/tiger,,us_rasters,georaster,georid=1 2 4 8 16 32
gdaladdo -r nearest georaster:scott/tiger,,us_rasters,georaster,georid=2 2 4 8 16 32
gdaladdo -r nearest georaster:scott/tiger,,us_rasters,georaster,georid=3 2 4 8 16 32
gdaladdo -r nearest georaster:scott/tiger,,us_rasters,georaster,georid=4 2 4 8 16 32

read -p "Hit return to continue... "
