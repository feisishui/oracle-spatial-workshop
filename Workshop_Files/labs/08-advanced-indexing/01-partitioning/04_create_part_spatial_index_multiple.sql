-- This script inserts metadata for the yellow_pages_part table
-- and creates a spatial index on the location column
-- The index is created as "unusable", then each individual partition is rebuilt

delete from user_sdo_geom_metadata
  where table_name = 'yellow_pages_part' and column_name = 'location' ;

insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid) values
  ('yellow_pages_part', 'location',
   sdo_dim_array (
     sdo_dim_element('x', -180.0, 180.0, 0.1),
     sdo_dim_element('y', -90.0, 90.0, 0.1)),
   8307);
commit;

drop index yellow_pages_part_sidx;
create index yellow_pages_part_sidx on yellow_pages_part (location)
  indextype is mdsys.spatial_index
  local
  unusable;

alter index yellow_pages_part_sidx rebuild partition p1;
alter index yellow_pages_part_sidx rebuild partition p2;
alter index yellow_pages_part_sidx rebuild partition p3;
alter index yellow_pages_part_sidx rebuild partition p4;
alter index yellow_pages_part_sidx rebuild partition p5;
alter index yellow_pages_part_sidx rebuild partition p6;

