#!/bin/bash -x
cd "`dirname "$0"`"

cd ../../../../data/04-loading/sqlldr_wkt/
export NLS_LANG=american_america.we8iso8859p1
sqlldr scott/tiger control=us_cities.ctl       data=us_cities.dat      log=/usr/tmp/ bindsize=20000000 readsize=20000000

read -p "Hit return to continue... "

