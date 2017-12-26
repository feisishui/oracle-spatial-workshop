#!/bin/bash -x
cd "`dirname "$0"`"

imp scott/tiger file=../../../data/16-3D-support/01-solids/building_footprints.dmp tables="(building_footprints)"


read -p "Hit return to continue... "

