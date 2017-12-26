-----------------------------------------------------------------
-- 1. Create and populate the grid table
-----------------------------------------------------------------
DROP TABLE partitioning_grid;

CREATE TABLE partitioning_grid AS
  SELECT id+1 cell_id, geometry cell_geom
  FROM TABLE (
    SELECT SDO_SAM.TILED_BINS(
             MIN(p.location.sdo_point.x),
             MAX(p.location.sdo_point.x),
             MIN(p.location.sdo_point.y),
             MAX(p.location.sdo_point.y),
             2,
             8307
           )
    FROM   yellow_pages p
  );

-----------------------------------------------------------------
-- 2. Create a spatial index on the grid cells
-----------------------------------------------------------------

delete from user_sdo_geom_metadata
  where table_name = 'PARTITIONING_GRID' and column_name = 'CELL_GEOM' ;

insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
values (
  'PARTITIONING_GRID',
  'CELL_GEOM',
  sdo_dim_array (
    sdo_dim_element('x', -180.0, 180.0, 0.1),
    sdo_dim_element('y', -90.0, 90.0, 0.1)
  ),
  8307
);
commit;

drop index partitioning_grid_sidx;
create index partitioning_grid_sidx on partitioning_grid (cell_geom)
  indextype is mdsys.spatial_index;
