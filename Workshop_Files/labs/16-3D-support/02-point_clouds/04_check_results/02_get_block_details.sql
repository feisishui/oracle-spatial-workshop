col obj_id for 9999
col blk_id for 9999
col bytes for 999999
col m2 for 99999.9
col density for 99.99
select obj_id,
       blk_id,
       num_points,
       length(points) bytes,
       sdo_geom.sdo_area(blk_extent,0.5,'unit=sq_m') m2,
       num_points / sdo_geom.sdo_area(blk_extent,0.5,'unit=sq_m') density
  from pc_blk_01
 order by obj_id, blk_id;

