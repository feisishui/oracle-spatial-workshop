Using the geocoder in parallel
==============================

To use the geocoder in parallel, we will use a pipelined function. A pipelined function
returns multiple results in a table/array structure, but produces them as they become
available. Pipelined functions can run in parallel, based on the degree or parallelism 
chosen by the user.

Because of the nature of pipelined functions (they return a continuous stream of results)
those results are written into a separate table. 


1) Prepare the environement for the test
----------------------------------------

01_TEST_SETUP.SQL

This script extracts the 15000 POIs from the US geocoding data set into a separate table
called ADDRESSES. It also creates a table called GC_RESULTS that will receive the results 
of the geocoding.

The two tables are connectd by the ID column, a unique identifier for each address to process

2) Define types
---------------

02_TYPES_GEOCODE_PIPELINED.SQL

This script defines the two object types needed by the pipelined function:

GC_RESULT holds the result of one geocode operation
GC_RESULT_TABLE is a table of results

3) Define the pipelined function
--------------------------------

03_FUNC_GEOCODE_PIPELINED.SQL

This defines function GEOCODE_PIPELINED. See its code for details

4) Perform the geocoding
------------------------

04_GEOCODE_PARALLEL.SQL

This SQL statement invokes the GEOCODE_PIPELINED function and writes the results into 
the GC_RESULTS table.

You can modify the degree of parallelism used by changing the PARALLEL(n) hint in the 
SELECT statement.

Typical results on a Core i7 (dual core);
  Noparallel:  Elapsed: 00:03:32.95 for 15122 addresses =  71/second
  Parallel(2): Elapsed: 00:01:43.61 for 15122 addresses = 145/second

5) Check the results
--------------------

05_CHECK_RESULTS.SQL

This script produces a summary of results by accuracy code.

6) Define the pipelined function for reverse geocoding
--------------------------------

06_FUNC_REVERSE_GEOCODE_PIPELINED.SQL

This function is similar to the REVERSE_GEOCODE_PIPELINED, except that it performs
reverse geocodes.

7) Perform the reverse geocoding
--------------------------------

07_REVERSE_GEOCODE_PARALLEL.SQL

Similar to the GEOCODE_PARALLEL.SQL script.

Typical results on a Core i7 (dual core);
  Noparallel:  Elapsed: 00:03:08.09 for 15122 points =  80/second
  Parallel(2): Elapsed: 00:01:53.26 for 15122 points = 153/second
