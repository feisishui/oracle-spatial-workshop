Rem
Rem $Header: sdo/demo/network/examples/data/navteq_sf/setup_traffic_data.sql /main/3 2012/10/18 05:32:18 begeorge Exp $
Rem
Rem setup_traffic_data.sql
Rem
Rem Copyright (c) 2010, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      setup_traffic_data.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    begeorge    11/04/10 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

--
-- This is a script to set up traffic data for NDM analysis for NAVTEQ_SF network.
-- This script uses procedures in traffic_util package 
-- currently under ndmdemo user.
-- 
-- Before running the script, make sure that 
-- (1) The network NAVTEQ_SF is loaded
-- (2) The traffic tables 
--     NVT_TRAF_PATT_MON_THURS, NVT_TRAF_PATT_FRIDAY, 
--     NVT_TRAF_PATT_SATURDAY, NVT_TRAF_PATT_SUNDAY
--     are available. 
-- (3) Directory object 'WORK_DIR' is created
-- If the traffic data is available in csv files in Navteq format, 
-- the following procedure in traffic_util package 
-- can be used to load the data into tables. 
-- load_speeds_from_csv_file (network_name IN varchar2,
--                            csv_file_name IN varchar2,
--                            tp_table_name IN varchar2, 
--                            num_intervals IN number,
--                            log_loc  IN varchar2,
--                            log_file IN varchar2,
--                            open_mode IN varchar2);
-- To load the RDF_TMC_LINK table (table to map link Ids to TMC)
-- use the following procedure
-- exec traffic_util.load_rdf_link_tmc_from_csv
--                           (network_name IN varchar2,
--                            csv_file_name IN varchar2,
--                            rdf_table_name IN varchar2,
--                            log_loc  IN varchar2,
--                            log_file IN varchar2,
--                            open_mode IN varchar2);
-- 
-- Create the metadata table for traffic, if it has not already been created.
exec ndmdemo.traffic_util.create_traffic_metadata;

-- Insert the row corresponding to NAVTEQ_SF network
exec ndmdemo.traffic_util.insert_traffic_metadata(network_name => 'NAVTEQ_SF', sampling_id => 1, link_length_column => 'length', link_speed_limit_column => 'S', link_traf_attr_name => 'speed', traf_attr_unit => 'mph', num_time_intervals => 96, number_of_patterns => 4);

-- Create traffic table for Mon - Thurs patterns
exec ndmdemo.traffic_util.convert_to_ndm_speed_tables(network_name => 'NAVTEQ_SF', tp_input_table => 'NVT_TRAF_PATT_MON_THURS', link_to_loc_map_table => 'RDF_LINK_TMC', sampling_id => 1, tp_output_table => 'NDM_TP_1',log_loc => 'WORK_DIR',log_file => 'traffic.log',open_mode =>'a');

-- Create traffic table for Friday patterns
exec ndmdemo.traffic_util.convert_to_ndm_speed_tables(network_name => 'NAVTEQ_SF',tp_input_table => 'NVT_TRAF_PATT_FRIDAY',link_to_loc_map_table => 'RDF_LINK_TMC', sampling_id => 1,tp_output_table => 'NDM_TP_2',log_loc => 'WORK_DIR',log_file => 'traffic.log',open_mode =>'a');

-- Create traffic table for Saturday patterns
exec ndmdemo.traffic_util.convert_to_ndm_speed_tables(network_name => 'NAVTEQ_SF',tp_input_table => 'NVT_TRAF_PATT_SATURDAY',link_to_loc_map_table => 'RDF_LINK_TMC', sampling_id => 1,tp_output_table => 'NDM_TP_3',log_loc => 'WORK_DIR',log_file => 'traffic.log',open_mode =>'a');

-- Create traffic table for Sunday patterns
exec ndmdemo.traffic_util.convert_to_ndm_speed_tables(network_name => 'NAVTEQ_SF',tp_input_table => 'NVT_TRAF_PATT_SUNDAY',link_to_loc_map_table => 'RDF_LINK_TMC', sampling_id => 1,tp_output_table => 'NDM_TP_4',log_loc => 'WORK_DIR',log_file => 'traffic.log',open_mode =>'a');

-- Create link speed table with link IDs and speeds 
-- This table aggregates all four speed patterns
exec ndmdemo.traffic_util.create_link_speeds_table(network_name => 'NAVTEQ_SF', output_table => 'NAVTEQ_SF_LINK_SPEED$', log_loc => 'WORK_DIR',log_file => 'traffic.log',open_mode =>'a');

-- Create speed table with partition info of start and end nodes.
-- Also create a table with IDs of covered partitions
exec ndmdemo.traffic_util.add_pid_to_link_speed_table(network_name => 'NAVTEQ_SF', sampling_id => 1, link_speed_table => 'NAVTEQ_SF_LINK_SPEED$', output_table => 'NAVTEQ_SF_LSPEED_PID', log_loc => 'WORK_DIR', log_file => 'traffic.log', open_mode => 'a');

-- 
-- Make sure that sdondmtf.jar is loaded in ndmdemo before running 
-- the following procedure
-- If required, use the following command to load the jar file
-- host loadjava -user ndmdemo/ndmdemo -grant public -resolve -v sdondmtf.jar
--
-- Generate link speed user data
exec ndmdemo.traffic_util.generate_traffic_user_data(network_name => 'NAVTEQ_SF', sampling_id => 1, link_speed_table => 'NAVTEQ_SF_LINK_SPEED$', link_speed_table_with_pid => 'NAVTEQ_SF_LSPEED_PID', overwrite_blobs => true, log_loc => 'WORK_DIR',log_file => 'traffic.log', open_mode => 'a');

-- Create table with link IDs and corresponding time zones
exec ndmdemo.traffic_util.add_timezones_to_links(network_name => 'NAVTEQ_SF', link_speed_table => 'NAVTEQ_SF_LSPEED_PID', output_table => 'NAVTEQ_SF_COVLINK_TZ$', log_loc => 'WORK_DIR', log_file => 'traffic.log', open_mode => 'a');

-- Generate time zone user data for links
exec ndmdemo.traffic_util.generate_tr_tz_user_data(network_name => 'NAVTEQ_SF',log_loc => 'WORK_DIR',log_file => 'traffic.log', open_mode => 'a');

