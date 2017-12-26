delete from user_sdo_geom_metadata where table_name in ('US_RASTERS_WGS84');
insert into user_sdo_geom_metadata (
  table_name, column_name, diminfo, srid 
)
values (
  'US_RASTERS_WGS84',
  'GEORASTER.SPATIALEXTENT',
   sdo_dim_array(
     sdo_dim_element('Long',  -180, 180, 1),
     sdo_dim_element('Lat',  -90, 90, 1)
   ),
   4326
);
commit;

