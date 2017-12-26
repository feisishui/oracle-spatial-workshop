select i.table_name, l.securefile
from user_sdo_index_info i, user_lobs l
where i.sdo_index_table = l.table_name
order by table_name;
