select p.id,
       b.obj_id,
       b.blk_id,
       sdo_pc_pkg.to_geometry(
         b.points,
         b.num_points,
         p.point_cloud.pc_tot_dimensions,
         p.point_cloud.pc_extent.sdo_srid
       )
  from lidar_scenes p, pc_blk_01 b
 where p.id = 101
   and b.obj_id = p.point_cloud.pc_id
   and b.blk_id = 326
 order by obj_id, blk_id;
