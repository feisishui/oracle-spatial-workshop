#!/bin/bash -x
cd "$(dirname "$0")"

./ogs/glassfish3/bin/asadmin create-file-user --groups asadmin --authrealmname file mapadmin

read -p "Hit return to continue... "
