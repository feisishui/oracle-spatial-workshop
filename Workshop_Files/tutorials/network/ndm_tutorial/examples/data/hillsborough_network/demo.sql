Rem
Rem $Header: sdo/demo/network/examples/data/hillsborough_network/demo.sql /main/1 2010/05/12 07:16:18 begeorge Exp $
Rem
Rem demo.sql
Rem
Rem Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      demo.sql - <one-line expansion of the name>
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

--
-- Before running this script, the HILLSBOROUGH network must be set up
-- setup.sql can be used to set up the network
-- User ndmdemo must have the ndmdemo_util package loaded
--

-- Log into Oracle as hillsborough

--
-- Define geometry metadata if it is not done yet
--
exec ndmdemo.ndmdemo_util.define_geometry_metadata;

--
-- Create required indexes
--
exec ndmdemo.ndmdemo_util.create_indexes;

--
-- Insert geometry metadata for NDM node and link views
--
exec ndmdemo.ndmdemo_util.define_geom_metadata_for_net('HILLSBOROUGH_NETWORK');

--
-- Compute partition convex hull, in order to display partition boundaries
-- during demo
-- Drop table, if it already exists
--
drop table HILLSBOROUGH_NETWORK_PCH$ purge;
exec ndmdemo.ndmdemo_util.create_partition_convexhull('HILLSBOROUGH_NETWORK');

commit;

--
-- Grant read access to the views to the ndmdemo
--
grant select on HILLSBOROUGH_NETWORK_NODE to ndmdemo;
grant select on HILLSBOROUGH_NETWORK_LINK$ to ndmdemo;
grant select on HILLSBOROUGH_NETWORK_PCH$ to ndmdemo;
