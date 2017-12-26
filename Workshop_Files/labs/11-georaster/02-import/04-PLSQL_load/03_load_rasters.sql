declare
  v_raster              sdo_georaster;
  v_start               timestamp;
  v_elapsed             interval day to second;
  v_load_duration       number;
  v_pyramid_duration    number;
  -- ***** Modify this to match your environment:
  -- FILE_BASE             varchar2(80) := 'D:\Courses\Spatial11g-Workshop\data\11-georaster\tiff'; -- Windows
  FILE_BASE             varchar2(80) := '/media/sf_Spatial-Workshop/data/11-georaster/tiff';     -- Linux
  -- *****
begin

  for c in (
    select * from us_rasters
    where georaster is null
    order by georid
  )
  loop

    -- Initialize the raster object
    v_raster := sdo_geor.init ('US_RASTERS_RDT_01', c.georid);

    -- Save the raster object
    update us_rasters
    set georaster = v_raster
    where georid = c.georid;

    -- Import the raster
    v_start := current_timestamp;
    sdo_geor.importFrom(
      v_raster,
      'blocking=true blocksize=(512,512,3)',
      'TIFF',
      'file',
      FILE_BASE || '/' || c.source_file,
      'WORLDFILE',
      'file',
      FILE_BASE || '/' || replace (c.source_file, '.tif','.tfw')
    );
    v_elapsed := current_timestamp - v_start;
    v_load_duration := extract (minute from v_elapsed) * 60 + extract (second from v_elapsed);

    -- Setup SRID
    sdo_geor.setModelSRID(v_raster, 26943);

    -- Setup the spatial extent in ground coordinates
    v_raster.spatialExtent := sdo_geor.generateSpatialExtent(v_raster);

    -- Generate resolution pyramid
    v_start := current_timestamp;
    sdo_geor.generatePyramid(v_raster, 'resampling=NN');
    v_elapsed := current_timestamp - v_start;
    v_pyramid_duration := extract (minute from v_elapsed) * 60 + extract (second from v_elapsed);

    -- Update the raster object
    update us_rasters set
      georaster = v_raster,
      load_duration = v_load_duration,
      pyramid_duration = v_pyramid_duration
    where georid = c.georid;

    commit;

  end loop;
end;
/
