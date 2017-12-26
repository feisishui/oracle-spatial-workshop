#!/bin/bash
echo -ne "\033]0;Glassfish Admin\007"
cd "$(dirname "$0")"
rlwrap ogs/glassfish3/bin/asadmin
read -p "Hit return to continue..."

