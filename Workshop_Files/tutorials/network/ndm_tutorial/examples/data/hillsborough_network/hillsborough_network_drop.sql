Rem
Rem $Header: sdo/demo/network/examples/data/hillsborough_network/hillsborough_network_drop.sql /main/2 2010/10/18 08:10:12 begeorge Exp $
Rem
Rem hillsborough_network_drop.sql
Rem
Rem Copyright (c) 2007, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      hillsborough_network_drop.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       02/09/07 - Created
Rem

delete from user_sdo_geom_metadata where table_name = 'HILLSBOROUGH_NETWORK_NODE$';
delete from user_sdo_geom_metadata where table_name = 'HILLSBOROUGH_NETWORK_LINK$';
delete from user_sdo_geom_metadata where table_name = 'HILLSBOROUGH_NETWORK_PATH$';
delete from user_sdo_network_metadata where network = 'HILLSBOROUGH_NETWORK';
delete from user_sdo_network_user_data where network = 'HILLSBOROUGH_NETWORK';

drop table hillsborough_network_node$ purge;
drop table hillsborough_network_link$ purge;
drop table hillsborough_network_path$ purge;
drop table hillsborough_network_plink$ purge;
drop table hillsborough_network_pblob$ purge;
