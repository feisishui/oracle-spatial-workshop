-- Create fully manually (copy the provided template - see $ORACLE_HOME/md/admin/sdotnpc.sql)
--
create table tin_blk_01 (
  obj_id              NUMBER ,
  blk_id              NUMBER,
  blk_extent          sdo_geometry,
  blk_domain          sdo_orgscl_type,
  pcblk_min_res       NUMBER,
  pcblk_max_res       NUMBER,
  num_points          NUMBER,
  num_unsorted_points NUMBER,
  pt_sort_dim         NUMBER,
  points              BLOB,
  tr_lvl              NUMBER,
  tr_res              NUMBER,
  num_triangles       NUMBER,
  tr_sort_dim         NUMBER,
  triangles           BLOB,
  primary key (
     obj_id, blk_id
  )
)
lob(points) store as securefile (compress high nocache nologging)
lob(triangles) store as securefile (compress high nocache nologging);
