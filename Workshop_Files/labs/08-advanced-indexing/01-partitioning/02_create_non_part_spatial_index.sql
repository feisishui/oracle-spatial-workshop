delete from user_sdo_geom_metadata
  where table_name = 'YELLOW_PAGES' and column_name = 'LOCATION' ;

insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
values (
  'YELLOW_PAGES',
  'LOCATION',
  sdo_dim_array (
    sdo_dim_element('x', -180.0, 180.0, 0.1),
    sdo_dim_element('y', -90.0, 90.0, 0.1)
  ),
  8307
);
commit;

drop index yellow_pages_sidx;
create index yellow_pages_sidx on yellow_pages (location)
  indextype is mdsys.spatial_index;
