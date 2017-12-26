#!/bin/bash -x
cd "`dirname "$0"`"

export CLASSPATH=.:$ORACLE_HOME/jdbc/lib/ojdbc8.jar:$ORACLE_HOME/md/jlib/sdoutl.jar:$ORACLE_HOME/md/jlib/sdoapi.jar:$ORACLE_HOME/jlib/orai18n.jar:$ORACLE_HOME/lib/xmlparserv2.jar
JAVA_PARAMS="-Xms128M -Xmx128M -Duser.language=en"

#Change the following to match your database connection
$ORACLE_HOME/jdk/bin/java $JAVA_PARAMS SdoLoadCityGML \
  -host 127.0.0.1 \
  -port 1521 \
  -sid orcl122 \
  -user scott -password tiger \
  -file ../../../data/16-3D-support/01-solids/CityGML_British_Ordnance_Survey.xml \
  -table buildings \
  -geomcol geom \
  -featurecol feature \
  -idcol building_id \
  -srid 7405

read -p "Hit return to continue... "
