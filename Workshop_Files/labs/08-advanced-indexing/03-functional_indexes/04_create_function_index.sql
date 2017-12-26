-- create the function-based spatial index
drop index us_cities_xy_sx;
create index us_cities_xy_sx
  on us_cities_xy ( get_point(longitude, latitude))
  indextype is mdsys.spatial_index;
