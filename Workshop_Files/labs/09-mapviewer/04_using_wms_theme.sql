/*

This script defines a theme, map and map cache on your local WMS (MapViewer) installation,

Theme: WMS US_BASE_MAP
Map:   WMS US_BASE_MAP
Cache: WMS US_BASE_MAP

NOTE: The URL specified for the WMS uses port 7001 (it assumes you have deployed MapViewer in Weblogic).
Chance it to 8888 if you are using OC4J

*/

delete from user_sdo_themes       where name = 'WMS US_BASE_MAP';
delete from user_sdo_maps         where name = 'WMS US_BASE_MAP';
delete from user_sdo_cached_maps  where name = 'WMS US_BASE_MAP';
set define off

-- -------------------------------------------------------------------
-- Theme
-- -------------------------------------------------------------------
insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'WMS US_BASE_MAP',
'WMS',
'WMS',
'<?xml version="1.0" standalone="yes"?>
<styling_rules theme_type="wms">
  <service_url> http://localhost:7001/mapviewer/wms? </service_url>
  <layers> WORLD_COUNTRIES, US_STATES, US_COUNTIES, US_INTERSTATES, US_CITIES</layers>
  <version> 1.1.1 </version>
  <srs> EPSG:4326 </srs>
  <format> image/png </format>
  <bgcolor> 0xA6CAF0 </bgcolor>
  <transparent> false </transparent>
  <capabilities_url> http://localhost:7001/mapviewer/wms? </capabilities_url>
</styling_rules>'
);

-- -------------------------------------------------------------------
-- Map
-- -------------------------------------------------------------------
insert into user_sdo_maps (name, definition)
values (
'WMS US_BASE_MAP',
'<?xml version="1.0" standalone="yes"?>
<map_definition>
  <theme name="WMS US_BASE_MAP"/>
</map_definition>'
);

-- -------------------------------------------------------------------
-- Map Cache
-- -------------------------------------------------------------------
insert into user_sdo_cached_maps (name, is_internal, is_online, definition, base_map)
values (
'WMS US_BASE_MAP',
'YES',
'YES',
'<map_tile_layer name="WMS US_BASE_MAP" image_format="PNG" http_header_expires="168.0" concurrent_fetching_threads="3">
   <internal_map_source data_source="SCOTT" base_map="WMS US_BASE_MAP" bgcolor="#ffffff"/>
   <tile_storage root_path="/tmp"/>
   <coordinate_system srid="8307" minX="-180.0" minY="-90.0" maxX="180.0" maxY="90.0"/>
   <tile_image width="256" height="256"/>
   <zoom_levels levels="20" min_scale="645309.0" max_scale="2.13103147E8"/>
</map_tile_layer>',
'WMS US_BASE_MAP'
);

commit;
