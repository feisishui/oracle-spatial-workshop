/
/ $Header: sdo/demo/network/examples/java/src/lod/drive_time_polygons/README.txt /main/1 2012/03/22 05:41:12 begeorge Exp $
/
/ README.txt
/
/ Copyright (c) 2012, Oracle. All Rights Reserved.
/
/   NAME
/     README.txt - <one-line expansion of the name>
/
/   DESCRIPTION
/     <short description of component this file declares/defines>
/
/   NOTES
/     <other useful comments, qualifications, etc.>
/
/   MODIFIED   (MM/DD/YY)
/   begeorge    03/21/12 - Creation
/
This directory has examples to compute within cost polygons (convex and
concave) and persist the results in the database.

The output table with the following schema must be created before running the programs.
	(id     	NUMBER,
         type           VARCHAR2(6),    -- WALK/DRIVE
         cost_in_sec    NUMBER,
         polygon        SDO_GEOMETRY);

Cost thresholds must be provided in seconds.

(1) ConcaveDriveTimePolygons.java - Computes concave within cost polygons.

        -- The inputs must be in a table in database. Inputs are (lat, lon)
           values of the start points.
           Schema of the input table ::
                (id 		NUMBER,
                 longitude      NUMBER,
                 latitude       NUMBER)

        -- Outputs are stored in the database.
        *** The output table must be created before running the program. ***

        -- To run the program

           rm -rf classes
           mkdir classes
           javac -cp $CLASSPATH -d classes *.java
           cp LODConfigs.xml classes/polygons/

           -- With default inputs
           java -cp classes:$CLASSPATH polygons.ConcaveDriveTimePolygons
           
           -- With command line inputs
           java -cp classes:$CLASSPATH polygons.ConcaveDriveTimePolygons -dbUrl "jdbc:oracle:thin:@localhost:1521:orcl" -dbUser navteq_sf -dbPassword navteq_sf -networkName NAVTEQ_SF -inputTableName TEST_INPUT_POINTS -outputTableName TEST_OUTPUT_POLYGONS -costThreshold 300 

(2) ConvexDriveTimePolygons.java - Computes convex within cost polygons.

        -- The inputs must be in a table in database. Inputs are (lat, lon)
           values of the start points.
           Schema of the input table ::
                (id     	NUMBER,
                 longitude      NUMBER,
                 latitude       NUMBER)

        -- Outputs are stored in the database.
        *** The output table must be created before running the program. ***

        -- To run the program

           rm -rf classes
           mkdir classes
           javac -cp $CLASSPATH -d classes *.java
           cp LODConfigs.xml classes/polygons/

           -- With default inputs
           java -cp classes:$CLASSPATH polygons.ConvexDriveTimePolygons
           
           -- With command line inputs
           java -cp classes:$CLASSPATH polygons.ConvexDriveTimePolygons -dbUrl "jdbc:oracle:thin:@localhost:1521:orcl" -dbUser navteq_sf -dbPassword navteq_sf -networkName NAVTEQ_SF -inputTableName TEST_INPUT_POINTS -outputTableName TEST_OUTPUT_POLYGONS -costThreshold 300

(3) WCPolygonsWithAddressInput.java - Computes concave within cost polygons.

        -- Inputs are strings that can be node ID or linkID@percentage or
           address. Recommended address format is  
           <Street Number Street Name>, <City>, <Country>, <ZIP code>
           Examples : 
               "70 Av. Juarez Colonia Centro, Mexico City, Mexico, 06010"
               "1940 Taraval St, San Francisco, United States, 94116"
                  
        -- Outputs are stored in the database.
        *** The output table must be created before running the program. ***

        -- To run the program

           rm -rf classes
           mkdir classes
           javac -cp $CLASSPATH -d classes *.java
           cp LODConfigs.xml classes/polygons/

           -- With default inputs
           java -cp classes:$CLASSPATH polygons.WCPolygonsWithAddressInput
           
           -- With command line inputs
           java -cp classes:$CLASSPATH polygons.WCPolygonsWithAddressInput -dbUrl "jdbc:oracle:thin:@localhost:1521:orcl" -dbUser navteq_sf -dbPassword navteq_sf -networkName NAVTEQ_SF -output TableName TEST_OUTPUT_POLYGONS -costThreshold 300 -inputString "1940 Taraval St, San Francisco, United States, 94116"

(4) DrivingSpeedLinkCostCalculator.java - Link cost calculator that returns
    link travel time (based on speed limit value in the link table) as the 
    link cost.

(5) WalkingSpeedLinkCostCalculator.java - Link cost calculator that returns
    link travel time (based on walking speed which can be set as an input parameter) as the
    link cost.

(6) ExcludeHighwaysConstraint.java - Implements LODConstraint to exclude
    highways in analysis. Included while computing within cost polygons
    for walk time.

(7) InputParser.java - Parses input strings of format address/node ID/linkID@percent

