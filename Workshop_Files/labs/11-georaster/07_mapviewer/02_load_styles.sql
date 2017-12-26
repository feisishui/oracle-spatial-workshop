delete from user_sdo_styles       where name in ('L.US_STREETS', 'T.US_STREETS', 'M.US_POIS', 'T.US_POIS');
delete from user_sdo_themes       where name in ('US_STREETS', 'US_POIS', 'US_RASTERS');
delete from user_sdo_maps         where name in ('US_RASTER_MAP');
delete from user_sdo_cached_maps  where name in ('US_RASTER_MAP');

-- -------------------------------------------------------------------
-- Styles
-- -------------------------------------------------------------------
insert into user_sdo_styles (name, type, definition)
values (
'L.US_STREETS',
'LINE',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <desc></desc>
  <g class="line" style="fill:#FF0000;fill-opacity:114;stroke-width:2">
    <line class="base" />
  </g>
</svg>'
);
insert into user_sdo_styles (name, type, definition)
values (
'M.US_POIS',
'MARKER',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <desc></desc>
  <g class="marker" style="stroke:#FFFFFF;fill:#FF0000;width:15;height:15;font-family:Dialog;font-size:12;font-fill:#FF0000">
    <circle cx="0" cy="0" r="0" />
  </g>
</svg>'
);
insert into user_sdo_styles (name, type, definition)
values (
'T.US_POIS',
'TEXT',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in" >
  <desc></desc>
  <g class="text" float-width="4" float-color="#FFFFFF" style="font-style:plain;font-family:Dialog;font-size:12;font-weight:bold;text-align:center;fill:#FF0000"> Hello World!
    <opoint halign="center" valign="middle" />
    <text-along-path valign="baseline" />
  </g>
</svg>'
);
insert into user_sdo_styles (name, type, definition)
values (
'T.US_STREETS',
'TEXT',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in" >
  <desc></desc>
  <g class="text" float-width="4" float-color="#FFFFFF" style="font-style:plain;font-family:Dialog;font-size:12;font-weight:bold;text-align:center;fill:#FF0000"> Hello World!
    <opoint halign="center" valign="middle" />
    <text-along-path  valign="baseline" />
  </g>
</svg>'
);

-- -------------------------------------------------------------------
-- Themes
-- -------------------------------------------------------------------
insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_POIS',
'US_POIS',
'GEOMETRY',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule>
    <features style="M.US_POIS"> </features>
    <label column="NAME" style="T.US_POIS"> 1 </label>
  </rule>
</styling_rules>'
);
insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_RASTERS',
'US_RASTERS',
'GEORASTER',
'<?xml version="1.0" standalone="yes"?>
<styling_rules theme_type="georaster">
</styling_rules>'
);
insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_STREETS',
'US_STREETS',
'GEOMETRY',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule>
    <features style="L.US_STREETS"> </features>
    <label column="NAME" style="T.US_STREETS"> 1 </label>
  </rule>
</styling_rules>'
);

-- -------------------------------------------------------------------
-- Maps
-- -------------------------------------------------------------------
insert into user_sdo_maps (name, definition)
values (
'US_RASTER_MAP',
'<?xml version="1.0" standalone="yes"?>
<map_definition>
  <theme name="US_RASTERS"/>
  <theme name="US_STREETS" no_repetitive_label="true"/>
  <theme name="US_POIS" min_scale="4000.0" max_scale="-Infinity" scale_mode="RATIO" allow_naked_points="false"/>
</map_definition>'
);

-- -------------------------------------------------------------------
-- Map Caches
-- -------------------------------------------------------------------
insert into user_sdo_cached_maps (name, is_online, is_internal, definition, base_map)
values (
'US_RASTER_MAP',
'YES',
'YES',
'<map_tile_layer name="US_RASTER_MAP" image_format="PNG" http_header_expires="168.0" concurrent_fetching_threads="3">
   <internal_map_source data_source="SCOTT" base_map="US_RASTER_MAP" bgcolor="#33ccff"/>
   <tile_storage root_path="/tmp"/>
   <coordinate_system srid="26943" minX="1820000" minY="644000" maxX="1840000" maxY="647000"/>
   <tile_image width="256" height="256"/>
   <zoom_levels levels="16" min_scale="600.0" max_scale="30000" />
</map_tile_layer>',
'US_RASTER_MAP'
);

commit;
