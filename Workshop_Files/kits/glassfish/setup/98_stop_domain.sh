#!/bin/bash -x
cd "$(dirname "$0")"

# Stop the server
ogs/glassfish3/bin/asadmin stop-domain

read -p "Hit return to continue..."
