col job_name for a20
-- Check the results of the current running and completed jobs
select job_name, status, actual_start_date, run_duration, output, errors 
from user_scheduler_job_run_details
where job_name like 'PYRAMID_%'
order by job_name;
