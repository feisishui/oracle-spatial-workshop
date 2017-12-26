Rem
Rem $Header: sdo/demo/network/examples/data/hillsborough_network/hillsborough_network_create.sql /main/3 2010/10/18 08:10:12 begeorge Exp $
Rem
Rem hillsborough_network_create.sql
Rem
Rem Copyright (c) 2007, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      hillsborough_network_create.sql
Rem
Rem    DESCRIPTION
Rem      Create metadata and indices for HILLSBOROUGH_NETWORK
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       04/16/08 - replace geometry user data with x, y
Rem    hgong       02/09/07 - Created
Rem

delete from user_sdo_geom_metadata where table_name = 'HILLSBOROUGH_NETWORK_NODE$';
insert into user_sdo_geom_metadata (table_name,column_name,diminfo,srid)
        values ( 'HILLSBOROUGH_NETWORK_NODE$','GEOMETRY',
                 MDSYS.SDO_DIM_ARRAY(
                        MDSYS.SDO_DIM_ELEMENT('X',-180,180,0.05),
                        MDSYS.SDO_DIM_ELEMENT('Y',0,90,0.05)),
                        8307);
delete from user_sdo_geom_metadata where table_name = 'HILLSBOROUGH_NETWORK_LINK$';
insert into user_sdo_geom_metadata (table_name,column_name,diminfo,srid)
        values ( 'HILLSBOROUGH_NETWORK_LINK$','GEOMETRY',
                 MDSYS.SDO_DIM_ARRAY(
                        MDSYS.SDO_DIM_ELEMENT('X',-180,180,0.05),
                        MDSYS.SDO_DIM_ELEMENT('Y',0,90,0.05)),
                        8307);
delete from user_sdo_geom_metadata where table_name = 'HILLSBOROUGH_NETWORK_PATH$';
insert into user_sdo_geom_metadata (table_name,column_name,diminfo,srid)
        values ( 'HILLSBOROUGH_NETWORK_PATH$','PATH_GEOMETRY',
                 MDSYS.SDO_DIM_ARRAY(
                        MDSYS.SDO_DIM_ELEMENT('X',-180,180,0.05),
                        MDSYS.SDO_DIM_ELEMENT('Y',0,90,0.05)),
                        8307);

create view hillsborough_network_node as
  select n.node_id node_id, n.node_name node_name, n.node_type node_type,
         n.active active, n.geometry geometry,
         n.geometry.sdo_point.x x, n.geometry.sdo_point.y y
  from hillsborough_network_node$ n;

delete from user_sdo_network_metadata where network = 'HILLSBOROUGH_NETWORK';
insert into user_sdo_network_metadata
    (network,
     network_category,
     geometry_type,
     network_type,
     no_of_hierarchy_levels,
     no_of_partitions,
     node_table_name,
     node_geom_column,
     node_cost_column,
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
    'HILLSBOROUGH_NETWORK',
    'SPATIAL',
    'SDO_GEOMETRY',
    'ROAD',
    1,
    1,
    'HILLSBOROUGH_NETWORK_NODE',
    'GEOMETRY',
    null,
    'HILLSBOROUGH_NETWORK_LINK$',
    'GEOMETRY',
    'UNDIRECTED',
    'COST',
    'HILLSBOROUGH_NETWORK_PART$',
    'HILLSBOROUGH_NETWORK_PBLOB$',
    'HILLSBOROUGH_NETWORK_PATH$',
    'PATH_GEOMETRY',
    'HILLSBOROUGH_NETWORK_PLINK$',
    'HILLSBOROUGH_NETWORK_SPATH$',
    'GEOMETRY',
    'Y' 
   );

--
-- Insert user data metadata
--
delete from user_sdo_network_user_data where network = 'HILLSBOROUGH_NETWORK';
insert into user_sdo_network_user_data
           (network,table_type,data_name,data_type)
    values ('HILLSBOROUGH_NETWORK','NODE','X','NUMBER') ;

insert into user_sdo_network_user_data
           (network,table_type,data_name,data_type)
    values ('HILLSBOROUGH_NETWORK','NODE','Y','NUMBER') ;

insert into user_sdo_network_user_data
	   (network, table_type, data_name, data_type, category_id)
    values ('HILLSBOROUGH_NETWORK','LINK','geometry','sdo_geometry',1);

insert into user_sdo_network_user_data 
	   (network, table_type, data_name, data_type, category_id)
    values ('HILLSBOROUGH_NETWORK','NODE','geometry','sdo_geometry',1);

commit;

create index hill_node_idx on hillsborough_network_node$(node_id);
create index hill_link_idx on hillsborough_network_link$(link_id);
create index hill_link_se_idx on hillsborough_network_link$(start_node_id,end_node_id);
create index hill_link_lvl_idx on hillsborough_network_link$(link_level);
create index hill_link_geom_idx on hillsborough_network_link$(geometry) indextype is mdsys.spatial_index;
create index hill_node_geom_idx on hillsborough_network_node$(geometry) indextype is mdsys.spatial_index;

