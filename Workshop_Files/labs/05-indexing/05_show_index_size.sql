col table_name for a16
col index_name for a20
col column_name for a8
col sdo_index_table for a12
col allocation for a12
select i.table_name, i.index_name, si.column_name, si.sdo_index_table,
       case
         when s.bytes > 1024*1024*1024   then s.bytes/1024/1024/1024 || ' GB'
         when s.bytes > 1024*1024        then s.bytes/1024/1024 || ' MB'
         when s.bytes > 1024             then s.bytes/1024 || ' KB'
       end allocation
from   user_indexes i,
       user_sdo_index_info si,
       user_segments s
where  i.index_type = 'DOMAIN'
and    i.ityp_name = 'SPATIAL_INDEX'
and    i.index_name = si.index_name
and    s.segment_name = si.sdo_index_table
order by i.table_name, i.index_name;
