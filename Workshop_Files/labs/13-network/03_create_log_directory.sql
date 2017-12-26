-- Create the directory for the log produced when partitioning
--
-- NOTES:
--   Make sure to first grant the CREATE ANY DIRECTORY right to the executing user!
--   Change the file specification below to match your environment

CREATE OR REPLACE DIRECTORY net_log_dir AS 'D:\Courses\Spatial11g-Workshop\labs\13-Network';

