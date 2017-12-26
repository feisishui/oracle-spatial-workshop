--
-- Convert a clipped section into a regular geometry
--

-- Create a table to hold the results
drop table clipped_tins_geom;
create table clipped_tins_geom (
  obj_id        number,
  blk_id        number,
  num_triangles number,
  triangles     sdo_geometry
);

-- Check number of points and triangles extracted
select count(*) num_blocks, sum(num_points) total_points, sum (num_triangles) total_triangles
from   clipped_tins_blocks;

-- Convert the triangles into geometry types
insert into clipped_tins_geom
select  obj_id, blk_id, num_triangles,
        sdo_tin_pkg.to_geometry (
          points,         -- LOB containing the points
          triangles,      -- LOB containing the triangles
          num_points,     -- # of points in the points LOB
          num_triangles,  -- # of triangles in the triangles LOB
          2,              -- Dimensionality of the TIN
          3,              -- Dimensionality of the points in the LOB
          32617           -- SRID for the TIN,
        )
from clipped_tins_blocks;

commit;

--
-- Define spatial metadata for the clip
--
delete from user_sdo_geom_metadata where table_name in ('CLIPPED_TINS_GEOM');

insert into user_sdo_geom_metadata (
  table_name, column_name, diminfo, srid
)
values (
  'CLIPPED_TINS_GEOM',
  'TRIANGLES',
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
drop index clipped_tins_geom_sx;
create index clipped_tins_geom_sx
  on clipped_tins_geom (triangles)
  indextype is mdsys.spatial_index;

