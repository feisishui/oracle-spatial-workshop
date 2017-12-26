--
-- Define spatial metadata
--

delete from user_sdo_geom_metadata where table_name in ('LIDAR_SCENES');

insert into user_sdo_geom_metadata (
  table_name, column_name, diminfo, srid
)
values (
  'LIDAR_SCENES',
  'POINT_CLOUD.PC_EXTENT',
   sdo_dim_array(
     sdo_dim_element('Easting',   200000,   300000, 0.05),
     sdo_dim_element('Northing', 4300000,  4400000, 0.05)
   ),
   32617
);

commit;

--
-- create spatial index
--
drop index lidar_scenes_sx;
create index lidar_scenes_sx
  on lidar_scenes (point_cloud.pc_extent)
  indextype is mdsys.spatial_index;
