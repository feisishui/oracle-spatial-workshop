#!/bin/bash
cd "`dirname "$0"`"

imp scott/tiger file=../../../data/09-mapviewer/us_streets.dmp full=yes

read -p "Hit return to continue... "
