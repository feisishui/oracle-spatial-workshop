col column_name for a30
-- List all spatial tables
select table_name, column_name
from   user_tab_columns
where  data_type = 'SDO_GEOMETRY';

-- Spatial tables without spatial metadata
select table_name, column_name
from   user_tab_columns
where  data_type = 'SDO_GEOMETRY'
and    (table_name, column_name) not in (
  select table_name, column_name from user_sdo_geom_metadata
)
order by table_name;

-- Spatial tables without spatial index
select table_name, column_name
from   user_tab_columns
where  data_type = 'SDO_GEOMETRY'
and    (table_name, column_name) not in (
  select table_name, column_name from user_sdo_index_info
)
order by table_name;

-- Invalid spatial indexes
select table_name, index_name
from user_indexes
where index_type = 'DOMAIN'
and ityp_name = 'SPATIAL_INDEX'
and domidx_opstatus = 'FAILED';

