Rem
Rem $Header: sdo/demo/network/examples/data/multimodal/setup_multimodal_data.sql /main/3 2012/10/18 05:32:18 begeorge Exp $
Rem
Rem setup_multimodal_data.sql
Rem
Rem Copyright (c) 2011, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      setup_multimodal_data.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    begeorge    03/12/12 - Make changes to reflect the new location of multimodal jar (sdondmapps)
Rem    begeorge    08/09/11 - Add metadata tables for multimodal data
Rem    begeorge    06/09/11 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

--
-- This script is to set up multimodal data for multimodal routing for NAVTEQ_DC network
-- The script uses procedures in mm_util package
--
--
-- Before running the script, make sure that 
-- (1) The basic network (NAVTEQ_DC) is loaded.
-- (2) The transit related tables
--         NAVTEQ_DC_ROUTE$,
--         NAVTEQ_DC_TRIP$,
--         NAVTEQ_DC_STOP$,
--         NAVTEQ_DC_STOP_TIME$,
--         NAVTEQ_DC_SHAPE$,
--         NAVTEQ_DC_CALENDAR$,
--         NAVTEQ_DC_AGENCY$
--     are available in the database.
--     (2 a)If the tables mentioned have not been loaded, they can be loaded
--          into the database using the following procedure in mm_util package.
--          exec mm_util.load_gtfs_data(network_name IN VARCHAR2,
--                                 log_loc  IN varchar2,
--                                 log_file IN varchar2,
--                                 open_mode IN varchar2);
--          Make sure that a directory called WORK_DIR has been created
--          before calling the procedure.
--     (2 b)Make sure that the csv files containing the gtfs data are persent
--          in the directory designated as 'WORK_DIR'
-- (3) The jar file sdondmapps.jar is available in the directory.
--     The jar file will be available in
--     sdo/demo/network/ndmdemo/ship/web/WEB_INF/lib directory.
-- (4) Directory called WORK_DIR is created and the user has read/write 
--     permissions on it.
-- (5) For transfer links generation, XML configuration file needs to be 
--     available in the directory indicated in the procedure call
--    
exec mm_util.create_multimodal_metadata;

exec mm_util.insert_multimodal_metadata(network_name => 'NAVTEQ_DC_MM', node_table_name => 'NAVTEQ_DC_MM_NODE$', link_table_name => 'NAVTEQ_DC_MM_LINK$', base_network_name => 'NAVTEQ_DC', base_node_table_name => 'NAVTEQ_DC_NODE$', base_link_table_name => 'NAVTEQ_DC_LINK$', service_node_table_name => null, service_link_table_name => null, stop_node_map_table_name => null, node_schedule_table_name => null, connect_link_table_name => null, transfer_link_table_name => null, link_type_table_name => null, route_table_name => 'NAVTEQ_DC_MM_ROUTE$', log_loc => 'WORK_DIR', log_file => 'mm.log', open_mode => 'a');

exec mm_util.create_mm_subnetwork_metadata;

exec mm_util.insert_mm_subnetwork_metadata(network_name => 'NAVTEQ_DC_MM',subnetwork_name => 'METRO', subnetwork_id => 1, agency_table_name => null, calendar_table_name => null, route_table_name => null, shape_table_name => null, stop_times_table_name => null, stop_table_name => null, trip_table_name => null, schedule_id_table_name => null, service_node_table_name => null, stop_node_map_table_name => null, service_link_table_name => null, connect_link_table_name => null, node_schedule_table_name => null, log_loc => 'WORK_DIR', log_file => 'mm.log', open_mode => 'a');

commit;

exec mm_util.load_gtfs_data('NAVTEQ_DC_MM', 'METRO', 'WORK_DIR', 'agency.csv', 'calendar.csv', 'routes.csv', 'shapes.csv', 'stop_times.csv', 'stops.csv', 'trips.csv', 'WORK_DIR', 'mm.log', 'a');

delete from user_sdo_network_metadata where network='NAVTEQ_DC_MM';
insert into user_sdo_network_metadata(network,network_id,network_category,
                                      node_table_name,node_geom_column,
                                      link_table_name,link_geom_column,
                                      link_direction,link_cost_column,
                                      path_table_name,path_geom_column,
                                      path_link_table_name,
                                      partition_table_name,partition_blob_table_name,
                                      node_level_table_name,user_defined_data)
values
                                      ('NAVTEQ_DC_MM',2001,'SPATIAL',
                                       'NAVTEQ_DC_MM_NODE$','GEOMETRY',
                                       'NAVTEQ_DC_MM_LINK$','GEOMETRY',
                                       'DIRECTED','COST',
                                       'NAVTEQ_DC_MM_PATH$','PATH_GEOMETRY',
                                       'NAVTEQ_DC_MM_PLINK$',
                                       'NAVTEQ_DC_PART$','NAVTEQ_DC_PBLOB$',
                                       'NAVTEQ_DC_MM_NLVL$','Y');

commit;

-- Load the jar file
host loadjava -user navteq_dc/navteq_dc -grant public -resolve -force -v sdondmapps.jar

commit;

exec mm_util.create_mm_node_tables('NAVTEQ_DC_MM', 'NAVTEQ_DC_MM_NODE$', 'NAVTEQ_DC_MM_SERVICE_NODE$', 'NAVTEQ_DC_MM_STOP_NODE_ID_MAP', 'WORK_DIR', 'mm.log', 'a');

exec mm_util.create_mm_node_schedule_table('NAVTEQ_DC_MM', 'NAVTEQ_DC_MM_NODE_SCH$', 'WORK_DIR', 'mm.log', 'a');

exec mm_util.create_mm_link_tables('NAVTEQ_DC_MM', 'NAVTEQ_DC_MM_LINK$', 'NAVTEQ_DC_MM_SERVICE_LINK$', 'NAVTEQ_DC_MM_CONNECT_LINK$', 'WORK_DIR', 'mm.log', 'a');

exec mm_util.create_link_type_table('NAVTEQ_DC_MM', 'NAVTEQ_DC_MM_LINK_TYPE$', 'WORK_DIR','mm.log','a');

exec mm_util.create_mm_route_table('NAVTEQ_DC_MM', 'NAVTEQ_DC_MM_ROUTE$', 'WORK_DIR', 'mm.log', 'a');

--
-- The following steps are performed to maintain the original partitions which are 
-- available in the table NAVTEQ_DC_ORIG_PART$ (would be in the table PARTITION in ODF; in that case
-- change the name accordingly)
-- 
drop table navteq_dc_part$ purge;
create table navteq_dc_part$ nologging as 
select node_id node_id, partition_id partition_id, link_level link_level
from navteq_dc_orig_part$;
commit;

-- Adds newly generated service nodes to existing partitions
exec mm_util.add_nodes_to_partitions('NAVTEQ_DC_MM', 'WORK_DIR', 'mm.log', 'a');

delete from user_sdo_network_user_data where network='NAVTEQ_DC_MM';

insert into user_sdo_network_user_data (network, table_type, data_name, data_type)
       VALUES ('NAVTEQ_DC_MM', 'NODE', 'X', 'NUMBER');
insert into user_sdo_network_user_data (network, table_type, data_name, data_type)
       VALUES ('NAVTEQ_DC_MM', 'NODE', 'Y', 'NUMBER');
insert into user_sdo_network_user_data (network, table_type, data_name, data_type)
       VALUES ('NAVTEQ_DC_MM', 'LINK', 'S', 'NUMBER');
commit;

exec sdo_net.generate_partition_blobs('NAVTEQ_DC_MM',1,'NAVTEQ_DC_PBLOB$',true,true,'WORK_DIR','mm.log','a');
exec sdo_net.generate_partition_blobs('NAVTEQ_DC_MM',2,'NAVTEQ_DC_PBLOB$',true,true,'WORK_DIR','mm.log','a');

----------------------------------*****---------------------------------------------
-- Transfer links generation using PL SQL procedure
------------------------------------------------------------------------------------
-- Make sure that a directory object (WORK_DIR in the following call) is created and 
-- the XML configuration file is 
-- available in the directory corresponding to this object.
--
-- exec mm_util.create_transfer_links(network_name => 'NAVTEQ_DC_MM', output_table => 'NAVTEQ_DC_MM_TRANSFER_LINK$', transfer_radius => 250, walking_speed => 1.33, config_file_loc => 'WORK_DIR', config_file => 'LODConfigs.xml', log_loc => 'WORK_DIR', log_file => 'mm.log', open_mode => 'a');
--
----------------------------------*****---------------------------------------------
--  Follow steps 1 - 4 to generate transfer links (without PL SQL Wrapper since this might be faster than 
--  PL-SQL Wrapper based procedure)
--  Make sure that sdondmapps.jar is the CLASSPATH
--
--(1) generate user data for transfer link generation
--
host java -cp classes:$CLASSPATH oracle.spatial.network.apps.multimodal.PreTLinkUserDataWriter -dbUrl "jdbc:oracle:thin:@localhost:1521:orcl" -dbUser navteq_dc -dbPassword navteq_dc -networkName NAVTEQ_DC_MM -outputTable NAVTEQ_DC_MM_TLINK_USER_DATA
commit;
--
--(2) create transfer links across stops on the same road link
--
exec mm_util.create_transfers_on_links('NAVTEQ_DC_MM', 'NAVTEQ_DC_MM_TRANSFER_ON_LINK$', 'WORK_DIR', 'mm.log', 'a');
commit;
--
--(3) create transfer links
--    Make sure that LODConfigs.xml is in the directory from which the java class is executed.
--    
host java -cp classes:$CLASSPATH oracle.spatial.network.apps.multimodal.TransferLinksGenerator -dbUrl "jdbc:oracle:thin:@localhost:1521:orcl" -dbUser navteq_dc -dbPassword navteq_dc -networkName NAVTEQ_DC_MM -configXmlFile LODConfigs.xml -outputTable NAVTEQ_DC_MM_TEMP_TR_LINK$ -transferRadius 250 walkingSpeed "1.33"
commit;
--
--(4) Process transfer link stable to remove links across stops on the same link that cycle through connect links
--
exec mm_util.process_transfer_links('NAVTEQ_DC_MM', 'NAVTEQ_DC_MM_TEMP_TR_LINK$','NAVTEQ_DC_MM_TRANSFER_LINK$', 250, 1.33, 'WORK_DIR', 'mm.log', 'a');
commit;
--
-- Regenerate partition blobs after adding transfer links to the network
--
exec sdo_net.generate_partition_blobs('NAVTEQ_DC_MM',1,'NAVTEQ_DC_PBLOB$',true,true,'WORK_DIR','mm.log','a');
commit;

exec sdo_net.generate_partition_blobs('NAVTEQ_DC_MM',2,'NAVTEQ_DC_PBLOB$',true,true,'WORK_DIR','mm.log','a');
commit;

exec mm_util.create_indexes('NAVTEQ_DC_MM', 'WORK_DIR', 'mm.log', 'a');
commit;

exec mm_util.generate_mm_user_data('NAVTEQ_DC_MM', 'WORK_DIR', 'mm.log', 'a');
commit;

