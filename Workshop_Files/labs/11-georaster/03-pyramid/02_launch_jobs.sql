-- WARNING: to do this, you need the CREATE JOB privilege!
declare
 NUM_JOBS             number := 5;
 first_raster_id      number;
 last_raster_id       number;
 num_rasters          number;
 from_raster_id       number;
 to_raster_id         number;
 num_rasters_per_job  number;
begin

  -- Get the number of rasters to process
  select min(georid), max(georid), count(*)
  into first_raster_id, last_raster_id, num_rasters
  from us_rasters;
  
  first_raster_id := 1276;
  last_raster_id := 67890;
  num_rasters := 51205;
  
  num_rasters_per_job := ceil((last_raster_id - first_raster_id +1)/NUM_JOBS);
  
  dbms_output.put_line('Number of jobs:    '||NUM_JOBS);
  dbms_output.put_line('First raster id:   '||first_raster_id);
  dbms_output.put_line('Last raster id:    '||last_raster_id);
  dbms_output.put_line('Number of rasters: '||num_rasters);  
  dbms_output.put_line('Rasters per job:   '||num_rasters_per_job);
  
  -- Generate the jobs
  from_raster_id := first_raster_id;
  for i in 1..NUM_JOBS loop
    to_raster_id := from_raster_id + num_rasters_per_job -1;
    dbms_output.put_line ('Launching job '||i||': rasters between '||
      from_raster_id ||' and '|| to_raster_id
    ); 
    dbms_scheduler.create_job ( 
      job_name    => 'PYRAMID_'||i,
      job_type    => 'PLSQL_BLOCK',
      job_action  => 'BEGIN GENERATE_PYRAMID('||
         from_raster_id||','|| to_raster_id||
      '); END;',
      enabled     => TRUE
    );
    from_raster_id := to_raster_id + 1;
    
  end loop;
  
end;
/

