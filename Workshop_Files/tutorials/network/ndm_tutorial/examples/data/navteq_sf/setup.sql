Rem
Rem $Header: sdo/demo/network/examples/data/navteq_sf/setup.sql /main/3 2010/05/12 07:16:18 begeorge Exp $
Rem
Rem setup.sql
Rem
Rem Copyright (c) 2009, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      setup.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      This script is an example of a customized data setup script from NAVTEQ.
Rem      The script creates NAVTEQ_SF user in the database and loads the NAVTEQ 
Rem      San Francisco Sample Data into this user.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       08/27/09 - Created
Rem

-------------------------------------------------------------------------
--  If you have already have navteq_sf installed, skip this script     --
-------------------------------------------------------------------------

--
--  These commands and the installation procedure are described in more
--  detail in the San Francisco Sample Installation Guide and Release Notes.
--
-- Replace the values in <brackets> with appropriate values for
-- your system
--
-- Log into Oracle as a privileged user (SYS or SYSTEM) and
-- create the NAVTEQ_SF user account.
--

--conn system/welcome as sysdba
--
--
set echo on

grant connect, resource to NAVTEQ_SF identified by navteq_sf;
--
-- set the NAVTEQ_SF account to the USERS user's default tablespace and 
-- allow full use of the tablespace
--
alter user NAVTEQ_SF default tablespace USERS quota unlimited on USERS;

--
-- From the command prompt, import the data from the directory
-- location where the file was unzipped
--
host imp NAVTEQ_SF/navteq_sf file=NAVTEQ_SF_Sample.dmp

--
-- log in as the navteq_sd user and move the mapping metadata to the Oracle 
-- map metadata views
--
conn NAVTEQ_SF/navteq_sf

-- Before executing the following commands, make sure that the required styles,
-- themes, and maps have been created. If not, create them using map builder.

insert into user_sdo_maps
  select * from my_maps;

insert into user_sdo_cached_maps
  select * from my_cached_maps;

insert into user_sdo_themes
  select * from my_themes;

insert into user_sdo_styles
  select * from my_styles;

commit;


