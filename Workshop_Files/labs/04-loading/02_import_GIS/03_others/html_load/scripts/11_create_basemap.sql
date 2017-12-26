create table basemap (geom sdo_geometry);

insert into basemap (geom)
select sdo_util.extract(sdo_aggr_union(sdoaggrtype(geom,0.5)),2,1) from regionitm;
commit;

-- Setup spatial metadata
insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid) 
values (
  'BASEMAP',
  'GEOM',
  sdo_dim_array (
    sdo_dim_element ('X', 0, 1000, 0.5),
    sdo_dim_element ('Y', 0, 1000, 0.5)
  ),
  262155
);
commit;

-- Create spatial index
create index BASEMAP_SX on BASEMAP (GEOM) indextype is mdsys.spatial_index;

-- Define Mapviewer style
insert into user_sdo_styles (name, type, definition)
values (
'C.BASEMAP',
'COLOR',
'<svg width="1in" height="1in">
  <desc/>
  <g class="color" style="stroke:#000000;fill:#FFFFFF">
    <rect width="50" height="50"/>
  </g>
</svg>'
);
commit;

-- Define Mapviewer theme
insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'BASEMAP',
'BASEMAP',
'GEOM',
'<styling_rules>
  <rule>
    <features style="C.BASEMAP"> </features>
  </rule>
</styling_rules>'
);
commit;

-- Define Mapviewer base map
insert into user_sdo_maps (name, definition)
values (
'BASEMAP',
'<map_definition>
  <theme name="BASEMAP"/>
</map_definition>'
);
commit;

-- Define a tile cache
insert into user_sdo_cached_maps (name,is_online,is_internal,definition,base_map)    
values (
'BASEMAP','YES','YES',
'<map_tile_layer name="BASEMAP" image_format="PNG" http_header_expires="168.0" concurrent_fetching_threads="3">
   <internal_map_source base_map="BASEMAP" bgcolor="#ffffff"/>
   <tile_storage root_path="/temp" xyz_storage_scheme="false"/>
   <coordinate_system srid="262155" minX="-300" minY="-600" maxX="800" maxY="100"/>
   <tile_image width="256" height="256"/>
   <zoom_levels levels="10" min_scale="1" max_scale="18.0">
   </zoom_levels>
</map_tile_layer>',
'BASEMAP'
);
commit;