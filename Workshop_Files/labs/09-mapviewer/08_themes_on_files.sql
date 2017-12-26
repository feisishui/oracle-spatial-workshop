/*

This script defines a set of themes on shape files. It uses the styles
previously defined for table-based themes.

Theme            File name
---------------- ---------------------------------------------------------
WORLD_COUNTRIES  world_countries.shp
US_STATES        us_states.shp
US_COUNTIES      us_counties.shp
US_PARKS         us_parks.shp
US_INTERSTATES   us_interstates.shp
US_CITIES        us_cities.shp

It also defines a base map (US_BASE_MAP.SHP) and a map cache (US_BASE_MAP_SHP) that
use those themes.

*/

delete from user_sdo_themes       where name like ('US%SHP');
delete from user_sdo_themes       where name like ('WORLD%SHP');
delete from user_sdo_maps         where name like ('US%SHP');
delete from user_sdo_cached_maps  where name like ('US%SHP');

-- -------------------------------------------------------------------
-- Themes on external shape files
-- -------------------------------------------------------------------
insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'WORLD_COUNTRIES.SHP',
'CUSTOM_TABLE',
'GEOMETRY',
'<?xml version="1.0" standalone="yes"?>
<styling_rules theme_type="geom_custom" srid="8307" provider_id="ogrSDP">
  <rule column="CNTRY_NAME">
    <features style="C.WORLD_COUNTRIES"> </features>
    <label column="CNTRY_NAME" style="T.WORLD_COUNTRIES"> 1 </label>
  </rule>
  <parameters>
    <parameter name="datasource" value="/media/sf_Spatial-Workshop/data/04-loading/shape/world_countries.shp"/>
  </parameters>
</styling_rules>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_STATES.SHP',
'CUSTOM_TABLE',
'GEOMETRY',
'<?xml version="1.0" standalone="yes"?>
<styling_rules theme_type="geom_custom" srid="8307" provider_id="ogrSDP">
  <hidden_info>
    <field column="STATE" name=""/>
    <field column="STATE_ABRV" name=""/>
    <field column="TOTPOP" name=""/>
    <field column="POPPSQMI" name=""/>
  </hidden_info>
  <rule column="STATE,STATE_ABRV,TOTPOP,POPPSQMI">
    <features style="C.US_STATES"> </features>
    <label column="STATE" style="T.US_STATES"> 1 </label>
  </rule>
  <parameters>
    <parameter name="datasource" value="/media/sf_Spatial-Workshop/data/04-loading/shape/us_states.shp"/>
  </parameters>
</styling_rules>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_COUNTIES.SHP',
'CUSTOM_TABLE',
'GEOMETRY',
'<?xml version="1.0" standalone="yes"?>
<styling_rules theme_type="geom_custom" srid="8307" provider_id="ogrSDP">
  <rule column="COUNTY">
    <features style="C.US_COUNTIES"> </features>
    <label column="COUNTY" style="T.US_COUNTIES"> 1 </label>
  </rule>
  <parameters>
    <parameter name="datasource" value="/media/sf_Spatial-Workshop/data/04-loading/shape/us_counties.shp"/>
  </parameters>
</styling_rules>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_PARKS.SHP',
'CUSTOM_TABLE',
'GEOMETRY',
'<?xml version="1.0" standalone="yes"?>
<styling_rules theme_type="geom_custom" srid="8307" provider_id="ogrSDP">
  <rule column="NAME">
    <features style="C.US_PARKS"> </features>
  </rule>
  <parameters>
    <parameter name="datasource" value="/media/sf_Spatial-Workshop/data/04-loading/shape/us_parks.shp"/>
  </parameters>
</styling_rules>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_INTERSTATES.SHP',
'CUSTOM_TABLE',
'GEOMETRY',
'<?xml version="1.0" standalone="yes"?>
<styling_rules theme_type="geom_custom" srid="8307" provider_id="ogrSDP">
  <rule column="INTERSTATE">
    <features style="L.US_INTERSTATES"> </features>
    <label column="INTERSTATE" style="M.US_INTERSTATES"> 1 </label>
  </rule>
  <parameters>
    <parameter name="datasource" value="/media/sf_Spatial-Workshop/data/04-loading/shape/us_interstates.shp"/>
  </parameters>
</styling_rules>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_CITIES.SHP',
'CUSTOM_TABLE',
'GEOMETRY',
'<?xml version="1.0" standalone="yes"?>
<styling_rules theme_type="geom_custom" srid="8307" provider_id="ogrSDP">
  <rule column="CITY,POP90,RANK90,STATE_ABRV">
    <features style="M.US_CITIES"> </features>
    <label column="CITY" style="T.US_CITIES"> 1 </label>
  </rule>
  <parameters>
    <parameter name="datasource" value="/media/sf_Spatial-Workshop/data/04-loading/shape/us_cities.shp"/>
  </parameters>
</styling_rules>'
);


-- -------------------------------------------------------------------
-- Maps
-- -------------------------------------------------------------------

insert into user_sdo_maps (name, definition)
values (
'US_BASE_MAP.SHP',
'<?xml version="1.0" standalone="yes"?>
<map_definition>
  <theme name="WORLD_COUNTRIES.SHP"                                       scale_mode="RATIO"/>
  <theme name="US_STATES.SHP"         min_scale="150000000" max_scale="0" scale_mode="RATIO"/>
  <theme name="US_COUNTIES.SHP"       min_scale="8500000"   max_scale="0" scale_mode="RATIO"/>
  <theme name="US_PARKS.SHP"          min_scale="10000000"  max_scale="0" scale_mode="RATIO"/>
  <theme name="US_INTERSTATES.SHP"    min_scale="20000000"  max_scale="0" scale_mode="RATIO"/>
  <theme name="US_CITIES.SHP"         min_scale="15000000"  max_scale="0" scale_mode="RATIO"/>
</map_definition>'
);

-- -------------------------------------------------------------------
-- Map Caches
-- -------------------------------------------------------------------
insert into user_sdo_cached_maps (name, is_online, is_internal, definition, base_map)
values (
'US_BASE_MAP_SHP',
'YES',
'YES',
'<map_tile_layer name="US_BASE_MAP_SHP" image_format="PNG" http_header_expires="168.0" concurrent_fetching_threads="3">
   <internal_map_source data_source="SCOTT" base_map="US_BASE_MAP" bgcolor="#33ccff"/>
   <tile_storage root_path="/tmp"/>
   <coordinate_system srid="8307" minX="-180.0" minY="-90.0" maxX="180.0" maxY="90.0"/>
   <tile_image width="256" height="256"/>
   <zoom_levels levels="20" min_scale="645309.0" max_scale="2.13103147E8"/>
</map_tile_layer>',
'US_BASE_MAP.SHP'
);

commit;
