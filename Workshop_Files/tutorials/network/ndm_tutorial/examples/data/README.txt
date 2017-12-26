/
/ $Header: sdo/demo/network/examples/data/README.txt /main/4 2009/11/05 12:59:11 hgong Exp $
/
/ README.txt
/
/ Copyright (c) 2007, Oracle. All Rights Reserved.
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
/   hgong       02/13/07 - Creation
/

Overview of this data directory:
--------------------------------

Each sub-directory under this folder contains dmp files and plsql scripts
to set up a network, whose network name is the same as the directory name.

The only exception is directory ndmdemo, which contains plsql scripts and
utilities to facilitate the set up of a NAVTEQ network.

The following is a description of the networks:
- bi_test: bi-directed small network
- un_test: undirected small network
- hillsborough_network: topology network of hillsborough county
- navteq_sf: NavTeq San Francisco network

Steps to set up the following networks:
---------------------------------------
- BI_TEST
- UN_TEST
- HILLSBOROUGH_NETWORK

1. Run <network_name>_drop.sql script to remove  all traces of the network
   from your database, e.g.,

   SQL> hillsborough_network_drop.sql

2. Import the network tables, e.g.,

   imp <dbuser>/<dbpassword> file=hillsborough_network.dmp full=y

3. Run <network_name>_create.sql script to create network metadata, e.g.,

   SQL> < hillsborough_network_create.sql

Steps to set up ndmdemo:
------------------------
Follow the README.txt file in ndmdemo folder.


Steps to set up the NavTeq networks:
------------------------------------
- NAVTEQ_SF

Follow the README.txt file in the corresponding folder.

If you have other NavTeq network, as long as they are in ODF format, you can 
use similar setup script as the setup.sql under navteq_sf, by simply replacing 
all the apprearances of navteq_sf with your own network name.

