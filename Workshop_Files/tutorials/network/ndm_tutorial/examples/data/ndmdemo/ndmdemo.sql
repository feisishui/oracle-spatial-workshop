Rem
Rem $Header: sdo/demo/network/examples/data/ndmdemo/ndmdemo.sql /main/8 2012/06/14 05:32:51 begeorge Exp $
Rem $Header: sdo/demo/network/examples/data/ndmdemo/ndmdemo.sql /main/8 2012/06/14 05:32:51 begeorge Exp $
Rem
Rem ndmdemo.sql
Rem
Rem Copyright (c) 2009, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem Copyright (c) 2009, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      ndmdemo.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       12/15/10 - remove thin in loadjava for traffic pattern
Rem    hgong       08/20/09 - Created
Rem

--This the main script to load ndmdemo data and create
--the network. You need to connect to sysdba user in order
--to run this script.
--
--Before running this script, make sure 
--  styles_themes_maps.dmp is under the same directory as this script

-- Create database user ndmdemo
create user ndmdemo identified by ndmdemo default tablespace users quota unlimited on users;

-- Grant necessary privileges to ndmdemo
grant connect, resource, create view to ndmdemo;

-- Import styles, themes, maps and caches maps tables
host imp ndmdemo/ndmdemo file=styles_themes_maps.dmp full=y ignore=y

-- Connect to ndmdemo user
conn ndmdemo/ndmdemo

-- Insert content of styles, themes and maps tables into corresponding mapviewer table
insert into user_sdo_maps select * from ndmdemo_sdo_maps;
insert into user_sdo_themes select * from ndmdemo_sdo_themes;
insert into user_sdo_styles select * from ndmdemo_sdo_styles;

commit;

-- Load ndmdemo_util package
@ndmdemo_util.sql


-- The following steps are require if traffic info needs to be included
-- Load traffic_util package
@traffic_util.sql;

-- Load sdondmtf.jar
-- Make sure that sdondmtf.jar is in the directory.
-- If not, copy from ndm_tutorial/examples/java/lib/ directory.
host loadjava -user ndmdemo/ndmdemo -grant public -resolve -v sdondmtf.jar
commit;

