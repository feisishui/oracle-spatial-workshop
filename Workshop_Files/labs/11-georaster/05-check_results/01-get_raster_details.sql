col georid for 999999
col blocksize for a30
col cell for 99
col inter for a5
col levels for 999
col bandsfor for 999 
col compression for a11
select georid,
       sdo_geor.getcelldepth(georaster) cell,
       sdo_geor.getblocksize(georaster) blocksize,
       sdo_geor.getinterleavingtype(georaster) inter,
       sdo_geor.getpyramidmaxlevel(georaster) levels,
       sdo_geor.getbanddimsize(georaster) bands,
       sdo_geor.getCompressionType(georaster) compression
  from us_rasters
 order by georid;
