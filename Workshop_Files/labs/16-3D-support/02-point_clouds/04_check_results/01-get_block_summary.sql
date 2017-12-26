col ncols for 99999
col mb for 99999.99
select obj_id,
       count(*) nblocks,
       sum(num_points) npoints,
       avg(length(points)) avg_bytes,
       sum(dbms_lob.getlength(points))/1024/1024 total_mb
  from pc_blk_01
 group by obj_id
 order by obj_id;
