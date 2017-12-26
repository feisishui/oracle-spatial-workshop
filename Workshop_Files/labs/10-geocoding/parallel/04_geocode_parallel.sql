truncate table gc_results;

insert /*+ append */ into gc_results
select /*+ parallel(2) */ * 
from table (
  geocode_pipelined (
    CURSOR (
      SELECT id, 
        line_1, 
        line_2, 
        country_code 
      FROM addresses
    )
  )    
);
commit;
-- Noparallel:  Elapsed: 00:03:32.95 for 15122 addresses =  71/second
-- Parallel(2): Elapsed: 00:01:43.61 for 15122 addresses = 145/second
