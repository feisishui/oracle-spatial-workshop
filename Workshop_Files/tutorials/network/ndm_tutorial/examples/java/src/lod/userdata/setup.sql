Rem
Rem $Header: sdo/demo/network/examples/java/src/lod/userdata/setup.sql /main/1 2010/12/09 10:15:00 begeorge Exp $
Rem
Rem setup.sql
Rem
Rem Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved. 
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
Rem    begeorge    12/08/10 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

-- Creates the example network
-- Connect as sysdba
set echo on

grant connect, resource to EXAMPLE identified by example;

alter user EXAMPLE default tablespace USERS quota unlimited on USERS;

--
-- Create a logging directory for partitioning and blob generation procedures.
--
create or replace directory WORK_DIR as '/tmp';

grant read,write on directory WORK_DIR to example;

--
-- Import example network from dump file. Make sure that the dmp file is in the directory
--
host imp EXAMPLE/example file=example.dmp full=y ignore=y;

conn EXAMPLE/example

--
-- Create indexes
--
create index example_node_idx on example_node$(node_id);
create index example_link_idx on example_link$(link_id);
create index example_l_se_idx on example_link$(start_node_id,end_node_id);
create index example_ll_index on example_link$(link_level);
create index example_ngeom_idx on example_node$(geometry) indextype is mdsys.spatial_index;
create index example_lgeom_idx on example_link$(geometry) indextype is mdsys.spatial_index;
commit;

--
-- Register geometry metadata
--
delete from user_sdo_geom_metadata where table_name = 'EXAMPLE_NODE$';
delete from user_sdo_geom_metadata where table_name = 'EXAMPLE_LINK$';
delete from user_sdo_geom_metadata where table_name = 'EXAMPLE_PATH$';
insert into user_sdo_geom_metadata (table_name,column_name,diminfo,srid)
        values ( 'EXAMPLE_NODE$','GEOMETRY',
                 MDSYS.SDO_DIM_ARRAY(
                        MDSYS.SDO_DIM_ELEMENT('X',-180,180,0.05),
                        MDSYS.SDO_DIM_ELEMENT('Y',0,90,0.05)),
                        8307);

insert into user_sdo_geom_metadata (table_name,column_name,diminfo,srid)
        values ( 'EXAMPLE_LINK$','GEOMETRY',
                 MDSYS.SDO_DIM_ARRAY(
                        MDSYS.SDO_DIM_ELEMENT('X',-180,180,0.05),
                        MDSYS.SDO_DIM_ELEMENT('Y',0,90,0.05)),
                        8307);

insert into user_sdo_geom_metadata (table_name,column_name,diminfo,srid)
        values ( 'EXAMPLE_PATH$','PATH_GEOMETRY',
                 MDSYS.SDO_DIM_ARRAY(
                        MDSYS.SDO_DIM_ELEMENT('X',-180,180,0.05),
                        MDSYS.SDO_DIM_ELEMENT('Y',0,90,0.05)),
                        8307);
commit;

--
-- Register network metadata
--
delete from user_sdo_network_metadata where network='EXAMPLE';
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
    'EXAMPLE',
    'SPATIAL',
    'SDO_GEOMETRY',
    'ROAD',
     1,
    'EXAMPLE_NODE$',
    'GEOMETRY',
    'EXAMPLE_LINK$',
    'GEOMETRY',
    'UNDIRECTED',
    'COST',
    'EXAMPLE_PART$',
    'EXAMPLE_PBLOB$',
    'EXAMPLE_PATH$',
    'PATH_GEOMETRY',
    'EXAMPLE_PLINK$',
    'EXAMPLE_SPATH$',
    'GEOMETRY',
    'Y');
commit;

-- The following four steps set up category 0 user data
-- X,Y from the node table and link level,s  from link table are stored as category 0
-- user data.
delete from user_sdo_network_user_data where network='EXAMPLE';
insert into user_sdo_network_user_data
           (network,table_type,data_name,data_type)
    values ('EXAMPLE','NODE','X','NUMBER') ;

insert into user_sdo_network_user_data
           (network,table_type,data_name,data_type)
    values ('EXAMPLE','NODE','Y','NUMBER') ;

insert into user_sdo_network_user_data
           (network,table_type,data_name,data_type)
    values ('EXAMPLE','LINK','LINK_LEVEL','NUMBER') ;

insert into user_sdo_network_user_data
	   (network,table_type,data_name,data_type)
    values ('EXAMPLE','LINK','S','NUMBER');
commit;

--
-- Partition the network (link levels 1 and 2)
--
EXEC sdo_net.spatial_partition('EXAMPLE', 'EXAMPLE_PART$', 2000, 'WORK_DIR', 'ex_part.log', 'a');
EXEC sdo_net.spatial_partition('EXAMPLE', 'EXAMPLE_PART$', 2000, 'WORK_DIR', 'ex_part.log', 'a',2);

--
-- Generate partition blobs (link levels 1 and 2)
--
EXEC sdo_net.generate_partition_blobs('EXAMPLE',1,'EXAMPLE_PBLOB$',true,true,'WORK_DIR','ex_pblob.log','a');
EXEC sdo_net.generate_partition_blobs('EXAMPLE',2,'EXAMPLE_PBLOB$',true,true,'WORK_DIR','ex_pblob.log','a');

-- This creates sample data to illustrate the creation of user data on links and nodes
-- A table that contains link IDs and associated link types (0,1,2,3 or 4) is created.
-- Another contains node IDs and their types (0, 1 or 2)
-- The node and link types are stored as link and node user data in user data table.
-- 
create table example_link_type (link_id number,
                                link_type number);

create table example_node_type (node_id number,
				node_type number);

insert into example_link_type (link_id,link_type) 
       select link_id,mod(link_id,5) from example_link$;
commit;

insert into example_node_type (node_id,node_type)
       select node_id,mod(node_id,3) from example_node$;
commit;
