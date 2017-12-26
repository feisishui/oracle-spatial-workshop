--
-- Create from the SDO_lidar_scenes_BLK object type
--
create table lidar_scenes_blk_01 of sdo_lidar_scenes_blk (
  primary key (
     obj_id, blk_id
  )
)
lob(points) store as securefile (compress high nocache nologging);

