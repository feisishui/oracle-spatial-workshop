#!/bin/bash
cd "$(dirname "$0")"

# Modify the following to match your environment
DB_CONNECTION=jdbc:oracle:thin:@127.0.0.1:1521:orcl122
DB_USER=scott
DB_PASS=tiger

export CLASSPATH=.:$ORACLE_HOME/jdbc/lib/ojdbc8.jar:$ORACLE_HOME/md/jlib/sdoutl.jar:$ORACLE_HOME/md/jlib/sdoapi.jar:$ORACLE_HOME/jlib/orai18n.jar:$ORACLE_HOME/lib/xmlparserv2.jar

echo SdoPrint: Print out the geometry of Denver county:
java SdoPrint $DB_CONNECTION $DB_USER $DB_PASS us_counties geom "where county='Denver'" 4

echo SdoExport: Export all counties in Colorado in GML format
java SdoExport $DB_CONNECTION $DB_USER $DB_PASS us_counties geom "where state='Colorado'" us_counties_co.xml gml

echo SdoImport: Import the counties from Colorado back into a table
echo NOTE: the table must exist prior to running the import
echo CREATE TABLE US_COUNTIES_CO (ID NUMBER, GEOM SDO_GEOMETRY);
java SdoImport $DB_CONNECTION $DB_USER $DB_PASS us_counties_co geom id us_counties_co.xml gml

echo SdoLoadShape: Load world countries from shape file WORLD_COUNTRIES.SHP into a new table called COUNTRIES.
java SdoLoadShape $DB_CONNECTION $DB_USER $DB_PASS countries geom id ../../../../data/04-loading/shape/world_countries 8307 1

read -p "Hit return to continue... "
