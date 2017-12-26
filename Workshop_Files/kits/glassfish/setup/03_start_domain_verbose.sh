#!/bin/bash -x
cd "$(dirname "$0")"

# Start the server for the domain
ogs/glassfish3/bin/asadmin start-domain --verbose=true

read -p "Hit return to continue... "

