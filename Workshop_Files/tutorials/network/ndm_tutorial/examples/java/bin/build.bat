cd ..

rmdir /S /Q classes

mkdir classes

SET CLASSPATH=lib/ojdbc6.jar;lib/xmlparserv2.jar;lib/sdoapi.jar;lib/sdoutl.jar;lib/sdonm.jar;lib/sdondmx.jar;lib/routeserver.jar;lib/sdogcdr.jar;lib/sdondmapps.jar

javac -cp %CLASSPATH% -d classes src/inmemory/*.java src/lod/*.java src/xml/*.java

copy src\lod\*.xml classes\lod

copy src\xml\*.xml classes\xml

cd bin
