col owner for a18
col table_name for a30
col column_name for a20
col sdo_dimname for a10

-- All spatial tables
select owner, table_name, column_name
from   all_tab_columns
where  data_type = 'SDO_GEOMETRY'
order by owner, table_name;

-- Spatial tables without spatial metadata
select owner, table_name, column_name
from   all_tab_columns
where  data_type = 'SDO_GEOMETRY'
and    (owner, table_name, column_name) not in (
  select owner, table_name, column_name from all_sdo_geom_metadata
)
and    owner <> 'MDSYS'
order by owner, table_name;

-- Spatial tables with invalid bounds (lower bound > upper bound)
select owner, table_name, column_name, sdo_dimname, sdo_lb, sdo_ub
from all_sdo_geom_metadata, table (diminfo)
where sdo_lb > sdo_ub
order by owner, table_name;

-- Spatial tables without spatial index
select owner, table_name, column_name
from   all_tab_columns
where  data_type = 'SDO_GEOMETRY'
and    (owner, table_name, column_name) not in (
  select table_owner, table_name, column_name from all_sdo_index_info
)
order by owner, table_name;

-- Invalid spatial indexes
select owner, table_name, index_name
from all_indexes
where index_type = 'DOMAIN'
and ityp_name = 'SPATIAL_INDEX'
and domidx_opstatus = 'FAILED'
order by owner, table_name;
