-- Estimated size for
--   Number of objects      1000000
--   Block size             8192
--   Percent free           10
--   Dimensions             2
--   Geodetic ?             1 (YES)
select sdo_tune.estimate_rtree_index_size  (1000000, 8192, 10, 2, 1) mb from dual;
