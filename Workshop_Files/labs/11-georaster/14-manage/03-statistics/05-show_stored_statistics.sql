with layers as (
  select rownum-1 layer from dual connect by level <= 4
)
SELECT georid, layer, sdo_geor.getStatistics(georaster, layer) statistics
FROM us_rasters, layers
ORDER BY georid, layer;