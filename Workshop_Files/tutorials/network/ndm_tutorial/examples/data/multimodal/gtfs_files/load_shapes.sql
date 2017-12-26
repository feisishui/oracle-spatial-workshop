Rem
Rem $Header: sdo/demo/network/examples/data/multimodal/gtfs_files/load_shapes.sql /main/1 2011/06/16 07:43:00 begeorge Exp $
Rem
Rem load_shapes.sql
Rem
Rem Copyright (c) 2011, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      load_shapes.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    begeorge    06/09/11 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

-- Loads shapes information into database.
-- Make sure that shapes.csv (csv version of 
-- the GTFS file shapes.txt) exists in the directory.
--
-- This script assumes that the table is being loaded into 
-- a user account 'NAVTEQ_DC'. 
-- Change suitably before running the script.
--

CREATE OR REPLACE DIRECTORY LOAD_DIR AS
        '/tmp';
GRANT READ, WRITE ON DIRECTORY LOAD_DIR to navteq_dc;

conn navteq_dc/navteq_dc;

CREATE TABLE NAVTEQ_DC_SHAPES_EXTERNAL
        (shape_id number,shape_pt_lat number,shape_pt_lon number,
         shape_pt_sequence number,shape_dist_traveled number)
        ORGANIZATION EXTERNAL
        ( TYPE ORACLE_LOADER
          DEFAULT DIRECTORY LOAD_DIR
          ACCESS PARAMETERS
                (
                 RECORDS delimited by newline
                 FIELDS terminated by ','
                 MISSING FIELD VALUES ARE NULL
                )
          LOCATION ('shapes.csv')
        ) REJECT LIMIT UNLIMITED;

CREATE TABLE NAVTEQ_DC_SHAPE$(shape_id number,
                              shape_pt_lat number,
                              shape_pt_lon number,
                              shape_pt_sequence number,
                              shape_dist_traveled number);

INSERT INTO NAVTEQ_DC_SHAPE$
   SELECT * FROM NAVTEQ_DC_SHAPES_EXTERNAL;

DROP TABLE NAVTEQ_DC_SHAPES_EXTERNAL PURGE;
