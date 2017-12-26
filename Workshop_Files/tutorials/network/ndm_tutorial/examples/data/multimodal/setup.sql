Rem
Rem $Header: sdo/demo/network/examples/data/multimodal/setup.sql /main/2 2012/06/14 05:32:51 begeorge Exp $
Rem
Rem setup.sql
Rem
Rem Copyright (c) 2011, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      setup.sql - <one-line expansion of the name>
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

-------------------------------------------------------------------------
--  If you have already have the basic (road) network installed, 
--  skip this script    
-------------------------------------------------------------------------

--
-- The script assumes that the network data created is NAVTEQ_DC
-- Change the network/user name suitably.
-- Log into Oracle as a privileged user (SYS or SYSTEM) and
-- create the NAVTEQ_DC user account.
--
set echo on;

grant connect, resource to NAVTEQ_DC identified by navteq_dc;

alter user NAVTEQ_DC default tablespace USERS quota unlimited on USERS;

create or replace directory WORK_DIR as '/scratch/begeorge/data/navteq_dc';

grant read,write on directory WORK_DIR to navteq_dc;

grant dba to navteq_dc;

commit;

-- Make sure that dmp file is present in the directory
host imp navteq_dc/navteq_dc file=navteq_dc.dmp full=y ignore=y;

conn navteq_dc/navteq_dc;

-- Insert the required geom metadata
delete from user_sdo_geom_metadata where table_name = 'NAVTEQ_DC_NODE$';
insert into user_sdo_geom_metadata (table_name,column_name,diminfo,srid) values
        ('NAVTEQ_DC_NODE$','GEOMETRY',SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', -180, 180, .05), SDO_DIM_ELEMENT('Y', 0, 90,.05)),8307);
commit;

delete from user_sdo_geom_metadata where table_name = 'NAVTEQ_DC_LINK$';
insert into user_sdo_geom_metadata (table_name,column_name,diminfo,srid) values
        ('NAVTEQ_DC_LINK$','GEOMETRY',SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', -180, 180, .05), SDO_DIM_ELEMENT('Y', 0, 90,.05)),8307);

delete from user_sdo_geom_metadata where table_name = 'NAVTEQ_DC_PATH$';
insert into user_sdo_geom_metadata (table_name,column_name,diminfo,srid) values
        ('NAVTEQ_DC_PATH$','GEOMETRY',SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', -180, 180, .05), SDO_DIM_ELEMENT('Y', 0, 90,.05)),8307);
commit;

-- Create indexes
drop index nvt_dc_nodeid_idx;
create index nvt_dc_nodeid_idx on navteq_dc_node$(node_id);

drop index  nvt_dc_node_geom_idx;
create index nvt_dc_node_geom_idx on navteq_dc_node$(geometry) indextype is mdsys.spatial_index;
commit;

drop index nvt_dc_linkid_idx;
create index nvt_dc_linkid_idx on navteq_dc_link$(link_id);

drop index nvt_dc_link_senid_idx;
create index nvt_dc_link_senid_idx on navteq_dc_link$(start_node_id,end_node_id);

drop index  nvt_dc_link_llevel_idx;
create index nvt_dc_link_llevel_idx on navteq_dc_link$(link_level);

drop index nvt_dc_func_idx;
create index nvt_dc_func_idx on navteq_dc_link$(f);

drop index nvt_dc_geom_idx;
create index nvt_dc_geom_idx on navteq_dc_link$(geometry) indextype is mdsys.spatial_index;
commit;

-- Insert network metadata
delete from user_sdo_network_metadata where network = 'NAVTEQ_DC';

insert into user_sdo_network_metadata
    (network,
     network_category,
     geometry_type,
     network_type,
     no_of_hierarchy_levels,
     node_table_name,
     node_geom_column,
     link_table_name,
     link_geom_column,
     link_direction,
     link_cost_column,
     partition_table_name,
     partition_blob_table_name,
     path_table_name,
     path_geom_column,
     path_link_table_name,
     subpath_table_name,
     subpath_geom_column,
     user_defined_data)
values (
    'NAVTEQ_DC',
    'SPATIAL',
    'SDO_GEOMETRY',
    'ROAD',
     1,
    'NAVTEQ_DC_NODE$',
    'GEOMETRY',
    'NAVTEQ_DC_LINK$',
    'GEOMETRY',
    'DIRECTED',
    'LENGTH',
    'NAVTEQ_DC_PART$',
    'NAVTEQ_DC_PBLOB$',
    'NAVTEQ_DC_PATH$',
    'PATH_GEOMETRY',
    'NAVTEQ_DC_PLINK$',
    'NAVTEQ_DC_SPATH$',
    'GEOMETRY',
    'Y');
commit;

