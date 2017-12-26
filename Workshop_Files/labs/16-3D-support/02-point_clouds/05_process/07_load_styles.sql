delete from user_sdo_styles where name in ('C.PC_BLK', 'M.PC_POINT');
delete from user_sdo_themes where name in ('PC_BLK', 'CLIPPED_LIDAR_SCENES_BLOCKS', 'CLIPPED_LIDAR_SCENES_GEOM');

insert into user_sdo_styles (name, type, definition)
values (
'C.PC_BLK',
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
'M.PC_POINT',
'MARKER',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <desc></desc>
  <g class="marker" style="stroke:#000000;fill:#FF0000;width:4;height:4;font-family:Dialog;font-size:12;font-fill:#FF0000">
    <circle cx="0" cy="0" r="0" />
  </g>
</svg>'
);


insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'PC_BLK',
'PC_BLK_01',
'BLK_EXTENT',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule>
    <features style="C.PC_BLK"> </features>
  </rule>
</styling_rules>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'CLIPPED_LIDAR_SCENES_BLOCKS',
'CLIPPED_LIDAR_SCENES_BLOCKS',
'BLK_EXTENT',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule>
    <features style="C.PC_BLK"> </features>
  </rule>
</styling_rules>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'CLIPPED_LIDAR_SCENES_GEOM',
'CLIPPED_LIDAR_SCENES_GEOM',
'POINTS',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule>
    <features style="M.PC_POINT"> </features>
  </rule>
</styling_rules>'
);

commit;