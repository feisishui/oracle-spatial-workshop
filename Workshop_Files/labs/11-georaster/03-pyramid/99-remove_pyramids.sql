declare
  v_raster    sdo_georaster;
  
begin

  -- Process rasters that have a pyramid
  for g in (
    select *
    from us_rasters
    where sdo_geor.getpyramidtype(georaster) <> 'NONE'
    order by georid
  )
  loop

    -- Read the raster object (metadata only)
    v_raster := g.georaster;

    -- Clear resolution pyramid
    sdo_geor.deletePyramid(v_raster);

    -- Update the raster object
    update us_rasters set
      georaster = v_raster,
      pyramid_duration = null
    where georid = g.georid;

    -- Commit and continue with next one.
    commit;
    dbms_output.put_line ('Pyramid cleared from raster '|| g.georid);
    
  end loop;
end;
/
show errors
