--
-- Initialize the point cloud object
--
insert into lidar_scenes (id, point_cloud)
values (
  101,
  sdo_pc_pkg.init (
    basetable          =>   'LIDAR_SCENES',
    basecol            =>   'POINT_CLOUD',
    blktable           =>   'PC_BLK_01',
    ptn_params         =>   'BLK_CAPACITY=10000',
    pc_tol             =>   0.5,
    pc_tot_dimensions  =>   3,
    pc_extent          =>   sdo_geometry(2003, 32617, null,
                              sdo_elem_info_array(1, 1003, 3),
                              sdo_ordinate_array(289021, 4320940, 290106, 4323640)
                            )
  )
);

--
-- Load the point cloud from the point table
-- WARNING: this takes some 2 minutes to complete!
-- Note that this creates a spatial index on the blocks table.
--
declare
  pc sdo_pc;
begin
  -- Read PC metadara
  select point_cloud into pc
  from lidar_scenes where id = 101;
  -- Load the point cloud
  sdo_pc_pkg.create_pc (pc, 'input_points');
end;
/
commit;
