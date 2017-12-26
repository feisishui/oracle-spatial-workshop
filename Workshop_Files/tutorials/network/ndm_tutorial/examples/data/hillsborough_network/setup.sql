Rem
Rem $Header: sdo/demo/network/examples/data/hillsborough_network/setup.sql /main/2 2010/10/18 08:10:12 begeorge Exp $
Rem
Rem setup.sql
Rem
Rem Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      setup.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    begeorge    05/05/10 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

-- Connect as privileged user
-- sqlplus sys/welcome as sysdba;

-- Create a user for the network-specific data in the database.
-- Tablespace is USERS
--
create user hillsborough identified by hillsborough default tablespace users quota unlimited on users;

--
-- grant privileges to the user
--
grant connect, resource, create view to hillsborough;

--
-- Create a directory WORK_DIR and grant access to hillsborough
--
create or replace directory WORK_DIR as '/tmp';
grant read, write on directory WORK_DIR to hillsborough;

--
-- Import the data from the dump file.
-- Make sure that the dump file is in the directory
--
host imp hillsborough/hillsborough file=hillsborough_network.dmp full=y

-- 
-- Connect as the network user and create required indexes and register 
-- the network in network_metadata and geom_metadata
-- 
conn hillsborough/hillsborough;

@hillsborough_network_create.sql;

commit;

--
-- Partition the network and generate partition BLOBs
--
exec sdo_net.spatial_partition('HILLSBOROUGH_NETWORK','HILLSBOROUGH_NETWORK_PART$', 2000,'WORK_DIR','hills_part.log','a');
exec sdo_net.generate_partition_blobs('HILLSBOROUGH_NETWORK',1, 'HILLSBOROUGH_NETWORK_PBLOB$',true,true, 'WORK_DIR','hills_pblob.log','a');
