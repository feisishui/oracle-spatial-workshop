col table_name for a20
col column_name for a20
col sdo_dimname for a10

-- Find any spatial tables without spatial metadata
select table_name, column_name
from   user_tab_columns
where  data_type = 'SDO_GEOMETRY'
and    (table_name, column_name) not in (
  select table_name, column_name from user_sdo_geom_metadata
)
order by table_name;

-- Find spatial metadata that does not belong to any spatial table
select table_name, column_name
from   user_sdo_geom_metadata
where  (table_name, column_name) not in (
  select table_name, column_name 
  from   user_tab_columns
  where  data_type = 'SDO_GEOMETRY'
)
order by table_name;

-- Find any spatial tables with invalid bounds (lower bound > upper bound)
select table_name, column_name, sdo_dimname, sdo_lb, sdo_ub
from user_sdo_geom_metadata, table (diminfo)
where sdo_lb > sdo_ub
order by table_name;

-- List all spatial tables with and without metadata
select t.table_name, t.column_name, nvl(m.metadata, 'NO') meta
from (
  select table_name, column_name
  from   user_tab_columns
  where  data_type = 'SDO_GEOMETRY'
) t
left outer join
(
  select table_name, column_name, 'YES' metadata
  from user_sdo_geom_metadata
) m
on t.table_name = m.table_name and t.column_name = m.column_name
order by t.table_name, t.column_name;
