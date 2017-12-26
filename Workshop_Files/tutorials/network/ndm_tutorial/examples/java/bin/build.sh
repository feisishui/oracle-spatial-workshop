#!/bin/sh
#
# Copyright (c) 2006, 2012, Oracle and/or its affiliates. All rights reserved. 
#

cd ..

rm -rf classes
mkdir classes

CLASSPATH=lib/ojdbc6.jar:lib/xmlparserv2.jar:lib/sdoapi.jar:lib/sdoutl.jar:lib/sdonm.jar:lib/sdondmx.jar:lib/routeserver.jar:lib/sdogcdr.jar:lib/sdondmapps.jar

javac -cp $CLASSPATH -d classes src/**/*.java

cp src/lod/*.xml classes/lod

cp src/xml/*.xml classes/xml

cd bin
