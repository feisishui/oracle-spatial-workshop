-----------------------------------------------------------------
-- 1. Create the grid table
-----------------------------------------------------------------
drop table partitioning_grid;

CREATE TABLE partitioning_grid (
  cell_id   NUMBER,
  cell_geom SDO_GEOMETRY
);

-----------------------------------------------------------------
-- 2. Build the grid cells
-----------------------------------------------------------------

declare
  min_x     number;
  min_y     number;
  max_x     number;
  max_y     number;
  x         number;
  y         number;
  step_x    number;
  step_y    number;
  i         number;
begin
  -- Get the area covered by our data
  select min(p.location.sdo_point.x),
         min(p.location.sdo_point.y),
         max(p.location.sdo_point.x),
         max(p.location.sdo_point.y)
  into   min_x, min_y, max_x, max_y
  from yellow_pages p;
  -- Generate the grid
  step_x := (max_x - min_x)/4;
  step_y := (max_y - min_y)/4;
  i := 1;
  x := min_x;
  while x < max_x loop
    y := min_y;
    while y < max_y loop
      -- Build grid cell
      insert into partitioning_grid (cell_id, cell_geom)
      values (
        i,
        sdo_geometry (
          2003, 8307, null,
          sdo_elem_info_array (1, 1003, 3),
          sdo_ordinate_array (x, y, x+step_x, y+step_y)
        )
      );
      i := i + 1;
      y := y + step_y;
    end loop;
    x := x + step_x;
  end loop;
end;
/

-----------------------------------------------------------------
-- 3. Create a spatial index on the grid cells
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
