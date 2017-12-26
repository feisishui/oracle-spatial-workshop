/
/ $Header: sdo/demo/network/examples/java/src/lod/persistent_network_buffers/README.txt /main/1 2012/05/24 07:15:54 begeorge Exp $
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
/   begeorge    04/24/12 - Creation
/
This directory has sample java code that illustrates the computation and 
persistence of  network buffers in database.

PersistentNetworkBuffers.java : Computes network buffers and writes them
                                in database. Network buffers are persisted
                                using writeNetworkBuffer API. The prefix
                                for table names can be specified in the API.
                                in five tables. 
                                (a) <prefix>_NBCN$
                                           -- Stores information about the
                                              start node of the buffer.
                                (b) <prefix>_NBCL$
                                           -- Stores information about
                                              the start point as 
                                              link ID, percentage
                                (c) <prefix>_NBN$
                                           -- Stores node IDs of all nodes
                                              included in the buffer. 
                                              It also stores the cost
                                              associated with each node.
                                (d) <prefix>_NBL$
                                           -- Stores link IDs of all link
                                              included in the buffer. 
                                              The start and end percentages,
                                              and costs at start and end 
                                              are also included. This takes
                                              care of cases where only a part
                                              of a link is included in the
                                              buffer.
                                (e) <prefix>_NBR$
                                           -- Contains the radius (cost) of
                                              buffer. Also stores the
                                              traversal direction (forward/
                                              backward).

LinkTravelTimeCalculator.java  : Link Cost calculator implementation to
                                 compute the link travel time as the link
                                 cost.

To compile and run :::::

*** Make sure that the following jar files are in the CLASSPATH.
              (a) sdoapi.jar
              (b) sdonm.jar
              (c) sdondmx.jar
              (d) sdoutl.jar
              (e) ojdbc6.jar
              (f) xdk.jar
              (g) xmlparserv2.jar
              (h) routeserver.jar

   (i)    rm -rf classes
   (ii)   mkdir classes
   (iii)  javac -cp $CLASSPATH -d classes *.java
   (iv)   cp LODConfigs.xml classes/nbuffer/
   (v)    java -cp classes:$CLASSPATH nbuffer.PersistentNetworkBuffer
          OR
          java -cp classes:$CLASSPATH nbuffer.PersistentNetworkBuffer -dbUrl "jdbc:oracle:thin:@localhost:1521:orcl" -dbUser navteq_sf -dbPassword navteq_sf -networkName NAVTEQ_SF -startNodeId 199908767 -cost 48000 -tableNamePrefix NAVTEQ_SF_30MILES

