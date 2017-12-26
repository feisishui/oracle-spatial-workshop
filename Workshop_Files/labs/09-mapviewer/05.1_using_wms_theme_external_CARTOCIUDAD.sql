/*

This script defines a theme, map and map cache on a public WMS, provided by
the national mapping agency of Spain

Theme: WMS_IGN_CARTOCIUDAD
Map:   WMS_IGN_CARTOCIUDAD
Cache: WMS_IGN_CARTOCIUDAD

*/

delete from user_sdo_themes       where name = 'WMS_IGN_CARTOCIUDAD';
delete from user_sdo_maps         where name = 'WMS_IGN_CARTOCIUDAD';
delete from user_sdo_cached_maps  where name like 'WMS_IGN_CARTOCIUDAD%';
set define off

-- -------------------------------------------------------------------
-- Theme
-- -------------------------------------------------------------------
insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'WMS_IGN_CARTOCIUDAD',
'WMS',
'WMS',
'<?xml version="1.0" standalone="yes"?>
<styling_rules theme_type="wms">
  <service_url> http://www.cartociudad.es/wms/CARTOCIUDAD/CARTOCIUDAD </service_url>
  <layers> DivisionTerritorial,FondoUrbano,Vial,Portal,Toponimo,SeccionCensal,CodigoPostal </layers>
  <version> 1.1.0 </version>
  <srs> EPSG:4326 </srs>
  <format> image/png </format>
  <bgcolor> 0xA6CAF0 </bgcolor>
  <transparent> false </transparent>
  <exceptions> application/vnd.ogc.se_xml </exceptions>
  <capabilities_url> http://www.cartociudad.es/wms/CARTOCIUDAD/CARTOCIUDAD?Request=GetCapabilities&amp;Service=WMS </capabilities_url>
</styling_rules>'
);

-- -------------------------------------------------------------------
-- Map
-- -------------------------------------------------------------------
insert into user_sdo_maps (name, definition)
values (
'WMS_IGN_CARTOCIUDAD',
'<?xml version="1.0" standalone="yes"?>
<map_definition>
  <theme name="WMS_IGN_CARTOCIUDAD"/>
</map_definition>'
);

-- -------------------------------------------------------------------
-- Map Cache
-- -------------------------------------------------------------------
insert into user_sdo_cached_maps (name, is_internal, is_online, definition, base_map)
values (
'WMS_IGN_CARTOCIUDAD_WGS84',
'YES',
'YES',
'<map_tile_layer name="WMS_IGN_CARTOCIUDAD" image_format="PNG" http_header_expires="168.0" concurrent_fetching_threads="3">
   <internal_map_source data_source="SCOTT" base_map="WMS_IGN_CARTOCIUDAD" bgcolor="#ffffff"/>
   <tile_storage root_path="/temp"/>
   <coordinate_system srid="4326" minX="-14.488" minY="33.742" maxX="11.184" maxY="48.093"/>
   <tile_image width="256" height="256"/>
   <zoom_levels levels="20" min_scale="1500.0" max_scale="15000000">
   </zoom_levels>
</map_tile_layer>',
'WMS_IGN_CARTOCIUDAD'
);

insert into user_sdo_cached_maps (name, is_internal, is_online, definition, base_map)
values (
'WMS_IGN_CARTOCIUDAD',
'YES',
'YES',
'<map_tile_layer name="WMS_IGN_CARTOCIUDAD" image_format="PNG" http_header_expires="168.0" concurrent_fetching_threads="3">
   <internal_map_source data_source="SCOTT" base_map="WMS_IGN_CARTOCIUDAD" bgcolor="#ffffff"/>
   <tile_storage root_path="/temp"/>
   <coordinate_system srid="3857" minX="-2.0037508E7" minY="-2.0037508E7" maxX="2.0037508E7" maxY="2.0037508E7"/>
   <tile_image width="256" height="256"/>
   <zoom_levels levels="19" min_scale="0.0" max_scale="0.0" min_tile_width="76.43702697753906" min_tile_height="2.0037508E7">
      <zoom_level level="0" name="" description="" scale="0.0" tile_width="2.0037508E7" tile_height="2.0037508E7"/>
      <zoom_level level="1" name="" description="" scale="0.0" tile_width="1.0018754E7" tile_height="1.0018754E7"/>
      <zoom_level level="2" name="" description="" scale="0.0" tile_width="5009377.0" tile_height="5009377.0"/>
      <zoom_level level="3" name="" description="" scale="0.0" tile_width="2504688.5" tile_height="2504688.5"/>
      <zoom_level level="4" name="" description="" scale="0.0" tile_width="1252344.25" tile_height="1252344.25"/>
      <zoom_level level="5" name="" description="" scale="0.0" tile_width="626172.125" tile_height="626172.125"/>
      <zoom_level level="6" name="" description="" scale="0.0" tile_width="313086.0625" tile_height="313086.0625"/>
      <zoom_level level="7" name="" description="" scale="0.0" tile_width="156543.03125" tile_height="156543.03125"/>
      <zoom_level level="8" name="" description="" scale="0.0" tile_width="78271.515625" tile_height="78271.515625"/>
      <zoom_level level="9" name="" description="" scale="0.0" tile_width="39135.7578125" tile_height="39135.7578125"/>
      <zoom_level level="10" name="" description="" scale="0.0" tile_width="19567.87890625" tile_height="19567.87890625"/>
      <zoom_level level="11" name="" description="" scale="0.0" tile_width="9783.939453125" tile_height="9783.939453125"/>
      <zoom_level level="12" name="" description="" scale="0.0" tile_width="4891.9697265625" tile_height="4891.9697265625"/>
      <zoom_level level="13" name="" description="" scale="0.0" tile_width="2445.98486328125" tile_height="2445.98486328125"/>
      <zoom_level level="14" name="" description="" scale="0.0" tile_width="1222.992431640625" tile_height="1222.992431640625"/>
      <zoom_level level="15" name="" description="" scale="0.0" tile_width="611.4962158203125" tile_height="611.4962158203125"/>
      <zoom_level level="16" name="" description="" scale="0.0" tile_width="305.74810791015625" tile_height="305.74810791015625"/>
      <zoom_level level="17" name="" description="" scale="0.0" tile_width="152.87405395507812" tile_height="152.87405395507812"/>
      <zoom_level level="18" name="" description="" scale="0.0" tile_width="76.43702697753906" tile_height="76.43702697753906"/>
   </zoom_levels>
</map_tile_layer>',
'WMS_IGN_CARTOCIUDAD'
);

commit;
