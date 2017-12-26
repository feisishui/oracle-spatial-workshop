delete from user_sdo_geom_metadata where table_name = 'FIELDS';
insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
values (
  'FIELDS',
  'GEOMETRY',
  sdo_dim_array (
    sdo_dim_element ('Longitude', -180, 180, 0.05),
    sdo_dim_element ('Latitude', -90, 90, 0.05)
  ),
  4326
);
commit;

drop index fields_sx;
create index fields_sx on fields(geometry)
  indextype is mdsys.spatial_index;
