-- create the function-based spatial index
drop index us_counties_centroid_sx;
create index us_counties_centroid_sx
  on us_counties (sdo_geom.sdo_centroid(geom,0.5))
  indextype is mdsys.spatial_index
  parameters ('layer_gtype=point')
;
