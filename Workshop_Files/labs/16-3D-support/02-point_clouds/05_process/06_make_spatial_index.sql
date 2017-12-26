-- Define spatial metadata for the clip
--
delete from user_sdo_geom_metadata where table_name in ('CLIPPED_LIDAR_SCENES_GEOM');

insert into user_sdo_geom_metadata (
  table_name, column_name, diminfo, srid
)
values (
  'CLIPPED_LIDAR_SCENES_GEOM',
  'POINTS',
   sdo_dim_array(
     sdo_dim_element('Easting',   200000,   300000, 0.05),
     sdo_dim_element('Northing', 4300000,  4400000, 0.05),
     sdo_dim_element('Elevation', -10000,    10000, 0.05)
   ),
   32617
);
commit;

--
-- create spatial index
--
drop index clipped_lidar_scenes_geom_sx;
create index clipped_lidar_scenes_geom_sx
  on clipped_lidar_scenes_geom (points)
  indextype is mdsys.spatial_index;



