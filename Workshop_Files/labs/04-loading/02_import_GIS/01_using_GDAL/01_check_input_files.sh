#!/bin/bash
cd "`dirname "$0"`"

cd ../../../../data/04-loading

echo ==========================================================
echo Checking ESRI shape files
echo ==========================================================
ogrinfo -al -so shape

echo ==========================================================
echo Checking Mapinfo files
echo ==========================================================
ogrinfo -al -so tab

echo ==========================================================
echo Checking GeoJSON files
echo ==========================================================
for g in $( ls geojson/*.json); do
  ogrinfo -al -so $g
done

echo ==========================================================
echo Checking ESRI File GDB
echo ==========================================================
ogrinfo -al -so fileGDB/us_data.gdb

read -p "Hit return to continue... "

