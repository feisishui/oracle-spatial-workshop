Rem
Rem $Header: component.sql 27-feb-2007.16:02:26 hgong    Exp $
Rem
Rem component.sql
Rem
Rem Copyright (c) 2007, Oracle.  All rights reserved.  
Rem
Rem    NAME
Rem      component.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Example on how to precompute connected components.
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

--pre-compute connected components for HILLSBOROUGH_NETWORK on link level 1
EXEC sdo_net.find_connected_components('HILLSBOROUGH_NETWORK', 1, 'HILLSBOROUGH_NETWORK_COMP$', 'WORK_DIR', 'hillsborough.log', 'a');

