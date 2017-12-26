#!/usr/bin/python

import os
import sys
import Queue
import threading
import subprocess
import time
import logging
import traceback
import cx_Oracle
import imp

"""
/*

NAME:
    load_vectors.py

LAST UPDATE:
    02-May-2016

DESCRIPTION:

  This script loads a set of vector files into an Oracle tables (one file = one table).
  The input files can be of any kind - as long as that kind is understood by GDAL. 
  It does so in parallel in a controled manner: you can choose the number of parallel threads to use.

  1. Parameters
  
  The process is driven by a set of parameters kept in a separate Python file :

    Database connection string (DB_CONNECTION)
    Name of the vector catalog (VECTOR_CATALOG)
    Load parameters (LOAD_PARAMS)
    Number of parallel processes to use (NUM_PROCESSES)
    Name of input file path (VECTOR_DATA)
    File types to load from that path (VECTOR_PATTERN)
    Logging level (LOGGING_LEVEL)
    GDAL-specific settings (debugging, memory, ...) (CPL_DEBUG, GDAL_CACHEMAX)
    Name of the SQL script to create the vector catalog

  The name of the parameter file is passed as a parameter to the command that launches
  the Python script. If no name is given, then the parameters are loaded from a default
  file called "load_vectors_parameters.py".

  No attempt is made to verify the correctness of presence of the parameters. 
  Just make sure they are well-formed and present. 

  2. The vector catalog
  
  The process maintains a status of the loading process in a database table (vector catalog).
  Each row in the table corresponds to one input file and contains the following:

  Unique identifier
  Full path and name of the input file
  Full path and name of the input file
  Type of vector file (derived from the file type)
  Name of vector table
  Timestamp when the load started
  Size (in bytes) of the input file
  Status of the file, as one of: new (not loaded yet), loaded, or failed
  Duration of the load (in seconds)
  Full standard output
  Full error output
  
  3. The overall process is the following:

  Create the vector catalog if it does not exist yet. This is done by executing a SQL script (CREATE_VECTOR_CATALOG.SQL) that exists in the same directory as the present python script.
  Get the full paths and names of the files to process.  
  Note that we recurse in all the sub-directories and process all files whose type matches any of the selected file types.)
  Check each file against the vector catalog.
  If the file does not exist, record it in the catalog with a status 'N', indicating a new file
  to be loaded. 
  If the file already exists, then check its status. 
  If the status is 'L', then the file was correctly loaded, and nothing more needs to be done with that file. 
  If the status is 'F', then the file failed loading and needs to be reprocessed. 

  Load the names if all files to be processed (new and failed) into a queue. 

  Start N threads (where N is the number of processes you choose)

  For each thread:
    Take a file name from the queue
    If that file failed loading, remove the existing partially loaded table
    Construct the load command (ogr2ogr) from the configuration parameters. 
    Execute the command as a sub-process.
    Update the vector catalog with the return code from the sub-process: 'L' (loaded) or 'F' (failed).
    Also add the output of the GDAL command (stdout and stderr).
  
  The main process waits for the queue to become empty, meaning that all files have been processed.
  
  4. Logging: 

  Major steps in the process are logged using Python's logging facility
 
  Event                Level      Information logged
  -------------------- ---------- ------------------------------------------------------
  Thread start         DEBUG      thread
  Thread completion    WARNING    #files processed, GB processed, elapsed time, throughput
  Thread failure       CRITICAL   Exception code and message
  Job start            WARNING    #files to process, GB, source path, destination table, number of RDTs
  Job completion       WARNING    #files processed, GB processed, elapsed time, throughput
  Add file to catalog  DEBUG      file path and name
  GDAL execution       DEBUG      GDAL command line
  Cleanup failed load  DEBUG      Thread, file 
  File load failure    ERROR      Thread, file, error output
  File completion      INFO       Thread, file, result code, size, elapsed
     
  5. How to use:
   
   1) Setup the job parameters in a python file (see file load_vectors_parameters.py 
      for an example). 
      
   2) Run the load:
        
      $ nohup ./load_vectors.py my_parameters.py 2>load_vectors.log &
      
      This will log all the progress messages to the above file and make sure the process 
      does not get killed if the terminal session exits.
   
   3) Monitor progress by tailing the log file
      $ tail -f load_vectors.log
   
   4) You can also check progress by querying the vector catalog table: the status after 
      file load is committed to that table. For example
      
      SELECT STATUS, COUNT(*), ROUND(SUM(FILE_SIZE)/1024/1024/1024,3) GB
      FROM VECTOR_CATALOG
      GROUP BY ROLLUP(STATUS);
      
      which prints this:
      
      STA   COUNT(*)         GB
      --- ---------- ----------
      F            4      1.402
      L           62     10.530
      N          142     25.400
                 208     36.332

      3 rows selected.

      where F, L and N are the counts and total sizes of files that failed, loaded and 
      still to load.
      
   5) If the process is interrupted in any way, just relaunch it and it will resume the 
      loading of all the files still to process, and retry those that failed. Repeat the 
      process until all files are sucessfully loaded, or until the remaining failed 
      loads cannot complete successfully
      
   6) To abort the process, just use CTRL-C. This will abort all active processes and 
      terminate the processing.

CHANGE HISTORY:

  MODIFIED     (DD-MON-YYYY)  DESCRIPTION
  agodfrin      04-May-2016   Automatically create the catalog
  agodfrin      04-May-2016   Always use an explicit target table name (-nln)
  agodfrin      03-May-2016   Created (based on load_vectors.py)
  
TODO:

*/
"""

#----------------------------------------------------------------
# Global variables
#----------------------------------------------------------------

# The file queue
q = Queue.Queue()

# The threads table
threads = []
thread_connections = []
#global thread_processes
thread_processes = []
stop_all_threads = False;

# Sizes and file counts
total_input_files = 0
total_input_bytes = 0

total_bytes = 0
total_files_loaded = 0
total_files_failed = 0

global thread_bytes
thread_bytes = []
global thread_files_loaded
thread_files_loaded = []
global thread_files_failed
thread_files_failed = []

#----------------------------------------------------------------
# Add a new file to the catalog
#----------------------------------------------------------------
def add_to_catalog (file_path, file_name, status):
  logger.debug ("Adding file %s %s to catalog" % (file_path,file_name))
  # How big is that file ?
  file_size = os.path.getsize(os.path.join(file_path, file_name))
  # What kind of file is it ?
  file_type = os.path.splitext(file_name)[1][1:].upper()
  # Table name is the same as the base file name
  table_name = os.path.splitext(file_name)[0].upper()
  cur = con.cursor()
  cur.execute (
    'insert into %s (file_path, file_name, file_size, file_type, status, table_name) '
    'values (:1, :2, :3, :4, :5, :6) ' % (param.VECTOR_CATALOG),
    (file_path, file_name, file_size, file_type, status, table_name)
  )
  cur.close()
  con.commit()

#----------------------------------------------------------------
# Process one vector file
#----------------------------------------------------------------
def process_file(thread, file_path, file_name, status):

  # Get the name of the target table
  table_name = os.path.splitext(file_name)[0].upper()

  # If we are retrying a failed load, then first remove the existing loaded vector
  if status == 'F':
    logger.debug ("[%d] Cleaning out previous failed load for %s %s" % (thread, file_path, file_name))
    cur = thread_connections[thread-1].cursor()
    try:
      cur.execute (
        'drop table %s purge' % (table_name)
      )
    except:
      pass
    # Following strange syntax is because somehow the python Oracle API
    # does not like it when a statement has only one bind variable with more 
    # than one character ...
    cur.execute (
      'delete from user_sdo_geom_metadata where table_name = :1 and table_name = :2',
      (table_name,table_name)
    )
    cur.close()
    thread_connections[thread-1].commit()
    
  # Get size of input file
  bytes = os.path.getsize(os.path.join(file_path, file_name))
    
  # Construct the ogr2ogr command
  ogr_command = (
    'ogr2ogr -f OCI OCI:%s: %s -nln %s %s'
    % 
    ( 
      param.DB_CONNECTION, 
      #table_name,
      os.path.join(file_path, file_name),
      table_name,
      param.LOAD_PARAMS
    )
  )
  logger.debug ("[%d] %s" % (thread,ogr_command))
    
  # Execute it in a sub_process
  start = time.time()
  p = subprocess.Popen(ogr_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  
  # Save process object
  thread_processes[thread-1]=p
  
  # Wait for completion and extract results and return code
  out, err = p.communicate()
  rc = p.returncode 
  end = time.time()
  elapsed = end - start
  
  # Clear process object
  thread_processes[thread-1]=None
  
  # Remove line delimiters from stderr and stdout
  out = out.replace('\n', ' ')
  err = err.replace('\n', ' ')

  # Keep counters and write log progress message
  thread_bytes[thread-1] = thread_bytes[thread-1] + bytes;
  # Watch out: ogr2ogr does not always properly return 1 on failure
  # Success is indicated by rc=0 and err is empty
  if rc == 0 and len(err) == 0:
    thread_files_loaded[thread-1] = thread_files_loaded[thread-1] + 1;
    status = 'L'
    logger.info (
      "[%d] File %s loaded (%.2f MB in %.2f sec) %.2f MB/sec" % 
      (
        thread,
        file_name,
        float(bytes)/1024/1024,
        elapsed,
        float(bytes)/1024/1024/elapsed
      )
    )
  else:
    thread_files_failed[thread-1] = thread_files_failed[thread-1] + 1;
    status = 'F'
    logger.error ('[%d] File %s failed: %s' % (thread, file_name, err))

  # Update the vector catalog  
  cur = thread_connections[thread-1].cursor()
  cur.execute (
    'update %s set '
    ' status=:1, '
    ' load_timestamp=to_timestamp(:2,\'YYYY-MM-DD HH24:MI:SS\'), '  
    ' load_duration=:3, '   
    ' load_output=:4, '     
    ' load_error=:5 '     
    'where file_path=:6 and file_name=:7 '
    % (param.VECTOR_CATALOG),
    (
      status, 
      time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(start)),
      elapsed,
      out,
      err,
      file_path, 
      file_name
    )
  )
  cur.close()
  
  thread_connections[thread-1].commit()

#----------------------------------------------------------------
# Process a set of files from the file queue
#----------------------------------------------------------------
def process_files(t):
  logger.debug ('[%d] Thread started' % (t))
  start = time.time()  
  n = 0
  # Process files
  try:
    while not q.empty() and not stop_all_threads:
      file_path,file_name,status = q.get()
      n = n + 1
      process_file (t, file_path,file_name,status)
      q.task_done()
  # Exception detected
  except Exception as e:
    logger.critical (
      "[%d] Thread aborted with exception: %s %s" % 
      (t,type(e).__name__,str(e))
    )
    logger.debug (
      "Thread %d aborted with traceback: %s" % 
      (t,traceback.format_exc())
    )
  # Successfull completion
  else:
    # Close thread-specific database connection
    thread_connections[t-1].close()
  
    # Log completion message
    end = time.time()
    elapsed = end - start
    if stop_all_threads:
      completion = "stopped"
    else:
      completion = "completed"
    logger.warning (
      '[%d] Thread %s: %.3f GB, %d files in %.2f seconds: %d loaded, %d failed, %.2f MB/sec' % 
      (
        t, 
        completion,
        float(thread_bytes[t-1])/1024/1024/1024,
        thread_files_loaded[t-1]+thread_files_failed[t-1],
        elapsed,
        thread_files_loaded[t-1],
        thread_files_failed[t-1],
        float(thread_bytes[t-1])/1024/1024/elapsed
      )
    )

#----------------------------------------------------------------
# Main process
#----------------------------------------------------------------

# Import parameters

# If no explicit name is passed, use the default parameter file
if len(sys.argv) > 1:
  parameter_file = sys.argv[1]
else:
  parameter_file = 'load_vectors_parameters';
# Find the parameter file
fp, pathname, description = imp.find_module(parameter_file)
# Load it 
param = imp.load_module(parameter_file, fp, pathname, description)


# Get a logger and configure logging.
logger = logging.getLogger('Vector Load')
logging.basicConfig(level=param.LOGGING_LEVEL, format='%(asctime)s %(levelname)-8s %(message)s')

# Setup GDAL-specific parameters
# Enable GDAL tracing if requested
os.environ['CPL_DEBUG'] = param.CPL_DEBUG
# Setup GDAL memory
os.environ['GDAL_CACHEMAX'] = param.GDAL_CACHEMAX

print ('* Using parameter file "%s"' % (parameter_file));
print ('* Loading vectors %s from %s' % (param.VECTOR_PATTERN, param.VECTOR_DATA)) 
print ('* Using %d parallel processes' % (param.NUM_PROCESSES))
print ('* Vector catalog table is %s' % (param.VECTOR_CATALOG))

# Connect to database
con = cx_Oracle.connect(param.DB_CONNECTION)

# Check if catalog exists
cur = con.cursor()
cur.execute(
  'select table_name '
  'from user_tables '
  'where table_name = :1'
  'and table_name = :1',
  (param.VECTOR_CATALOG,param.VECTOR_CATALOG)
)
r = cur.fetchone();
cur.close()

# If catalog does not exist, create it.
if r is None:

  # Get the absolute path of the creation script
  # (it must be in the same directory as the present python script)
  script_path = os.path.abspath(os.path.dirname(sys.argv[0]))

  # Read the table creation script
  with open(os.path.join(script_path, param.CATALOG_CREATION_DDL)) as ddl_file:
    ddl="".join(line.rstrip() for line in ddl_file)
  
  # Create the table (= execute the DDL script)
  cur = con.cursor()
  cur.execute (ddl.rstrip(';'))
  cur.close()
  # Log it
  logger.info (
    'Vector catalog %s successfully created using script "%s"' 
    % (param.VECTOR_CATALOG,param.CATALOG_CREATION_DDL)
  )

# Load names of files to process
for file_path, dirs, file_names in os.walk(param.VECTOR_DATA):
  for file_name in file_names:
    if file_name.endswith(tuple(param.VECTOR_PATTERN)):
      # Check if the file already exists in the catalog
      cur = con.cursor()
      cur.execute(
        'select status '
        'from %s '
        'where file_path = :1 ' 
        'and file_name = :2 '
        % (param.VECTOR_CATALOG),
        (file_path, file_name)
      )
      r = cur.fetchone();
      if r is None :
        # New file, never seen before, add it to the catalog
        status = 'N'
        add_to_catalog (file_path, file_name, status)
      else :
        # File is already in the catalog. Get its status
        status = r[0]
      
      # If file is new or failed loading then enqueue it for processing
      if status in ('N','F') :
         q.put((file_path, file_name, status))
         total_input_bytes = total_input_bytes + os.path.getsize(os.path.join(file_path, file_name))
      
      # Close the cursor
      cur.close()
      con.commit()

total_input_files = q.qsize()

# Close database connection
con.close() 

# Exit right away if nothing do to (no files to load)
if total_input_files == 0:
  print ("All files already loaded - nothing to do")
  exit()

logger.warning (
  "Loading %d files (%.3f GB) from %s in %d processes" 
  % 
  (
    total_input_files,
    float(total_input_bytes)/1024/1024/1024,
    param.VECTOR_DATA,
    param.NUM_PROCESSES
  )
)

# Start the processing threads
start = time.time()
for p in range(1,param.NUM_PROCESSES+1):
  t=threading.Thread(target=process_files, args=(p,))
  threads.append(t)
  thread_connections.append(cx_Oracle.connect(param.DB_CONNECTION))
  thread_processes.append(None)
  thread_bytes.append(0)
  thread_files_loaded.append(0)
  thread_files_failed.append(0)
  t.start()

# Wait for processing to finish
# There are several ways of doing that:
# * Wait for the queue to be empty
#   q.join()
# * Wait for all threads to complete
#   for t in threads:
#     t.join()
# Those methods block and prevent the main thread from receiving the keyboard interrup.
# 
# The better approach is an active loop with sleep that can be interrupted.
 
try:
  # Keep waiting as long as there are active threads
  # NOTE: the count never goes to zero: the main thread is still active!
  while threading.active_count() > 1:
    time.sleep(1)
except KeyboardInterrupt:
  # Handle CTRL-C keyboard interrupt
  print ("\nProcessing stopped\n");
  logger.info ("Processing stopped on user request");
  # Indicate that the threads should all stop
  stop_all_threads=True;
  # Kill all running subprocesses
  for p in thread_processes:
    if p is not None:
      p.kill() 

# Wait for all threads to terminate
for t in threads:
  t.join()

# Get total counts
for p in range(0,param.NUM_PROCESSES):
  total_bytes = total_bytes + thread_bytes[p]
  total_files_loaded = total_files_loaded + thread_files_loaded[p]
  total_files_failed = total_files_failed + thread_files_failed[p]

# Final completion message
end = time.time()
elapsed = end - start
if stop_all_threads:
  completion = "stopped"
else:
  completion = "completed"
logger.warning (
  'Processing %s: %.3f GB, %d files in %.2f seconds: %d loaded, %d failed, %.2f MB/sec' % 
  (
    completion,
    float(total_bytes)/1024/1024/1024,
    total_files_loaded+total_files_failed, 
    elapsed,
    total_files_loaded,
    total_files_failed, 
    float(total_bytes)/1024/1024/elapsed
  )
)

# Warn if queue is not empty:
if not q.empty():
  logger.error (
    'Queue not fully processed. %d files not processed!' % (q.qsize())
  )
