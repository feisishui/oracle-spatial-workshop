-- This script inserts metadata for the yellow_pages_part table --
-- and creates a spatial index on the location column --

delete from user_sdo_geom_metadata
  where table_name = 'YELLOW_PAGES_PART' and column_name = 'LOCATION' ;

insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
values (
  'YELLOW_PAGES_PART',
  'LOCATION',
  sdo_dim_array (
    sdo_dim_element('x', -180.0, 180.0, 0.1),
    sdo_dim_element('y', -90.0, 90.0, 0.1)
  ),
  8307
);
commit;

drop index yellow_pages_part_sidx;
create index yellow_pages_part_sidx on yellow_pages_part (location)
  indextype is mdsys.spatial_index
  local;
