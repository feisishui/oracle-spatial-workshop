--
-- Convert a clipped section into a regular geometry
--

-- Create a table to hold the results
drop table clipped_lidar_scenes_geom;
create table clipped_lidar_scenes_geom (
  obj_id        number,
  blk_id        number,
  num_points    number,
  points        sdo_geometry
);

-- Check number of points extracted
select count(*) num_blocks, sum(num_points) total_points
from   clipped_lidar_scenes_blocks;

-- Convert the points into geometry types
insert into clipped_lidar_scenes_geom
select  obj_id, blk_id, num_points,
        sdo_pc_pkg.to_geometry (
          points,     -- PTS = LOB containing the points
          num_points, -- NUM_PTS = # of points in the LOB
          5,          -- PC_TOT_DIM = Total dimensionality of the points in the LOB
          32617       -- SRID for the point cloud,
        )
from clipped_lidar_scenes_blocks
where num_points > 0;
commit;
