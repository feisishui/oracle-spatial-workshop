Using the geocoder in parallel
==============================

This presents another way of using the geocoder in parallel. This time we will run
multiple concurrent jobs, each one processing a slice of the input table. We will use the
Oracle scheduler (DMBS_SCHEDULER) to run those jobs.

The result of each geocoding is updated in the input table: there is no need for a separate
table to hold the results.


1) Prepare the environement for the test
----------------------------------------

01_TEST_SETUP.SQL

This script extracts the 15000 POIs from the US geocoding data set into a separate table
called ADDRESSES. 

2) Define the geocoding procedure
---------------------------------

02_PROC_GEOCODE.SQL

This procedure is invoked with two arguments that defines the range of addresses to geocode,
using their identifiers: the input address table is built in such a way that each address 
has a unique numeric identifier, and all the identifiers are numbered in a continuous 
sequence (from 1 to 15000).

3) Launch the jobs
------------------

03_LAUNCH_JOBS.SQL

This script uses DBMS_SCHEDULER.CREATE_JOB to launch as many jobs as needed. Each job 
invokes the procedure GEOCODE on a range of address identifiers. The ranges are computed
dynamically based on the number of jobs you want to run.

Change variable NUM_JOBS to change the number of jobs.

4) Monitor the running jobs
---------------------------

04_MONITOR_JOBS.SQL

This checks the status of the jobs in USER_SCHEDULER_JOBS which logs all pending and
and running jobs.


5) Check completed jobs
-----------------------

05_CHECK_COMPLETED_JOBS.SQL

This script checks the results of the jobs (success, failures, ...) from USER_SCHEDULER_JOB_RUN_DETAILS
