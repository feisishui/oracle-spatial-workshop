truncate table gc_results;

insert /*+ append */ into gc_results
select /*+ parallel(2) */ * 
from table (
  reverse_geocode_pipelined (
    CURSOR (
      SELECT id, 
        sdo_geometry(2001, 4326, sdo_point_type(longitude, latitude, null), null, null),
        country_code
      FROM addresses
    )
  )    
);
commit;
-- Noparallel:  Elapsed: 00:03:08.09 for 15122 points =  80/second
-- Parallel(2): Elapsed: 00:01:53.26 for 15122 points = 153/second