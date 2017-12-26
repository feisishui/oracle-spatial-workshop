title GlassFish (verbose)

rem Check java version
java -version

rem Start the server
call ogs-3.1\glassfish3\bin\asadmin start-domain --verbose=true
pause

