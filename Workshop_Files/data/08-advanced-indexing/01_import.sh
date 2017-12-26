#!/bin/bash
cd "`dirname "$0"`"

imp scott/tiger file=yp_data.dmp full=yes indexes=no

read -p "Hit return to continue... " X

