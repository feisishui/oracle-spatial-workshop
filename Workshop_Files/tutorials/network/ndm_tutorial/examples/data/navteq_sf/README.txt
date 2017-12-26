/ Copyright (c) 2009, Oracle. All Rights Reserved.

This folder contains dmp files and plsql scripts to setup NAVTEQ San Francisco
data.

(I)   SETTING UP DATA
      ---------------
  (1) Login as sysdba;

  (2) Run the script setup.sql is the script to install the NAVTEQ San Francisco 
      sample data set. 
      Before running this script, make sure the following:

          (i)  You have downloaded the NAVTEQ_SF_Sample.dmp file from NAVTEQ, and 
               placed it under the same directory as setup.sql;

          (ii) You are connected to the database as sysdba.

  (3) Run demo.sql to get the data set ready for the NDM Demo.
      Before running this script, make sure the following

          (i)   You have already set up ndmdemo data;

          (ii)  You have already installed NAVTEQ San Francisco sample data set;

          (iii) If you database version is 11.1, you must download NDM partial upgrade 
                patch (patch # 7700528), extract router_network.sql from the package,
                and place it under the same directory as demo.sql;

          (iv)  You are connected to the database as sysdba. 

          ****  If traffic information needs to be included
          (v)   Make sure that setup_traffic_data.sql is in the current
                directory.


(II)  CONFIGURING THE NETWORK FOR ANALYSIS
      ------------------------------------
  (1)   Make sure that LODConfigs.xml has the correct entries for the network.
        The partition blob translator should be set correctly.
        For Navteq_SF network (which is in ODF format) use
        oracle.spatial.network.router.RouterPartitionBlobTranslator10g.

(III) RUNNING THE DEMO
      ----------------
  (1)   Deploy ndmdemo, mapviewer, and geocoder (if data is available).

  (2)   Add data sources NAVTEQ_SF and NDMDEMO to mapviewer data sources
           (i)     Open mapviewer web page (example: http://localhost:7001/mapviewer)
           (ii)    Log in as admin.
           (iv)    Add the data sources to the Configuration XML; save and restart
                   mapviewer.
  (3)   Open the ndmdemo web page (example: http://localhost:7001/ndmdemo)
        Set the configuration.

(IV)   DEMO CONFIGURATION EXAMPLE
      --------------------------

         DB URL:                         jdbc:orcale:thin:@localhost:1521:orcl
         Demo User:                      ndmdemo
         Demo Password:                  ndmdemo
         Network User:                   navteq_sf
         Network Password:               navteq_sf
         Network Name:                   NAVTEQ_SF
         Geocoder URL:			 http://elocation.oracle.com/geocoder/gcserver
         Mapviewer URL:                  http://localhost:7001/mapviewer
         Base Map Tile URL:              http://localhost:7001/mapviewer
         Base Map Tile Layer Name:       navteq_sf.world_map
         Network SRID:                   8307
         Map Center X:                   -122.45
         Map Center Y:                   37.7706
         Zoom Level:                     13
         Max FOIs to Display:            1000
         Max Characters in Text Results: 100000
         Log Level:                      INFO
         Click to Show:                  Nearest Node ID
         Show Partition Boundaries:      NO
         Show Congested Links:           NO

     NOTES:

        - truckingDemo.txt contains a list of addresses to demonstrate trucking
          constraints.

        - If traffic information needs to be included in the demo, make sure
	  that traffic USER DATA table (TP_USER_DATA) is
    	  loaded in the database. 


