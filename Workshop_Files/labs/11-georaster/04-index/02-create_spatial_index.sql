drop index us_rasters_sx;
create index us_rasters_sx
  on us_rasters (georaster.spatialextent)
  indextype is mdsys.spatial_index;
