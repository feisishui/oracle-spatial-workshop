declare
  v_pc          sdo_pc;
  v_pc_extent   sdo_geometry;
  v_contours    sdo_geometry_array := new sdo_geometry_array();
  v_elevations  sdo_ordinate_array := new sdo_ordinate_array();
  v_min_z       number;
  v_max_z       number;
  i             integer;
  j             integer;
begin

  for t in (select * from lidar_scenes order by id)
  loop
  
    -- Get the PC object
    v_pc := t.point_cloud;
     
    -- Get the extent of the point cloud
    if v_pc.pc_extent.sdo_gtype = 2003 then
      -- The extent is 2D. Use it with hard coded range of elevations
      v_pc_extent := v_pc.pc_extent;
      v_min_z := 166; 
      v_max_z := 215; 
    else 
      -- Extract 2D extent from the 3D extent
      v_pc_extent := sdo_geometry (
        2003, 
        v_pc.pc_extent.sdo_srid,
        null,
        sdo_elem_info_array (1,1003,3),
        sdo_ordinate_array (
          v_pc.pc_extent.sdo_ordinates(1), -- Min X
          v_pc.pc_extent.sdo_ordinates(2), -- Min Y
          v_pc.pc_extent.sdo_ordinates(4), -- Max X
          v_pc.pc_extent.sdo_ordinates(5)  -- Max Y
        )
      );
      -- Get the minimum and maximum elevations in this point cloud
      -- rounded to the next meter
      v_min_z := ceil(v_pc.pc_extent.sdo_ordinates(3)); 
      v_max_z := floor(v_pc.pc_extent.sdo_ordinates(6));
    end if;
    
    -- Generate the list of elevations we want in 1m steps
    v_elevations.extend(v_max_z - v_min_z + 1);
    j := 1;
    for i in v_min_z..v_max_z loop
      v_elevations (j) := i;
      j := j + 1;
    end loop;
    
    
    dbms_output.put_line('V_PC_EXTENT='||sdo_tools.format(v_pc_extent));
    dbms_output.put_line('AREA='||sdo_geom.sdo_area(v_pc_extent,0.5)||' M2');
    for i in 1..v_elevations.count loop
      dbms_output.put_line ('V_ELEVATIONS ('||i||') = '||v_elevations (i));
    end loop;
        
    -- Generate the contours from the point cloud
    v_contours := sdo_pc_pkg.create_contour_geometries(
      pc                  => v_pc,
      sampling_resolution => 5,
      elevations          => v_elevations,
      region              => v_pc_extent
    );
     
    -- Write the contours
    for i in 1..v_contours.count loop
      insert into contours (id, elevation, contour)
      values (
        i,
        v_elevations (i),
        v_contours (i)
      );
    end loop;
   
  end loop;
end;
/
