-- Delete spatial metadata
delete from user_sdo_geom_metadata where table_name in (select table_name from html_pages);
delete from user_sdo_geom_metadata where table_name = 'BASEMAP';
commit;

-- Delete mapviewer styles,themes and maps
delete from user_sdo_themes where base_table in (select table_name from html_pages);
delete from user_sdo_styles where name = 'C.BASEMAP';
delete from user_sdo_themes where base_table = 'BASEMAP';
delete from user_sdo_maps where name = 'BASEMAP';
delete from user_sdo_cached_maps where name = 'BASEMAP';
commit;

-- Drop data tables
begin
  for h in (
    select table_name
    from html_pages
  )
  loop
    execute immediate 'drop table '||h.table_name||' purge'; 
  end loop;
end;
/
show errors

drop table basemap purge;
drop table html_pages purge;
