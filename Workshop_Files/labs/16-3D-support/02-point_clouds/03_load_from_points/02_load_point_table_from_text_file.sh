#!/bin/bash
cd "$(dirname "$0")"

time sqlldr scott/tiger \
  control=point_table.ctl \
  data=Serpent_Mound_Model_LAS_Data.dat \
  direct=true columnarrayrows=20000 streamsize=2560000 \
  multithreading=true

read -p "Hit return to continue... "
