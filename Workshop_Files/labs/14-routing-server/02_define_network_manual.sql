--------------------------------------------------------------
-- Define a network over the routing tables
-- 
-- This script performs the same actions as procedure
-- SDO_ROUTER_PARTITION.CREATE_ROUTER_NETWORK(), but it lets
-- you choose the names of the indexes and the views.
--------------------------------------------------------------

-- Create index for edge func_class
create index EDGE_FUNC_CLASS_IDX on EDGE (FUNC_CLASS);

-- Create a function based index for link level
create index EDGE_LEVEL_IDX on EDGE (floor((8-FUNC_CLASS)/3));

-- Create a view on the NODE table
create or replace view ROUTE_SF_NODE$ as
select
   n.node_id                node_id,
   n.geometry               geometry,
   n.geometry.              sdo_point.x x,
   n.geometry.              sdo_point.y y
from NODE n;

-- Create a view on the EDGE table
create or replace view ROUTE_SF_LINK$ as
select
   edge_id                  link_id,
   start_node_id            start_node_id,
   end_node_id              end_node_id,
   floor((8-FUNC_CLASS)/3)  link_level,
   length                   length,
   speed_limit              s,
   func_class               f,
   geometry                 geometry,
   name                     name,
   divider                  divider
from EDGE;

-- Create a view on the NODE table node_id and partition_id information
create or replace view ROUTE_SF_PART$ as
select
   node_id                  node_id,
   partition_id             partition_id,
   1                        link_level
from NODE;

-- Create a view on the PARTITION table adding link level and changing the format of the edge counts
create or replace view ROUTE_SF_PBLOB$ as
select
   link_level                                                 link_level,
   partition_id                                               partition_id,
   subnetwork                                                 blob,
   num_nodes                                                  num_inodes,
   num_outgoing_boundary_edges + num_incoming_boundary_edges  num_enodes,
   num_non_boundary_edges                                     num_ilinks,
   num_outgoing_boundary_edges + num_incoming_boundary_edges  num_elinks,
   num_incoming_boundary_edges                                num_inlinks,
   num_outgoing_boundary_edges                                num_outlinks,
   'Y'                                                        user_data_included
from (
  select 1 link_level, partition_id, subnetwork, num_nodes, num_non_boundary_edges,
    num_outgoing_boundary_edges, num_incoming_boundary_edges
  from PARTITION
  where partition_id > 0
  union all
  select 2 link_level, partition_id, subnetwork, num_nodes, num_non_boundary_edges,
    num_outgoing_boundary_edges, num_incoming_boundary_edges
  from PARTITION
  where partition_id = 0
  );

-- Define network metadata
insert into USER_SDO_NETWORK_METADATA (
  network,
  network_category,
  geometry_type,
  node_table_name,
  node_geom_column,
  link_table_name,
  link_geom_column,
  link_cost_column,
  link_direction,
  partition_table_name,
  partition_blob_table_name,
  user_defined_data)
values (
  'ROUTE_SF',
  'SPATIAL',
  'SDO_GEOMETRY',
  'ROUTE_SF_NODE$',
  'GEOMETRY',
  'ROUTE_SF_LINK$',
  'GEOMETRY',
  'LENGTH',
  'DIRECTED',
  'ROUTE_SF_PART$',
  'ROUTE_SF_PBLOB$',
  'Y'
);

-- Define user data items
-- NODE x coordinate
insert into USER_SDO_NETWORK_USER_DATA (network, table_type, data_name, data_type)
values ('ROUTE_SF', 'NODE', 'X', 'NUMBER');

-- NODE y coordinate
insert into USER_SDO_NETWORK_USER_DATA (network, table_type, data_name, data_type)
values ('ROUTE_SF', 'NODE', 'Y', 'NUMBER');

-- LINK speed limit
insert into USER_SDO_NETWORK_USER_DATA (network, table_type, data_name, data_type)
values ('ROUTE_SF', 'LINK', 'S', 'NUMBER');

-- LINK function class
insert into USER_SDO_NETWORK_USER_DATA (network, table_type, data_name, data_type)
values ('ROUTE_SF', 'LINK', 'F', 'NUMBER');

commit;
