#!/bin/bash -x
cd "$(dirname "$0")"

loadjava -user scott/tiger@orcl122 -resolve -force SdoLoadShape.java -verbose

read -p "Hit return to continue... "
