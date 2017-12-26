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
      'CREATE OR REPLACE TRIGGER '||t.table_name||'_'||t.column_name||
      ' BEFORE INSERT OR UPDATE OF '||t.column_name||' ON '||t.table_name||
      ' FOR EACH ROW '||
      'DECLARE'||
      ' status VARCHAR2(1024); '||
      'BEGIN'||
      ' IF :NEW.'||t.column_name||' IS NOT NULL THEN '||
      '  status := SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT (:NEW.'||t.column_name||', 0.5); '||
      '  IF status <> ''TRUE'' THEN '||
      '   RAISE_APPLICATION_ERROR (-20000, SQLERRM (-SUBSTR(status,1,5)) ); '||
      '  END IF; '||
      ' END IF; '||
      'END; ';
    dbms_output.put_line ('-');
    dbms_output.put_line (ddl);
    execute immediate ddl;
  end loop;
end;
/
show errors
