delete from user_sdo_geom_metadata where table_name in ('US_RASTERS');
insert into user_sdo_geom_metadata (
  table_name, column_name, diminfo, srid
)
values (
  'US_RASTERS',
  'GEORASTER.SPATIALEXTENT',
   sdo_dim_array(
     sdo_dim_element('Easting',  1000000, 2000000, 1),
     sdo_dim_element('Northing',  500000,  800000, 1)
   ),
   26943
);
commit;
