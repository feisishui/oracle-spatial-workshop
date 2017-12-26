col obj_id for 99999
col nblocks for 99999
col npoints for 9999999
col ntriangles for 9999999
col mb for 99999.99
select obj_id,
       count(*) nblocks,
       sum(num_points) npoints,
       sum(num_triangles) ntriangles,
       sum(dbms_lob.getlength(points))/1024/1024 points_mb,
       sum(dbms_lob.getlength(triangles))/1024/1024 triangles_mb
  from tin_blk_01
 group by obj_id
 order by obj_id;
