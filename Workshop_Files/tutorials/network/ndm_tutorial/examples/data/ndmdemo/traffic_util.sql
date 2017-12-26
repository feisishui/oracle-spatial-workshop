Rem
Rem $Header: sdo/demo/network/examples/data/ndmdemo/traffic_util.sql /main/8 2013/04/18 05:48:19 begeorge Exp $
Rem
Rem traffic_util.sql
Rem
Rem Copyright (c) 2010, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      traffic_util.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)

Rem    begeorge    04/16/13 - add user data table name as a parameter to the procedure
Rem    begeorge    04/16/13 - add data_provider in traffic metadata
Rem    begeorge    02/14/12 - add sampling id as a parameter
Rem    begeorge    02/14/12 - change to reflect the new location of traffic jar sdondmtf.jar
Rem    begeorge    10/27/10 - add generate_traffic_timezone_user_data
Rem    begeorge    10/26/10 - add timezone info to links
Rem    begeorge    10/21/10 - procedure to add partition IDs of start node and end node to link speed table 
Rem    begeorge    09/27/10 - add generate_traffic_user_data
Rem    begeorge    09/14/10 - modify to create and use traffic metadata
Rem    begeorge    08/27/10 - add dbms_assert to prevent sql injection
Rem    begeorge    08/25/10 - Modify to extend traffic data to include variations w/ day
Rem    begeorge    05/10/10 - Created
Rem

SET ECHO OFF
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100
CREATE OR REPLACE PACKAGE traffic_util AUTHID current_user AS

TYPE cursor_type IS REF CURSOR;
PROCEDURE set_log_info(file      IN UTL_FILE.FILE_TYPE);
PROCEDURE log_message(message IN VARCHAR2, show_time IN BOOLEAN);
FUNCTION table_exists(table_name IN VARCHAR2) RETURN BOOLEAN;
FUNCTION view_exists(view_name IN VARCHAR2) RETURN BOOLEAN;
FUNCTION index_exists(index_name IN VARCHAR2) RETURN BOOLEAN;
FUNCTION index_on_col_exists(tab_name IN VARCHAR2,col_name IN VARCHAR2) RETURN BOOLEAN;
FUNCTION geometry_metadata_exists(table_name IN VARCHAR2, col_name VARCHAR2) RETURN BOOLEAN;
PROCEDURE insert_geometry_metadata(table_name VARCHAR2, col_name VARCHAR2);
PROCEDURE delete_geometry_metadata(table_name VARCHAR2, col_name VARCHAR2);
FUNCTION get_link_table_name(network_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION get_part_table_name(network_name IN VARCHAR2) RETURN VARCHAR2;
--
-- Procedure to load speed data from csv file to a database table
--
PROCEDURE load_speeds_from_csv_file (network_name IN varchar2,
                                     csv_file_name IN varchar2,
                                     tp_table_name IN varchar2,
                                     num_intervals IN number,
				     log_loc  IN varchar2,
				     log_file IN varchar2,
				     open_mode IN varchar2);
--
-- Loads all csv files and generates the tables for entire North America
--
PROCEDURE load_speeds_from_all_csv_files(network_name IN varchar2,
					 country_code IN varchar2,
					 log_loc  IN varchar2,
					 log_file IN varchar2,
					 open_mode IN varchar2);
--
-- If the traffic pattern format is not the required one, it needs to be mapped
-- This procedure is an example using Navteq data
--
PROCEDURE convert_to_ndm_speed_tables(network_name IN varchar2,
				      tp_input_table IN varchar2,
				      link_to_loc_map_table IN varchar2,
				      sampling_id IN number,
				      tp_output_table IN varchar2,
				      log_loc  IN varchar2,
				      log_file IN varchar2,
				      open_mode IN varchar2);

--
-- Creates and populates link speeds table
-- 
PROCEDURE create_single_patt_speed_table(network_name IN VARCHAR2);
--
-- Creates link speed tables accounting for differences with day of week
--
PROCEDURE create_link_speeds_table(network_name IN VARCHAR2,
                                   output_table IN VARCHAR2,
				   log_loc  IN varchar2,
				   log_file IN varchar2,
				   open_mode IN varchar2);
--
-- Creates a table that has link speeds and partition info of start, end nodes
-- Procedure also finds the IDs pf partitions associated with links that show speed 
-- variations. The IDs are stored in a table to be used in user data generation
--
PROCEDURE add_pid_to_link_speed_table(network_name IN varchar2,
                                      sampling_id IN varchar2,
                                      link_speed_table In varchar2,
                                      output_table IN varchar2,
                                      log_loc IN varchar2,
                                      log_file IN varchar2,
                                      open_mode IN varchar2);
--
-- Creates a table that has link IDs and timezones.
-- Link is assigned the timezone id of its start node
-- 0 - EST, 1 - CST, 2 - MT, 3 - PST
--
PROCEDURE add_timezones_to_links(network_name IN varchar2,
                                 link_speed_table IN varchar2,
                                 output_table IN varchar2,
				 log_loc IN varchar2,
				 log_file IN varchar2,
				 open_mode IN varchar2);

--
-- Creates a table that stores info on links with speed difference > threshold
--
PROCEDURE create_congested_links_table(network_name IN VARCHAR2,
                                       link_speed_table_name IN VARCHAR2,
				       speed_threshold IN NUMBER);

--
-- Creates the views required views under ndmdemo
--
PROCEDURE create_ndmdemo_views(network_user IN varchar2, network_name IN varchar2);

--  Creates metadata
PROCEDURE create_traffic_metadata;

--  Inserts traffic metadata
PROCEDURE insert_traffic_metadata(network_name IN varchar2,
                                  sampling_id in number,
                                  link_length_column IN varchar2,
                                  link_speed_limit_column IN varchar2,
                                  link_traf_attr_name IN varchar2,
                                  traf_attr_unit IN varchar2,
                                  num_time_intervals IN number,
                                  number_of_patterns IN number);

FUNCTION get_link_length_column(network_name IN varchar2) RETURN varchar2;

FUNCTION get_link_speed_limit_column(network_name IN varchar2) RETURN varchar2;

FUNCTION get_link_traf_attr_name(network_name IN varchar2) RETURN varchar2;

--FUNCTION get_mapping_table_name(network_name IN varchar2) RETURN varchar2;

--FUNCTION get_mapping_col_name(network_name IN varchar2) RETURN varchar2;

FUNCTION get_num_time_intervals(network_name IN varchar2) RETURN number;

FUNCTION get_link_traf_patt_tables(network_name IN varchar2)
                                         RETURN sdo_string_array;
FUNCTION get_traf_attr_unit(network_name IN varchar2) RETURN varchar2;

FUNCTION convert_to_speed(time_series IN sdo_number_array, length IN number) 
					RETURN sdo_number_array;

PROCEDURE create_link_speed_series_table(network_name in varchar2,
                                         link_pattern_table IN varchar2,
                                         speed_pattern_table in varchar2,
                                         exclude_links_not_in_network in boolean,
                                         link_speed_series_table in varchar2,
                                         log_loc in varchar2,
                                         log_file in varchar2,
                                         open_mode in varchar2);

PROCEDURE generate_traffic_user_data(network_name IN varchar2,
                                     sampling_id in number,
                                     link_speed_table in varchar2,
                                     link_speed_table_with_pid in varchar2,
                                     overwrite_blobs in boolean,
                                     user_data_table in varchar2 DEFAULT 'TP_USER_DATA',
				     log_loc IN varchar2,
				     log_file IN varchar2,
				     open_mode IN varchar2);

PROCEDURE generate_traffic_user_data(network_name IN varchar2,
                                     sampling_id in number,
				     startOfPeriod IN varchar2,
				     endOfPeriod IN varchar2,
                                     link_speed_table in varchar2,
                                     link_speed_table_with_pid in varchar2,
                                     overwrite_blobs in boolean,
                                     user_data_table in varchar2 DEFAULT 'TP_USER_DATA',
				     log_loc IN varchar2,
				     log_file IN varchar2,
				     open_mode IN varchar2);

PROCEDURE generate_tr_tz_user_data(network_name IN varchar2,
				   log_loc IN varchar2,
				   log_file IN varchar2,
				   open_mode IN varchar2);

END traffic_util;
/

CREATE OR REPLACE PACKAGE BODY traffic_util AS

-- Log file
   traf_log_file utl_file.file_type := NULL;

PROCEDURE set_log_info(file UTL_FILE.FILE_TYPE) IS
BEGIN

  traf_log_file := file;

  EXCEPTION
      WHEN OTHERS THEN
         RAISE;
END set_log_info;

PROCEDURE log_message(message IN VARCHAR2, show_time IN BOOLEAN) IS
BEGIN

  if  ( utl_file.is_open(traf_log_file) = FALSE )  then
     return;
  end if;
  IF ( show_time ) THEN
    utl_file.put_line (traf_log_file, '      ' || to_char(sysdate,'Dy fmMon DD HH24:MI:SS YYYY'));
  END IF;
  utl_file.put_line (traf_log_file, message);
  utl_file.fflush(traf_log_file); 
END log_message;

FUNCTION table_exists(table_name IN VARCHAR2) RETURN BOOLEAN IS
   query_str	VARCHAR2(512);
   no		NUMBER := 0;

   BEGIN
      query_str := 'SELECT count(*) FROM TAB ' ||
       		   ' WHERE tname = :tname';
      EXECUTE IMMEDIATE query_str INTO no USING UPPER(sys.dbms_assert.noop(table_name));
      IF (no > 0) THEN
        RETURN true;
      ELSE 
        RETURN false;
      END IF;
   END table_exists;

FUNCTION view_exists(view_name IN VARCHAR2) RETURN BOOLEAN IS
   query_str 	VARCHAR2(512);
   no		NUMBER;

   BEGIN
      query_str := 'SELECT count(*) FROM USER_VIEWS ' ||
		   ' WHERE view_name = :name';
      EXECUTE IMMEDIATE query_str INTO no USING UPPER(sys.dbms_assert.noop(view_name));
      IF (no > 0) THEN
         RETURN true;
      ELSE
         RETURN false;
      END IF;
   END view_exists;

FUNCTION index_exists(index_name IN VARCHAR2) RETURN BOOLEAN IS
   query_str    VARCHAR2(512);
   no           NUMBER;

   BEGIN
      query_str := 'SELECT COUNT(*) FROM IND WHERE INDEX_NAME = :iname';
      EXECUTE IMMEDIATE query_str INTO no USING UPPER(sys.dbms_assert.noop(index_name));
      IF (no > 0) THEN
         RETURN true;
      ELSE
         RETURN false;
      END IF;
   END index_exists;

 FUNCTION index_on_col_exists( tab_name IN VARCHAR2, col_name IN VARCHAR2)
    RETURN boolean
  IS
    stmt  	varchar2(256);
    no    	number := 0;
  BEGIN
    stmt := 'SELECT count(*) FROM USER_IND_COLUMNS WHERE TABLE_NAME = :tab_name AND COLUMN_NAME = :col_name';
    EXECUTE IMMEDIATE stmt into no using UPPER(tab_name), UPPER(col_name);
    IF (no >= 1) THEN
      RETURN true;
    ELSE
      RETURN false;
    END IF;
  END index_on_col_exists;

FUNCTION geometry_metadata_exists(table_name IN VARCHAR2, col_name VARCHAR2)
    RETURN BOOLEAN
  IS
    stmt  VARCHAR2(256);
    no    NUMBER := 0;
  BEGIN
    stmt := 'SELECT COUNT(*) FROM user_sdo_geom_metadata 
             where table_name = :table_name and column_name = :col_name';

    EXECUTE IMMEDIATE stmt into no using UPPER(sys.dbms_assert.noop(table_name)), 
					 UPPER(sys.dbms_assert.noop(col_name));
    IF (no > 0) THEN
      RETURN true;
    ELSE
      RETURN false;
    END IF;
  END geometry_metadata_exists;

PROCEDURE insert_geometry_metadata(table_name VARCHAR2, col_name VARCHAR2)
  IS
    stmt VARCHAR2(1024);
    no   NUMBER;
  BEGIN
    IF NOT(geometry_metadata_exists(table_name, col_name)) THEN
      stmt := 'insert into user_sdo_geom_metadata (table_name,column_name,diminfo,srid)
               values ( :tname, :cname,
                 MDSYS.SDO_DIM_ARRAY(
                   MDSYS.SDO_DIM_ELEMENT(''X'',-180,180,0.05),
                   MDSYS.SDO_DIM_ELEMENT(''Y'',-90,90,0.05)),
                   8307)';
      execute immediate stmt using UPPER(sys.dbms_assert.noop(table_name)), 
				   UPPER(sys.dbms_assert.noop(col_name));
    END IF;
  END;

PROCEDURE delete_geometry_metadata(table_name VARCHAR2, col_name VARCHAR2)
  IS
    stmt VARCHAR2(1024);
    no   NUMBER;
  BEGIN
    IF (geometry_metadata_exists(table_name, col_name)) THEN
      stmt := 'delete from user_sdo_geom_metadata 
               where table_name = :tname and column_name = :cname';
      execute immediate stmt using UPPER(sys.dbms_assert.noop(table_name)), 
				   UPPER(sys.dbms_assert.noop(col_name));
    END IF;
  END;

FUNCTION get_link_table_name(network_name IN VARCHAR2) RETURN VARCHAR2 IS
   query_str 		VARCHAR2(512);
   link_table_name 	VARCHAR2(128);
   network		VARCHAR2(128);

   BEGIN
      network := UPPER(network_name);
      query_str := 'SELECT link_table_name FROM ' ||
		   ' user_sdo_network_metadata  WHERE ' ||
                   ' network = :n';
      EXECUTE IMMEDIATE query_str INTO link_table_name USING sys.dbms_assert.noop(network);
      RETURN link_table_name; 	
   END get_link_table_name;

--
-- Returns partition table name
--
FUNCTION get_part_table_name(network_name IN VARCHAR2) RETURN VARCHAR2 IS
   query_str            VARCHAR2(512);
   part_table_name      VARCHAR2(128);
   network              VARCHAR2(128);

   BEGIN
      network := UPPER(network_name);
      query_str := 'SELECT partition_table_name FROM ' ||
                   ' user_sdo_network_metadata  WHERE ' ||
                   ' network = :n';
      EXECUTE IMMEDIATE query_str INTO part_table_name USING sys.dbms_assert.noop(network);
      RETURN part_table_name;
   END get_part_table_name;

--
--
--
FUNCTION get_num_traf_patterns(network_name IN VARCHAR2, sampling_id IN NUMBER)
                                                          RETURN number IS
   query_str                                    varchar2(512);
   num_patterns                                 number;
   network              VARCHAR2(128);
   BEGIN
       network := UPPER(network_name);
       query_str := 'SELECT number_of_patterns FROM '||
                    ' NDM_TRAFFIC_METADATA ' ||
                    ' WHERE network_name = :n AND ' ||
                    ' sampling_id = :s ';
       execute immediate query_str into num_patterns
                                        using network, sampling_id;
       return num_patterns;
   END get_num_traf_patterns;
--
--
--
-- Creates a link speed table with just one link speed series.
-- table name : network_name+'D_LINK_SPEED$'
--
PROCEDURE create_single_patt_speed_table (network_name IN VARCHAR2) IS
   query_str 		 	varchar2(8192);
   link_speed_table_name 	varchar2(64);
   traf_patt_tables		sdo_string_array;
   traffic_pattern_table	varchar2(128);
   traffic_unit			varchar2(10);
   column_name			varchar2(32);
   BEGIN
      
--
-- Create table with links and speed series
--
     link_speed_table_name := network_name || '_S_P_LINK_SPEED$';
     IF table_exists(link_speed_table_name) THEN
	EXECUTE IMMEDIATE 'drop table ' || 
			  sys.dbms_assert.qualified_sql_name(link_speed_table_name) ||
			  ' purge' ;
     END IF;

     query_str := 'CREATE TABLE ' ||
		  sys.dbms_assert.qualified_sql_name(link_speed_table_name) ||
		  ' (link_id number, link_speed_series sdo_number_array) ';
     EXECUTE IMMEDIATE query_str;

-- Getting required parameters from traffic metadata
      traf_patt_tables := get_link_traf_patt_tables(network_name);
      traffic_pattern_table := traf_patt_tables(1);

-- Getting the column name for link speed series from traffic pattern table
-- Here the convention is the column name for speed series starts with 'link_speed_series'
      query_str := 'SELECT column_name from user_tab_columns WHERE table_name = :a ' ||
		   ' AND ' || ' column_name like ''LINK_SPEED_SERIES%'' ';
      execute immediate query_str into column_name using traffic_pattern_table;
   

-- Here link has only one speed series ; so, a single table is chosen.
      query_str := 'INSERT INTO ' || 
                   sys.dbms_assert.qualified_sql_name(link_speed_table_name) ||
                   ' (link_id,link_speed_series) ' ||
                   ' SELECT link_id,' || column_name || ' FROM ' ||
                   traffic_pattern_table;
      execute immediate query_str;

END create_single_patt_speed_table;

--
-- The following procedure loads speed values from a csv file into a table
-- It is assumed that each row is identified by tmc code
--
PROCEDURE load_speeds_from_csv_file (network_name IN varchar2,
                                     csv_file_name IN varchar2,
                                     tp_table_name IN varchar2,
                                     num_intervals IN number,
				     log_loc  IN varchar2,
				     log_file IN varchar2,
				     open_mode IN varchar2) IS

   columns_str                  	varchar2(2048);
   query_str                    	varchar2(4096);
   time_str                     	varchar2(32);
   hr_str                       	varchar2(8);
   min_str                      	varchar2(8);
   column_name                  	varchar2(64);
   incr                         	number;
   index_name				varchar2(64);
   ext_table_name               	varchar2(32);
   traf_log_file			utl_file.file_type := NULL;
   show_time				boolean;
   BEGIN
--   Open log file
      traf_log_file := utl_file.fopen(log_loc,log_file,open_mode);
      traffic_util.set_log_info(traf_log_file);
      show_time := true;

      time_str  := '00:00';
      columns_str := '';

      ext_table_name  := network_name || '_TRAF_PATT_EXT';
      if table_exists(ext_table_name) then
         execute immediate 'drop table ' || ext_table_name || ' purge';
      end if;
--    Assumes that the num_intervals spans 24 hours of a day
--    Assumes that num_intervals is small enough so that the interval size 
--    is in minutes
--    For example, num_intervals = 96 -> interval size = 15 minutes
      incr            := (24/num_intervals)*60;
      for i IN 1 .. num_intervals loop
         hr_str     := substr(time_str,1,2);
         min_str    := substr(time_str,4,2);
         column_name := ' H' || hr_str || '_' || min_str || '  number';
         dbms_output.put_line(' ** '||column_name);
         columns_str := columns_str || column_name;
         if (i<num_intervals) then
            columns_str := columns_str||',';
         end if;
         time_str :=  to_char((to_date(time_str,'HH24:MI')+incr/1440),'HH24:MI');
      end loop;
      columns_str := '(TMC varchar2(10), ' || columns_str || ')';

      traffic_util.log_message('------ START : Loading from csv file '||csv_file_name,true);
      traffic_util.log_message('------ Start : Create external file  ------',show_time);
      query_str := 'CREATE TABLE ' || ext_table_name ||
                   columns_str ||
                   ' ORGANIZATION EXTERNAL ' ||
                   ' ( TYPE ORACLE_LOADER ' ||
                   '   DEFAULT DIRECTORY NDM_TRAFFIC_DIR ' ||
                   '   ACCESS PARAMETERS ' ||
                   '   (RECORDS delimited by newline ' ||
                   '    FIELDS terminated by '','') '   ||
                   ' LOCATION (''' || csv_file_name || ''') ) ' ||
                   ' REJECT LIMIT UNLIMITED ';
      execute immediate query_str;
      traffic_util.log_message('------ End : Create external file  ------ ',show_time);

      if (table_exists(tp_table_name)) then
        execute immediate 'drop table ' || tp_table_name || ' purge';
      end if;
      query_str := 'CREATE TABLE ' || tp_table_name  ||
                   columns_str;
      execute immediate query_str;

      traffic_util.log_message('------ Start : Insert values into DB table '||tp_table_name,show_time);
      query_str := 'INSERT INTO ' || tp_table_name ||
                ' SELECT * FROM ' || ext_table_name;
      execute immediate query_str;
      traffic_util.log_message('------ End : Insert values into DB table '||tp_table_name,show_time);

      if (table_exists(ext_table_name)) then
         execute immediate 'drop table ' || ext_table_name || ' purge';
      end if;
--    Create indexes
      index_name := 'nvt' || substr(tp_table_name,6)||'_str5_idx';
      if (not (index_exists(index_name))) then
         execute immediate 'create index ' || index_name || ' on ' ||
			   tp_table_name || '(substr(tmc,5)) ';
      end if;
      index_name := 'nvt' || substr(tp_table_name,6)||'_str41_idx';
       if (not (index_exists(index_name))) then
         execute immediate 'create index ' || index_name || ' on ' ||
                           tp_table_name || '(substr(tmc,4,1)) ';
      end if;

      traffic_util.log_message('------ END : Loading from csv file '||csv_file_name,true);
      utl_file.fclose(traf_log_file);
   END load_speeds_from_csv_file;

--
-- The following procedure loads rdf_link_tmc from csv file
--
PROCEDURE load_rdf_link_tmc_from_csv(network_name IN varchar2,
				     csv_file_name IN varchar2,
				     rdf_table_name IN varchar2,
				     log_loc  IN varchar2,
                                     log_file IN varchar2,
                                     open_mode IN varchar2) IS
   ext_table_name			varchar2(32);
   query_str				varchar2(4096);
   columns_str				varchar2(1024);
   traf_log_file			utl_file.file_type := NULL;
   show_time				boolean;
   BEGIN
--    Open log file
      traf_log_file := utl_file.fopen(log_loc,log_file,open_mode);
      traffic_util.set_log_info(traf_log_file);
      show_time := true;
      traffic_util.log_message('------ START : Loading from csv file '||csv_file_name,true);
      traffic_util.log_message('------ Start : Create external file  ------',show_time);
      ext_table_name := 'NDM_RDF_LINK_TMC_EXT';
      columns_str := '(link_id number, ebu_country_code varchar2(20),'||
		     'location_table_nr number, tmc_path_direction varchar2(10),'||
		     'location_code number, road_direction varchar2(10))';
      query_str := 'CREATE TABLE ' || ext_table_name ||
                   columns_str ||
                   ' ORGANIZATION EXTERNAL ' ||
                   ' ( TYPE ORACLE_LOADER ' ||
                   '   DEFAULT DIRECTORY NDM_TRAFFIC_DIR ' ||
                   '   ACCESS PARAMETERS ' ||
                   '   (RECORDS delimited by newline ' ||
                   '    FIELDS terminated by '','') '   ||
                   ' LOCATION (''' || csv_file_name || ''') ) ' ||
                   ' REJECT LIMIT UNLIMITED ';
      execute immediate query_str;
      traffic_util.log_message('------ End : Create external file  ------ ',show_time);
      if (table_exists(rdf_table_name)) then
        execute immediate 'drop table ' || rdf_table_name || ' purge';
      end if;
      query_str := 'CREATE TABLE ' || rdf_table_name  ||
                   columns_str;
      execute immediate query_str;

      traffic_util.log_message('------ Start : Insert values into DB table '||rdf_table_name,show_time);
      query_str := 'INSERT INTO ' || rdf_table_name ||
                ' SELECT * FROM ' || ext_table_name;
      execute immediate query_str;
      traffic_util.log_message('------ End : Insert values into DB table '||rdf_table_name,show_time);

      if (table_exists(ext_table_name)) then
         execute immediate 'drop table ' || ext_table_name || ' purge';
      end if;
      traffic_util.log_message('------ END : Loading from csv file '||csv_file_name,true);
      utl_file.fclose(traf_log_file);

      traffic_util.log_message('------ END : Loading from csv file '||csv_file_name,true);

    END load_rdf_link_tmc_from_csv;

--
-- The following procedure loads csv files (Navteq) for USA and Canada.
--
PROCEDURE load_speeds_from_all_csv_files(network_name IN varchar2,
					 country_code IN varchar2,
					 log_loc  IN varchar2,
					 log_file IN varchar2,
					 open_mode IN varchar2) IS
   query_str				varchar2(1024);
   table_name				varchar2(32);
   traf_log_file			utl_file.file_type := NULL;
   show_time				boolean;
  

   BEGIN
--    Open log file
      traf_log_file := utl_file.fopen(log_loc,log_file,open_mode);
      traffic_util.set_log_info(traf_log_file);
      show_time := true;
      traffic_util.log_message('****** START : Loading from csv files ******',show_time);

      load_speeds_from_csv_file('ODF_NA_Q309','NTP_CAN_15MIN_MWTR_08101.csv','NVT_CAN_TP_MON_THURS',96,'WORK_DIR','traffic.log','a');
      load_speeds_from_csv_file('ODF_NA_Q309','NTP_CAN_15MIN_F_08101.csv','NVT_CAN_TP_FRIDAY',96,'WORK_DIR','traffic.log','a');
      load_speeds_from_csv_file('ODF_NA_Q309','NTP_CAN_15MIN_S_08101.csv','NVT_CAN_TP_SATURDAY',96,'WORK_DIR','traffic.log','a');
      load_speeds_from_csv_file('ODF_NA_Q309','NTP_CAN_15MIN_SU_08101.csv','NVT_CAN_TP_SUNDAY',96,'WORK_DIR','traffic.log','a');
      load_speeds_from_csv_file('ODF_NA_Q309','NTP_USA_15MIN_MWTR_08101.csv','NVT_USA_TP_MON_THURS',96,'WORK_DIR','traffic.log','a');
      load_speeds_from_csv_file('ODF_NA_Q309','NTP_USA_15MIN_F_08101.csv','NVT_USA_TP_FRIDAY',96,'WORK_DIR','traffic.log','a');
      load_speeds_from_csv_file('ODF_NA_Q309','NTP_USA_15MIN_S_08101.csv','NVT_USA_TP_SATURDAY',96,'WORK_DIR','traffic.log','a');
      load_speeds_from_csv_file('ODF_NA_Q309','NTP_USA_15MIN_SU_08101.csv','NVT_USA_TP_SUNDAY',96,'WORK_DIR','traffic.log','a');
      traffic_util.log_message('****** END : Loading from csv files ******',show_time);

--    Performing union operation on tables for USA and Canada
--    to generate tables for the entire North America
      table_name := 'NVT_NA_TP_MON_THURS';
      if table_exists(table_name) then
         execute immediate 'drop table ' || table_name || ' purge';
      end if;
      
      query_str := 'CREATE TABLE ' || table_name || ' AS ' ||
		   ' SELECT * FROM NVT_USA_TP_MON_THURS ' || ' UNION ' ||
		   ' SELECT * FROM NVT_CAN_TP_MON_THURS ';
      execute immediate query_str;

      table_name := 'NVT_NA_TP_FRIDAY';
      if table_exists(table_name) then
         execute immediate 'drop table ' || table_name || ' purge';
      end if;

      query_str := 'CREATE TABLE ' || table_name || ' AS ' ||
                   ' SELECT * FROM NVT_USA_TP_FRIDAY ' || ' UNION ' ||
                   ' SELECT * FROM NVT_CAN_TP_FRIDAY ';
      execute immediate query_str;

      table_name := 'NVT_NA_TP_SATURDAY';
      if table_exists(table_name) then
         execute immediate 'drop table ' || table_name || ' purge';
      end if;

      query_str := 'CREATE TABLE ' || table_name || ' AS ' ||
                   ' SELECT * FROM NVT_USA_TP_SATURDAY ' || ' UNION ' ||
                   ' SELECT * FROM NVT_CAN_TP_SATURDAY ';
      execute immediate query_str;

      table_name := 'NVT_NA_TP_SUNDAY';
      if table_exists(table_name) then
         execute immediate 'drop table ' || table_name || ' purge';
      end if;

      query_str := 'CREATE TABLE ' || table_name || ' AS ' ||
                   ' SELECT * FROM NVT_USA_TP_SUNDAY ' || ' UNION ' ||
                   ' SELECT * FROM NVT_CAN_TP_SUNDAY ';
      execute immediate query_str;
      commit;

--    Creating indexes
      execute immediate 'create index nvt_mon_thur_str5_idx on nvt_na_tp_mon_thurs(substr(tmc,5))';
      execute immediate 'create index nvt_fri_str5_idx on nvt_na_tp_friday(substr(tmc,5))';
      execute immediate 'create index nvt_sat_str5_idx on nvt_na_tp_saturday(substr(tmc,5))';
      execute immediate 'create index nvt_sun_str5_idx on nvt_na_tp_sunday(substr(tmc,5))';
      execute immediate 'create index nvt_mon_thur_str41_idx on nvt_na_tp_mon_thurs(substr(tmc,4,1))';
      execute immediate 'create index nvt_fri_str41_idx on nvt_na_tp_friday(substr(tmc,4,1))';
      execute immediate 'create index nvt_sat_str41_idx on nvt_na_tp_saturday(substr(tmc,4,1))';
      execute immediate 'create index nvt_sun_str41_idx on nvt_na_tp_sunday(substr(tmc,4,1))';
      commit;
    
      utl_file.fclose(traf_log_file);

   END load_speeds_from_all_csv_files;

--
-- The following procedure is an example to construct link-speed series tables
-- from tables (navteq) from speed patterns for locations
--
PROCEDURE convert_to_ndm_speed_tables(network_name IN varchar2,
                                      tp_input_table IN varchar2,
                                      link_to_loc_map_table IN varchar2,
                                      sampling_id IN number,
                                      tp_output_table IN varchar2,
                                      log_loc  IN varchar2,
                                      log_file IN varchar2,
                                      open_mode IN varchar2) IS
num_intervals				number;
incr					number;
to_link_mapping_col			varchar2(32);
speed_patt_table			varchar2(32);
link_to_location_table			varchar2(32);
link_table_name				varchar2(32);
out_table				varchar2(32);
speed_limit_col				varchar2(32);
length_col				varchar2(32);
traf_attribute				varchar2(32);
traffic_unit				varchar2(32);
query_str				varchar2(4096);
columns_str				varchar2(4096);
column_name				varchar2(16);
time_str				varchar2(12);
hr_str					varchar2(6);
min_str					varchar2(6);
traf_log_file                     	utl_file.file_type := NULL;
BEGIN
-- Open log file
      traf_log_file := utl_file.fopen(log_loc,log_file,open_mode);
      traffic_util.set_log_info(traf_log_file);
      
      num_intervals := get_num_time_intervals(network_name);
      to_link_mapping_col := 'TMC';
      speed_patt_table := sys.dbms_assert.qualified_sql_name(tp_input_table);
      link_to_location_table := sys.dbms_assert.qualified_sql_name(link_to_loc_map_table);
      out_table := sys.dbms_assert.qualified_sql_name(tp_output_table);
      link_table_name	:= get_link_table_name(network_name);
      speed_limit_col := get_link_speed_limit_column(network_name);
      length_col := get_link_length_column(network_name);
      traf_attribute := 'speed';
      traffic_unit := 'mph'; 

      traffic_util.log_message('****** Set log to file ' || log_file || ' in directory ' || log_loc, false);
      traffic_util.log_message('****** START CONVERSION ****** ',true);
      
      if (table_exists('RDF_LINK_TMC_MODIFIED')) then
         execute immediate 'drop table RDF_LINK_TMC_MODIFIED purge';
      end if;

      query_str := 'CREATE TABLE RDF_LINK_TMC_MODIFIED '||
                   ' (link_id number, tmc_path_direction varchar2(1),'||
                   ' location_code number) NOLOGGING';
      execute immediate query_str;

      query_str := 'INSERT /*+ APPEND */ INTO RDF_LINK_TMC_MODIFIED '||
                   ' SELECT link_id link_id, tmc_path_direction  tmc_path_direction,'||
                   '  min(location_code) location_code '||
                   ' FROM '||link_to_location_table||
                   ' GROUP BY link_id, tmc_path_direction';
      execute immediate query_str;
      commit;

      columns_str := '';
      time_str    := '00:00';
      incr        := (24/num_intervals)*60;
      
--    Construct columns-string H00_00 .. HH23_45
      for i in 1 .. num_intervals loop
          hr_str  := substr(time_str,1,2);
          min_str := substr(time_str,4,2);       
          column_name := 'H'||hr_str||'_'||min_str;
          columns_str := columns_str||' nvt.'||column_name;
          if (i<num_intervals) then
             columns_str := columns_str||',';
          end if;
          time_str := to_char((to_date(time_str,'HH24:MI')+incr/1440),'HH24:MI');
      end loop;
      columns_str := 'sdo_number_array('||columns_str||') ';

      if (table_exists('TEST_TRAFFIC_PATTERNS')) then
          execute immediate 'drop table TEST_TRAFFIC_PATTERNS purge';
      end if;

      query_str := 'CREATE TABLE TEST_TRAFFIC_PATTERNS '||
                   ' (link_id number, sampling_id number,'||
                   ' tmc_location_code varchar2(5),tmc_path_direction varchar2(1), '||
                   ' direction_from_nvt varchar2(1), link_speed_series sdo_number_array) '||
                   ' NOLOGGING ';
      execute immediate query_str;

      query_str := 'INSERT /*+ APPEND */ INTO TEST_TRAFFIC_PATTERNS '||
                   ' SELECT t1.link_id, :s, t1.location_code, '||
                   ' t1.tmc_path_direction tmc_path_direction, '||
                   ' substr(nvt.tmc,4,1) direction_from_nvt, '|| columns_str ||
                   ' FROM '|| speed_patt_table || ' nvt, '||
                   ' RDF_LINK_TMC_MODIFIED t1 '||
                   ' WHERE t1.location_code=substr(nvt.tmc,5) AND '||
                   ' ((substr(nvt.tmc,4,1)=''N'' AND '||
                   ' (t1.tmc_path_direction=''-'' or t1.tmc_path_direction=''N'')) OR '||
                   ' (substr(nvt.tmc,4,1)=''P'' AND '||
                   ' (t1.tmc_path_direction=''+'' or t1.tmc_path_direction=''P''))) ';
      execute immediate query_str using sampling_id;  
      commit;

      if (table_exists('TR_TEMPTABLE1')) then
         execute immediate 'drop table TR_TEMPTABLE1 purge';
      end if;

      query_str := 'CREATE TABLE TR_TEMPTABLE1 NOLOGGING AS '||
                   ' SELECT link_id, tmc_location_code, '||
                   ' tmc_path_direction, direction_from_nvt '||
                   ' FROM TEST_TRAFFIC_PATTERNS  ';
      execute immediate query_str;
      commit;

      if (table_exists('TR_TEMPTABLE2')) then
         execute immediate 'drop table TR_TEMPTABLE2 purge';
      end if;

      query_str := 'CREATE TABLE TR_TEMPTABLE2 NOLOGGING AS '||
                   ' SELECT link_id, direction_from_nvt, '||
                   ' min(tmc_location_code) tmc_location_code '||
                   ' FROM TR_TEMPTABLE1 '||
                   ' GROUP BY link_id, direction_from_nvt ';
      execute immediate query_str;
      commit;
      
      if (table_exists('TEMP_TRAFFIC_FINAL')) then
           execute immediate 'drop table TEMP_TRAFFIC_FINAL purge';
      end if;
 
      query_str := 'CREATE TABLE TEMP_TRAFFIC_FINAL NOLOGGING AS '||
                   ' SELECT t1.link_id, t2.sampling_id, t1.tmc_location_code,'||
                   ' t1.direction_from_nvt, t2.link_speed_series '||
                   ' FROM TR_TEMPTABLE2 t1, test_traffic_patterns t2 '||
                   ' WHERE t1.link_id = t2.link_id AND '||
                   ' t1.tmc_location_code=t2.tmc_location_code AND '||
                   ' t1.direction_from_nvt=t2.direction_from_nvt ';
      execute immediate query_str;
      commit;

      if (table_exists(out_table)) then
         execute immediate 'drop table '||out_table||' purge';
      end if;

      query_str := 'CREATE TABLE '||out_table||
                   ' (link_id number, sampling_id number, link_speed_series sdo_number_array) '||
                   ' NOLOGGING ';
      execute immediate query_str;

      query_str := 'INSERT /*+ APPEND */ INTO '||out_table||
                   ' SELECT  link_id, :s, link_speed_series '||
                   ' FROM  temp_traffic_final '||
                   ' WHERE  direction_from_nvt=''P'' ';
      execute immediate query_str using sampling_id;
      commit;

      query_str := 'INSERT /*+ APPEND */ INTO '||out_table||
                   ' SELECT  -link_id link_id, :s, link_speed_series '||
                   ' FROM  temp_traffic_final '||
                   ' WHERE  direction_from_nvt=''N'' ';
      execute immediate query_str using sampling_id;
      commit;
      
      traffic_util.log_message('****** END CONVERSION ****** ',true); 
      utl_file.fclose(traf_log_file);

      if (table_exists('RDF_TMC_LINK_MODIFIED')) then
          execute immediate 'drop table rdf_tmc_link_modified purge';
      end if;
      if (table_exists('TEST_TRAFFIC_PATTERNS')) then
          execute immediate 'drop table test_traffic_patterns purge';
      end if;
      if (table_exists('TR_TEMPTABLE1')) then
          execute immediate 'drop table tr_temptable1 purge';
      end if;
      if (table_exists('TR_TEMPTABLE2')) then
          execute immediate 'drop table tr_temptable2 purge';
      end if;
      if (table_exists('TEMP_TRAFFIC_FINAL')) then
          execute immediate 'drop table temp_traffic_final purge';
      end if;

END convert_to_ndm_speed_tables;
/*
PROCEDURE convert_to_ndm_speed_tables(network_name IN varchar2,
				      tp_input_table IN varchar2,
				      link_to_loc_map_table IN varchar2,
				      sampling_id IN number,
				      tp_output_table IN varchar2,
				      log_loc  IN varchar2,
				      log_file IN varchar2,
				      open_mode IN varchar2) IS
      patt_table			varchar2(32);
      table_name			varchar2(32);
      temp_table			varchar2(32);
      to_link_mapping_col		varchar2(32);
      link_to_location_table		varchar2(32);
      link_table_name			varchar2(32);
      columns_str			varchar2(4096);
      column_name			varchar2(4096);
      conv_factor			number;
      precision				integer := 3;
      traffic_unit			varchar2(16);
      insert_columns			varchar2(256);
      query_str				varchar2(8192);
      num_intervals 			number;
      traf_attribute               	varchar2(36);
      link_series_str              	varchar2(512);
      select_str                   	varchar2(512);
      attr_str                     	varchar2(512);
      attr_name                    	varchar2(128);
      speed_limit_col              	varchar2(24);
      length_col                   	varchar2(24);
      unique_linkid_table		varchar2(32);
      rdf_pos_temp_table		varchar2(32);
      rdf_neg_temp_table		varchar2(32);
      rdf_p_unique_lid_table		varchar2(32); 
      rdf_n_unique_lid_table		varchar2(32); 
      index_name			varchar2(32);
      link_traf_patt_tables		sdo_string_array;
      show_time				boolean;
      time_str                     	varchar2(32);
      hr_str                       	varchar2(8);
      min_str                      	varchar2(8);
      incr                         	number;
      interval_columns             	varchar2(4096);
      rdf_columns			varchar2(1024);
      traf_log_file			utl_file.file_type := NULL;
   BEGIN
-- Open log file
      traf_log_file := utl_file.fopen(log_loc,log_file,open_mode);
      traffic_util.set_log_info(traf_log_file);
      
      num_intervals := get_num_time_intervals(network_name);
      to_link_mapping_col := 'TMC';
      link_to_location_table := link_to_loc_map_table;
      link_table_name	:= get_link_table_name(network_name);
      speed_limit_col := get_link_speed_limit_column(network_name);
      length_col := get_link_length_column(network_name);
      traf_attribute := 'speed';
      traffic_unit := 'mph'; 

      patt_table := tp_input_table;
      table_name := tp_output_table;
      show_time := true;
      traffic_util.log_message('****** Set log to file ' || log_file || ' in directory ' || log_loc, false);
      traffic_util.log_message('****** START CONVERSION ****** ',true);
      if table_exists(table_name) then
            traffic_util.log_message('------ Dropping table '||table_name,show_time);
	    execute immediate 'drop table '|| table_name || ' purge';
      end if;
      columns_str := ' (link_id number, sampling_id number, '|| 
			' link_speed_series ' ||
			'  sdo_number_array) ';
      query_str := 'CREATE TABLE ' || sys.dbms_assert.qualified_sql_name(table_name) ||
		      columns_str || '  NOLOGGING ';
      traffic_util.log_message('------ Created table '||table_name,show_time);
      execute immediate query_str;
         
      columns_str := null;
      for k IN 1 .. num_intervals loop
 	 column_name := traf_attribute || '_' || k || ' number';
	 columns_str := concat(columns_str,column_name);
         if k<num_intervals then
            columns_str := concat(columns_str,',');
	 end if;
      end loop;         

      time_str  := '00:00';
      incr            := (24/num_intervals)*60;
      interval_columns := '';

-- Determining the conversion factor for speed
      if (trim(traffic_unit)='mph') then
             conv_factor := round(16/36,3);
      elsif (trim(traffic_unit)='kmph') then
             conv_factor := round(10/36,3);
      elsif (trim(traffic_unit)='mps') then
             conv_factor := 1;
      elsif (trim(traffic_unit)='s') then
             conv_factor := 1;
      end if;
	
      for i IN 1 .. num_intervals loop
           hr_str     := substr(time_str,1,2);
           min_str    := substr(time_str,4,2);
           column_name := 'H' || hr_str || '_' || min_str;
           interval_columns := interval_columns || 
                              ' round(nvt.'||column_name||'*'||conv_factor||
                              ','||precision||')';
           if (i<num_intervals) then
              interval_columns := interval_columns || ',';
           end if;
           time_str :=  to_char((to_date(time_str,'HH24:MI')+incr/1440),'HH24:MI');
      end loop; 

      interval_columns := 'sdo_number_array('||interval_columns||')';

--
--  Find the RDF table link IDs that match positive link IDs in the link table
--
      rdf_pos_temp_table := 'rdf_link_tmc_p_subset';
      if table_exists(rdf_pos_temp_table) then
	  execute immediate 'drop table ' || rdf_pos_temp_table || ' purge';
      end if;
      traffic_util.log_message('------ Start :: Create '||rdf_pos_temp_table,show_time);
      query_str := 'CREATE TABLE ' || rdf_pos_temp_table || ' NOLOGGING AS ' ||
		   ' SELECT link_id,tmc_path_direction,location_code,road_direction '||
		   ' FROM ' || 
		   sys.dbms_assert.qualified_sql_name(link_to_location_table) ||
                   ' WHERE link_id IN (SELECT link_id FROM ' ||
		   sys.dbms_assert.qualified_sql_name(link_table_name) ||
                   ')';
      execute immediate query_str;     
   --   execute immediate 'create index rdf_p_lid_idx on ' || rdf_pos_temp_table || '(link_id)' ;
      traffic_util.log_message('------ End :: Create '||rdf_pos_temp_table,show_time);
     commit;

--
--  Find the RDF table link IDs that match negative link IDs in the link table
--
      rdf_neg_temp_table := 'rdf_link_tmc_n_subset';
      if table_exists(rdf_neg_temp_table) then
	  execute immediate 'drop table ' || rdf_neg_temp_table || ' purge';
      end if;
      traffic_util.log_message('------ Start :: Create '||rdf_neg_temp_table,show_time);
      query_str := 'CREATE TABLE ' || rdf_neg_temp_table || ' NOLOGGING AS ' ||
                   ' SELECT link_id,tmc_path_direction,location_code,road_direction '||
                   ' FROM ' ||
                   sys.dbms_assert.qualified_sql_name(link_to_location_table) ||
                   ' WHERE -link_id IN (SELECT link_id FROM ' ||
                   sys.dbms_assert.qualified_sql_name(link_table_name) ||
                   ')';
      execute immediate query_str;
 --     execute immediate 'create index rdf_n_lid_idx on ' || rdf_neg_temp_table || '(link_id)' ;
      traffic_util.log_message('------ End :: Create '||rdf_neg_temp_table,show_time);
      commit;

--
--  Eliminate repeating link IDs
--
      rdf_p_unique_lid_table := 'rdf_p_unique_link_id';
      if table_exists(rdf_p_unique_lid_table) then
	  execute immediate 'drop table ' || rdf_p_unique_lid_table || ' purge';
      end if;
      traffic_util.log_message('------ Start :: Create '||rdf_p_unique_lid_table,show_time);
      query_str := 'create table ' || rdf_p_unique_lid_table || ' nologging as '||
       		   ' select * from ' || rdf_pos_temp_table || ' where rowid in ' ||
                      ' (select min(rowid) from ' ||  rdf_pos_temp_table ||
                                          '  group by link_id)';
      execute immediate query_str;
      traffic_util.log_message('------ End :: Create '||rdf_p_unique_lid_table,show_time);

      rdf_n_unique_lid_table := 'rdf_n_unique_link_id';
      if table_exists(rdf_n_unique_lid_table) then
	  execute immediate 'drop table ' || rdf_n_unique_lid_table || ' purge';
      end if;
      traffic_util.log_message('------ Start :: Create '||rdf_n_unique_lid_table,show_time);
      query_str := 'create table ' || rdf_n_unique_lid_table || ' nologging as '||
                   ' select * from ' || rdf_neg_temp_table || ' where rowid in ' ||
                      ' (select min(rowid) from ' ||  rdf_neg_temp_table ||
                                          '  group by link_id)';
      execute immediate query_str;
      traffic_util.log_message('------ End :: Create '||rdf_n_unique_lid_table,show_time);

--      execute immediate 'create index rdf_p_u_lid_idx on ' || rdf_p_unique_lid_table || '(link_id)';
--      execute immediate 'create index rdf_p_u_rdir_idx on ' || rdf_p_unique_lid_table || '(road_direction)';
--      execute immediate 'create index rdf_p_u_lc_idx on ' || rdf_p_unique_lid_table || '(location_code)';
--      execute immediate 'create index rdf_p_u_tpdir_idx on ' || rdf_p_unique_lid_table || '(tmc_path_direction)';
--      execute immediate 'create index rdf_n_u_lid_idx on ' || rdf_n_unique_lid_table || '(link_id)';
--      execute immediate 'create index rdf_n_u_rdir_idx on ' || rdf_n_unique_lid_table || '(road_direction)';
--      execute immediate 'create index rdf_n_u_lc_idx on ' || rdf_n_unique_lid_table || '(location_code)';
--      execute immediate 'create index rdf_n_u_tpdir_idx on ' || rdf_n_unique_lid_table || '(tmc_path_direction)';

      commit;
      execute immediate 'drop table ' || rdf_pos_temp_table || ' purge';
      execute immediate 'drop table ' || rdf_neg_temp_table || ' purge';

      traffic_util.log_message('------ Start insert (+ direction) in '||table_name,show_time);
      query_str := 'INSERT /*+ APPEND  INTO '|| table_name ||
		   ' SELECT t1.link_id,:a, '||interval_columns|| ' FROM ' ||
		   rdf_p_unique_lid_table || ' t1, ' ||
		   sys.dbms_assert.qualified_sql_name(patt_table) || ' nvt ' ||
		   ' where t1.location_code = substr(nvt.tmc,5) AND ' ||
                   ' substr(nvt.tmc,4,1) = ''P'' AND ' ||
                   ' (t1.tmc_path_direction = ''P'' OR t1.tmc_path_direction = ''+'') '||
                   ' AND (t1.road_direction = ''T'' OR t1.road_direction is NULL)';
      execute immediate query_str using sampling_id;
      traffic_util.log_message('------ End insert (+ direction) in '||table_name,show_time);
      commit;      

      traffic_util.log_message('------ Start insert (- direction) in '||table_name,show_time);
      query_str := 'INSERT /*+ APPEND  INTO '|| table_name ||
                   ' SELECT t1.link_id,:a, '||interval_columns|| ' FROM ' ||
                   rdf_n_unique_lid_table || ' t1, ' ||
                   sys.dbms_assert.qualified_sql_name(patt_table) || ' nvt ' ||
                   ' where t1.location_code = substr(nvt.tmc,5) AND ' ||
                   ' substr(nvt.tmc,4,1) = ''N'' AND ' ||
                   ' (t1.tmc_path_direction = ''N'' OR t1.tmc_path_direction = ''-'') '||
                   ' AND (t1.road_direction = ''F'' OR t1.road_direction is NULL)';
      execute immediate query_str using sampling_id;
      index_name := table_name||'_lid_idx';
      traffic_util.log_message('------ End insert (- direction) in '||table_name,show_time);
     -- execute immediate 'create index ' || index_name || ' on ' || table_name || '(link_id)';
      commit;
      execute immediate 'drop table ' || rdf_p_unique_lid_table || ' purge';
      execute immediate 'drop table ' || rdf_n_unique_lid_table || ' purge';

--
--    Eliminate duplicate link IDs. Copy to a new table
--
      unique_linkid_table := table_name || '_UNIQUE_LINKID';
      columns_str := '(link_id number,sampling_id number,link_speed_series sdo_number_array)';
      if table_exists(unique_linkid_table) then
	   execute immediate 'drop table ' || unique_linkid_table || ' purge';
      end if;
      query_str := 'CREATE TABLE '|| unique_linkid_table ||
                 columns_str || ' NOLOGGING ';
      execute immediate query_str;
      traffic_util.log_message('------ Start insert in  '|| unique_linkid_table ||' from '||table_name,show_time);
      query_str :=  'INSERT /*+ APPEND  INTO ' || unique_linkid_table ||
                 ' SELECT *  FROM '|| table_name || ' a WHERE ' ||
                 ' rowid IN (SELECT min(rowid) FROM ' || table_name || ' b ' ||
                 ' GROUP BY link_id)';
      execute immediate query_str;
      traffic_util.log_message('------ End insert in  '||table_name||'_UNIQUE_LINKID '||' from '||table_name,show_time);
      commit;
--
-- Drop the original table
--
      query_str := 'DROP TABLE ' || table_name || ' PURGE';
      execute immediate query_str;
      traffic_util.log_message('------ Dropped table  ' ||table_name,show_time);
      commit;
--
-- Rename the unique link ID table to 'table_name'
--
      query_str := 'ALTER TABLE ' || unique_linkid_table || ' RENAME TO ' || table_name;
      execute immediate query_str;
      commit;
      traffic_util.log_message('------ Altered table name to  ' ||table_name,show_time);
      
      traffic_util.log_message('------ Creating index on '||table_name||'(link Id)',show_time);
      execute immediate 'create index ' || index_name || ' on ' || table_name || '(link_id)';
      traffic_util.log_message('------ Created index on '||table_name||'(link Id)',show_time);
      commit;

-- Retrieve LINK_TRAFFIC_PATTERN_TABLES from metadata
--      query_str := 'SELECT link_tp_tables FROM ndm_traffic_metadata' ||
--		   ' WHERE upper(network_name) = :a';
--      execute immediate query_str into link_traf_patt_tables using upper(network_name); 
   
-- Insert the final link speed tables (with a schema required by NDM) in metadata
--      if (link_traf_patt_tables is  null) then
--         link_traf_patt_tables := sdo_string_array();
--      end if;
--      link_traf_patt_tables.extend;
--      link_traf_patt_tables(link_traf_patt_tables.last) := tp_output_table;
--      query_str := 'UPDATE ndm_traffic_metadata ' || ' SET ' ||
--		   ' link_tp_tables = :a WHERE ' ||
--		   ' upper(network_name) = :b ';
--      execute immediate query_str using link_traf_patt_tables,upper(network_name);   
--      traffic_util.log_message('------ Modified metadata; added the speed table names',show_time);

     traffic_util.log_message('****** END CONVERSION ****** ',true);
      utl_file.fclose(traf_log_file);
   END convert_to_ndm_speed_tables;
*/

--
-- Creates a link speed table with each link associated with multiple patterns
-- one series per pattern.
-- Table name : network_name+'_LINK_SPEED$'
--
PROCEDURE create_link_speeds_table(network_name IN VARCHAR2,
                                   output_table IN VARCHAR2,
				   log_loc  IN varchar2,
				   log_file IN varchar2,
				   open_mode IN varchar2) IS
   query_str			varchar2(8192);
   link_table_name        	varchar2(128);
   link_speed_table_name 	varchar2(128);
   traf_patt_table		varchar2(128);
   traf_attr			varchar2(32);
   column_1			varchar2(128);
   column_2			varchar2(128);
   nt_name			varchar2(128);
   id_col_name			varchar2(32);
   speed_col_name		varchar2(32);
   column_name			varchar2(128);
   columns_str                  varchar2(8192);
   column_names                 varchar2(4096);
   temptable                    varchar2(128);
   traf_patt_tables             sdo_string_array;
   tp_index_array		sdo_number_array := sdo_number_array();
   num_patterns			number;
   pattern_table        varchar2(128);
   speed_series_size            number;
   sampling_id			number;
   select_columns		varchar2(2048);
   link_series_str		varchar2(2048);
   attr_name			varchar2(128);
   tables_str			varchar2(1024);
   conditions_str		varchar2(2048);   
   insert_str                   varchar2(512);
   attr_str                     varchar2(512);
   temptable1			varchar2(32);
   temptable2			varchar2(32);
   pid_table			varchar2(32);
   speed_limit_col              varchar2(24);
   traf_log_file		utl_file.file_type := NULL;
   show_time			boolean;
   BEGIN
--
-- Create the table with links and speed series
-- markers are used to mark the beginning of each series. 
-- one link series per group (such as mon-thurs, fri, sat sun)
-- Schema : link_id, speed series_1,
--                   speed series_2....
--
      traf_log_file := utl_file.fopen(log_loc,log_file,open_mode);
      traffic_util.set_log_info(traf_log_file);

      show_time := true;
      traffic_util.log_message('***** Set log to file ' || log_file || ' in directory ' || log_loc, show_time);
--    link_speed_table_name := network_name || '_LINK_SPEED$';
      link_speed_table_name := output_table;
      sampling_id := 1;

   -- Getting required parameters from traffic metadata
      num_patterns := get_num_traf_patterns(network_name, sampling_id);
--
--  Insert rows for variant speeds
-- 
--  Monday-Thurday pattern  
    pattern_table := 'NDM_TP_1';
    temptable1 := 'NTP_SP_TEMP_1';
    if (table_exists(temptable1)) then
       execute immediate 'drop table '||temptable1||' purge';
    end if;

    query_str := 'CREATE TABLE '||temptable1||
                 ' (link_id number, sampling_id number, '||
                 ' speed_series_1 sdo_number_array) '||
                 ' NOLOGGING ';
    execute immediate query_str;

    insert_str := 'INSERT /*+ APPEND */ INTO '|| temptable1 ||
                  ' (link_id, sampling_id, speed_series_1) '||
                  ' SELECT t1.link_id, t1.sampling_id, '||
                  ' t1.link_speed_series speed_series_1 '||
                  ' FROM '|| pattern_table || ' t1 ';
    execute immediate insert_str;
    commit;

--
--  Friday Pattern
    pattern_table := 'NDM_TP_2';
    temptable2 := 'NTP_SP_TEMP_2';
    if (table_exists(temptable2)) then
       execute immediate 'drop table '||temptable2||' purge';
    end if;
    
    query_str := 'CREATE TABLE '||temptable2||
                 ' (link_id number, sampling_id number, '||
                 ' speed_series_1 sdo_number_array, '||
                 ' speed_series_2 sdo_number_array) '||
                 ' NOLOGGING ';
    execute immediate query_str;

    insert_str := 'INSERT /*+ APPEND */ INTO '|| temptable2 ||
                  ' (link_id, sampling_id, speed_series_1, speed_series_2) '||
                  ' SELECT t1.link_id, t1.sampling_id, '||
                  ' t1.speed_series_1 speed_series_1, '||
                  ' t2.link_speed_series speed_series_2 '||
                  ' FROM '|| temptable1 || ' t1, '||
                  pattern_table || ' t2 ' || ' WHERE '||
                  ' t1.link_id = t2.link_id ';
    execute immediate insert_str;
    commit;
    
    if (table_exists(temptable1)) then
       execute immediate 'drop table '||temptable1||' purge';
    end if;

--
--  Saturday pattern
    pattern_table := 'NDM_TP_3';
    temptable1 := 'NTP_SP_TEMP_3';
    if (table_exists(temptable1)) then
       execute immediate 'drop table '||temptable1||' purge';
    end if;

    query_str := 'CREATE TABLE '||temptable1||
                 ' (link_id number, sampling_id number, '||
                 ' speed_series_1 sdo_number_array, '||
                 ' speed_series_2 sdo_number_array, '||
                 ' speed_series_3 sdo_number_array) '||
                 ' NOLOGGING ';
    execute immediate query_str;
    
    insert_str := 'INSERT /*+ APPEND */ INTO '|| temptable1 ||
                  ' (link_id, sampling_id, speed_series_1, '||
                  ' speed_series_2, speed_series_3) '||
                  ' SELECT t1.link_id, t1.sampling_id, '||
                  ' t1.speed_series_1 speed_series_1, '||  
                  ' t1.speed_series_2 speed_series_2, '||
                  ' t2.link_speed_series speed_series_3 '||
                  ' FROM '|| temptable2 || ' t1, '||
                  pattern_table || ' t2 ' || ' WHERE '||
                  ' t1.link_id = t2.link_id ';
    execute immediate insert_str;
    commit;
    
    if (table_exists(temptable2)) then
       execute immediate 'drop table '||temptable2||' purge';
    end if;

--
--  Sunday pattern
    pattern_table := 'NDM_TP_4';
    temptable2 := 'NTP_SP_TEMP_4';
    if (table_exists(temptable2)) then
       execute immediate 'drop table '||temptable2||' purge';
    end if;     

    query_str := 'CREATE TABLE '||temptable2||
                 ' (link_id number, sampling_id number, '||
                 ' speed_series_1 sdo_number_array, '||
                 ' speed_series_2 sdo_number_array, '||
                 ' speed_series_3 sdo_number_array, '||
                 ' speed_series_4 sdo_number_array) '||
                 ' NOLOGGING ';
    execute immediate query_str;

    insert_str := 'INSERT /*+ APPEND */ INTO '|| temptable2 ||
                  ' (link_id, sampling_id, speed_series_1, '||
                  ' speed_series_2, speed_series_3,'||
                  ' speed_series_4) '||
                  ' SELECT t1.link_id, t1.sampling_id, '||
                  ' t1.speed_series_1 speed_series_1, '||  
                  ' t1.speed_series_2 speed_series_2, '||
                  ' t1.speed_series_3 speed_series_3, '||
                  ' t2.link_speed_series speed_series_4 '||
                  ' FROM '|| temptable1 || ' t1, '||
                  pattern_table || ' t2 ' || ' WHERE '||
                  ' t1.link_id = t2.link_id ';
    execute immediate insert_str;
    commit;

    if (table_exists(temptable1)) then
       execute immediate 'drop table '||temptable1||' purge';
    end if;

    IF table_exists(link_speed_table_name) THEN
        EXECUTE IMMEDIATE 'drop table ' ||
                         sys.dbms_assert.qualified_sql_name(link_speed_table_name) ||
                         ' purge' ;
    END IF;

    execute immediate 'alter table '||temptable2||' rename to '|| link_speed_table_name;
    commit;
--
--
    traffic_util.log_message('End:: Insert ' || link_speed_table_name || ' from patt tables', show_time);
    commit;
    utl_file.fclose(traf_log_file);
   END create_link_speeds_table;

PROCEDURE add_pid_to_link_speed_table(network_name IN varchar2,
                                      sampling_id IN varchar2,
                                      link_speed_table In varchar2,
                                      output_table IN varchar2,
				      log_loc IN varchar2,
				      log_file IN varchar2,
				      open_mode IN varchar2) IS
   table_name 			varchar2(32);
   pid_table_name 		varchar2(32);
   speed_table_name		varchar2(32);
   pid_speed_table		varchar2(32);
   link_table			varchar2(32);
   part_table			varchar2(32);
   query_str 			varchar2(4096);
   traf_patt_tables             sdo_string_array;
   num_patterns			integer;
   ins_columns_str		varchar2(4096);
   cr_columns_str		varchar2(4096);
   index_name			varchar2(32);
   traf_log_file 		utl_file.file_type := NULL;
   show_time			boolean;

   BEGIN
-- Open log file
      traf_log_file := utl_file.fopen(log_loc,log_file,open_mode);
      traffic_util.set_log_info(traf_log_file);
      traffic_util.log_message('****** Set log to file ' || log_file || ' in directory ' || log_loc, false);
      show_time  := true;
      traffic_util.log_message('****** Start: Add Partition ID info to Link Speed Table',show_time);

      table_name := output_table;
      speed_table_name := link_speed_table;
      if (not(table_exists(speed_table_name))) then
         traffic_util.log_message(speed_table_name||' does not exist; Cannot proceed',false);
         return;
      end if;
         
      if (table_exists(table_name)) then
         execute immediate 'drop table ' || table_name || ' purge';
      end if;

-- Getting required parameters from traffic metadata
      link_table := get_link_table_name(network_name);
      part_table := get_part_table_name(network_name);
      num_patterns := get_num_traf_patterns(network_name, sampling_id);
      
      cr_columns_str := '';
      ins_columns_str := '';

      for i IN 1 .. num_patterns loop      
         cr_columns_str := cr_columns_str ||
                           ' speed_series_'||i||' sdo_number_array ';
         ins_columns_str := ins_columns_str ||
                        ' t1.speed_series_'||i||' as speed_series_'||i;
         if i<num_patterns then
            cr_columns_str := cr_columns_str || ',';
            ins_columns_str := ins_columns_str || ',';
         end if;
      end loop;

      cr_columns_str := ' (link_id number, sampling_id number, '||
                        ' snode_pid number, '||
                        ' enode_pid number, num_patterns number,'||
                         cr_columns_str || ')';
      ins_columns_str := ' t1.link_id as link_id, '||
                         ' t1.sampling_id as sampling_id, '||
                         ' t2.partition_id as snode_pid, '||
                         ' t3.partition_id as enode_pid, '||
                         ' :n as num_patterns, '||
                         ins_columns_str;

-- Create table 
      query_str := 'CREATE TABLE '||table_name||cr_columns_str||' NOLOGGING';
      execute immediate query_str;
      commit;
   
-- Insert into link speeds table with partition info
      traffic_util.log_message('------ Start insert in '||table_name,show_time);
      query_str := 'INSERT /*+ APPEND */ INTO ' || table_name || ' SELECT ' ||
		   ins_columns_str || ' FROM ' || speed_table_name || ' t1, '||
		   part_table || ' t2, '|| part_table || ' t3, '||
                   link_table || ' t4 ' || ' WHERE ' ||
		   ' t1.link_id = t4.link_id AND ' || 
		   ' t4.start_node_id=t2.node_id AND '||
 		   ' t4.end_node_id = t3.node_id';
     execute immediate query_str using num_patterns;
     commit;
     traffic_util.log_message('------ End insert in '||table_name,show_time);

-- Create indexes on link_id, start_node partition_id and end node partition_id
     traffic_util.log_message('------ Start create indexes on '||table_name,show_time);
     index_name := 'nvt_lspeed'||'_lid_idx';
     execute immediate 'create index '||index_name ||' on '|| table_name ||'(link_id)';
     index_name := 'nvt_lspeed'||'_sid_idx';
     execute immediate 'create index '||index_name ||' on '|| table_name ||'(snode_pid)';
     index_name := 'nvt_lspeed'||'_eid_idx';
     execute immediate 'create index '||index_name ||' on '|| table_name ||'(enode_pid)';
     commit; 
     traffic_util.log_message('------ End create indexes on '||table_name,show_time);
     traffic_util.log_message('****** Start: Add Partition ID info to Link Speed Table',show_time);

--
-- Create a table for the IDs of partitions associated with links that show speed 
-- variations. The IDs are stored in a table to be used in user data generation
--

      show_time := true;
      traffic_util.log_message('****** Start :: Find partitions of dynamic links',show_time);
      pid_table_name := network_name||'_COV_PARTITIONS';
      pid_speed_table := output_table;
      if (table_exists(pid_table_name)) then
 	 execute immediate 'drop table ' || pid_table_name || ' purge';
      end if;
      query_str := 'CREATE TABLE '||pid_table_name|| ' (partition_id number)'||
		   ' NOLOGGING';
      execute immediate query_str;
      commit;       
      traffic_util.log_message('------ Start :: insert into ' || pid_table_name,show_time);
      query_str := 'INSERT /*+ append */ INTO ' || pid_table_name ||
		   ' SELECT distinct snode_pid as partition_id FROM ' ||
		   pid_speed_table;
      execute immediate query_str;
      commit;

      query_str := 'INSERT /*+ append */ INTO ' || pid_table_name ||
                   ' SELECT distinct enode_pid as partition_id FROM ' ||
                   pid_speed_table || ' WHERE enode_pid NOT IN ' ||
		   ' (SELECT partition_id FROM ' || pid_table_name || ')';
      execute immediate query_str;
      commit;
      traffic_util.log_message('------ End :: insert into ' || pid_table_name,show_time);
      traffic_util.log_message('****** End :: Find partitions of dynamic links',show_time);
      utl_file.fclose(traf_log_file);

   END  add_pid_to_link_speed_table;

--
-- Creates a table that has link IDs and timezones.
-- Link is assigned the timezone id of its start node
-- 0 - EST, 1 - CST, 2 - MT, 3 - PST
--
PROCEDURE add_timezones_to_links(network_name IN varchar2,
                                 link_speed_table IN varchar2,
                                 output_table IN varchar2,
				 log_loc IN varchar2,
				 log_file IN varchar2,
				 open_mode IN varchar2) IS
   table_name				varchar2(32);
   speed_table				varchar2(32);
   node_table				varchar2(32);
   query_str				varchar2(4096);
   temp_table_1				varchar2(32);
   temp_table_2				varchar2(32);
   index_name				varchar2(32);
   traf_log_file                     	utl_file.file_type := NULL;
   show_time                         	boolean;
   BEGIN
   -- Open log file
      traf_log_file := utl_file.fopen(log_loc,log_file,open_mode);
      traffic_util.set_log_info(traf_log_file);
      
      traffic_util.log_message('****** Set log to file ' || log_file || ' in directory ' || log_loc, false);
      show_time := true;
      traffic_util.log_message('****** Start : Assign timezones to links',show_time);

      table_name := output_table;      
      speed_table := link_speed_table;
      query_str := 'SELECT node_table_name FROM user_sdo_network_metadata WHERE ' ||
		   ' network = :a';
      execute immediate query_str into node_table using network_name;
   -- add start node id and partition id to links
      temp_table_1 := network_name || '_LINK_SNODE'; 
      if (table_exists(temp_table_1)) then
	 execute immediate 'drop table ' || temp_table_1 || ' purge';
      end if;
      query_str := 'CREATE TABLE ' || temp_table_1 ||
		   ' (link_id number,start_node_id number,'||
		   'partition_id number) ' || ' NOLOGGING ';
      execute immediate query_str;
      
      traffic_util.log_message('------ Start : Adding start node IDs to link_speed table',show_time);
      query_str := 'INSERT /*+ APPEND */ INTO ' || temp_table_1 ||
                   ' SELECT t1.link_id as link_id, '||
                   ' t2.start_node_id as start_node_id, '||
                   ' t2.partition_id as partition_id ' ||
                   ' FROM ' ||
                   ' (SELECT link_id link_id , min(sampling_id) min_sample_id '||
                   ' FROM '|| speed_table || ' GROUP BY link_id)  t1,'||
                   '  EDGE t2 ' ||
                   ' WHERE t1.link_id=t2.edge_id ';
      execute immediate query_str;
      commit;
      traffic_util.log_message('------ End : Adding start node IDs to link_speed table',show_time);

  --  create index on start_node_id column
      traffic_util.log_message('------ Start : Create index on start node id',show_time);
      index_name := network_name||'_lsnode_idx';
      query_str := 'CREATE INDEX ' || index_name || ' ON ' ||
 		   temp_table_1 || '(start_node_id)';
      execute immediate query_str;
      commit;
      traffic_util.log_message('------ End : Create index on start node id',show_time);

  --  Add longitude to start node id
      temp_table_2 := network_name || '_LINK_SNODE_LON';
      if (table_exists(temp_table_2)) then
	 execute immediate 'drop table ' || temp_table_2 || ' purge ';
      end if;
      query_str := 'CREATE TABLE ' || temp_table_2 ||
	  	  ' (link_id number, partition_id number,'||
		  ' start_node_id number,longitude number) '||
		  ' NOLOGGING ';
      execute immediate query_str;
   
      traffic_util.log_message('------ Start : Adding longitudes to start node IDs',show_time);
      query_str := 'INSERT /*+ APPEND */ INTO ' || temp_table_2 ||
    		  ' SELECT t1.link_id as link_id, '||
			  ' t1.partition_id as partition_id,'||
			  ' t1.start_node_id as start_node_id,' ||
			  ' t2.X as longitude ' ||
		  ' FROM ' || temp_table_1 || ' t1, ' || node_table || ' t2 '||
                  ' WHERE t1.start_node_id = t2.node_id ';
      execute immediate query_str;
      commit;
      traffic_util.log_message('------ End : Adding longitudes to start node IDs',show_time);

      execute immediate 'drop table ' || temp_table_1 || ' purge';
     
--    Create table with links, timezones
      if (table_exists(table_name)) then
	 execute immediate 'drop table ' || table_name || ' purge';
      end if;
      query_str := 'CREATE TABLE ' || table_name ||
		   ' (link_id number, partition_id number, '||
		   ' start_node_id number, timezone number) ' ||
		   ' NOLOGGING ';
      execute immediate query_str;

      traffic_util.log_message('------ Start : Assigning timezones to links',show_time);
      query_str := 'INSERT /*+ APPEND */ INTO '|| table_name ||
		   ' select link_id,partition_id,start_node_id,0 as timezone '||
		   ' FROM ' || temp_table_2 || ' WHERE longitude >= -85 ';
      execute immediate query_str;
      commit;

      query_str := 'INSERT /*+ APPEND */ INTO '|| table_name ||
		 ' select link_id,partition_id,start_node_id,1 as timezone '||
                 ' FROM ' || temp_table_2  ||
		 ' WHERE longitude < -85 and longitude >= -105 ';
      execute immediate query_str;
      commit;

      query_str := 'INSERT /*+ APPEND */ INTO '|| table_name ||
		 ' select link_id,partition_id,start_node_id,2 as timezone '||
		 ' FROM ' || temp_table_2  ||
		 ' WHERE longitude < -105 and longitude >= -115 ';
      execute immediate query_str;
      commit;

      query_str := 'INSERT /*+ APPEND */ INTO '|| table_name ||
		 ' select link_id,partition_id,start_node_id,3 as timezone '||
		 ' FROM ' || temp_table_2 ||
		 ' WHERE longitude < -115 ';
      execute immediate query_str;
      commit;
      traffic_util.log_message('------ End : Assigning timezones to links',show_time);

      execute immediate 'drop table ' || temp_table_2 || ' purge ';
      traffic_util.log_message('****** End : Assign timezones to links',show_time);
      utl_file.fclose(traf_log_file);

   END add_timezones_to_links;

PROCEDURE create_congested_links_table(network_name IN VARCHAR2,
                                       link_speed_table_name IN VARCHAR2,
				       speed_threshold IN NUMBER) IS
   view_name		 varchar2(64);
   query_str 		 varchar2(512);
-- link_speed_table_name varchar2(64);
   congested_links_table varchar2(64);
   link_table            varchar2(64);
   index_name 		 varchar2(64);
   threshold_in_mps      number;

   BEGIN
--
-- drop temporary view
-- 
   view_name := upper(network_name) || '_MINMAX_SPEED';
   IF (view_exists(view_name)) THEN 
     EXECUTE IMMEDIATE 'drop view ' || view_name;
   END IF;

-- Convert speed difference threshold to meters/second
   threshold_in_mps := (speed_threshold*4)/9;

--
-- create a view that has minimum and maximum speeds for each link
-- link_speed_table_name := upper(network_name) || '_LSPEED_PID';
   query_str := 'CREATE VIEW ' || view_name || ' AS ' ||
		' SELECT link_id, min_speed, max_speed FROM ' ||
		' (SELECT link_id, min(speed) min_speed ,max(speed) max_speed FROM ' ||
		'   (SELECT link_id , column_value speed FROM ' ||
		link_speed_table_name || ' a, ' ||
		' TABLE(a.speed_series_1) ) GROUP BY link_id ) ' ||
                ' WHERE min_speed != max_speed ';
   EXECUTE IMMEDIATE query_str;

--   
-- Create congested links table 
--
  congested_links_table := upper(network_name) || '_DYNAMIC_LINK$';
  
  IF table_exists(congested_links_table) THEN
    EXECUTE IMMEDIATE 'drop table ' || congested_links_table || ' purge';
  END IF;

  link_table := get_link_table_name(network_name);

  query_str := 'CREATE TABLE ' || congested_links_table || 
	       ' (link_id number, geometry mdsys.sdo_geometry) ';
  EXECUTE IMMEDIATE query_str;

--
-- Insert tuples into congested links table
--
  query_str := 'INSERT INTO ' || congested_links_table ||
               ' (SELECT a.link_id link_id, b.geometry geometry FROM ' ||
               ' (SELECT link_id, max_speed, min_speed, (max_speed-min_speed) FROM ' ||
	       view_name || ' WHERE (max_speed - min_speed) >= :thr) a, ' ||
               link_table || ' b ' || ' WHERE a.link_id = b.link_id) ';  
  EXECUTE IMMEDIATE query_str USING threshold_in_mps;

--
-- Insert geometry metadata
--
  IF NOT(geometry_metadata_exists(congested_links_table,'GEOMETRY')) THEN
    insert_geometry_metadata(congested_links_table, 'GEOMETRY');
  END IF;

--
-- create spatial index on the geometry column of congested links table
--
  index_name := network_name || '_dyn_link_idx';
  IF (index_exists(index_name)) THEN
    EXECUTE IMMEDIATE 'drop index ' || index_name;
  END IF;
  
  query_str := 'CREATE INDEX ' || index_name || ' ON ' || congested_links_table || 
	       '(geometry) INDEXTYPE IS mdsys.spatial_index ';
  EXECUTE IMMEDIATE query_str;

--
-- grant read privilege to ndmdemo
--
   EXECUTE IMMEDIATE 'grant select on ' || congested_links_table || ' to ndmdemo';

   EXECUTE IMMEDIATE 'drop view ' || view_name;

   commit;

   END create_congested_links_table;


PROCEDURE create_ndmdemo_views(network_user IN varchar2, network_name IN varchar2) IS
query_str			varchar2(512);
congested_links_view_name       varchar2(64);
origin_table_name 		varchar2(64);

BEGIN
   congested_links_view_name := 'NDMDEMO_DYNAMIC_LINK$';
   origin_table_name := UPPER(network_user)||'.'||UPPER(network_name)||'_DYNAMIC_LINK$';

   IF (view_exists(congested_links_view_name)) THEN
  	execute immediate 'drop view ' || congested_links_view_name;
   END IF;
   query_str := 'CREATE VIEW ' || congested_links_view_name || ' AS ' ||
		' SELECT * FROM ' || origin_table_name;
   EXECUTE IMMEDIATE query_str;
--
-- Insert geometry metadata
--
  IF NOT(geometry_metadata_exists(congested_links_view_name,'GEOMETRY')) THEN
    insert_geometry_metadata(congested_links_view_name, 'GEOMETRY');
  END IF;
   
END create_ndmdemo_views;

PROCEDURE create_speed_patt_series_table(speed_pattern_table in varchar2,
                                         final_speed_pattern_table in varchar,
                                         log_loc in varchar2,
                                         log_file in varchar2,
                                         open_mode in varchar2) IS
--final_speed_pattern_table                     varchar2(32);
speed_series                                    sdo_number_array;
pattern_ids                                     sdo_number_array;
pattern_id                                      number;
sampling_id                                     number;
query_str                                       varchar2(512);
BEGIN
   --final_speed_pattern_table := 'NTP_SPEED_PATTERN_SERIES';
   if (table_exists(final_speed_pattern_table)) then
      execute immediate 'drop table '||final_speed_pattern_table||
                        ' purge';
   end if;

   query_str := 'CREATE TABLE '||final_speed_pattern_table||
                ' (pattern_id number, sampling_id number, '||
                ' speed_series sdo_number_array) ' ||
                ' NOLOGGING ';
   execute immediate query_str;

   query_str := 'SELECT DISTINCT pattern_id FROM '||
                speed_pattern_table;
   execute immediate query_str bulk collect into pattern_ids;

   for i in 1 .. pattern_ids.count loop
      pattern_id := pattern_ids(i);
      query_str := 'SELECT DISTINCT sampling_id FROM '||
                   speed_pattern_table ||
                   ' WHERE pattern_id = :p';
      execute immediate query_str into sampling_id using pattern_id;

      query_str := 'SELECT speed_kph FROM '||
                   speed_pattern_table ||
                   ' WHERE pattern_id = :p';
      execute immediate query_str bulk collect into speed_series
                        using pattern_id;

      query_str := 'INSERT /*+ APPEND */ INTO '||
                   final_speed_pattern_table ||
                   ' (pattern_id,sampling_id,speed_series) '||
                   ' VALUES (:a,:b,:c)';
      execute immediate query_str using pattern_id, sampling_id,
                                        speed_series;
      commit;
   end loop;
END create_speed_patt_series_table;
--
-- Creates a table with separate link ids for each travel direction
--
PROCEDURE create_expanded_link_table(network_name in varchar2,
                                     link_pattern_table in varchar2,
                                     expanded_link_table in varchar2,
                                     exclude_links_not_in_network boolean,
                                     log_loc in varchar2,
                                     log_file in varchar2,
                                     open_mode in varchar2) IS
query_str                                       varchar2(512);
temptable                                       varchar2(32);
network_link_table                              varchar2(32);
BEGIN

   if (table_exists(expanded_link_table)) then
       execute immediate 'drop table '||expanded_link_table||
                         ' purge';
   end if;

   query_str := 'CREATE TABLE '||expanded_link_table||
                ' (link_id number, sampling_id number, '||
                ' sunday_pattern_id integer, '||
                ' monday_pattern_id integer, '||
                ' tuesday_pattern_id integer, '||
                ' wednesday_pattern_id integer, '||
                ' thursday_pattern_id integer, '||
                ' friday_pattern_id integer, '||
                ' saturday_pattern_id integer) '||
                ' NOLOGGING ';
   execute immediate query_str;

   query_str := 'INSERT /*+ APPEND */ INTO '||
                expanded_link_table||
                ' (link_id, sampling_id, '||
                ' sunday_pattern_id, monday_pattern_id, ' ||
                ' tuesday_pattern_id, wednesday_pattern_id, '||
                ' thursday_pattern_id, friday_pattern_id, '||
                ' saturday_pattern_id) '||
                ' SELECT link_id, sampling_id,'||
                ' sunday_pattern_id, monday_pattern_id,' ||
                ' tuesday_pattern_id, wednesday_pattern_id, '||
                ' thursday_pattern_id, friday_pattern_id, '||
                ' saturday_pattern_id '||
                ' FROM '||link_pattern_table||
                ' WHERE travel_direction=''T'' ';
   execute immediate query_str;
   commit;

   query_str := 'INSERT /*+ APPEND */ INTO '||
                expanded_link_table||
                ' (link_id, sampling_id, '||
                ' sunday_pattern_id, monday_pattern_id, ' ||
                ' tuesday_pattern_id, wednesday_pattern_id, '||
                ' thursday_pattern_id, friday_pattern_id, '||
                ' saturday_pattern_id) '||
                ' SELECT -link_id link_id, sampling_id,'||
                ' sunday_pattern_id, monday_pattern_id,' ||
                ' tuesday_pattern_id, wednesday_pattern_id, '||
                ' thursday_pattern_id, friday_pattern_id, '||
                ' saturday_pattern_id '||
                ' FROM '||link_pattern_table||
                ' WHERE travel_direction=''F'' ';
   execute immediate query_str;
   commit;

   if (exclude_links_not_in_network) then
       network_link_table := get_link_table_name(network_name);
       temptable := 'TEMP_LINK_SPEEDS';
       if (table_exists(temptable)) then
           execute immediate 'drop table '||temptable || ' purge';
       end if;
       query_str := 'CREATE TABLE '||temptable||' NOLOGGING '||' AS '||
                    ' SELECT * FROM '||expanded_link_table||
                    ' WHERE link_id IN '||
                    ' (SELECT link_id FROM '||network_link_table|| ' ) ';
       execute immediate query_str;
       commit;

       if (table_exists(expanded_link_table)) then
           execute immediate 'drop table '|| expanded_link_table || ' purge';
       end if;

       execute immediate 'alter table '||temptable||' rename to '||
                          expanded_link_table;

   end if;

END create_expanded_link_table;
--
-- Creates a table with link IDs and seven speed series
--

PROCEDURE create_link_speed_series_table(network_name in varchar2,
                                         link_pattern_table IN varchar2,
                                         speed_pattern_table in varchar2,
                                         exclude_links_not_in_network in boolean,
                                         link_speed_series_table in varchar2,
                                         log_loc in varchar2,
                                         log_file in varchar2,
                                         open_mode in varchar2) IS                                       
final_speed_pattern_table                       varchar2(32);
expanded_link_table                             varchar2(32);
final_link_speed_table                          varchar2(32);
query_str                                       varchar2(1024);
temptable1                                      varchar2(32);
temptable2                                      varchar2(32);
BEGIN
   final_speed_pattern_table := 'NTP_SPEED_PATTERN_SERIES';
   expanded_link_table := 'NTP_EXPANDED_LINK_PATT';

--   final_link_speed_table := 'NTP_LINK_SPEED_SERIES';
   final_link_speed_table := link_speed_series_table;

   create_speed_patt_series_table(speed_pattern_table,
                                  final_speed_pattern_table,
                                  log_loc, log_file, open_mode);

   create_expanded_link_table(network_name,
                              link_pattern_table,
                              expanded_link_table,
                              exclude_links_not_in_network,
                              log_loc, log_file, open_mode);


   if (table_exists(final_link_speed_table)) then
       execute immediate 'drop table '||final_link_speed_table||' purge';
   end if;
--
-- speed_series_1 Sunday
-- speed_series_2 Monday
-- speed_series_3 Tuesday
-- speed_series_4 Wednesday
-- speed_series_5 Thursday
-- speed_series_6 Friday
-- speed_series_7 Saturday
--
   query_str := 'CREATE TABLE '||final_link_speed_table||
                ' (link_id number, sampling_id number, '||
                ' speed_series_1 sdo_number_array, '||
                ' speed_series_2 sdo_number_array, '||
                ' speed_series_3 sdo_number_array, '||
                ' speed_series_4 sdo_number_array, '||
                ' speed_series_5 sdo_number_array, '||
                ' speed_series_6 sdo_number_array, '||
                ' speed_series_7 sdo_number_array) '||
                ' NOLOGGING ';
   execute immediate query_str;
   temptable1 := 'NTP_SP_TEMP_1';
   if (table_exists(temptable1)) then
       execute immediate 'drop table '||temptable1||' purge';
   end if;

-- Incorporate Sunday speed series
   query_str := 'CREATE TABLE '||temptable1||
                ' (link_id number, sampling_id number, '||
                ' speed_series_1 sdo_number_array, '||
                ' monday_pattern_id number, '||
                ' tuesday_pattern_id number, '||
                ' wednesday_pattern_id number, '||
                ' thursday_pattern_id number, '||
                ' friday_pattern_id number, '||
                ' saturday_pattern_id number) '||
                ' NOLOGGING ';
   execute immediate query_str;

   query_str := 'INSERT /*+ APPEND */ INTO '||temptable1||
                ' (link_id,sampling_id,speed_series_1,'||
                ' monday_pattern_id,tuesday_pattern_id,'||
                ' wednesday_pattern_id, thursday_pattern_id,'||
                ' friday_pattern_id,saturday_pattern_id) '||
                ' SELECT t1.link_id, t1.sampling_id,'||
                ' t2.speed_series speed_series_1, t1.monday_pattern_id,'||
                ' t1.tuesday_pattern_id,t1.wednesday_pattern_id,'||
                ' t1.thursday_pattern_id,t1.friday_pattern_id,'||
                ' t1.saturday_pattern_id '||' FROM '||
                expanded_link_table || ' t1, '||
                final_speed_pattern_table || ' t2 '||
                ' WHERE '|| ' t1.sampling_id=t2.sampling_id AND '||
                ' t1.sunday_pattern_id=t2.pattern_id';
   execute immediate query_str;
   commit;
-- Incorporating monday speed series
   temptable2 := 'NTP_SP_TEMP_2';
   if (table_exists(temptable2)) then
       execute immediate 'drop table '|| temptable2 || ' purge';
   end if;
   query_str := 'CREATE TABLE '||temptable2||
                ' (link_id number, sampling_id number, '||
                ' speed_series_1 sdo_number_array, '||
                ' speed_series_2 sdo_number_array, '||
                ' tuesday_pattern_id number, '||
                ' wednesday_pattern_id number, '||
                ' thursday_pattern_id number, '||
                ' friday_pattern_id number, '||
                ' saturday_pattern_id number) '||
                ' NOLOGGING ';
   execute immediate query_str;

   query_str := 'INSERT /*+ APPEND */ INTO '||temptable2||
                ' (link_id,sampling_id,speed_series_1,'||
                ' speed_series_2,tuesday_pattern_id,'||
                ' wednesday_pattern_id, thursday_pattern_id,'||
                ' friday_pattern_id,saturday_pattern_id) '||
                ' SELECT t1.link_id, t1.sampling_id,'||
                ' t1.speed_series_1, t2.speed_series speed_series_2, '||
                ' t1.tuesday_pattern_id,t1.wednesday_pattern_id,'||
                ' t1.thursday_pattern_id,t1.friday_pattern_id,'||
                ' t1.saturday_pattern_id '||' FROM '||
                temptable1 || ' t1, '||
                final_speed_pattern_table || ' t2 '||
                ' WHERE '|| ' t1.sampling_id=t2.sampling_id AND '||
                ' t1.monday_pattern_id=t2.pattern_id';
   execute immediate query_str;
   commit;

   if (table_exists(temptable1)) then
      execute immediate 'drop table '||temptable1||' purge';
   end if;

-- Incorporating tuesday speed series
   temptable1 := 'NTP_SP_TEMP_3';
   if (table_exists(temptable1)) then
       execute immediate 'drop table '|| temptable1 || ' purge';
   end if;

   query_str := 'CREATE TABLE '||temptable1||
                ' (link_id number, sampling_id number, '||
                ' speed_series_1 sdo_number_array, '||
                ' speed_series_2 sdo_number_array, '||
                ' speed_series_3 sdo_number_array, '||
                ' wednesday_pattern_id number, '||
                ' thursday_pattern_id number, '||
                ' friday_pattern_id number, '||
                ' saturday_pattern_id number) '||
                ' NOLOGGING ';
   execute immediate query_str;

   query_str := 'INSERT /*+ APPEND */ INTO '||temptable1||
                ' (link_id,sampling_id,speed_series_1,'||
                ' speed_series_2,speed_series_3,'||
                ' wednesday_pattern_id, thursday_pattern_id,'||
                ' friday_pattern_id,saturday_pattern_id) '||
                ' SELECT t1.link_id, t1.sampling_id,'||
                ' t1.speed_series_1, t1.speed_series_2, '||
                ' t2.speed_series speed_series_3,t1.wednesday_pattern_id,'||
                ' t1.thursday_pattern_id,t1.friday_pattern_id,'||
                ' t1.saturday_pattern_id '||' FROM '||
                temptable2 || ' t1, '||
                final_speed_pattern_table || ' t2 '||
                ' WHERE '|| ' t1.sampling_id=t2.sampling_id AND '||
                ' t1.tuesday_pattern_id=t2.pattern_id';
   execute immediate query_str;
   commit;

   if (table_exists(temptable2)) then
      execute immediate 'drop table '||temptable2||' purge';
   end if;

-- Incorporating wednesday speed series 
   temptable2 := 'NTP_SP_TEMP_4';
   if (table_exists(temptable2)) then
       execute immediate 'drop table '|| temptable2 || ' purge';
   end if;

   query_str := 'CREATE TABLE '||temptable2||
                ' (link_id number, sampling_id number, '||
                ' speed_series_1 sdo_number_array, '||
                ' speed_series_2 sdo_number_array, '||
                ' speed_series_3 sdo_number_array, '||
                ' speed_series_4 sdo_number_array, '||
                ' thursday_pattern_id number, '||
                ' friday_pattern_id number, '||
                ' saturday_pattern_id number) '||
                ' NOLOGGING ';
   execute immediate query_str;

   query_str := 'INSERT /*+ APPEND */ INTO '||temptable2||
                ' (link_id,sampling_id,speed_series_1,'||
                ' speed_series_2,speed_series_3,'||
                ' speed_series_4, thursday_pattern_id,'||
                ' friday_pattern_id,saturday_pattern_id) '||
                ' SELECT t1.link_id, t1.sampling_id,'||
                ' t1.speed_series_1, t1.speed_series_2, '||
                ' t1.speed_series_3, '||
                ' t2.speed_series speed_series_4,'||
                ' t1.thursday_pattern_id,t1.friday_pattern_id,'||
                ' t1.saturday_pattern_id '||' FROM '||
                temptable1 || ' t1, '||
                final_speed_pattern_table || ' t2 '||
                ' WHERE '|| ' t1.sampling_id=t2.sampling_id AND '||
                ' t1.wednesday_pattern_id=t2.pattern_id';
   execute immediate query_str;
   commit;

   if (table_exists(temptable1)) then
      execute immediate 'drop table '||temptable1||' purge';
   end if;

-- Incorporating thursday speed series
   temptable1 := 'NTP_SP_TEMP_5';
   if (table_exists(temptable1)) then
       execute immediate 'drop table '|| temptable1 || ' purge';
   end if;

   query_str := 'CREATE TABLE '||temptable1||
                ' (link_id number, sampling_id number, '||
                ' speed_series_1 sdo_number_array, '||
                ' speed_series_2 sdo_number_array, '||
                ' speed_series_3 sdo_number_array, '||
                ' speed_series_4 sdo_number_array, '||
                ' speed_series_5 sdo_number_array, '||
                ' friday_pattern_id number, '||
                ' saturday_pattern_id number) '||
                ' NOLOGGING ';
   execute immediate query_str;

   query_str := 'INSERT /*+ APPEND */ INTO '||temptable1||
                ' (link_id,sampling_id,speed_series_1,'||
                ' speed_series_2,speed_series_3,'||
                ' speed_series_4, speed_series_5,'||
                ' friday_pattern_id,saturday_pattern_id) '||
                ' SELECT t1.link_id, t1.sampling_id,'||
                ' t1.speed_series_1, t1.speed_series_2, '||
                ' t1.speed_series_3, t1.speed_series_4,'||
                ' t2.speed_series speed_series_5,t1.friday_pattern_id,'||
                ' t1.saturday_pattern_id '||' FROM '||
                temptable2 || ' t1, '||
                final_speed_pattern_table || ' t2 '||
                ' WHERE '|| ' t1.sampling_id=t2.sampling_id AND '||
                ' t1.thursday_pattern_id=t2.pattern_id';
   execute immediate query_str;
   commit;

   if (table_exists(temptable2)) then
      execute immediate 'drop table '||temptable2||' purge';
   end if;

-- Incorporating friday speed series 
   temptable2 := 'NTP_SP_TEMP_6';
   if (table_exists(temptable2)) then
       execute immediate 'drop table '|| temptable2 || ' purge';
   end if;

   query_str := 'CREATE TABLE '||temptable2||
                ' (link_id number, sampling_id number, '||
                ' speed_series_1 sdo_number_array, '||
                ' speed_series_2 sdo_number_array, '||
                ' speed_series_3 sdo_number_array, '||
                ' speed_series_4 sdo_number_array, '||
                ' speed_series_5 sdo_number_array, '||
                ' speed_series_6 sdo_number_array, '||
                ' saturday_pattern_id number) '||
                ' NOLOGGING ';
   execute immediate query_str;

   query_str := 'INSERT /*+ APPEND */ INTO '||temptable2||
                ' (link_id,sampling_id,speed_series_1,'||
                ' speed_series_2,speed_series_3,'||
                ' speed_series_4, speed_series_5,'||
                ' speed_series_6,saturday_pattern_id) '||
                ' SELECT t1.link_id, t1.sampling_id,'||
                ' t1.speed_series_1, t1.speed_series_2, '||
                ' t1.speed_series_3, t1.speed_series_4,'||
                ' t1.speed_series_5,'||
                ' t2.speed_series speed_series_6,'||
                ' t1.saturday_pattern_id '||' FROM '||
                temptable1 || ' t1, '||
                final_speed_pattern_table || ' t2 '||
                ' WHERE '|| ' t1.sampling_id=t2.sampling_id AND '||
                ' t1.friday_pattern_id=t2.pattern_id';
   execute immediate query_str;
   commit;

   if (table_exists(temptable1)) then
      execute immediate 'drop table '||temptable1||' purge';
   end if;

-- Incorporating saturday speed series
   temptable1 := 'NTP_SP_TEMP_7';
   if (table_exists(temptable1)) then
       execute immediate 'drop table '|| temptable1 || ' purge';
   end if;

   query_str := 'CREATE TABLE '||temptable1||
                ' (link_id number, sampling_id number, '||
                ' speed_series_1 sdo_number_array, '||
                ' speed_series_2 sdo_number_array, '||
                ' speed_series_3 sdo_number_array, '||
                ' speed_series_4 sdo_number_array, '||
                ' speed_series_5 sdo_number_array, '||
                ' speed_series_6 sdo_number_array, '||
                ' speed_series_7 sdo_number_array) '||
                ' NOLOGGING ';
   execute immediate query_str;

   query_str := 'INSERT /*+ APPEND */ INTO '||temptable1||
                ' (link_id,sampling_id,speed_series_1,'||
                ' speed_series_2,speed_series_3,'||
                ' speed_series_4, speed_series_5,'||
                ' speed_series_6,speed_series_7) '||
                ' SELECT t1.link_id, t1.sampling_id,'||
                ' t1.speed_series_1, t1.speed_series_2, '||
                ' t1.speed_series_3, t1.speed_series_4,'||
                ' t1.speed_series_5,'||
                ' t1.speed_series_6,'||
                ' t2.speed_series speed_series_7 '||' FROM '||
                temptable2 || ' t1, '||
                final_speed_pattern_table || ' t2 '||
                ' WHERE '|| ' t1.sampling_id=t2.sampling_id AND '||
                ' t1.saturday_pattern_id=t2.pattern_id';
   execute immediate query_str;
   commit;

   if (table_exists(temptable2)) then
      execute immediate 'drop table '||temptable2||' purge';
   end if;

   if (table_exists(final_link_speed_table)) then
      execute immediate 'drop table '||final_link_speed_table||' purge';
   end if;

   execute immediate 'alter table '||temptable1||' rename to '||
                     final_link_speed_table;
   commit;

END create_link_speed_series_table;


--
-- Metadata related procedures/functions
--
-- Creates traffic metadata
--

PROCEDURE create_traffic_metadata is
   query_str            varchar2(2048);
   table_name           varchar2(128) := 'NDM_TRAFFIC_METADATA';
   BEGIN
      if (table_exists(table_name)) then
        execute immediate 'drop table ' || table_name || ' purge';
      end if;
      
      query_str := 'CREATE TABLE ' || table_name ||
                  ' (network_name varchar2(32), ' ||
                  ' data_provider varchar2(32), ' ||
                  ' sampling_id number, '||
                  ' link_length_column varchar2(32),'||
                  ' link_speed_limit_column varchar2(32),'||
                  ' link_traf_attr_name varchar2(16) NOT NULL 
                                   CHECK (NLS_LOWER(link_traf_attr_name) IN 
                                    (''speed'',''travel_time'')), '||
                  ' traf_attr_unit varchar2(10) NOT NULL
                                   CHECK (NLS_LOWER(traf_attr_unit) IN 
                                    (''mph'',''kmph'',''mps'',''s'',''km/h'',''mi/h'')), ' ||
                  ' num_time_intervals number, '||
                  ' number_of_patterns number, '||
                  ' CONSTRAINT net_traf_patt_pk '||
                  ' PRIMARY KEY(network_name, sampling_id)) ';
     dbms_output.put_line(query_str);
     execute immediate query_str;
     commit;

   END create_traffic_metadata;

--
-- Inserts metadata
--
PROCEDURE insert_traffic_metadata(network_name IN varchar2,
                                  sampling_id in number,
                                  link_length_column IN varchar2 ,
                                  link_speed_limit_column IN varchar2,
                                  link_traf_attr_name IN varchar2,
                                  traf_attr_unit IN varchar2,
                                  num_time_intervals IN number,
                                  number_of_patterns IN number) IS
   query_str            varchar2(1024);
   table_name           varchar2(128);
   BEGIN
      table_name := 'NDM_TRAFFIC_METADATA';

      query_str := 'DELETE FROM ' || table_name || ' WHERE ' ||
                   ' network_name = :a AND sampling_id = :b';
      execute immediate query_str using UPPER(network_name),sampling_id;

      query_str := 'INSERT INTO ' || table_name ||
                 ' (network_name,sampling_id,link_length_column,
                   link_speed_limit_column,link_traf_attr_name,
                   traf_attr_unit,
                   num_time_intervals,
                   number_of_patterns) ' ||
                  ' VALUES ' ||
                 ' (:c1,:c2,:c3,:c4,:c5,:c6,:c7,:c8) ';
      execute immediate query_str using network_name,sampling_id,
                                      link_length_column,link_speed_limit_column,
                                      link_traf_attr_name,traf_attr_unit,
                                      num_time_intervals,number_of_patterns;
      commit;
   END insert_traffic_metadata;

--
--
--
FUNCTION get_link_length_column(network_name IN varchar2) RETURN varchar2 IS
   query_str                    varchar2(512);
   link_length_column           varchar2(128);
   network                      varchar2(128);
   BEGIN
      network := UPPER(network_name);
      query_str := 'SELECT link_length_column FROM ndm_traffic_metadata' ||
                   ' WHERE network_name = :a';
      execute immediate query_str into link_length_column using network_name;
      RETURN link_length_column;
   END get_link_length_column;

--
--
--
FUNCTION get_link_speed_limit_column(network_name IN varchar2) RETURN varchar2 IS
   query_str                    varchar2(512);
   link_speed_limit_column      varchar2(128);
   network                      varchar2(128);
   BEGIN
      network := UPPER(network_name);
      query_str :=  'SELECT link_speed_limit_column FROM ndm_traffic_metadata' ||
                   ' WHERE network_name = :a';
      execute immediate query_str into link_speed_limit_column using network_name;
      RETURN link_speed_limit_column;
   END get_link_speed_limit_column;

--
--
--
FUNCTION get_link_traf_attr_name(network_name IN varchar2) RETURN varchar2 IS
   query_str                    varchar2(512);
   link_traf_attr_name        varchar2(128);
   network                      varchar2(128);
   BEGIN
      network := UPPER(network_name);
      query_str :=  'SELECT link_traf_attr_name FROM ndm_traffic_metadata' ||
                   ' WHERE network_name = :a';
      execute immediate query_str into link_traf_attr_name using network_name;
      RETURN link_traf_attr_name;
   END get_link_traf_attr_name;

--
--
--
FUNCTION get_link_traf_patt_tables(network_name IN varchar2) RETURN sdo_string_array IS
   query_str                    varchar2(512);
   network                      varchar2(128);
   traf_patt_tables             sdo_string_array;
   BEGIN
      network := UPPER(network_name);
      query_str := 'SELECT link_tp_tables FROM ndm_traffic_metadata' ||
                   ' WHERE network_name = :a';
      execute immediate query_str into traf_patt_tables using network_name;
      RETURN traf_patt_tables;
   END get_link_traf_patt_tables;

--
--
--
FUNCTION get_num_time_intervals(network_name IN varchar2) RETURN number IS
   query_str                    varchar2(512);
   num_intervals                number;
   BEGIN
      query_str := 'SELECT num_time_intervals FROM ndm_traffic_metadata '||
                   ' WHERE network_name = :a';
      execute immediate query_str into num_intervals using network_name;
      RETURN num_intervals;
   END get_num_time_intervals;

--
--
--
FUNCTION get_traf_attr_unit(network_name IN varchar2) RETURN varchar2 IS
   query_str			varchar2(512);
   unit 			varchar2(10);
   BEGIN
      query_str := 'SELECT traf_attr_unit FROM ndm_traffic_metadata '||
		   ' WHERE network_name = :a';
      execute immediate query_str into unit  using network_name;
      RETURN unit;
   END get_traf_attr_unit;

--
--
--
--
FUNCTION convert_to_speed(time_series IN sdo_number_array, length IN number) RETURN sdo_number_array IS
   series_length		number;
   sp_series 			sdo_number_array := sdo_number_array();
   BEGIN
      series_length := time_series.count;
      for i IN time_series.first .. time_series.last loop
         sp_series.extend;
         sp_series(i) := length/time_series(i);
      end loop;
      RETURN sp_series;
   END convert_to_speed;

PROCEDURE generate_traf_user_data_java(network_name IN varchar2, 
                                       sampling_id in number, 
                                       link_speed_table in varchar2, 
                                       link_speed_table_with_pid in varchar2,
                                       overwrite_blobs in boolean,
                                       user_data_table in varchar2)
   AS LANGUAGE JAVA
   NAME 'oracle.spatial.network.apps.traffic.NDMTrafficWrapper.writeTrafficUserData(java.lang.String, int, java.lang.String, java.lang.String, boolean, java.lang.String)';

PROCEDURE generate_traf_user_data_java(network_name IN varchar2, 
                                       sampling_id in number,
				       startOfPeriod IN varchar2,
				       endOfPeriod IN varchar2,
                                       link_speed_table in varchar2, 
                                       link_speed_table_with_pid in varchar2,
                                       overwrite_blobs in boolean,
                                       user_data_table in varchar2)
   AS LANGUAGE JAVA
   NAME 'oracle.spatial.network.apps.traffic.NDMTrafficWrapper.writeTrafficUserData(java.lang.String,int,java.lang.String,java.lang.String,java.lang.String,java.lang.String,boolean,java.lang.String)';

PROCEDURE generate_traffic_user_data(network_name IN varchar2,
                                     sampling_id in number,
                                     link_speed_table in varchar2,
                                     link_speed_table_with_pid in varchar2,
                                     overwrite_blobs in boolean,
                                     user_data_table in varchar2 DEFAULT 'TP_USER_DATA',
				     log_loc IN varchar2,
				     log_file IN varchar2,
				     open_mode IN varchar2) IS

   traf_log_file 		utl_file.file_type := NULL;
   show_time			boolean;
   BEGIN
   -- Open log file
      traf_log_file := utl_file.fopen(log_loc,log_file,open_mode);
      traffic_util.set_log_info(traf_log_file);
      show_time := true;
      traffic_util.log_message('****** Start : Generation of traffic user data ', show_time);
      
      generate_traf_user_data_java(network_name,sampling_id,link_speed_table,link_speed_table_with_pid,overwrite_blobs,user_data_table);
      commit;
      traffic_util.log_message('****** End : Generation of traffic user data ', show_time);
      utl_file.fclose(traf_log_file);

   END generate_traffic_user_data;

PROCEDURE generate_traffic_user_data(network_name IN varchar2,
                                     sampling_id in number,
				     startOfPeriod IN varchar2,
				     endOfPeriod IN varchar2,
                                     link_speed_table in varchar2,
                                     link_speed_table_with_pid in varchar2,
                                     overwrite_blobs in boolean,
                                     user_data_table in varchar2 DEFAULT 'TP_USER_DATA',
				     log_loc IN varchar2,
				     log_file IN varchar2,
				     open_mode IN varchar2) IS
   traf_log_file 		utl_file.file_type := NULL;
   show_time			boolean;
   BEGIN
   -- Open log file
      traf_log_file := utl_file.fopen(log_loc,log_file,open_mode);
      traffic_util.set_log_info(traf_log_file);
      show_time := true;
      traffic_util.log_message('****** Start : Generation of traffic user data ', show_time);
      generate_traf_user_data_java(network_name,sampling_id,startOfPeriod,endOfPeriod,link_speed_table,link_speed_table_with_pid,overwrite_blobs,user_data_table);
      commit;
      traffic_util.log_message('****** End : Generation of traffic user data ', show_time);
      utl_file.fclose(traf_log_file);
   END generate_traffic_user_data;

PROCEDURE generate_tr_tz_user_data_java(network_name IN varchar2) 
   AS LANGUAGE JAVA
   NAME 'oracle.spatial.network.apps.traffic.NDMTrafficWrapper.writeTrafficTimezoneUserData(java.lang.String)';

PROCEDURE generate_tr_tz_user_data(network_name IN varchar2,
				     log_loc IN varchar2,
				     log_file IN varchar2,
				     open_mode IN varchar2) IS
   
   traf_log_file 		utl_file.file_type := NULL;
   show_time			boolean;
   BEGIN
   -- Open log file
      traf_log_file := utl_file.fopen(log_loc,log_file,open_mode);
      traffic_util.set_log_info(traf_log_file);
      show_time := true;
      traffic_util.log_message('****** Start : Generation of time zone user data ', show_time);
      generate_tr_tz_user_data_java(network_name);
      commit;
      traffic_util.log_message('****** End : Generation of time zone user data ', show_time);
      utl_file.fclose(traf_log_file);

   END generate_tr_tz_user_data;

END traffic_util;
/
grant execute on traffic_util to public;
show error;
