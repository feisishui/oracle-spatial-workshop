declare
  i integer;
  k integer;
begin
  k := 1;
  for p in (
    select p.point_cloud.pc_id pc_id, p.point_cloud.pc_extent.sdo_srid sdo_srid,
           p.point_cloud.pc_tot_dimensions pc_tot_dimensions
    from lidar_scenes p
    where id=1
  )
  loop
    for b in (
      select blk_id,
             sdo_pc_pkg.to_geometry (
               points,              -- PTS = LOB containing the points
               num_points,          -- NUM_PTS = # of points in the LOB
               p.pc_tot_dimensions, -- PC_TOT_DIM = Total dimensionality of the points in the LOB
               p.sdo_srid           -- SRID for the output
             ) points
      from pc_blk_01
      where obj_id = p.pc_id
    )
    loop
      dbms_output.put_line (p.pc_id || ' ' || b.blk_id);
      i := 0;
      while i < b.points.sdo_ordinates.count
      loop
        insert into input_points (rid, val_d1, val_d2, val_d3)
        values (
          k,
          b.points.sdo_ordinates(i+1),
          b.points.sdo_ordinates(i+2),
          b.points.sdo_ordinates(i+3)
        );
        k := k + 1;
        i := i + p.pc_tot_dimensions;
      end loop;
    end loop;

  end loop;
end;
/

commit;
