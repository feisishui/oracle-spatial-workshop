#!/bin/bash
cd "$(dirname "$0")"
cp -v ogs/glassfish3/oracle-jdbc-drivers/ojdbc6.jar ogs/glassfish3/glassfish/lib
read -p "Hit return to continue..."
