--
-- Split the 3D surface into individual faces.
--

drop table clipped_tins_geom_split;
create table clipped_tins_geom_split (
  obj_id        number,
  blk_id        number,
  triangle_id   number,
  triangle      sdo_geometry
);

insert into clipped_tins_geom_split
select obj_id, blk_id, element_id, element_geom
from clipped_tins_geom, table (get_elements (triangles));

commit;

--
-- Define spatial metadata for the clip
--
delete from user_sdo_geom_metadata where table_name in ('CLIPPED_TINS_GEOM_SPLIT');

insert into user_sdo_geom_metadata (
  table_name, column_name, diminfo, srid
)
values (
  'CLIPPED_TINS_GEOM_SPLIT',
  'TRIANGLE',
   sdo_dim_array(
     sdo_dim_element('Easting',   200000,   300000, 0.05),
     sdo_dim_element('Northing', 4300000,  4400000, 0.05),
     sdo_dim_element('Elevation', -10000,    10000, 0.05)
   ),
   32617
);
commit;

--
-- create spatial index
--
drop index clipped_tins_geom_split_sx;
create index clipped_tins_geom_split_sx
  on clipped_tins_geom_split (triangle)
  indextype is mdsys.spatial_index;
