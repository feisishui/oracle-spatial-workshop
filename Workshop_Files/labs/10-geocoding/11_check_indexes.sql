col table_name for a20
col index_name for a21
col column_position for 99
col column_name for a20
select  c.table_name, c.index_name, c.column_position, 
        c.column_name, e.column_expression
from user_ind_columns c left outer join user_ind_expressions e
on c.table_name = e.table_name
and c.index_name = e.index_name
and c.column_position = e.column_position
where c.table_name like 'GC%'
order by c.table_name, c.index_name, c.column_position;
