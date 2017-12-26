/
/ $Header: sdo/demo/network/examples/data/hillsborough_network/README.txt /main/1 2010/05/12 07:16:18 begeorge Exp $
/
/ README.txt
/
/ Copyright (c) 2010, Oracle. All Rights Reserved.
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
/   begeorge    05/05/10 - Creation
/
This folder contains the dump file and SQL scripts to set up HILLSBOORUGH
network data (non-ODF format) for NDM demo.

Steps to set up the network are provided below:

(I)   SETTING UP DATA
      ---------------

  (1)   Login as sysdba;

  (2)   Run the script setup.sql to install Hillsborough data set.
        Make sure that the dump file hillsborough_network.dmp is in the current
        directory.

  (3)   Login as hillsborough/hillsborough

  (4)   Run the script demo.sql
        Before running the script, make sure that ndmdemo data has already been
        set up. To set it up, follow the instructions in the README file in 
        sdo/demo/network/examples/data/ndmdemo directory.

(II)  CREATING THE BASE MAP AND TILE LAYER FOR THE NETWORK
      ----------------------------------------------------
  
  (1)   Create a connection HILLSBOROUGH in mapbuilder.
  
  (2)   Using map builder, create map viewer themes (HILLSBOROUGH_NODE,
        HILLSBOROUGH_LINK) for the node and link tables. 
  
  (3)   Create a base map (HILLSBOROUGH_MAP) that consists of the node and link themes.

  (4)   Create a tile layer (HILLSBOROUGH_MAP) for the base map created in the previous 
        step. Set the parameters (scale, cx, cy) to appropriate values.  

(III) CONFIGURING THE NETWORK FOR ANALYSIS
      ------------------------------------

  (1)   Make sure that LODConfigs.xml has the correct entries for the network.
        The partition blob translator should be set correctly.
        For Hillsborough network (which is in non-ODF format) use
        oracle.spatial.network.lod.PartitionBlobTranslator11gR2.

(IV)  RUNNING THE DEMO
      ----------------
  
  (1)   Deploy ndmdemo, mapviewer, and geocoder (if data is available).

  (2)   Open mapviewer web page (example: http://localhost:7001/mapviewer)
        Log in as admin.
        (i)   Add the data source HILLSBOROUGH to the mapviewer data sources.
        (ii)  Add the data source to the Configuration XML; save and restart
              mapviewer.
  (3)   Open the ndmdemo web page (example: http://localhost:7001/ndmdemo)
        Set the configuration.

(V)   DEMO CONFIGURATION EXAMPLE
      --------------------------

         DB URL:			 jdbc:orcale:thin:@localhost:1521:orcl
	 Demo User:			 ndmdemo
	 Demo Password:			 ndmdemo
	 Network User:			 hillsborough
	 Network Password:		 hillsborough
	 Network Name:			 HILLSBOROUGH_NETWORK
  	 Geocoder URL:			 http://elocation.oracle.com/geocoder/gcserver
	 Mapviewer URL: 		 http://localhost:7001/mapviewer
	 Base Map Tile URL:		 http://localhost:7001/mapviewer
	 Base Map Tile Layer Name:	 hillsborough.hillsborough_map
	 Network SRID:			 8307
	 Map Center X:			 -71.446
	 Map Center Y:			 43.525
	 Zoom Level:			 4
	 Max FOIs to Display:		 1000
	 Max Characters in Text Results: 100000	
	 Log Level:			 INFO
	 Click to Show:			 Nearest Node ID
	 Show Partition Boundaries:	 NO
	 Show Congested Links:		 NO

     NOTE:
           
           The traffic related features in the demo (including 'Show Congested Links' on the 
           Congiguration page) would work only if traffic data is available for the network 
           and the required user data is generated and loaded under the network user.  
