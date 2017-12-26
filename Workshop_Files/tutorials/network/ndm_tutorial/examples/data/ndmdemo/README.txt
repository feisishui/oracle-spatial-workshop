/
/ $Header: sdo/demo/network/examples/data/ndmdemo/README.txt /main/6 2012/05/24 07:13:56 begeorge Exp $
/
/ README.txt
/
/ Copyright (c) 2009, Oracle. All Rights Reserved.
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
/   hgong       08/20/09 - Creation
/

This folder contains dmp files and plsql scripts to setup ndmdemo data.

- ndmdemo.sql is the main script to setup ndmdemo data. This script must
  be run before the scripts to set up individual NAVTEQ networks, such as 
  NAVTEQ_SF, are executed.

  Before running this script, make sure styles_themes_maps.dmp and
  ndmdemo_uil.sql are under the same directory as this script.

-- If the demo needs include traffic information,

   -- load the package traffic_util.sql 
   -- Load sdondmapps.jar 

Before running the demo, ensure the following steps are executed

(1) Add data source NDMDEMO to mapviewer data sources
           (i)     Open mapviewer web page (example: http://localhost:7001/mapviewer)
           (ii)    Log in as admin.
           (iv)    Add the data source to the Configuration XML; save and
                   restart mapviewer.

(2) Add a data source corresponding to network user (for example, if NAVTEQ_SF
    network is used in the demo, add a data source NAVTEQ_SF to mapviewer
    data sources). To add a data source follow the steps (i), (ii) and (iii)
    in Step 1.



