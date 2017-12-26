Rem
Rem $Header: sdo/demo/network/examples/data/multimodal/gtfs_files/load_agencies.sql /main/1 2011/06/16 07:43:00 begeorge Exp $
Rem
Rem load_agencies.sql
Rem
Rem Copyright (c) 2011, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      load_agencies.sql - <one-line expansion of the name>
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

-- Loads agency information into database.
-- Make sure that agency.csv (csv version of
-- the GTFS file agency.txt) exists in the directory.
--
-- This script assumes that the table is being loaded into 
-- a user account 'NAVTEQ_DC'. 
-- Change this suitably before running the script.
--

CREATE OR REPLACE DIRECTORY LOAD_DIR AS
        '/tmp';
GRANT READ, WRITE ON DIRECTORY LOAD_DIR to navteq_dc;

conn navteq_dc/navteq_dc;

CREATE TABLE NAVTEQ_DC_AGENCY_EXTERNAL
        (agency_id number,
         agency_name varchar2(128),
         agency_url varchar2(512),
         agency_timezone varchar2(256),
         agency_lang varchar2(64),
         agency_phone varchar2(16))
        ORGANIZATION EXTERNAL
        ( TYPE ORACLE_LOADER
          DEFAULT DIRECTORY LOAD_DIR
          ACCESS PARAMETERS
                (
                 RECORDS delimited by newline
                 FIELDS terminated by ','
                 MISSING FIELD VALUES ARE NULL
                )
          LOCATION ('agency.csv')
        ) REJECT LIMIT UNLIMITED;

CREATE TABLE NAVTEQ_DC_AGENCY$ (agency_id number,
                               agency_name varchar2(128),
                               agency_url varchar2(512),
                               agency_timezone varchar2(256),
                               agency_lang varchar2(64),
                               agency_phone varchar2(16));
INSERT INTO NAVTEQ_DC_AGENCY$
   SELECT * FROM NAVTEQ_DC_AGENCY_EXTERNAL;

DROP TABLE NAVTEQ_DC_AGENCY_EXTERNAL purge;
