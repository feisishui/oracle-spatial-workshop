#!/bin/bash -x
cd "$(dirname "$0")"

# Enable remote admin
./ogs/glassfish3/bin/asadmin enable-secure-admin

# Restart the server
./ogs/glassfish3/bin/asadmin restart-domain

read -p "Hit return to continue..."

