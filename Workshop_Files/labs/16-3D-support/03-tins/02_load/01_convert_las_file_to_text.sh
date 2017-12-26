#!/bin/bash
cd "$(dirname "$0")"

# Convert to text using all dimensions
las2txt -i ../../../../data/16-3D-support/02-point_clouds/Serpent_Mound_Model_LAS_Data.las \
  -o Serpent_Mound_Model_LAS_Data.dat \
  --parse xyzirndecaupt
  -v

read -p "Hit return to continue... "
