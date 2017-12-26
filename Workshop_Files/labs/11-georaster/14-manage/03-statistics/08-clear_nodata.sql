declare
  v_raster    sdo_georaster;
  
begin

  -- Process rasters in sequence
  for g in (
    select *
    from us_rasters
    order by georid
  )
  loop
    -- Read the raster object (metadata only)
    v_raster := g.georaster;

    -- Clear NODATA from the object level
    sdo_geor.deleteNodata(v_raster, 0, 0);
    sdo_geor.deleteNodata(v_raster, 1, 0);
    sdo_geor.deleteNodata(v_raster, 2, 0);
    sdo_geor.deleteNodata(v_raster, 3, 0);

    -- Update the raster object
    update us_rasters set
      georaster = v_raster
    where georid = g.georid;
    
  end loop;
end;
/
show errors
