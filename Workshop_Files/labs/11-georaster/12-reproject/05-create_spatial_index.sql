drop index us_rasters_wgs84_sx;
create index us_rasters_wgs84_sx
  on us_rasters_wgs84 (georaster.spatialextent)
  indextype is mdsys.spatial_index;

