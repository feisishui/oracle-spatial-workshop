NAME:
    load_rasters.py

LAST UPDATE:
    04-May-2016

DESCRIPTION:

  This script loads a set of raster files into an Oracle georaster table. 
  It does so in parallel in a controled manner: you can choose the number of parallel threads to use.

  1. Parameters
  
  The process is driven by a set of parameters kept in a separate Python file :

    Database connection string (DB_CONNECTION)
    Name of the raster catalog (RASTER_CATALOG)
    Name of the raster table (and column) to load into (RASTER_TABLE and RASTER_COLUMN)
    Pattern of the rdt names (they are assumed to be named <raster_table>_RDT_<nn>) (RDT_PATTERN)
    Number of rdts to use (NUM_RDTS)
    Load parameters (blocksize, etc) (LOAD_PARAMS)
    Number of parallel processes to use (NUM_PROCESSES)
    Name of input file path (RASTER_DATA)
    File types to load from that path (RASTER_PATTERN)
    Logging level (LOGGING_LEVEL)
    GDAL-specific settings (debugging, memory, ...) (CPL_DEBUG, GDAL_CACHEMAX)

  The name of the parameter file is passed as a parameter to the command that launches
  the Python script. If no name is given, then the parameters are loaded from a default
  file called "load_rasters_parameters.py".
  
  No attempt is made to verify the correctness of presence of the parameters. 
  Just make sure they are well-formed and present. 

  2. The raster catalog
  
  The process maintains a status of the loading process in a database table (raster catalog).
  Each row in the table corresponds to one raster file and contains the following:
  
    Unique identifier (automatically generated sequential number)
    Full path and name of the raster file
    The full time stamp when the loading of that file started
    Full path and name of the raster file
    Type of raster (derived from the file type)
    Name of raster table
    Timestamp when the load started
    Size (in bytes) of the input raster file
    Status of the file, as one of: new (not loaded yet), loaded, or failed
    Duration of the load (in seconds)
    Name of the RDT table used
    Raster ID in the RDT table
    Full standard output
    Full error output

  
  3. The overall process is the following:

  Create the raster catalog if it does not exist yet. This is done by executing a SQL script (CREATE_RASTER_CATALOG.SQL) that exists in the same directory as the present python script.
  Get the full paths and names of the files to process.  
  Note that we recurse in all the sub-directories and process all files whose type matches any of the selected file types.)
  Check each file against the raster catalog.
  If the file does not exist, record it in the catalog with a status 'N', indicating a new file
  to be loaded. 
  If the file already exists, then check its status. 
  If the status is 'L', then the raster was correctly loaded, and nothing more needs to be done with that file. 
  If the status is 'F', then the raster failed loading and needs to be reprocessed. 

  Load the names if all files to be processed (new and failed) into a queue. 

  Start N threads (where N is the number of processes you choose)

  For each thread:
    Take a file name from the queue
    If that file failed loading, remove the existing partially loaded raster
    Choose an RDT (distribute the files to the available RDTs in a round-robin fashion).
    Construct the load command (gdal_translate) from the configuration parameters. 
    Execute the command as a sub-process.
    Update the raster catalog with the return code from the sub-process: 'L' (loaded) or 'F' (failed).
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
  
  5. Output tables:
  
  The process expects the destination raster table(s) to have the following structure:

  CREATE TABLE US_RASTERS (
    GEORID              NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    FILE_PATH           VARCHAR2(256),
    FILE_NAME           VARCHAR2(80),
    GEORASTER           SDO_GEORASTER,
    IMPORT_DATE         TIMESTAMP WITH LOCAL TIME ZONE,
    UNIQUE (FILE_PATH,FILE_NAME)
  );

  Note that:
  - the unique identifier (GEORID) is automatically generated.
  - the file path and name are unique. This prevents the same file to be loaded twice.
  - the table can contain any other attributes in any sequence.
  
  6. How to use:
   
   1) Setup the job parameters in a python file (see file load_rasters_parameters.py 
      for an example). 
      
   2) Run the load:
        
      $ nohup ./load_rasters.py my_parameters.py 2>load_rasters.log &
      
      This will log all the progress messages to the above file and make sure the process 
      does not get killed if the terminal session exits.
   
   3) Monitor progress by tailing the log file
      $ tail -f load_rasters.log
   
   4) You can also check progress by querying the raster catalog table: the status after 
      file load is committed to that table. For example
      
      SELECT STATUS, COUNT(*), ROUND(SUM(FILE_SIZE)/1024/1024/1024,3) GB
      FROM RASTER_CATALOG
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
  agodfrin      04-May-2016   Use dynamic parameters
  agodfrin      03-May-2016   Allow processing to be aborted with CTRL-C
  agodfrin      03-May-2016   Standardize format of log messages
  agodfrin      03-May-2016   Add exception handling so that failed threads terminate gracefully
  agodfrin      03-May-2016   Wait for all threads to finish (not just for the queue to be depleted)
  agodfrin      03-May-2016   Use random RDT distribution instead of round-robin
  agodfrin      21-Apr-2016   Log (debug) cleanups
  agodfrin      21-Apr-2016   Cleanup failed loads before retrying
  agodfrin      18-Apr-2016   Adjust RDT allocation to start at 1 for each thread
  agodfrin      18-Apr-2016   Include raster table name when filling catalog
  agodfrin      13-Apr-2016   Also update IMPORT_DATE timestamp in raster table
  agodfrin		  12-Apr-2016   Restructured logging messages and severity levels
  agodfrin		  12-Apr-2016   Updating of raster catalog
  agodfrin		  11-Apr-2016   Implemented raster catalog (removed csv log)
  agodfrin      10-Apr-2016   Decoding gdal-translate output (stderr/stdout)
  agodfrin      09-Apr-2016   Use Python queues and multithreading
  agodfrin      09-Apr-2016   Created
  
TODO:
  - add pyramiding ? Just add the proper -co option to the parameters
  
REQUIREMENTS:

  This script needs the cx_oracle package for using the Oracle database
  The simplest is to install it using easy_install:
  
    sudo env ORACLE_HOME=$ORACLE_HOME easy_install cx_oracle
  
  Confirm that it works by running the following Python script:

    #!/usr/bin/python
    import cx_Oracle
    con = cx_Oracle.connect('scott/tiger@localhost:1521/orcl121')
    print con.version
    con.close()
