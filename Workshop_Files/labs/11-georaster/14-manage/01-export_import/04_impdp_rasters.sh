#!/bin/bash
impdp scott/tiger directory=DATA_PUMP_DIR dumpfile=us_rasters.dmp tables="(us_rasters, us_rasters_rdt_01)" exclude="trigger:\"like 'GRDMLTR%%'\""
read -p "Hit return to continue... "

