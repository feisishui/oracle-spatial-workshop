#!/bin/bash
cd "$(dirname "$0")"
export CLASSPATH=.:$ORACLE_HOME/jdbc/lib/ojdbc8.jar:$ORACLE_HOME/md/jlib/sdoutl.jar:$ORACLE_HOME/md/jlib/sdoapi.jar:$ORACLE_HOME/jlib/orai18n.jar:$ORACLE_HOME/lib/xmlparserv2.jar

for g in $( ls *.java); do
  echo Compiling $g
  $ORACLE_HOME/jdk/bin/javac $g
done

read -p "Hit return to continue... "
