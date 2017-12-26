#!/bin/bash
cd "$(dirname "$0")"
exp scott/tiger file=us_rasters.dmp tables="(us_rasters, us_rasters_rdt_01)" triggers=n
read -p "Hit return to continue... "
