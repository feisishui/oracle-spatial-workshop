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

    -- Add NODATA at the object level (the same value gets applied to all layers)
    sdo_geor.addNodata(v_raster, 0, 0);

    -- Update the raster object
    update us_rasters set
      georaster = v_raster
    where georid = g.georid;

  end loop;
end;
/
show errors
