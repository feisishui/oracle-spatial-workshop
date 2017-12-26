Contents of this directory:
---------------------------

This directory contains sample Java programs that uses NDM Java API. 
The programs that uses the in-memory API are placed in package inmemory; 
The programs that uses the load-on-demand API are placed in package lod.


How to setup and run these sample Java programs:
------------------------------------------------

This procedure assumes that 
    1. You have Oracle Network Data Model 
       installed on your database.
    2. You have all the necessary Java libraries
       in your classpath:
            sdonm.jar       - Oracle Network Data Model
            sdondmx.jar       - Oracle Network Data Model XML API
            sdoapi.jar      - Oracle JGeometry
            sdoutl.jar      - Oracle Spatial Utility Package
            xmlparserv2.jar - Oracle XDK v2
            ojdbc5.jar      - Oracle JDBC
       (NOTE ::: If you use jdk 1.6 (ojdbc6.jar), make sure that xdb.jar
                 is also included in the CLASSPATH)
    3. You have created a user on your database to
       store your sample networks.  The instructions
       in this file assume that you created a user 
       named mdnetwork with password mdnetwork.
    4. You have created the sample networks in your database
       as described in data/README.txt file.
    5. To test the lod package, you must also partitoin and generate
       partition BLOBs for HILLSBOROUGH_NETWORK, following the 
       example in plsql/partition.sql file.
    6. If you need to run the java programs in the java/src/traffic directory
       		(i)  Make sure that the following library is in the class path
	   	     ndmtraffic.jar
		(ii) Your database must have the data for the NAVTEQ_SF
                     network.
		(iii) The database must be set up to include the required user
                      data tables (Refer to the instructions in 
		      examples/data/navteq_sf directory).

1. Compile the java programs.

        rm -rf classes
        mkdir classes
        javac -cp $CLASSPATH -d classes src/*/*.java
        cp src/lod/*.xml classes/lod
        cp src/xml/*.xml classes/xml

2.  Run the sample java program of interest. For example, to run LoadAndAnalyze
    in the inmemory package, use

        java -cp classes:$CLASSPATH inmemory.LoadAndAnalyze
        
    If your database connection parameters are different from the default values
    in the sample programs, you may specify your connection parameters as input 
    parameters to the java program. For example,

        java -cp classes:$CLASSPATH inmemory.LoadAndAnalyze -dbUrl "jdbc:oracle:thin:@dbhost:1523:sdo" -dbUser mdnetwork -dbPassword mdnetwork    
    

