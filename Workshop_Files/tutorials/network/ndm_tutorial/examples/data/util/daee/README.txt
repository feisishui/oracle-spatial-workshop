/
/ $Header: sdo/demo/network/examples/data/util/daee/README.txt /main/1 2012/03/08 05:58:44 begeorge Exp $
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
/   begeorge    03/07/12 - Creation
/
This directory has scripts to set up data for the water utility network (DAEE)  in
Porto Alegre, Brazil (GEMPI).

To set up the data run 
   (i)  setup.sql 
   (ii) demo.sql 

Notes ::

(1) To import the data successfully, the user DAEE needs to be created with
tablespace DAEE_POA. Please go through the script file setup.sql and change
the directory for dbf file suitably before running the script.

(2) Import command for database version 12.1.0.0.2 is different from the
command included in the script. The commands required for 12.1.0.0.2 are
included as comments. The directory object needs to be created before running
IMPDP. The dmp file should be available in the directory associated with 
the directory object.
 
