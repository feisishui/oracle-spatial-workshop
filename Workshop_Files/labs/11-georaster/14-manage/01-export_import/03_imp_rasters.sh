#!/bin/bash
cd "$(dirname "$0")"
imp scott/tiger file=us_rasters.dmp tables="(us_rasters, us_rasters_rdt_01)"
read -p "Hit return to continue... "
