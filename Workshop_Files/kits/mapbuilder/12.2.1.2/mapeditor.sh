#!/bin/bash
cd "$(dirname "$0")"
java -Xms128m -Xmx256m -Duser.language=EN -Duser.region=US -jar mapeditor.jar
read -p "Hit return to continue... "
