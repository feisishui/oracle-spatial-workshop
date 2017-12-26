/
/ $Header: sdo/demo/network/examples/java/src/lod/userdata/README.txt /main/1 2010/12/09 10:15:00 begeorge Exp $
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
/   begeorge    12/08/10 - Creation
/
This directory contains examples on how to set up user data for NDM Analysis.

example.dmp : dump file for the network tables.

setup.sql : this is the script to set up the required data.

EUserDataWriter.java : this is the java code to generate user data blobs for
Category 1 user data for links and nodes.

EUserDataIO.java : this is the user data IO for the category 1 user data.

SPAnalysisWithUserData.java : sample code to run shortest path analysis on the
network with user data included.

To run the example::

(1) Run setup.sql to set up the network.

(2) Compile the java files Make sure that the necessary 
    Java libraries are in your classpath.

(3) Run EUserDataGenerator to generate the user data blobs.

(4) SPAnalysisWithUserData can be run.
