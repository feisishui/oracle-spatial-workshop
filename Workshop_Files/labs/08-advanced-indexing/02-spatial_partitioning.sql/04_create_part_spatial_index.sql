delete from user_sdo_geom_metadata
  where table_name = 'YELLOW_PAGES_PART_SPATIAL' and column_name = 'LOCATION' ;

insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
values (
  'YELLOW_PAGES_PART_SPATIAL',
  'LOCATION',
  sdo_dim_array (
    sdo_dim_element('x', -180.0, 180.0, 0.1),
    sdo_dim_element('y', -90.0, 90.0, 0.1)
  ),
  8307
);
commit;

drop index yellow_pages_part_spatial_sidx;
CREATE INDEX yellow_pages_part_spatial_sidx ON yellow_pages_part_spatial (location)
  INDEXTYPE IS mdsys.spatial_index
  LOCAL;
