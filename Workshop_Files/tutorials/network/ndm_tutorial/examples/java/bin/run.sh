#!/bin/sh
#
# Copyright (c) 2006, 2012, Oracle and/or its affiliates. All rights reserved. 
#

cd ..

CLASSPATH=classes:lib/ojdbc6.jar:lib/xmlparserv2.jar:lib/sdoapi.jar:lib/sdoutl.jar:lib/sdonm.jar:lib/sdondmx.jar:lib/routeserver.jar:lib/sdogcdr.jar:lib/sdondmapps.jar

java -Xmx1G -cp $CLASSPATH lod.ShortestPathAnalysis

cd bin
