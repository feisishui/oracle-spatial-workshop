drop index us_rasters_3857_sx;
create index us_rasters_3857_sx
  on us_rasters_3857 (georaster.spatialextent)
  indextype is mdsys.spatial_index;

