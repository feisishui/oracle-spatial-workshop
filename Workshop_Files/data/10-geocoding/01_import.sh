#!/bin/bash
cd "$(dirname "$0")"
export NLS_LANG=american_america.we8iso8859p1
imp scott/tiger file=gc_data.dmp full=yes
read -p "Hit return to continue... " X
