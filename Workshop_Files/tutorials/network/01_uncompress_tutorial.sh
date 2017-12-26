#!/bin/bash -x
cd "$(dirname "$0")"

# Cleanup
rm -r -f ndm_tutorial

# Create unpack directories for the tutorial
mkdir ndm_tutorial

# Unpack the tutorial into the directory
unzip ndm_tutorial.zip -d ndm_tutorial

read -p "Hit return to continue... "
