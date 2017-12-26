declare
  ddl varchar2(1000);
begin
  for t in (
    select table_name, column_name
    from   user_tab_columns
    where  data_type = 'SDO_GEOMETRY'
  )
  loop
    ddl := 
      'DROP TRIGGER '||t.table_name||'_'||t.column_name;
    dbms_output.put_line ('-');
    dbms_output.put_line (ddl);
    execute immediate ddl;
  end loop;
end;
/
show errors
