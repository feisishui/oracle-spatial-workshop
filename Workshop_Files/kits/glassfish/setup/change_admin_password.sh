#!/bin/bash -x
cd "$(dirname "$0")"

ogs/glassfish3/bin/asadmin change-admin-password

read -p "Hit return to continue... "
