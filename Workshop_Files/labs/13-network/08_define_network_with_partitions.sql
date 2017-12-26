-- Cleanout any existing network metadata
delete from user_sdo_network_metadata where network in ('NET_SF');
delete from user_sdo_network_user_data where network in ('NET_SF');

-- Setup network metadata
insert into user_sdo_network_metadata (
  NETWORK,
  NETWORK_CATEGORY,
  GEOMETRY_TYPE,
  NODE_TABLE_NAME,
  NODE_GEOM_COLUMN,
  LINK_TABLE_NAME,
  LINK_GEOM_COLUMN,
  LINK_DIRECTION,
  LINK_COST_COLUMN,
  USER_DEFINED_DATA,
  PARTITION_TABLE_NAME,
  PARTITION_BLOB_TABLE_NAME
)
values (
  'NET_SF',
  'SPATIAL',
  'SDO_GEOMETRY',
  'NET_NODES',
  'GEOMETRY',
  'NET_LINKS',
  'GEOMETRY',
  'DIRECTED',
  'LENGTH',
  'Y',
  'NET_PARTITIONS',
  'NET_PARTITIONS_BLOBS'
);

-- Setup user data for LINKS
insert into user_sdo_network_user_data (network, table_type, data_name, data_type, data_length)
  values ('NET_SF', 'LINK', 'LINK_NAME', 'VARCHAR2', 80);
insert into user_sdo_network_user_data (network, table_type, data_name, data_type, data_length)
  values ('NET_SF', 'LINK', 'LINK_TYPE', 'VARCHAR2',  1);
insert into user_sdo_network_user_data (network, table_type, data_name, data_type, data_length)
  values ('NET_SF', 'LINK', 'FUNC_CLASS', 'VARCHAR2',  1);
insert into user_sdo_network_user_data (network, table_type, data_name, data_type, data_length)
  values ('NET_SF', 'LINK', 'LENGTH', 'NUMBER',  null);
insert into user_sdo_network_user_data (network, table_type, data_name, data_type, data_length)
  values ('NET_SF', 'LINK', 'TIME', 'NUMBER',  null);
insert into user_sdo_network_user_data (network, table_type, data_name, data_type, data_length)
  values ('NET_SF', 'LINK', 'SPEED_LIMIT', 'NUMBER',  null);

-- Setup user data for NODES
insert into user_sdo_network_user_data (network, table_type, data_name, data_type, data_length)
  values ('NET_SF', 'NODE', 'NODE_TYPE',     'VARCHAR2',  1);
commit;

-- Check network structures (must return 'TRUE')
select sdo_net.validate_network('NET_SF') from dual;
