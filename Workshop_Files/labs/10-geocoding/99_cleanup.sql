begin
  for t in (select table_name from user_tables where table_name like 'GC%')
  loop
    execute immediate 'drop table '||t.table_name||' purge';
  end loop;
end;
/
delete from user_sdo_geom_metadata where table_name like 'GC%';
commit;
 