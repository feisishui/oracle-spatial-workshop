begin
  for h in (
    select table_name
    from html_pages
  )
  loop
    -- Setup theme
    insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
    values (
      h.table_name,
      h.table_name,
      'GEOM',
      '<styling_rules>
        <rule>
          <features> </features>
          <label column="AREA_NAME"> 1 </label>
        </rule>
      </styling_rules>'
    );
  end loop;
end;
/
show errors
commit;
