delete from user_sdo_geom_metadata where table_name = 'LIDAR_SCENES_BLK_01';

insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
values (
  'LIDAR_SCENES_BLK_01',
  'BLK_EXTENT',
  SDO_DIM_ARRAY(
    SDO_DIM_ELEMENT('D', 250000, 260000, .05), 
    SDO_DIM_ELEMENT('D', 470000, 480000, .05),
    SDO_DIM_ELEMENT('D', 31, 71, .05)
  ),
  28992
);

create index lidar_scenes_blk_01_sx on lidar_scenes_blk_01 (blk_extent) indextype is mdsys.spatial_index;
