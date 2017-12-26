--
-- Define spatial metadata for TIN extents
--

delete from user_sdo_geom_metadata where table_name in ('TINS');

insert into user_sdo_geom_metadata (
  table_name, column_name, diminfo, srid
)
values (
  'TINS',
  'TIN.TIN_EXTENT',
   sdo_dim_array(
     sdo_dim_element('Easting',   200000,   300000, 0.05),
     sdo_dim_element('Northing', 4300000,  4400000, 0.05),
     sdo_dim_element('Elevation',    100,      300, 0.05)
   ),
   32617
);
commit;

--
-- create spatial index for TIN extents
--
drop index tins_sx;
create index tins_sx
  on tins (tin.tin_extent)
  indextype is mdsys.spatial_index
  parameters ('sdo_indx_dims=3');

/*
--
-- Define spatial metadata for TIN block extents
--

delete from user_sdo_geom_metadata where table_name in ('TIN_BLK_01');

insert into user_sdo_geom_metadata (
  table_name, column_name, diminfo, srid
)
values (
  'TIN_BLK_01',
  'BLK_EXTENT',
   sdo_dim_array(
     sdo_dim_element('Easting',   200000,   300000, 0.05),
     sdo_dim_element('Northing', 4300000,  4400000, 0.05),
     sdo_dim_element('Elevation',    100,      300, 0.05)
   ),
   32617
);

drop index tin_blk_01_sx;
create index tin_blk_01_sx
  on tin_blk_01 (blk_extent)
  indextype is mdsys.spatial_index
  parameters ('sdo_indx_dims=3');

*/