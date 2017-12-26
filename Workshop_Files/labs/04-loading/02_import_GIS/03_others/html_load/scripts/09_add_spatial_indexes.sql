begin
  for h in (
    select table_name
    from html_pages
  )
  loop
    -- Setup spatial metadata
    insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid) 
    values (
      h.table_name,
      'GEOM',
      sdo_dim_array (
        sdo_dim_element ('X', 0, 1000, 0.5),
        sdo_dim_element ('Y', 0, 1000, 0.5)
      ),
      262155
    );
    -- Create spatial index
    execute immediate 'create index '||h.table_name||'_SX on '||h.table_name||'(GEOM) indextype is mdsys.spatial_index';   
  end loop;
end;
/
show errors
