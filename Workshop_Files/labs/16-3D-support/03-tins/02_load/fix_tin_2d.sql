-- Fix tin extent
drop index tins_sx;

delete from user_sdo_geom_metadata where table_name in ('TINS');

update tins t
set t.tin.tin_extent =
      sdo_geometry(2003, 32617, null,
        sdo_elem_info_array(1,1003,3),
        sdo_ordinate_array(
          289021, 4320940,
          290106, 4323640
        )
      );
commit;

insert into user_sdo_geom_metadata (
  table_name, column_name, diminfo, srid
)
values (
  'TINS',
  'TIN.TIN_EXTENT',
   sdo_dim_array(
     sdo_dim_element('Easting',   200000,   300000, 0.05),
     sdo_dim_element('Northing', 4300000,  4400000, 0.05)
   ),
   32617
);
commit;

create index tins_sx
  on tins (tin.tin_extent)
  indextype is mdsys.spatial_index;

-- Fix tin block extents
drop index MDTNIX_1_2B16E$$$;
drop index tin_blk_01_sx;

delete from user_sdo_geom_metadata where table_name in ('TIN_BLK_01');

update tin_blk_01
set blk_extent = sdo_cs.make_2d(blk_extent);
commit;

insert into user_sdo_geom_metadata (
  table_name, column_name, diminfo, srid
)
values (
  'TIN_BLK_01',
  'BLK_EXTENT',
   sdo_dim_array(
     sdo_dim_element('Easting',   200000,   300000, 0.05),
     sdo_dim_element('Northing', 4300000,  4400000, 0.05)
   ),
   32617
);
commit;

create index tin_blk_01_sx
  on tin_blk_01 (blk_extent)
  indextype is mdsys.spatial_index;
