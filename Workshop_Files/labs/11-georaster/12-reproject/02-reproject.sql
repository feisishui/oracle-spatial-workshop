-- Reproject the rasters into a new table
declare
  v_raster          sdo_georaster;
  v_raster_trans    sdo_georaster;
  v_start           timestamp;
  v_elapsed         interval day to second;
  v_duration        number;
  v_blocktype       varchar2(10);
  v_blocksize       sdo_number_array;
  v_interleave      varchar2(10);
  v_storage_params  varchar2(256);
  
begin

  -- Process rasters that have not been transformed yet
  for g in (
    select *
    from us_rasters
    where sdo_geor.getmodelSRID(georaster) <> 3857
    order by georid
  )
  loop
    dbms_output.put_line ('Transforming raster '|| g.georid || ' ' || g.source_file);
    
    -- Read the raster object (metadata only)
    v_raster := g.georaster;
    
    -- Create a new raster
    insert into us_rasters_3857 (
      georid, source_file, description, georaster, load_duration, pyramid_duration
    )
    values (
      g.georid, 
      g.source_file,
      g.description,
      sdo_geor.init ('US_RASTERS_3857_RDT_01'),
      g.load_duration,
      g.pyramid_duration
    )
    returning georaster into v_raster_trans;       

    -- Get storage parameters for new raster
    -- They are the same as for the input raster
    v_blocktype := sdo_geor.getblockingtype(v_raster);
    v_blocksize := sdo_geor.getblocksize(v_raster);
    v_interleave := sdo_geor.getinterleavingtype(v_raster);
    v_storage_params := 
      'blocking=' ||
      case v_blocktype 
        when 'REGULAR' then 'true'
        when 'NONE' then 'none'
      end ||
      ', ' ||
      'blocksize=(' || v_blocksize(1) || ',' || v_blocksize(2) || ',' || v_blocksize(3) || '), ' ||
      'interleaving='||v_interleave;
    
    -- Transform the raster
    v_start := current_timestamp;
    sdo_geor.reproject(
      inGeoRaster    => v_raster,
      resampleParam  => 'resampling=NN',
      storageParam   => v_storage_params,
      outSRID        => 3857,
      outGeoraster   => v_raster_trans
    );
    v_elapsed := current_timestamp - v_start;
    v_duration := 
      extract (hour from v_elapsed * 36000) + 
      extract (minute from v_elapsed) * 60 + 
      extract (second from v_elapsed);
    
    -- Compute new spatial extent
    v_raster_trans.spatialextent := sdo_geor.generatespatialextent(v_raster_trans);  

    -- Update the new raster object
    update us_rasters_3857 set
      georaster = v_raster_trans,
      transform_duration = v_duration
    where georid = g.georid;

    -- Commit and continue with next one.
    commit;
    dbms_output.put_line ('Transforming raster '|| g.georid || ' completed in ' ||  v_duration || ' seconds');
    
  end loop;
end;
/
show errors
