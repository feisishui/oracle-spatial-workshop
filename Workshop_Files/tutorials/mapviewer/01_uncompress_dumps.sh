#!/bin/bash -x
cd "$(dirname "$0")"

# Cleanup
rm -r -f dmp

# Create unpack directories for the dumps
mkdir dmp
mkdir dmp/naturalearth

# Unpack the dumps into the directory
unzip mvdemo_naturalearth.zip -d dmp/naturalearth
unzip mvdemo_stormdata.zip -d dmp

read -p "Hit return to continue... "
