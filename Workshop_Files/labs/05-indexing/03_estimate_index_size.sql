col table_name for a16
col column_name for a16
-- Estimated index sizes
select table_name, column_name,
       sdo_tune.estimate_rtree_index_size (user, table_name, column_name) mb
from   user_tab_columns
where  data_type = 'SDO_GEOMETRY'
order by table_name;
