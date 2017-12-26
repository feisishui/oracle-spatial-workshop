drop index tins_sx;

delete from user_sdo_geom_metadata where table_name in ('TINS');

update tins t
set t.tin.tin_extent =
      sdo_geometry(3008, 32617, null,
        sdo_elem_info_array(1,1007,3),
        sdo_ordinate_array(
          289021, 4320940, 166,
          290106, 4323640, 216
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
     sdo_dim_element('Northing', 4300000,  4400000, 0.05),
     sdo_dim_element('Elevation',    100,      300, 0.05)
   ),
   32617
);
commit;

create index tins_sx
  on tins (tin.tin_extent)
  indextype is mdsys.spatial_index
  parameters ('sdo_indx_dims=3');


