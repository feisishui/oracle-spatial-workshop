#!/bin/bash
cd "`dirname "$0"`"

cd ../../../data/04-loading/sqlldr/
export NLS_LANG=american_america.we8iso8859p1
time sqlldr scott/tiger direct=yes control=us_cities.ctl       data=us_cities.dat      log=/usr/tmp/

read -p "Hit return to continue... "
