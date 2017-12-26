col georid    for 99999 
col rasterid  for 99999
col plevel    for 99999
col avg_bytes for 99999999
col nblocks   for 99999
col mb        for 99999.99
select r.georid,
       b.rasterid,
       b.pyramidlevel plevel,
       count(*) nblocks,
       avg(length(b.rasterblock)) avg_bytes,
       sum(dbms_lob.getlength(b.rasterblock)) bytes,
       sum(dbms_lob.getlength(b.rasterblock))/1024/1024 mb
  from us_rasters r, us_rasters_rdt_01 b
 where r.georaster.rasterid = b.rasterid
 group by r.georid, b.rasterid, b.pyramidlevel
 order by r.georid, b.rasterid, b.pyramidlevel;
