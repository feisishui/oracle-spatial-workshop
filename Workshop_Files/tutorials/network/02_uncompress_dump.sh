#!/bin/bash -x
cd "$(dirname "$0")"

# Cleanup
rm -r -f here_sf_sample

# Create unpack directories for the dump
mkdir here_sf_sample

# Unpack the dump into the directory
unzip here_sf_sample.zip -d here_sf_sample

read -p "Hit return to continue... "