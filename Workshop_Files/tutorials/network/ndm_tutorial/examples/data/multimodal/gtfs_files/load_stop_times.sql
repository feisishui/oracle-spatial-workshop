Rem
Rem $Header: sdo/demo/network/examples/data/multimodal/gtfs_files/load_stop_times.sql /main/1 2011/06/16 07:43:00 begeorge Exp $
Rem
Rem load_stop_times.sql
Rem
Rem Copyright (c) 2011, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      load_stop_times.sql - <one-line expansion of the name>
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

-- Loads stop_times information into database.
-- Make sure that stop_times.csv (csv version of
-- the GTFS file stop_times.txt) exists in the directory.
--
-- This script assumes that the table is being loaded into 
-- a user account 'NAVTEQ_DC'. 
-- Change this suitably before running the script.
--

CREATE OR REPLACE DIRECTORY LOAD_DIR AS '/tmp';
GRANT READ, WRITE ON DIRECTORY LOAD_DIR to navteq_dc;

conn navteq_dc/navteq_dc;

CREATE TABLE NAVTEQ_DC_STOP_TIMES_EXTERNAL
        (trip_id number,arrival_time varchar2(10), departure_time varchar2(10),
         stop_id number,stop_sequence number, pickup_type number,drop_off_type number,
         shape_dist_traveled number)
        ORGANIZATION EXTERNAL
        ( TYPE ORACLE_LOADER
          DEFAULT DIRECTORY LOAD_DIR
          ACCESS PARAMETERS
                (
                 RECORDS delimited by newline
                 FIELDS terminated by ','
                 MISSING FIELD VALUES ARE NULL
                )
          LOCATION ('stop_times.csv')
        ) REJECT LIMIT UNLIMITED;

CREATE TABLE NAVTEQ_DC_STOP_TIME$ (trip_id number,
                                arrival_time varchar2(10),
                                departure_time varchar2(10),
                                stop_id number,
                                stop_sequence number,
                                pickup_type number,
                                drop_off_type number,
                                shape_dist_traveled number);
INSERT INTO NAVTEQ_DC_STOP_TIME$
   SELECT * FROM NAVTEQ_DC_STOP_TIMES_EXTERNAL;

DROP TABLE NAVTEQ_DC_STOP_TIMES_EXTERNAL purge;

