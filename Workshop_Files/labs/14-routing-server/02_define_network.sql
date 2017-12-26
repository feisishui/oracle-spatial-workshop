-- NOTE: the user must have the rights to create and drop directories, for example: 
-- GRANT CREATE ANY DIRECTORY TO SCOTT;
-- GRANT DROP ANY DIRECTORY TO SCOTT;

-- Create the directory that will receive the log file (Change the file specifications below to match your environment)
CREATE OR REPLACE DIRECTORY sdo_router_log_dir AS '/tmp';

-- Create the network
EXECUTE SDO_ROUTER_PARTITION.CREATE_ROUTER_NETWORK('define_network.log', 'route_sf');

-- Remove the directory
DROP DIRECTORY sdo_router_log_dir ;
