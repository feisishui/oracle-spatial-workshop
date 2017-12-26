#!/bin/bash -x
cd "$(dirname "$0")"

ogs/glassfish3/bin/asadmin undeploy mapviewer
ogs/glassfish3/bin/asadmin undeploy mvdemo

read -p "Hit return to continue..."e
