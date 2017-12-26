col owner for a16
col table_name for a24
col column_name for a20
col sdo_dimname for a10

-- Find all spatial tables without spatial metadata
select owner, table_name, column_name
from   all_tab_columns
where  data_type = 'SDO_GEOMETRY'
and    (owner, table_name, column_name) not in (
  select owner, table_name, column_name from all_sdo_geom_metadata
)
and    owner <> 'MDSYS'
order by owner, table_name;

-- Find spatial metadata that does not belong to any spatial table
-- Note that we cannot use the ALL_SDO_GEOM_METADATA view since it already includes a join with ALL_TABLES
-- Instead, query MDSYS.SDO_GEOM_METADATA_TABLE directly
select sdo_owner owner, sdo_table_name table_name, sdo_column_name column_name
from   mdsys.sdo_geom_metadata_table
where  (sdo_owner, sdo_table_name, sdo_column_name) not in (
  select owner, table_name, column_name 
  from   all_tab_columns
  where  data_type = 'SDO_GEOMETRY'
)
and    sdo_owner <> 'MDSYS'
order by owner, table_name;

-- Find any spatial tables with invalid bounds (lower bound > upper bound)
select owner, table_name, column_name, sdo_dimname, sdo_lb, sdo_ub
from all_sdo_geom_metadata, table (diminfo)
where sdo_lb > sdo_ub
order by owner, table_name;