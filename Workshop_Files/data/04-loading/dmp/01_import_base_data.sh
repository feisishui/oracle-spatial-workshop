#!/bin/bash
cd "$(dirname "$0")"
imp scott/tiger file=base_data.dmp tables="(US_CITIES,US_COUNTIES,US_INTERSTATES,US_PARKS,US_RIVERS,US_STATES,WORLD_CONTINENTS,WORLD_COUNTRIES)"
read -p "Hit return to continue... "
