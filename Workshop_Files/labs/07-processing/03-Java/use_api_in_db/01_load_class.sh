#!/bin/bash
cd "`dirname "$0"`"
loadjava -user scott/tiger@orcl122 -resolve -force SdoTest.java -verbose
read -p "Hit return to continue... "

