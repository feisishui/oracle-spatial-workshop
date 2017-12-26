----------------------------------------------------------------------------
-- BUILDING_FOOTPRINTS: 2D
----------------------------------------------------------------------------
delete from user_sdo_geom_metadata where table_name  = 'BUILDING_FOOTPRINTS';
insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
values (
  'BUILDING_FOOTPRINTS',
  'GEOM',
  sdo_dim_array (
    sdo_dim_element ('Easting',  0, 1000000, 0.05),
    sdo_dim_element ('Northing', 0, 1000000, 0.05)
  ),
  27700
);
drop index building_footprints_sx;
create index building_footprints_sx on building_footprints (geom)
  indextype is mdsys.spatial_index;

----------------------------------------------------------------------------
-- BUILDINGS_EXT: 3D
----------------------------------------------------------------------------
delete from user_sdo_geom_metadata where table_name  = 'BUILDINGS_EXT';
insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
values (
  'BUILDINGS_EXT',
  'GEOM',
  sdo_dim_array (
    sdo_dim_element ('Easting',   0, 1000000, 0.05),
    sdo_dim_element ('Northing',  0, 1000000, 0.05),
    sdo_dim_element ('Elevation', 0, 1000, 0.05)
  ),
  7405
);
drop index buildings_ext_sx;
create index buildings_ext_sx on buildings_ext (geom)
  indextype is mdsys.spatial_index
  parameters ('sdo_indx_dims=3');

----------------------------------------------------------------------------
-- BUILDINGS: 3D
----------------------------------------------------------------------------
delete from user_sdo_geom_metadata where table_name  = 'BUILDINGS';
insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
values (
  'BUILDINGS',
  'GEOM',
  sdo_dim_array (
    sdo_dim_element ('Easting',   0, 1000000, 0.05),
    sdo_dim_element ('Northing',  0, 1000000, 0.05),
    sdo_dim_element ('Elevation', 0, 1000, 0.05)
  ),
  7405
);

drop index buildings_sx;
create index buildings_sx on buildings (geom)
  indextype is mdsys.spatial_index
  parameters ('sdo_indx_dims=3');
