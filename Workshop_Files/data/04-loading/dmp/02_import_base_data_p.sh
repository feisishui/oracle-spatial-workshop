#!/bin/bash
cd "$(dirname "$0")"
imp scott/tiger file=base_data_p.dmp tables="(US_CITIES_P,US_COUNTIES_P,US_INTERSTATES_P,US_PARKS_P,US_RIVERS_P,US_STATES_P)"
read -p "Hit return to continue... "
