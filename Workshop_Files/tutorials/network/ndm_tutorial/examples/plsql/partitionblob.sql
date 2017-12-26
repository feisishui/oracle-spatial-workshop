Rem
Rem $Header: partitionblob.sql 28-feb-2007.14:29:27 hgong Exp $
Rem
Rem partitionblob.sql
Rem
Rem Copyright (c) 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      partitionblob.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Example on how to generate partition BLOBs.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       02/27/07 - Created
Rem

set serveroutput on

--create a database directory to store the partition log file
CREATE OR REPLACE DIRECTORY WORK_DIR AS '/tmp';

-- display java output
exec dbms_java.set_output(10000);

-- set java logging level
BEGIN
  sdo_net.set_logging_level(sdo_net.LOGGING_LEVEL_ERROR);
END;
/

--generate partition BLOBs for HILLSBOROUGH_NETWORK on link level 1
EXEC sdo_net.generate_partition_blobs('HILLSBOROUGH_NETWORK', 1, 'HILLSBOROUGH_NETWORK_PBLOB$', true, true, 'WORK_DIR', 'hillsborough.log', 'a');
  
--generate partition BLOBs for HILLSBOROUGH_NETWORK on link level 2
EXEC sdo_net.generate_partition_blobs('HILLSBOROUGH_NETWORK', 2, 'HILLSBOROUGH_NETWORK_PBLOB$', true, true, 'WORK_DIR', 'hillsborough.log', 'a');

select link_level, partition_id, length(blob), num_inodes, num_enodes, user_data_included from HILLSBOROUGH_NETWORK_PBLOB$ order by link_level, partition_id;

