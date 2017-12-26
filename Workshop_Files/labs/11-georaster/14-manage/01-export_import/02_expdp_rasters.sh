#!/bin/bash
expdp scott/tiger directory=DATA_PUMP_DIR dumpfile=us_rasters.dmp tables="(us_rasters, us_rasters_rdt_01)"
read -p "Hit return to continue... "
