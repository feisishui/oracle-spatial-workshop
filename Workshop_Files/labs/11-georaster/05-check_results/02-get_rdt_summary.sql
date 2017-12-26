col georid      for 99999
col rasterid    for 99999
col levels      for 99999
col nblocks     for 99999 
col base_mb     for 9,999.99
col pyramid_mb  for 9,999.99
col total_mb    for 9,999.99
col pct         for 99.99
select georid,
       rasterid,
       count (distinct pyramidlevel) levels,
       count (*) nblocks,
       sum(base_bytes)/1024/1024 base_mb,
       sum(pyramid_bytes)/1024/1024 pyramid_mb,
       (sum(base_bytes)+sum(pyramid_bytes))/1024/1024 total_mb,
       sum(pyramid_bytes)/sum(base_bytes)*100 pct
from (
  select r.georid,
         b.rasterid,
         b.pyramidlevel,
         case
           when b.pyramidlevel = 0 then dbms_lob.getlength(b.rasterblock)
           else 0
         end base_bytes,
         case
           when b.pyramidlevel > 0 then dbms_lob.getlength(b.rasterblock)
           else 0
         end pyramid_bytes
    from us_rasters r, us_rasters_rdt_01 b
   where r.georaster.rasterid = b.rasterid
 )
group by georid, rasterid
order by georid, rasterid;
