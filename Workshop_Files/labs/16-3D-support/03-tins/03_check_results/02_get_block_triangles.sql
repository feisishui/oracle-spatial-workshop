select t.id,
       b.obj_id,
       b.blk_id,
       sdo_tin_pkg.to_geometry(
         b.points,
         b.triangles,
         b.num_points,
         b.num_triangles,
         t.tin.tin_extent.get_dims(),
         t.tin.tin_tot_dimensions,
         t.tin.tin_extent.sdo_srid
       )
  from tins t, tin_blk_01 b
 where t.id = 1
   and b.obj_id = t.tin.tin_id
   and b.blk_id = 1
 order by obj_id, blk_id;
