insert into fields (id, file_name, kml) 
select rownum, column_value, empty_clob() 
from table(
  list_files('KML_DATA_DIR')
);
commit;
