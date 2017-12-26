Rem
Rem $Header: sdo/demo/network/examples/data/multimodal/demo.sql /main/2 2012/06/14 05:32:51 begeorge Exp $
Rem
Rem demo.sql
Rem
Rem Copyright (c) 2011, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      demo.sql - <one-line expansion of the name>
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

-- Log into Oracle as a privileged user (SYS or SYSTEM)
--
set echo on

-- Grant create view to NAVTEQ_DC user.
grant create view, create table to navteq_dc;

create or replace directory WORK_DIR as '/scratch/begeorge/data/navteq_dc';
grant read, write on directory WORK_DIR to navteq_dc;

conn navteq_dc/navteq_dc

--
-- Prepare multimodal data
--
-- Before running the proceure, make sure that 
-- (1) The basic network (NAVTEQ_DC) is loaded.
-- (2) The transit related tables
--         NAVTEQ_DC_ROUTE$,
--         NAVTEQ_DC_TRIP$,
--         NAVTEQ_DC_STOP$,
--         NAVTEQ_DC_STOP_TIME$,
--         NAVTEQ_DC_SHAPE$,
--         NAVTEQ_DC_CALENDAR$,
--         NAVTEQ_DC_AGENCY$
--     are available in the database.
-- (3) Directory called WORK_DIR is created and the user has read/write 
--     permissions on it.
-- (4) Make sure that a directory WORK_DIR has the csv files with GTFS data.
-- (5) The sql file to load the mm_util package (mm_util.sql) is in the 
--     directory.
-- (6) The jar file sdondmmm.jar is available in the directory.
--     The jar file will be available in
--     sdo/demo/network/ndmdemo/ship/web/WEB_INF/lib directory.
-- (7) Extract class files from sdondmmm.jar files and set classpath
--     to include sdonm.jar, sdondmx.jar, sdoapi.jar, sdoutl.jar, xmlparserv2.jar,
--     ojdbc6.jar, xdb.jar, sdondmmm.jar. 
--     This step is required for transfer links generation.
--
--
@mm_util;

@setup_multimodal_data;

--
-- Grant permissions to ndmdemo
--
grant select on navteq_dc_mm_node$ to ndmdemo;
grant select on navteq_dc_mm_link$ to ndmdemo;
commit;
