delete from user_sdo_styles where name in ('C.TIN_BLK', 'C.TIN_TRIANGLE');
delete from user_sdo_themes where name in ('TIN_BLK', 'CLIPPED_TINS_BLOCKS', 'CLIPPED_TINS_GEOM', 'CLIPPED_TINS_GEOM_SPLIT');

insert into user_sdo_styles (name, type, definition)
values (
'C.TIN_BLK',
'COLOR',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <desc></desc>
    <g class="color" style="stroke:#000000;fill:#FFFFCC;fill-opacity:127">
    <rect width="50" height="50"/>
  </g>
</svg>'
);

insert into user_sdo_styles (name, type, definition)
values (
'C.TIN_TRIANGLE',
'COLOR',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <desc></desc>
    <g class="color" style="stroke:#000000;fill:#FFFFCC;fill-opacity:127">
    <rect width="50" height="50"/>
  </g>
</svg>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'TIN_BLK',
'TIN_BLK_01',
'BLK_EXTENT',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule>
    <features style="C.TIN_BLK"> </features>
  </rule>
</styling_rules>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'CLIPPED_TINS_BLOCKS',
'CLIPPED_TINS_BLOCKS',
'BLK_EXTENT',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule>
    <features style="C.TIN_BLK"> </features>
  </rule>
</styling_rules>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'CLIPPED_TINS_GEOM',
'CLIPPED_TINS_GEOM',
'TRIANGLES',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule>
    <features style="C.TIN_TRIANGLE"> </features>
  </rule>
</styling_rules>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'CLIPPED_TINS_GEOM_SPLIT',
'CLIPPED_TINS_GEOM_SPLIT',
'TRIANGLE',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule>
    <features style="C.TIN_TRIANGLE"> </features>
  </rule>
</styling_rules>'
);

commit;