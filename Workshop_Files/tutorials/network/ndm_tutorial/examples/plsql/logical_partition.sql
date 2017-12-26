Rem
Rem $Header: sdo/demo/network/examples/plsql/logical_partition.sql /main/1 2009/10/08 12:25:18 hgong Exp $
Rem
Rem logical_partition.sql
Rem
Rem Copyright (c) 2009, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      logical_partition.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      This plsql script demonstrates how to partition a logical or a spatial network.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       09/03/09 - Created
Rem

set serveroutput on

--create a database directory to store the partition log file (here, hillsborough.log)
--log file logs relevant info such as error messages while partitioning goes through. 

CREATE OR REPLACE DIRECTORY WORK_DIR AS '/tmp';

--partitions HILLSBOROUGH_NETWORK on link level 1 (default link_level) into partitions with at most 
-- 2000 nodes

EXEC sdo_net.logical_partition('HILLSBOROUGH_NETWORK', 'HILLSBOROUGH_NETWORK_LPART$', 2000, 'WORK_DIR', 'hillsborough.log', 'a');

--partitions HILLSBOROUGH_NETWORK on link level 2

EXEC sdo_net.spatial_partition('HILLSBOROUGH_NETWORK', 'HILLSBOROUGH_NETWORK_LPART$', 2000, 'WORK_DIR', 'hillsborough.log', 'a', 2);


