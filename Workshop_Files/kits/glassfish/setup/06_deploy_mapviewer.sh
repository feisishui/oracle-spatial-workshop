#!/bin/bash -x
cd "$(dirname "$0")"

ogs/glassfish3/bin/asadmin deploy --name=mapviewer --force=true ../../kits/mapviewer/mapviewer.ear

read -p "Hit return to continue..."
 
