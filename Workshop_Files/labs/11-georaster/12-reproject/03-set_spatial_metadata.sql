delete from user_sdo_geom_metadata where table_name in ('US_RASTERS_3857');
insert into user_sdo_geom_metadata (
  table_name, column_name, diminfo, srid 
)
values (
  'US_RASTERS_3857',
  'GEORASTER.SPATIALEXTENT',
   sdo_dim_array(
     sdo_dim_element('X', -20000000, 20000000, 1),
     sdo_dim_element('Y', -20000000, 20000000, 1)
   ),
   3857
);
commit;

