Rem
Rem $Header: sdo/demo/network/examples/data/navteq_sf/demo.sql /main/10 2012/05/24 07:13:56 begeorge Exp $
Rem
Rem demo.sql
Rem
Rem Copyright (c) 2009, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      demo.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      This script get the NAVTEQ data ready for the NDM Demo.
Rem      It creates NDM network on top of NAVTEQ data, 
Rem      computes partition boundaries for the network partitions,
Rem      and grants necessary privileges to the ndmdemo user.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    begeorge    05/15/12 - comment out grant statements on 11.2.0.1 release views
Rem    hgong       12/15/10 - create WORK_DIR to be used by traffic pattern
Rem    begeorge    07/16/10 - add traffic related demo
Rem    hgong       06/10/10 - add feature analysis demo
Rem    hgong       11/02/09 - Add create table privilege, because dynamic sql
Rem                           only recognizes direct privileges.
Rem    hgong       11/02/09 - Created
Rem

------------------------------------------------------------
-- Before running this script, make sure you have already --
-- installed NAVTEQ San Francisco sample data set.        --
------------------------------------------------------------
--
-- Log into Oracle as a privileged user (SYS or SYSTEM)
--
-- conn sys/welcome as sysdba

set echo on

-- Grant create view to NAVTEQ_SF user.
grant create view, create table to navteq_sf;

-- You need to create the database directory only if
-- your database version is 11.2, and you are calling
-- sdo_router_partition.create_router_network to create the
-- router network.

-- Create database directory SDO_ROUTER_LOG_DIR, and
-- grant read/write access to this directory to navteq_sf user.
create or replace directory SDO_ROUTER_LOG_DIR as '/tmp';
grant read, write on directory SDO_ROUTER_LOG_DIR to navteq_sf;

-- Create database directory WORK_DIR, and
-- grant read/write access to this directory to navteq_sf user.
create or replace directory WORK_DIR as '/tmp';
grant read, write on directory WORK_DIR to navteq_sf;

-- Connect to the Oracle user that owns the network
conn navteq_sf/navteq_sf

-- Define geometry metadata for node/edge tables if they are undefined yet
exec ndmdemo.ndmdemo_util.define_geometry_metadata;

-- Create necessary indexes if they do not exist yet
exec ndmdemo.ndmdemo_util.create_indexes;

-- Create a network named NAVTEQ_SF for the San Francisco data set.
-- Or if you are not using NAVTEQ_SF data set, replace NAVTEQ_SF with
-- the name appropriate for your network. 
-- The create_router_network procedure creates NDM views on router tables
-- and enters the network in the NDM metadata.

-- If your database version is 11.1, download patch 7700528, 
-- extract router_network.sql from the patch, and use the following statements.
--@router_network.sql
--exec create_router_network('NAVTEQ_SF');

-- If your database version is 11.2 or above, use the following statement.
exec sdo_router_partition.create_router_network('navteq_sf.log', 'NAVTEQ_SF');

-- Insert geom metadata for NDM node and link views
exec ndmdemo.ndmdemo_util.define_geom_metadata_for_net('NAVTEQ_SF');

-- Compute partition convex hull, in order to display partition boundaries during the demo
exec ndmdemo.ndmdemo_util.create_partition_convexhull('NAVTEQ_SF', TRUE);

commit;

-- Grant read access to the NDM views to the ndmdemo user.
grant select on NAVTEQ_SF_NODE$ to ndmdemo;
grant select on NAVTEQ_SF_LINK$ to ndmdemo;
grant select on NAVTEQ_SF_PCH$ to ndmdemo;

-- In the first 11.2 release (11.2.0.1), NDM views are prefixed
-- with NDM_US, so grant read access to the following views too.
-- Execute the following two steps if the release is 11.2.0.1
-- grant select on NDM_US_NODE$ to ndmdemo;
-- grant select on NDM_US_LINK$ to ndmdemo;

--
-- INCLUDING TRAFFIC INFORMATION:
--

--
-- If traffic information needs to be included, execute the following steps
-- The package traffic_util must be loaded in ndmdemo.
-- sdondmtf.jar must be loaded in ndmdemo.
-- 
--
-- Set up traffic data
-- This set up is based on the traffic schema with four patterns associated with a link
-- corresponding to Mon-Thurs, Fri, Sat, Sun
-- If the schema with seven patterns for a link needs to be used, use the script
-- setup_traffic_data_new_schema.sql
--
@setup_traffic_data.sql;

--
-- Create congested links table to display congested links on demo
--
exec ndmdemo.traffic_util.create_congested_links_table('NAVTEQ_SF', 'NAVTEQ_SF_LSPEED_PID', 8.5);

commit;

--
-- Create a view on congested links table under ndmdemo.
--
conn ndmdemo/ndmdemo

exec traffic_util.create_ndmdemo_views('NAVTEQ_SF','NAVTEQ_SF');
commit;

conn navteq_sf/navteq_sf;

-------------------------------------------------------------------------------------
---- The following procedures are related to feature modeling in 12.1.
-------------------------------------------------------------------------------------
--
-- FEATURE LAYER related
--
-- fill in the POI percentage, because the original navteq data does not have the correct values
exec ndmdemo.ndmdemo_util.update_gc_poi_percent('GC_POI_NVT', 'GC_ROAD_SEGMENT_NVT');

-- create feature layer for HOTEL POIs 
exec ndmdemo.ndmdemo_util.create_poi_feature_layer('NAVTEQ_SF', 'HOTEL', 7011, 'HOTEL_FEAT$', 'HOTEL_REL$');
 
-- create feature layer for RESTAURANT POIs
exec ndmdemo.ndmdemo_util.create_poi_feature_layer('NAVTEQ_SF', 'RESTAURANT', 5800, 'RESTAURANT_FEAT$', 'RESTAURANT_REL$');

--add geometry user data for node/link views (user data category 3)
--this will be used in computing path feature geometry
insert into user_sdo_network_user_data (network, table_type, data_name, data_type, data_length, category_id)
values('NAVTEQ_SF', 'NODE', 'GEOMETRY', 'SDO_GEOMETRY', NULL, 3);

insert into user_sdo_network_user_data (network, table_type, data_name, data_type, data_length, category_id)
values('NAVTEQ_SF', 'LINK', 'GEOMETRY', 'SDO_GEOMETRY', NULL, 3);

commit;

-- To diaplay the hotel and restaurant POI themes on the map, 
-- add those themes to mapviewer view USER_SDO_MAPS using mapbuilder.
-- Use RATIO as scale mode, and set the minimum scale to 18000 for hotels
-- and 5000 for restaurants.

