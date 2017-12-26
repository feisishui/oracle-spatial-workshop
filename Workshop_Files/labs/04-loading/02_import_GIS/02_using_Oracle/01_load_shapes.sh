#!/bin/bash
cd "`dirname "$0"`"

# Change the following to match your environment:
DB_SERVER=127.0.0.1
DB_PORT=1521
DB_SID=orcl122
DB_USER=scott
DB_PASS=tiger

SHAPE_FILES="../../../../data/04-loading/shape/"

JAVA=$ORACLE_HOME/jdk/bin/java
CLASSPATH=$ORACLE_HOME/jdbc/lib/ojdbc8.jar:$ORACLE_HOME/md/jlib/sdoutl.jar:$ORACLE_HOME/md/jlib/sdoapi.jar:$ORACLE_HOME/jlib/orai18n.jar
LOADER_CLASS=oracle.spatial.util.SampleShapefileToJGeomFeature

echo Loading shape files from $SHAPE_FILES
for g in $( ls $SHAPE_FILES/*.shp); do

  full_file_name=${g%.*}
  file_name=${g##*/}
  table_name=${file_name%.*}

  echo Loading file: $file_name into $table_name
  $JAVA -Dfile.encoding=ISO-8859-1 -cp $CLASSPATH $LOADER_CLASS -h $DB_SERVER -p $DB_PORT -s $DB_SID -u $DB_USER -d $DB_PASS -r 8307 -f $full_file_name -t $table_name -g geometry -i id
done

read -p "Hit return to continue... "
