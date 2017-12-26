Rem
Rem $Header: sdo/demo/network/examples/data/navteq_sf/setup_traffic_data_new_schema.sql /main/3 2013/04/18 05:48:19 begeorge Exp $
Rem
Rem setup_traffic_data_new_schema.sql
Rem
Rem Copyright (c) 2012, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      setup_traffic_data_new_schema.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    begeorge    03/02/12 - Created
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
--     NTP_LINK_PATTERN, NTP_SPEED_PATTERN, NTP_PATTERN_META 
--     are available. 
-- (3) Directory object 'WORK_DIR' is created
-- 
-- Create the metadata table for traffic, if it has not already been created.
exec ndmdemo.traffic_util.create_traffic_metadata;

-- Insert the row corresponding to NAVTEQ_SF network for sampling id = 1 (96, 15 min intervals)
exec ndmdemo.traffic_util.insert_traffic_metadata(network_name =>'NAVTEQ_SF_NEW', sampling_id => 1,link_length_column => 'length', link_speed_limit_column => 'S', link_traf_attr_name => 'speed', traf_attr_unit => 'kmph', num_time_intervals => 96, number_of_patterns => 7);

-- Insert the row corresponding to NAVTEQ_SF network for sampling id = 2 (24, 1 hour  intervals)
exec ndmdemo.traffic_util.insert_traffic_metadata(network_name => 'NAVTEQ_SF_NEW', sampling_id => 2, link_length_column => 'length', link_speed_limit_column => 'S', link_traf_attr_name => 'speed', traf_attr_unit => 'kmph', num_time_intervals => 24, number_of_patterns => 7);


-- Create link speed table with link IDs and speeds 
-- This table would associate each link with 7 speed patterns for sampling id = 1 and 
-- seven speed patterns for sampling id = 2
exec ndmdemo.traffic_util.create_link_speed_series_table(network_name=>'NAVTEQ_SF_NEW',link_pattern_table => 'NTP_LINK_PATTERN',speed_pattern_table=>'NTP_SPEED_PATTERN',exclude_links_not_in_network=>true,link_speed_series_table=>'NAVTEQ_SF_NEW_LINK_SPEEDS',log_loc=>'WORK_DIR',log_file=>'traf.log', open_mode=>'a');

-- Create speed table with partition info of start and end nodes.
-- Also create a table with IDs of covered partitions
exec ndmdemo.traffic_util.add_pid_to_link_speed_table(network_name => 'NAVTEQ_SF_NEW', sampling_id => 1, link_speed_table => 'NAVTEQ_SF_NEW_LINK_SPEEDS', output_table => 'NVT_L_SPEED_PIDS', log_loc => 'WORK_DIR', log_file => 'traf.log', open_mode => 'a');

-- Add time zones to links
exec ndmdemo.traffic_util.add_timezones_to_links(network_name => 'NAVTEQ_SF_NEW', link_speed_table => 'NAVTEQ_SF_NEW_LINK_SPEEDS', output_table => 'NAVTEQ_SF_NEW_COVLINK_TZ$', log_loc => 'WORK_DIR', log_file => 'traf.log', open_mode => 'a');

-- Load the traffic jar file sdondmapps.jar
host loadjava -user ndmdemo/ndmdemo -grant public -resolve -v sdondmapps.jar

-- 
-- Make sure that sdondmapps.jar is loaded in ndmdemo before running 
-- the following procedure
--
-- Generate link speed user data for sampling id = 1
exec ndmdemo.traffic_util.generate_traffic_user_data(network_name => 'NAVTEQ_SF_NEW', sampling_id => 1, link_speed_table => 'NAVTEQ_SF_NEW_LINK_SPEEDS', link_speed_table_with_pid => 'NVT_L_SPEED_PIDS', overwrite_blobs => true, log_loc => 'WORK_DIR', log_file => 'traf.log', open_mode => 'a');

commit;

-- Generate link speed user data for sampling id = 2
exec ndmdemo.traffic_util.generate_traffic_user_data(network_name => 'NAVTEQ_SF_NEW', sampling_id => 2, link_speed_table => 'NAVTEQ_SF_NEW_LINK_SPEEDS', link_speed_table_with_pid => 'NVT_L_SPEED_PIDS', overwrite_blobs => false, log_loc => 'WORK_DIR', log_file => 'traf.log', open_mode => 'a');

-- Generate time zone user data 
exec ndmdemo.traffic_util.generate_tr_tz_user_data(network_name => 'NAVTEQ_SF',log_loc => 'WORK_DIR',log_file => 'traffic.log', open_mode => 'a');
