--
-- Define spatial metadata
--

delete from user_sdo_geom_metadata where table_name in ('PC_BLK_01');

insert into user_sdo_geom_metadata (
  table_name, column_name, diminfo, srid
)
values (
  'PC_BLK_01',
  'BLK_EXTENT',
   sdo_dim_array(
     sdo_dim_element('Easting',   200000,   300000, 0.05),
     sdo_dim_element('Northing', 4300000,  4400000, 0.05)
   ),
   32617
);

commit;

--
-- create spatial index
--
drop index pc_blk_01_sx;
create index pc_blk_01_sx
  on pc_blk_01 (blk_extent)
  indextype is mdsys.spatial_index;
