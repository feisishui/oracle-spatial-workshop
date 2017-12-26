#!/bin/bash
cd "`dirname "$0"`"
imp scott/tiger file=../../../data/08-advanced-indexing/yp_data.dmp full=yes indexes=no

read -p "Hit return to continue."
