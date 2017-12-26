#!/bin/bash -x
cd "$(dirname "$0")"

ogs/glassfish3/bin/asadmin create-jvm-options -Duser.region=US:-Duser.language=EN:-Dcom.sun.media.jai.disableMediaLib=true

read -p "Hit return to continue..."

