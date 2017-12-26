#!/bin/bash -x
cd "$(dirname "$0")"

ogs/glassfish3/bin/asadmin deploy --name=mvdemo --force=true ../../tutorials/mapviewer/mvdemo.war

read -p "Hit return to continue..."
 
