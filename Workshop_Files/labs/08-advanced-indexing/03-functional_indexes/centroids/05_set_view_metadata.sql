-- Setup spatial metadata for the view
-- This is needed for most GIS tools to operate correctly
delete from user_sdo_geom_metadata
where table_name = 'US_COUNTIES_CENTROID';

insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
values (
  'US_COUNTIES_CENTROID', 
  'CENTROID',
  sdo_dim_array (
    sdo_dim_element('long', -180.0, 180.0, 0.5),
    sdo_dim_element('lat', -90.0, 90.0, 0.5)
  ),
  8307
);
commit;

