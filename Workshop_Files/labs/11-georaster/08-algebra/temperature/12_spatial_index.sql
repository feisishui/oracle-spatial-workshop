--------------------------------------------------------------------------------
-- Create spatial index
--------------------------------------------------------------------------------

-- Setup spatial metadata
delete from user_sdo_geom_metadata where table_name = 'TEMPERATURE_TABLE';
insert into user_sdo_geom_metadata(table_name, column_name, diminfo, SRID)
values (
  'TEMPERATURE',
  'RASTER.SPATIALEXTENT',
  sdo_dim_array(
    sdo_dim_element('X', -180, 180, 0.5),
    sdo_dim_element('Y',  -90,  90, 0.5)
  ), 
  4326
);
commit;

-- Create the spatial index
drop index TEMPERATURE_idx;
create index TEMPERATURE_idx on TEMPERATURE_table (RASTER.spatialextent) indextype is mdsys.spatial_index;

