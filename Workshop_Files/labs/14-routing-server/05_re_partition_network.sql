-----------------------------------------------------------------------
-- Step 1: Grant rights to the user that runs the partitioning
--
-- Must connect as SYS or SYSTEM to run this
-- Change the file specifications below to match your environment
-----------------------------------------------------------------------

connect system

-- Create the directory that will receive the log file produced by the partitioning code
CREATE OR REPLACE DIRECTORY sdo_router_log_dir AS 'D:\Courses\Spatial11g-Workshop\labs\14-routing-server';

-- Grant access to the user that will perform the partitioning
GRANT READ, WRITE ON DIRECTORY sdo_router_log_dir TO scott;

-- Grant SCOTT the right to write to the log file:
call dbms_java.grant_permission( 'SCOTT', 'SYS:java.io.FilePermission', 'D:\Courses\Spatial11g-Workshop\labs\14-routing-server\sdo_router_partition.log', 'write' );

-- Also grant MDSYS the right to write to the log file:
call dbms_java.grant_permission( 'MDSYS', 'SYS:java.io.FilePermission', 'D:\Courses\Spatial11g-Workshop\labs\14-routing-server\sdo_router_partition.log', 'write' );
 
-----------------------------------------------------------------------
-- Step 2: Perform the partitioning
-----------------------------------------------------------------------

connect scott/tiger

-- Show existing partitioning
select partition_id, count(*)
from node
group by partition_id
order by partition_id;

select partition_id, count(*)
from edge
group by partition_id
order by partition_id;

select partition_id, num_nodes, length(subnetwork)/1024 KB
from partition
order by partition_id;

-- Partition the network
-- This uses tables EDGES and NODES as input
-- It creates and populates a new PARTITION table and updates NODES and EDGES with the proper PARTITION_ID
begin
  sdo_router_partition.partition_router(
    log_file_name => 'sdo_router_partition.log',
    max_v_no      => 2000,
    network_name  => 'ROUTE_SF'
  );
end;
/

-- Show new partitioning
select partition_id, count(*)
from node
group by partition_id
order by partition_id;

select partition_id, count(*)
from edge
group by partition_id
order by partition_id;

select partition_id, num_nodes, length(subnetwork)/1024 KB
from partition
order by partition_id;

-----------------------------------------------------------------------
-- Step 3: Revoke the rights we granted
--
-- Must connect as SYS or SYSTEM to run this
-- Change the file specifications below to match your environment
-----------------------------------------------------------------------

connect system
call dbms_java.revoke_permission( 'SCOTT', 'SYS:java.io.FilePermission', 'D:\Courses\Spatial11g-Workshop\labs\14-routing-server\sdo_router_partition.log', 'write' );
call dbms_java.revoke_permission( 'MDSYS', 'SYS:java.io.FilePermission', 'D:\Courses\Spatial11g-Workshop\labs\14-routing-server\sdo_router_partition.log', 'write' );
DROP DIRECTORY sdo_router_log_dir ;
