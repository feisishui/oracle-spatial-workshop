insert into html_pages (id, file_name, table_name, html) 
select rownum, column_value, upper(substr(column_value,1,instr(column_value,'.')-1)), empty_clob() 
from table(
  list_files('HTML_DATA_DIR')
);
commit;
