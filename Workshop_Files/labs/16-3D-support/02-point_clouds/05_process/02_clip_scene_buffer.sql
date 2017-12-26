--
-- Clip the section of the point cloud that lies
-- within a 1KM buffer from a point
--

-- Create a block table to hold the results of the clipping
drop table clipped_lidar_scenes_blocks;
create table clipped_lidar_scenes_blocks as select * from mdsys.sdo_pc_blk_table;

declare
  clip_window sdo_geometry;
begin

  -- Construct the clipping window
  clip_window := sdo_geom.sdo_buffer (
    SDO_GEOMETRY(2001, 4326, SDO_POINT_TYPE(-83.430895, 39.0243455, NULL), NULL, NULL),
    200, 0.05, 'UNIT=METER'
  );

  -- Find the matching scenes
  for s in (
    select point_cloud
    from   lidar_scenes s
    where  sdo_anyinteract(s.point_cloud.pc_extent, clip_window) = 'TRUE'
  )
  loop

    -- Clip out the desired subset from the scene
    insert into clipped_lidar_scenes_blocks
      select * from table (
        sdo_pc_pkg.clip_pc (
          INP             =>  s.point_cloud,
          IND_DIM_QRY     =>  clip_window,
          OTHER_DIM_QRY   =>  null,
          QRY_MIN_RES     =>  null,
          QRY_MAX_RES     =>  null
        )
      );
  end loop;

end;
/
commit;

--
-- Define spatial metadata for the clip
--
delete from user_sdo_geom_metadata where table_name in ('CLIPPED_LIDAR_SCENES_BLOCKS');

insert into user_sdo_geom_metadata (
  table_name, column_name, diminfo, srid
)
values (
  'CLIPPED_LIDAR_SCENES_BLOCKS',
  'BLK_EXTENT',
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
drop index clipped_lidar_scenes_blocks_sx;
create index clipped_lidar_scenes_blocks_sx
  on clipped_lidar_scenes_blocks (blk_extent)
  indextype is mdsys.spatial_index;
