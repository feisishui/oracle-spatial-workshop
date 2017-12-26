begin
  for h in (
    select table_name
    from html_pages
  )
  loop
    execute immediate 'create table '||h.table_name||' (' ||
    ' id number,'||
    ' area_name varchar2(10),'||
    ' geom sdo_geometry'||
    ')';
  end loop;
end;
/
show errors