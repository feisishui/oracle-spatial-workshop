-- WARNING: to do this, you need the CREATE JOB privilege!
declare
 NUM_JOBS number := 4;
 num_addresses_per_job number;
begin

  -- Get the number of addresses per job
  select ceil(count(*)/NUM_JOBS) 
  into num_addresses_per_job 
  from addresses;
  
  -- Generate the jobs
  for i in 1..num_jobs loop
    dbms_output.put_line ('Launching job '||i||': addresses between '||
      ((i-1)*num_addresses_per_job+1)||' and '||
      ((i)*num_addresses_per_job)
    ); 
    dbms_scheduler.create_job ( 
      job_name    => 'GEOCODE_'||i,
      job_type    => 'PLSQL_BLOCK',
      job_action  => 'BEGIN GEOCODE('||
         ((i-1)*num_addresses_per_job+1)||','||
         ((i)*num_addresses_per_job)||
      '); END;',
      enabled     => TRUE
    );
  end loop;
  
end;
/

