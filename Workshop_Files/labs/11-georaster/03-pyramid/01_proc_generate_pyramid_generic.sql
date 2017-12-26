create or replace procedure generate_pyramid (
  table_name varchar2,
  id_column varchar2 default 'GEORID',
  raster_column varchar2 default 'GEORASTER',
  start_id number default 0,
  end_id number default 2147483647
)
is
  v_raster sdo_georaster;
begin
  for g in (
    execute immediate 
    'select '||id_column||','||raster_column||
    ' from '||table_name||
    ' where sdo_geor.getpyramidmaxlevel('||raster_column||') = 0'||
    |'and georid between :start_id and :end_id'
    
  )
  loop
    v_raster := g.georaster;

    -- Generate resolution pyramid
    sdo_geor.generatePyramid(v_raster, 'resampling=NN');

    -- Update the raster object
    update us_rasters set
      georaster = v_raster
    where georid = g.georid;
    
  end loop;
end;
/
show errors
