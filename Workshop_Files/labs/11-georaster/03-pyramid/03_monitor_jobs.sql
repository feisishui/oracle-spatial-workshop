-- Check the current state of the running jobs
select job_name, job_action, state, last_start_date, last_run_duration 
from user_scheduler_jobs
where job_name like 'PYRAMID_%'
order by last_start_date;


