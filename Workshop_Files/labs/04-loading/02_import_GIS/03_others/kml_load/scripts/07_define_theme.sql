delete from user_sdo_themes where name = 'FIELDS';
insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'FIELDS',
'FIELDS',
'GEOMETRY',
'<styling_rules>
  <rule>
    <features> </features>
    <label column="ID"> 1 </label>
  </rule>
</styling_rules>');
commit;
