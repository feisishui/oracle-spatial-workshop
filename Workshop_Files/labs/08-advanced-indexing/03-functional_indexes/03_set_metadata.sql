-- Setup spatial metadata for the function-based index
delete from user_sdo_geom_metadata
  where table_name = 'US_CITIES_XY';
  
-- IMPORTANT: The column expression must NOT contain any SPACES
-- If not: ORA-13199: wrong column name: ...
insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
values (
  'US_CITIES_XY', 
  'SCOTT.GET_POINT(LONGITUDE,LATITUDE)',
  sdo_dim_array (
    sdo_dim_element('long', -180.0, 180.0, 0.5),
    sdo_dim_element('lat', -90.0, 90.0, 0.5)
  ),
  8307
);
commit;
