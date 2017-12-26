-- Cleanup
delete from user_sdo_cached_maps
where name in ('US_BASE_MAP_G', 'US_BASE_MAP_E');

-- Google-compatible tile cache on local base map
insert into user_sdo_cached_maps (
  name,
  description,
  is_online,
  is_internal,
  definition,
  base_map,
  map_adapter
)
values (
  'US_BASE_MAP_G',
  'Tile cache in Google Spherical Mercator projection. Compatible with Google, Bing, OpenStreetMap and most online mapping servcices',
  'YES',
  'YES',
  '<map_tile_layer name="US_BASE_MAP_G" image_format="PNG" http_header_expires="168.0" concurrent_fetching_threads="3">
     <tile_storage root_path="/tmp"/>
     <coordinate_system srid="3857" minX="-20037508" minY="-20037508" maxX="20037508" maxY="20037508"/>
     <tile_image width="256" height="256"/>
     <zoom_levels levels="19" min_scale="1096.9668834114077" max_scale="2.8756328668500006E8" min_tile_width="76.43702697753906" min_tile_height="2.0037508E7">
       <zoom_level level="0" name="" description="" scale="2.8756328668500006E8" tile_width="2.0037508E7" tile_height="2.0037508E7"/>
       <zoom_level level="1" name="" description="" scale="1.4378164334250003E8" tile_width="1.0018754E7" tile_height="1.0018754E7"/>
       <zoom_level level="2" name="" description="" scale="7.189082167125002E7"  tile_width="5009377.0" tile_height="5009377.0"/>
       <zoom_level level="3" name="" description="" scale="3.594541083562501E7"  tile_width="2504688.5" tile_height="2504688.5"/>
       <zoom_level level="4" name="" description="" scale="1.7972705417812504E7" tile_width="1252344.25" tile_height="1252344.25"/>
       <zoom_level level="5" name="" description="" scale="8986352.708906252" tile_width="626172.125" tile_height="626172.125"/>
       <zoom_level level="6" name="" description="" scale="4493176.354453126" tile_width="313086.0625" tile_height="313086.0625"/>
       <zoom_level level="7" name="" description="" scale="2246588.177226563" tile_width="156543.03125" tile_height="156543.03125"/>
       <zoom_level level="8" name="" description="" scale="1123294.0886132815" tile_width="78271.515625" tile_height="78271.515625"/>
       <zoom_level level="9" name="" description="" scale="561647.0443066407" tile_width="39135.7578125" tile_height="39135.7578125"/>
       <zoom_level level="10" name="" description="" scale="280823.5221533204" tile_width="19567.87890625" tile_height="19567.87890625"/>
       <zoom_level level="11" name="" description="" scale="140411.7610766602" tile_width="9783.939453125" tile_height="9783.939453125"/>
       <zoom_level level="12" name="" description="" scale="70205.8805383301" tile_width="4891.9697265625" tile_height="4891.9697265625"/>
       <zoom_level level="13" name="" description="" scale="35102.94026916505" tile_width="2445.98486328125" tile_height="2445.98486328125"/>
       <zoom_level level="14" name="" description="" scale="17551.470134582523" tile_width="1222.992431640625" tile_height="1222.992431640625"/>
       <zoom_level level="15" name="" description="" scale="8775.735067291262" tile_width="611.4962158203125" tile_height="611.4962158203125"/>
       <zoom_level level="16" name="" description="" scale="4387.867533645631" tile_width="305.74810791015625" tile_height="305.74810791015625"/>
       <zoom_level level="17" name="" description="" scale="2193.9337668228154" tile_width="152.87405395507812" tile_height="152.87405395507812"/>
       <zoom_level level="18" name="" description="" scale="1096.9668834114077" tile_width="76.43702697753906" tile_height="76.43702697753906"/>
     </zoom_levels>
   </map_tile_layer>',
  'US_BASE_MAP',
  empty_blob()
);

-- eLocation-compatible tile cache on local base map
insert into user_sdo_cached_maps (
  name,
  description,
  is_online,
  is_internal,
  definition,
  base_map,
  map_adapter
)
values (
  'US_BASE_MAP_E',
  'Tile cache in Ellipsoidal Mercator projection. Compatible with Oracle eLocation',
  'YES',
  'YES',
  '<map_tile_layer name="US_BASE_MAP_E" image_format="PNG" http_header_expires="168.0" concurrent_fetching_threads="3">
     <tile_storage root_path="/tmp"/>
     <coordinate_system srid="54004" minX="-20037508" minY="-20037508" maxX="20037508" maxY="20037508"/>
     <tile_image width="256" height="256"/>
     <zoom_levels levels="19" min_scale="1096.9668834114077" max_scale="2.8756328668500006E8" min_tile_width="76.43702697753906" min_tile_height="2.0037508E7">
       <zoom_level level="0" name="" description="" scale="2.8756328668500006E8" tile_width="2.0037508E7" tile_height="2.0037508E7"/>
       <zoom_level level="1" name="" description="" scale="1.4378164334250003E8" tile_width="1.0018754E7" tile_height="1.0018754E7"/>
       <zoom_level level="2" name="" description="" scale="7.189082167125002E7"  tile_width="5009377.0" tile_height="5009377.0"/>
       <zoom_level level="3" name="" description="" scale="3.594541083562501E7"  tile_width="2504688.5" tile_height="2504688.5"/>
       <zoom_level level="4" name="" description="" scale="1.7972705417812504E7" tile_width="1252344.25" tile_height="1252344.25"/>
       <zoom_level level="5" name="" description="" scale="8986352.708906252" tile_width="626172.125" tile_height="626172.125"/>
       <zoom_level level="6" name="" description="" scale="4493176.354453126" tile_width="313086.0625" tile_height="313086.0625"/>
       <zoom_level level="7" name="" description="" scale="2246588.177226563" tile_width="156543.03125" tile_height="156543.03125"/>
       <zoom_level level="8" name="" description="" scale="1123294.0886132815" tile_width="78271.515625" tile_height="78271.515625"/>
       <zoom_level level="9" name="" description="" scale="561647.0443066407" tile_width="39135.7578125" tile_height="39135.7578125"/>
       <zoom_level level="10" name="" description="" scale="280823.5221533204" tile_width="19567.87890625" tile_height="19567.87890625"/>
       <zoom_level level="11" name="" description="" scale="140411.7610766602" tile_width="9783.939453125" tile_height="9783.939453125"/>
       <zoom_level level="12" name="" description="" scale="70205.8805383301" tile_width="4891.9697265625" tile_height="4891.9697265625"/>
       <zoom_level level="13" name="" description="" scale="35102.94026916505" tile_width="2445.98486328125" tile_height="2445.98486328125"/>
       <zoom_level level="14" name="" description="" scale="17551.470134582523" tile_width="1222.992431640625" tile_height="1222.992431640625"/>
       <zoom_level level="15" name="" description="" scale="8775.735067291262" tile_width="611.4962158203125" tile_height="611.4962158203125"/>
       <zoom_level level="16" name="" description="" scale="4387.867533645631" tile_width="305.74810791015625" tile_height="305.74810791015625"/>
       <zoom_level level="17" name="" description="" scale="2193.9337668228154" tile_width="152.87405395507812" tile_height="152.87405395507812"/>
       <zoom_level level="18" name="" description="" scale="1096.9668834114077" tile_width="76.43702697753906" tile_height="76.43702697753906"/>
     </zoom_levels>
   </map_tile_layer>',
  'US_BASE_MAP',
  empty_blob()
);

commit;
