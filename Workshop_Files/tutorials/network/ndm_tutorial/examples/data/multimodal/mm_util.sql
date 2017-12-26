Rem
Rem $Header: sdo/demo/network/examples/data/multimodal/mm_util.sql /main/2 2012/06/14 05:32:51 begeorge Exp $
Rem
Rem mm_util.sql
Rem
Rem Copyright (c) 2011, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      mm_util.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    begeorge    06/22/11 - Adding multimodal metadata
Rem    begeorge    06/14/11 - Created
Rem

--SET ECHO ON
--SET FEEDBACK 1
--SET NUMWIDTH 10
--SET LINESIZE 80
--SET TRIMSPOOL ON
--SET TAB OFF
--SET PAGESIZE 100

set serveroutput on;
-- Create type date_array
CREATE OR REPLACE TYPE date_array AS varray(1024) OF date;
/
grant execute on date_array to public;
show errors;

CREATE OR REPLACE PACKAGE mm_util AUTHID current_user AS
   TYPE cursor_type IS REF CURSOR;
   TYPE number_array IS table of number;
   TYPE char_array IS table of varchar2(1);
   TYPE varchar_array is table of varchar2(256);
   TYPE short_varchar_array is table of varchar2(10);
   TYPE rowidarray is table of rowid;
   TYPE number_assoc_array IS table of number index by binary_integer;
   TYPE string_assoc_array IS table of varchar2(12) index by binary_integer;
   TYPE number_assoc_matrix IS table of number_assoc_array index by binary_integer;
   TYPE geom_array is table of sdo_geometry;
   
   PROCEDURE set_log_info(file      IN UTL_FILE.FILE_TYPE);
   PROCEDURE log_message(message IN VARCHAR2, show_time IN BOOLEAN);

   FUNCTION table_exists(table_name IN VARCHAR2) RETURN BOOLEAN;
   FUNCTION view_exists(view_name IN VARCHAR2) RETURN BOOLEAN;
   FUNCTION index_exists(index_name IN VARCHAR2) RETURN BOOLEAN;
   FUNCTION index_on_col_exists( tab_name IN VARCHAR2, col_name IN VARCHAR2)
    							RETURN BOOLEAN;
   FUNCTION get_node_table_name(network_name IN VARCHAR2) RETURN VARCHAR2;
   FUNCTION get_schedule_ids(network_name IN VARCHAR2, 
                            subnetwork_name IN VARCHAR2) RETURN number_array;
   FUNCTION get_link_table_name(network_name IN VARCHAR2) RETURN VARCHAR2;
   FUNCTION get_part_table_name(network_name IN VARCHAR2) RETURN VARCHAR2;
   FUNCTION get_pblob_table_name(network_name IN VARCHAR2) RETURN VARCHAR2;
   FUNCTION find_diff_between_time_strings(timestr1 IN VARCHAR2,
					   timestr2 IN VARCHAR2) RETURN number;
   FUNCTION adjust_times_to_format(times_array IN SDO_STRING_ARRAY) 
					       RETURN SDO_STRING_ARRAY;
   PROCEDURE create_nodes_for_subnetwork(network_name IN VARCHAR2,
                                         base_network_name IN VARCHAR2,
                                         subnetwork_name IN VARCHAR2,
                                         output_node_table IN VARCHAR2,
				         node_stop_map_table IN VARCHAR2,
				         log_loc  IN varchar2,
				         log_file IN varchar2,
			   	         open_mode IN varchar2);
/*
   PROCEDURE create_nodes_for_stops(network_name IN VARCHAR2,
                                    output_node_table IN VARCHAR2,
				    node_stop_map_table IN VARCHAR2,
				    log_loc  IN varchar2,
                                    log_file IN varchar2,
                                   open_mode IN varchar2);
*/
   FUNCTION find_op_trips_for_a_route(network_name IN VARCHAR2,
                                      subnetwork_name IN VARCHAR2,
				      trip_table IN VARCHAR2,
				      route_id IN NUMBER) RETURN sdo_number_array;
   PROCEDURE create_service_links_table(network_name IN VARCHAR2,
				        service_link_table IN VARCHAR2);
   PROCEDURE create_route_trip_stop_table(network_name IN VARCHAR2,
                                          subnetwork_name IN VARCHAR2,
					  route_table IN VARCHAR2,
					  trip_table  IN VARCHAR2,
					  stop_time_table IN VARCHAR2);
   PROCEDURE convert_stid_to_nid_in_links(input_table IN VARCHAR2,
					  stop_to_node_map_table IN VARCHAR2,
					  service_link_table IN VARCHAR2,
					  create_new_table IN BOOLEAN);
   PROCEDURE convert_stop_id_to_node_id(input_table IN VARCHAR2,
					stop_to_node_map_table IN VARCHAR2,
					node_time_table IN VARCHAR2);
   FUNCTION create_links_for_a_route(network_name IN VARCHAR2,
                                     subnetwork_name IN VARCHAR2,
				     service_link_table IN VARCHAR2,
				     trip_table IN VARCHAR2,
				     route_trip_stop_table IN VARCHAR2,
				     route_id IN NUMBER,
				     max_link_id IN NUMBER, 
				     prev_link_id_incr IN NUMBER,
				     overwrite IN BOOLEAN,
			             log_loc  IN varchar2,
				     log_file IN varchar2,
				     open_mode IN varchar2) RETURN NUMBER;
   PROCEDURE create_subnet_service_links(network_name IN VARCHAR2,
                                         subnetwork_name IN VARCHAR2,
                                         output_table IN VARCHAR2,
                                         log_loc  IN VARCHAR2,
                                         log_file IN VARCHAR2,
                                         open_mode IN VARCHAR2);
  /*
   PROCEDURE generate_links_for_all_routes(network_name IN VARCHAR2,
					   output_table IN VARCHAR2,
					   log_loc  IN varchar2,
                                           log_file IN varchar2,
                                           open_mode IN varchar2);
  */
   PROCEDURE create_node_times(network_name IN VARCHAR2,
                               subnetwork_name IN VARCHAR2,
			       node_time_table IN VARCHAR2,
			       log_loc  IN varchar2,
                               log_file IN varchar2,
                               open_mode IN varchar2);
   FUNCTION get_service_node_ids(network_name IN VARCHAR2,
                                 subnetwork_name IN VARCHAR2) RETURN sdo_number_array;
   PROCEDURE create_node_schedule_for_an_id(network_name IN VARCHAR2,
                                            subnetwork_name IN VARCHAR2,
                                            node_sch_table_name IN VARCHAR2,
                                            schedule_id IN number,
					    log_loc  IN varchar2,
					    log_file IN varchar2,
					    open_mode IN varchar2);
   PROCEDURE create_subnet_node_schedules(network_name IN VARCHAR2,
                                   subnetwork_name IN VARCHAR2,
  			           node_schedule_table IN VARCHAR2,
				   log_loc  IN varchar2,
				   log_file IN varchar2,
				   open_mode IN varchar2);
   PROCEDURE insert_geom_metadata(table_name IN VARCHAR2, column_name IN VARCHAR2);
   PROCEDURE create_mm_node_tables(network_name IN VARCHAR2,
                                    final_node_table IN VARCHAR2,
                                    mm_service_node_table in VARCHAR2,
                                    mm_stop_node_map_table in VARCHAR2,
                                    log_loc IN VARCHAR2,
                                    log_file IN VARCHAR2,
                                    open_mode IN VARCHAR2);
   PROCEDURE create_mm_node_schedule_table(network_name IN VARCHAR2,
                                      output_table IN VARCHAR2,
                                      log_loc IN VARCHAR2,
                                      log_file IN VARCHAR2,
                                      open_mode IN VARCHAR2);
   PROCEDURE add_nodes_to_partitions(network_name IN VARCHAR2, 
                                     log_loc IN VARCHAR2,
                                     log_file IN VARCHAR2, 
                                     open_mode in VARCHAR2);
   PROCEDURE remove_srvc_nodes_from_part(network_name IN VARCHAR2,
				         log_loc IN VARCHAR2,
					 log_file IN VARCHAR2,
					 open_mode IN VARCHAR2);
   PROCEDURE create_mm_link_tables(network_name IN VARCHAR2,
                                   output_link_table IN VARCHAR2,
                                   mm_service_link_table IN VARCHAR2,
                                   mm_connect_link_table IN VARCHAR2,
                                   log_loc IN VARCHAR2,
                                   log_file IN VARCHAR2,
                                   open_mode IN VARCHAR2);
   PROCEDURE add_links_to_mm_links(network_name IN VARCHAR2,
				   input_link_table IN VARCHAR2,
				   mm_link_table IN VARCHAR2,
                                   include_geometry IN boolean,
                                   include_s IN boolean,
                                   log_loc IN VARCHAR2,
                                   log_file IN VARCHAR2,
                                   open_mode IN VARCHAR2);
   PROCEDURE correct_service_node_geom(network_name IN VARCHAR2,
			               log_loc IN VARCHAR2,
			  	       log_file IN VARCHAR2,
				       open_mode IN VARCHAR2);
   PROCEDURE create_subnet_connect_links(network_name IN VARCHAR2,
                                   	 subnetwork_name IN VARCHAR2,
                                   	 output_table IN VARCHAR2,
				   	 log_loc  IN varchar2,
				   	 log_file IN varchar2,
				   	 open_mode IN varchar2);
   PROCEDURE create_clique(network_name IN VARCHAR2, 
                           link_id IN number,
			   node_array IN sdo_number_array,
			   output_table IN VARCHAR2,
			   log_loc IN VARCHAR2,
			   log_file IN VARCHAR2,
			   open_mode IN VARCHAR2);
   PROCEDURE create_transfers_on_links(network_name IN VARCHAR2,
                                       final_table IN VARCHAR2,
                                       log_loc in VARCHAR2, 
				       log_file IN VARCHAR2, 
                                       open_mode IN VARCHAR2);
   PROCEDURE create_transfer_links(network_name IN VARCHAR2,
                                   output_table IN VARCHAR2,
                                   transfer_radius IN integer,
                                   walking_speed IN number,
                                   config_file_loc IN VARCHAR2,
                                   config_file IN VARCHAR2,
				   log_loc IN VARCHAR2,
				   log_file IN VARCHAR2,
			           open_mode IN VARCHAR2);
   PROCEDURE process_transfer_links(network_name IN VARCHAR2,
                                    input_tlink_table IN VARCHAR2,
                                    output_table IN varchar2,
                                    transfer_radius IN integer,
                                    walking_speed IN number,
                                    log_loc IN VARCHAR2,
                                    log_file IN VARCHAR2,
                                    open_mode IN VARCHAR2);
   PROCEDURE create_link_type_table(network_name IN VARCHAR2,
                                    output_table IN VARCHAR2,
                                    log_loc IN VARCHAR2,
                                    log_file IN VARCHAR2,
                                    open_mode IN VARCHAR2);
   PROCEDURE insert_in_link_type_table(network_name IN VARCHAR2,
                                       link_table IN VARCHAR2,
                                       link_type  IN NUMBER,
                                       rewrite IN BOOLEAN,
     			               log_loc IN VARCHAR2,
				       log_file IN VARCHAR2,
				       open_mode IN VARCHAR2);
   PROCEDURE create_node_pairs_for_sp(network_name IN VARCHAR2,
				      log_loc IN VARCHAR2,
				      log_file IN VARCHAR2,
				      open_mode IN VARCHAR2);
   PROCEDURE project_service_node_to_link(network_name IN VARCHAR2,
			                  log_loc IN VARCHAR2,
			  	          log_file IN VARCHAR2,
				          open_mode IN VARCHAR2);
   PROCEDURE correct_node_geom_from_shapes(network_name IN VARCHAR2,
                                           subnetwork_name IN VARCHAR2,
                                           lrs_project_table IN VARCHAR2,
                                           log_loc IN VARCHAR2,
                                           log_file IN VARCHAR2,
                                           open_mode IN VARCHAR2);
   PROCEDURE create_lrs_measures_for_stops(network_name IN VARCHAR2,
                                           subnetwork_name IN VARCHAR2,
                                     	   log_loc IN VARCHAR2,
                                           log_file IN VARCHAR2,
                                           open_mode IN VARCHAR2);
   PROCEDURE add_geometry_to_service_links(network_name IN VARCHAR2,
                                           subnetwork_name IN VARCHAR2,
                                           service_link_table IN VARCHAR2,
					   log_loc IN VARCHAR2,
					   log_file IN VARCHAR2,
					   open_mode IN VARCHAR2);
   PROCEDURE split_links(network_name IN VARCHAR2, 
                         subnetwork_name IN VARCHAR2,
			 log_loc IN VARCHAR2,
		         log_file IN VARCHAR2,
		         open_mode IN VARCHAR2);
   PROCEDURE compute_geometry_for_trips(network_name IN VARCHAR2,
                                        subnetwork_name IN VARCHAR2,
                                        output_table IN VARCHAR2,
                                        log_loc IN VARCHAR2,
				        log_file IN VARCHAR2,
				        open_mode IN VARCHAR2);
   PROCEDURE generate_mm_user_data(network_name IN VARCHAR2,
                                   log_loc IN VARCHAR2,
                                   log_file IN VARCHAR2,
                                   open_mode IN VARCHAR2); 
   PROCEDURE generate_tlink_user_data(network_name IN VARCHAR2,
                                      log_loc IN VARCHAR2,
                                      log_file IN VARCHAR2,
                                      open_mode IN VARCHAR2);
   PROCEDURE create_indexes(network_name IN VARCHAR2,
                            log_loc IN VARCHAR2,
                            log_file IN VARCHAR2,
                            open_mode IN VARCHAR2);
   PROCEDURE create_subnet_schedule_ids(network_name IN VARCHAR2,
                                        subnetwork_name IN VARCHAR2,
                                        output_table IN VARCHAR2,
                                        log_loc IN VARCHAR2,
 		                        log_file IN VARCHAR2,
			   	        open_mode IN VARCHAR2);
   PROCEDURE create_schedule_ids(network_name IN VARCHAR2,
                                 log_loc IN VARCHAR2,
 		                 log_file IN VARCHAR2,
			   	 open_mode IN VARCHAR2);
   PROCEDURE load_gtfs_data(network_name IN VARCHAr2,
                            sub_network_name IN VARCHAR2,
                            csv_file_loc IN VARCHAR2,
                            agency_csv_file IN VARCHAR2,
                            calendar_csv_file IN VARCHAR2,
                            routes_csv_file IN VARCHAR2,
                            shapes_csv_file IN VARCHAR2,
                            stop_times_csv_file IN VARCHAR2,
                            stops_csv_file IN VARCHAR2,
                            trips_csv_file IN VARCHAR2, 
                            log_loc IN VARCHAR2,
                            log_file IN VARCHAR2,
                            open_mode IN VARCHAR2);
   PROCEDURE set_max_memory_size(bytes NUMBER);

   PROCEDURE create_multimodal_metadata;
   PROCEDURE create_mm_subnetwork_metadata;
   PROCEDURE insert_multimodal_metadata(network_name IN varchar2,
                                        node_table_name IN varchar2,
                                        link_table_name IN varchar2,
                                        base_network_name IN varchar2,
                                        base_node_table_name IN varchar2,
                                        base_link_table_name IN varchar2,
                                        service_node_table_name IN varchar2,
                                        service_link_table_name IN varchar2,
                                        stop_node_map_table_name IN varchar2,
                                        node_schedule_table_name IN varchar2,
                                        connect_link_table_name IN varchar2,
                                        transfer_link_table_name IN varchar2,
                                        link_type_table_name IN varchar2,
                                        route_table_name IN varchar2,
                                        log_loc IN varchar2,
                                        log_file IN varchar2,
                                        open_mode IN varchar2);
   PROCEDURE insert_mm_subnetwork_metadata(network_name IN varchar2,
                                           subnetwork_name IN varchar2,
                                           subnetwork_id IN number,
                                           agency_table_name IN varchar2,
                                           calendar_table_name IN varchar2,
                                           route_table_name IN varchar2, 
                                           shape_table_name IN varchar2, 
                                           stop_times_table_name IN varchar2,
                                           stop_table_name IN varchar2,
                                           trip_table_name IN varchar2,
                                           schedule_id_table_name varchar2,
                                           service_node_table_name IN varchar2,
                                           stop_node_map_table_name  varchar2,
                                           service_link_table_name IN varchar2,
                                           connect_link_table_name IN varchar2,
                                           node_schedule_table_name IN varchar2,
                                           log_loc IN varchar2,
                                           log_file IN varchar2,
                                           open_mode IN varchar2);
   FUNCTION get_mm_link_table_name(network_name IN varchar2) RETURN varchar2;
   FUNCTION get_base_network_name(network_name IN VARCHAR2) RETURN varchar2;
   FUNCTION get_base_node_table_name(network_name IN varchar2) RETURN varchar2;
   FUNCTION get_base_link_table_name(network_name IN varchar2) RETURN varchar2;
   FUNCTION get_service_node_table_name(network_name IN varchar2) RETURN varchar2;
   FUNCTION get_service_link_table_name(network_name IN varchar2) RETURN varchar2;
   FUNCTION get_stop_node_map_table_name(network_name IN varchar2) RETURN varchar2;
   FUNCTION get_node_schedule_table_name(network_name IN varchar2) RETURN varchar2;
   FUNCTION get_connect_link_table_name(network_name IN varchar2) RETURN varchar2;
   FUNCTION get_transfer_link_table_name(network_name IN varchar2) RETURN varchar2;
   FUNCTION get_link_type_table_name(network_name IN varchar2) RETURN varchar2;
   FUNCTION get_agency_table_name(network_name IN varchar2,
                                  subnetwork_name IN varchar2) RETURN varchar2;
   FUNCTION get_calendar_table_name(network_name IN varchar2,
                                    subnetwork_name IN varchar2) RETURN varchar2;
   FUNCTION get_sub_route_table_name(network_name IN varchar2,
                                 subnetwork_name IN varchar2) RETURN varchar2;
   FUNCTION get_shape_table_name(network_name IN varchar2,
                                 subnetwork_name IN varchar2) RETURN varchar2;
   FUNCTION get_stop_times_table_name(network_name IN varchar2,
                                      subnetwork_name IN varchar2) RETURN varchar2;
   FUNCTION get_stop_table_name(network_name IN varchar2,
                                subnetwork_name IN varchar2) RETURN varchar2;
   FUNCTION get_trip_table_name(network_name IN varchar2,
                                subnetwork_name IN varchar2) RETURN varchar2;
   FUNCTION get_schedule_id_table_name(network_name IN varchar2,
                                       subnetwork_name IN varchar2) RETURN varchar2;
   FUNCTION get_sub_service_node_table(network_name IN varchar2, 
                                       subnetwork_name IN varchar2)  RETURN varchar2;
   FUNCTION get_sub_service_link_table(network_name IN varchar2,
                                       subnetwork_name IN varchar2)  RETURN varchar2;
   FUNCTION get_sub_connect_link_table(network_name IN varchar2,
                                       subnetwork_name IN varchar2)  RETURN varchar2;
   FUNCTION get_sub_node_map_table(network_name IN varchar2, 
                                   subnetwork_name IN varchar2) RETURN varchar2;
   FUNCTION get_sub_node_sch_table(network_name IN varchar2,
                                   subnetwork_name IN varchar2) RETURN varchar2;
   PROCEDURE create_mm_views(network_name IN VARCHAR2,
                             log_loc IN VARCHAR2,
                             log_file IN VARCHAR2,
                             open_mode IN VARCHAR2);
   PROCEDURE create_mm_route_table(network_name IN VARCHAR2,
                                   output_table IN VARCHAR2,
                                   log_loc IN VARCHAR2,
                                   log_file IN VARCHAR2,
                                   open_mode IN VARCHAR2);
   PROCEDURE remove_subnetwork(network_name IN VARCHAR2,
                               subnetwork_name IN VARCHAR2,
                               remove_subnet_tables IN BOOLEAN,
                               log_loc IN VARCHAR2,
                               log_file IN VARCHAR2,
                               open_mode IN VARCHAR2);
   PROCEDURE add_subnetwork(network_name IN VARCHAR2,
                            base_network_name IN VARCHAR2,
                            subnetwork_name IN VARCHAR2,
                            transfer_radius IN VARCHAR2,
                            walking_speed IN VARCHAR2,
                            config_file_loc in VARCHAR2,
                            config_file IN VARCHAR2,
                            log_loc IN VARCHAR2,
                            log_file IN VARCHAR2,
                            open_mode IN VARCHAR2);
   PROCEDURE add_nodes_to_mm_nodes(network_name IN VARCHAR2,
                                   subnetwork_name IN VARCHAR2,
                                   input_node_table IN VARCHAR2,
				   mm_node_table IN VARCHAR2,
				   log_loc IN VARCHAR2,
				   log_file IN VARCHAR2,
				   open_mode IN VARCHAR2);
--
--
--
  PROCEDURE create_transfer_links_java(network_name IN VARCHAR2,
                                         output_table IN VARCHAR2,
                                         transfer_radius in number,
                                         walking_speed in number);
  PROCEDURE load_config(file_directory  IN VARCHAR2,
                        file_name       IN VARCHAR2);
  PROCEDURE load_config_java(config_xml IN CLOB);

END mm_util;
/

CREATE OR REPLACE PACKAGE BODY mm_util AS
 
-- log file
   mm_log_file utl_file.file_type := NULL;

   PROCEDURE set_log_info(file UTL_FILE.FILE_TYPE) IS
   BEGIN
      mm_log_file := file;
      EXCEPTION
	 WHEN OTHERS THEN RAISE;
   END set_log_info;

   PROCEDURE log_message(message IN VARCHAR2, show_time IN BOOLEAN) IS
   BEGIN
      if  (utl_file.is_open(mm_log_file) = FALSE )  then
         return;
      end if;
      IF ( show_time ) THEN
         utl_file.put_line (mm_log_file, '      ' || to_char(sysdate,'Dy fmMon DD HH24:MI:SS YYYY'));
      END IF;
      utl_file.put_line (mm_log_file, message);
      utl_file.fflush(mm_log_file);
   END log_message;

  PROCEDURE load_config_java( config_xml  IN CLOB )
  AS LANGUAGE JAVA
  NAME 'oracle.spatial.network.apps.multimodal.NDMMultimodalWrapper.loadConfig(oracle.sql.CLOB)';

  PROCEDURE load_config( file_directory  IN VARCHAR2 ,
                         file_name       IN VARCHAR2 )
  IS
    config_file    BFILE;
    config_xml     CLOB;
    amount         INTEGER;
  BEGIN
    config_file := bfilename(file_directory, file_name);
    dbms_lob.fileopen(config_file, dbms_lob.file_readonly);
    amount := dbms_lob.getlength(config_file);
    dbms_lob.createtemporary(config_xml, true);
    dbms_lob.loadfromfile(config_xml, config_file, amount);
    --call java stored procedure to load config xml
    load_config_java(config_xml);
    --clean up and close file
    dbms_lob.freetemporary(config_xml);
    dbms_lob.fileclose(config_file);
  END load_config;


   FUNCTION table_exists(table_name IN VARCHAR2) RETURN BOOLEAN IS
   query_str    VARCHAR2(512);
   no           NUMBER := 0;

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
    stmt  VARCHAR2(256);
    no    NUMBER := 0;
  BEGIN
    stmt := 'SELECT COUNT(*) FROM USER_VIEWS' ||
            ' WHERE VIEW_NAME = :n';
    EXECUTE IMMEDIATE stmt into no using UPPER(view_name);
    IF (no = 1) THEN
      RETURN true;
    ELSE
      RETURN false;
    END IF;
  END view_exists;

   FUNCTION index_on_col_exists( tab_name IN VARCHAR2, col_name IN VARCHAR2)
    							RETURN BOOLEAN IS
   stmt  VARCHAR2(256);
   no    NUMBER := 0;
   BEGIN
      stmt := 'SELECT COUNT(*) FROM USER_IND_COLUMNS WHERE TABLE_NAME = :tab_name AND COLUMN_NAME = :col_name';
      EXECUTE IMMEDIATE stmt into no using UPPER(tab_name), UPPER(col_name);
      IF (no >= 1) THEN
          RETURN true;
      ELSE
          RETURN false;
      END IF;
   END index_on_col_exists;

   FUNCTION index_exists(index_name IN VARCHAR2) RETURN BOOLEAN IS
   stmt  VARCHAR2(256);
   no    NUMBER := 0;
   BEGIN
      stmt := 'SELECT COUNT(*) FROM IND WHERE INDEX_NAME = :name';
      EXECUTE IMMEDIATE stmt into no using UPPER(index_name);
      IF (no = 1) THEN
         RETURN true;
      ELSE
         RETURN false;
      END IF;
   END index_exists;

   FUNCTION get_node_table_name(network_name IN VARCHAR2) RETURN VARCHAR2 IS
   query_str			varchar2(512);
   node_table_name		varchar2(32);
   BEGIN
      query_str := 'SELECT node_table_name FROM user_sdo_network_metadata ' ||
		   ' WHERE network=:a';
      execute immediate query_str into node_table_name using UPPER(network_name);
      return node_table_name;
   END get_node_table_name;

   FUNCTION get_link_table_name(network_name IN VARCHAR2) RETURN VARCHAR2 IS
   query_str 			varchar2(512);
   link_table_name		varchar2(32);
   BEGIN
      query_str := 'SELECT link_table_name FROM user_sdo_network_metadata ' ||
		   ' WHERE network=:a';
      execute immediate query_str into link_table_name using UPPER(network_name);
      return link_table_name;
   END get_link_table_name;

   FUNCTION get_part_table_name(network_name IN VARCHAR2) RETURN VARCHAR2 IS
   query_str 			varchar2(512);
   part_table_name		varchar2(32);
   BEGIN
      query_str := 'SELECT partition_table_name FROM user_sdo_network_metadata ' ||
		   ' WHERE network=:a';
      execute immediate query_str into part_table_name using UPPER(network_name);
      return part_table_name;
   END get_part_table_name;

   FUNCTION get_pblob_table_name(network_name IN VARCHAR2) RETURN VARCHAR2 IS
   query_str                    varchar2(512);
   table_name              varchar2(32);
   BEGIN
      query_str := 'SELECT partition_blob_table_name FROM user_sdo_network_metadata ' ||
                   ' WHERE network=:a';
      execute immediate query_str into table_name using UPPER(network_name);
      return table_name;
   END get_pblob_table_name;

   FUNCTION get_schedule_ids(network_name IN VARCHAR2,
                             subnetwork_name IN VARCHAR2) RETURN number_array IS
   query_str			varchar2(512);
   schedule_table		varchar2(32);
   sch_ids			number_array;
   BEGIN
      schedule_table := get_schedule_id_table_name(network_name, subnetwork_name);
      query_str := 'SELECT distinct schedule_id FROM ' || schedule_table ||
		   ' WHERE schedule_id > 0 ' || ' ORDER BY schedule_id';
      execute immediate query_str bulk collect into sch_ids;
      return sch_ids;
   END get_schedule_ids;

--
-- Find difference between two strings that represent time in HH:MI:SS format
-- The result will be in seconds
--
   FUNCTION find_diff_between_time_strings(timestr1 IN VARCHAR2,
					   timestr2 IN VARCHAR2) RETURN number IS
   hours				number;
   minutes				number;
   seconds				number;
   BEGIN
      hours := to_number(substr(timestr1,1,2),99) - 
	       to_number(substr(timestr2,1,2),99);
      minutes := to_number(substr(timestr1,4,2),99) - 
	         to_number(substr(timestr2,4,2),99);
      seconds := to_number(substr(timestr1,7,2),99) - 
	         to_number(substr(timestr2,7,2),99);
      return hours*3600+minutes*60+seconds;
   END find_diff_between_time_strings;

--
-- Adjusts the values of times when hour >= 24
-- Each time value must be represented as HH:MI:SS
--
   FUNCTION adjust_times_to_format(times_array IN SDO_STRING_ARRAY) 
					       RETURN SDO_STRING_ARRAY IS
   result_array				sdo_string_array := sdo_string_array();
   hour					number;
   separator				varchar(1) := ':';
   minutes				varchar2(2);
   seconds				varchar2(2);
   BEGIN
      for i IN 1 .. times_array.count loop
         result_array.extend;
	 hour := to_number(substr(times_array(i),1,2),99);
         minutes := substr(times_array(i),4,2);
         seconds := substr(times_array(i),7,2);
         if (hour >= 24) then
            hour := hour - 24;
	    result_array(i) := to_char(hour,'09') || separator || minutes || 
			       separator || seconds;
         else
	    result_array(i) := times_array(i);
         end if;
      end loop;
      return result_array;
   END adjust_times_to_format;
--
--
-- Creating nodes for bus stops for a subnetwork
   PROCEDURE create_nodes_for_subnetwork(network_name IN VARCHAR2,
                                         base_network_name IN VARCHAR2,
                                         subnetwork_name IN VARCHAR2,
                                         output_node_table IN VARCHAR2,
				         node_stop_map_table IN VARCHAR2,
				         log_loc  IN varchar2,
				         log_file IN varchar2,
			   	         open_mode IN varchar2) IS
   temp_routes_stops_table		varchar2(32);
   service_node_table			varchar2(32);
   stop_to_node_mapping_table           varchar2(32);
   route_table                          varchar2(32);
   trip_table 				varchar2(32);
   stop_table				varchar2(32);
   stop_times_table 			varchar2(32);
   temp_node_table			varchar2(32);
   link_table				varchar2(32);
   query_str				varchar2(1024);
   stmt					varchar2(512);
   incr					integer;
   query_csr				cursor_type;	
   max_node_id 				number;
   node_table				varchar2(32);
   temp_nid_idx				varchar2(32);
   temp_n_geom_idx			varchar2(32);
   sid_array				number_array;
   rid_array				number_array;
   stid_array                           number_array;
   d_array			        number_array;
   st_name_array			varchar_array;
   rowid_array				rowidarray;
   start_date				date;
   mm_log_file				utl_file.file_type := NULL;
   show_time                            boolean;

   BEGIN
      mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
      mm_util.set_log_info(mm_log_file);
      show_time := true;
      temp_routes_stops_table := network_name||'_route_nodes';
      route_table := get_sub_route_table_name(network_name,subnetwork_name);
      trip_table  := get_trip_table_name(network_name,subnetwork_name);
      stop_table  := get_stop_table_name(network_name,subnetwork_name);
      stop_times_table  := get_stop_times_table_name(network_name,subnetwork_name);
      service_node_table := output_node_table;
      stop_to_node_mapping_table := node_stop_map_table;
      if (trim(service_node_table) is null) then
         service_node_table := subnetwork_name||'_SERVICE_NODE$';
      end if;
      if (trim(stop_to_node_mapping_table) is null) then
         stop_to_node_mapping_table := subnetwork_name||'_STOP_NODE_ID_MAP';
      end if;
      mm_util.log_message('------ START : Create node table for stops: '||subnetwork_name,false);
      start_date := sysdate;
      if table_exists(temp_routes_stops_table) then
         execute immediate 'drop table ' || temp_routes_stops_table || ' purge';
      end if;
      query_str := 'CREATE TABLE ' || temp_routes_stops_table ||
                   ' (agency_id number,route_id number,stop_id number,'||
                   ' direction_id number, stop_name varchar2(256)) ' ||
		   ' NOLOGGING ';
      execute immediate query_str;
      
      query_str := 'INSERT /*+ APPEND */ INTO ' || temp_routes_stops_table ||
 		   ' (agency_id,route_id,stop_id,direction_id,stop_name) ' ||
                   ' SELECT distinct r.agency_id, r.route_id,st.stop_id,'||
                   ' t.direction_id, s.stop_name  FROM ' ||
		   route_table||' r, '||trip_table ||' t, '||stop_times_table ||' st, '||
                   stop_table || ' s ' ||
		   ' WHERE r.route_id=t.route_id AND st.trip_id=t.trip_id AND '||
                   ' s.stop_id = st.stop_id ';
      execute immediate query_str;
      commit;

/*
      node_table := get_node_table_name(network_name);
      query_str := 'SELECT max(node_id) FROM '||node_table;
      execute immediate query_str into max_node_id;
*/
--    Create a table for agency nodes
      if (table_exists(stop_to_node_mapping_table)) then
          execute immediate 'drop table ' || stop_to_node_mapping_table || ' purge';
      end if;
      query_str := 'CREATE TABLE ' || stop_to_node_mapping_table ||
   		   ' (node_id number,agency_id number,route_id number,'||
		   ' stop_id number,direction_id number,stop_name varchar2(256)) ';
      execute immediate query_str; 

      query_str := 'SELECT agency_id,route_id,stop_id,direction_id,stop_name,rowid  FROM ' || 
		   temp_routes_stops_table ;
      open query_csr for query_str;
      incr := 1;
      LOOP
         FETCH query_csr BULK COLLECT INTO sid_array,rid_array,stid_array,d_array,st_name_array,rowid_array LIMIT 5000;
         FOR i IN 1 .. rowid_array.count LOOP
            stmt := 'INSERT INTO ' || stop_to_node_mapping_table || 
                    ' (agency_id,route_id,stop_id,direction_id,node_id,stop_name) ' ||
		    ' VALUES (:a,:b,:c,:d,:e,:f) ' ;
            execute immediate stmt using sid_array(i),
                                         rid_array(i),
					 stid_array(i),
					 d_array(i),
					 --max_node_id+incr,
					 incr,
                                         st_name_array(i);
            incr := incr+1;
         END LOOP;
         sid_array.delete();
         rid_array.delete();
         stid_array.delete();
         d_array.delete();
         rowid_array.delete();
      EXIT WHEN query_csr%NOTFOUND;		
      END LOOP;
      close query_csr;
      commit;
--    Create temp node table
      temp_node_table := network_name ||'_TEMP_NODES';
      if (table_exists(temp_node_table)) then
          execute immediate 'drop table ' || temp_node_table || ' purge';
      end if;
      query_str := 'CREATE TABLE ' || temp_node_table ||
		   ' (node_id number, geometry sdo_geometry, x number, y number) ';
      execute immediate query_str;
      query_str := 'INSERT INTO ' || temp_node_table ||
                   ' (node_id, geometry, x, y) ' ||
                   ' SELECT t1.node_id,'||
                   ' SDO_GEOMETRY(2001,8307,SDO_POINT_TYPE(t2.stop_lon,t2.stop_lat,NULL),NULL,NULL),'||
                   ' t2.stop_lon,t2.stop_lat ' || ' FROM ' ||
                   stop_to_node_mapping_table || ' t1, '||
                   stop_table || ' t2 '|| ' WHERE ' ||
                   ' t1.stop_id = t2.stop_id ';
       execute immediate query_str;

--    Create a agency node table
      link_table := get_base_link_table_name(network_name);
      if (table_exists(service_node_table)) then
  	 execute immediate 'drop table ' || service_node_table || ' purge';
      end if;
      query_str := 'CREATE TABLE ' || service_node_table ||
  		   ' (node_id number, geometry sdo_geometry, x number, y number, '||
		   ' link_id number, percent number) ';
      execute immediate query_str;
      query_str := 'INSERT INTO ' || service_node_table ||
  		   ' (node_id, geometry, x, y, link_id,percent) ' ||
                   ' SELECT n.node_id node_id, n.geometry geometry, ' ||
		   ' n.x x, n.y y, t.link_id link_id, ' ||
		   ' SDO_NET.GET_PERCENTAGE(:a,t.link_id,n.geometry) percent '||
	           ' FROM ' || 
                   ' (SELECT t1.link_id link_id, t2.node_id node_id ' ||
                   '  FROM ' || link_table || '  t1, ' ||
                   temp_node_table || '  t2 ' ||
                   ' WHERE ' || 
                   'SDO_NN(t1.geometry,t2.geometry,''sdo_num_res=1'')=''TRUE'') t, '||
                   temp_node_table || ' n ' ||
                   ' WHERE n.node_id = t.node_id';
       execute immediate query_str using base_network_name;
       commit;

       query_str := 'UPDATE multimodal_subnetwork_metadata '||
                    ' SET service_node_table_name = :a '||
                    ' WHERE upper(network_name) = :b ';
       execute immediate query_str using service_node_table, upper(network_name);

       query_str := 'UPDATE multimodal_subnetwork_metadata ' ||
                    ' SET stop_node_map_table_name = :a ' ||
                    ' WHERE upper(network_name) = :b';
       execute immediate query_str using stop_to_node_mapping_table, upper(network_name);
       commit;
       if (table_exists(temp_routes_stops_table)) then
	  execute immediate 'drop table ' || temp_routes_stops_table || ' purge';
       end if;
       if (table_exists(temp_node_table)) then
	  execute immediate 'drop table ' || temp_node_table || ' purge';
       end if;
       mm_util.log_message('Creation of nodes for '||subnetwork_name||' took '||to_char((sysdate-start_date)*24*60,'99999.999')||' min', false);
       mm_util.log_message('------ END : Create node table for stops '||subnetwork_name,false);
       utl_file.fclose(mm_log_file);
   END create_nodes_for_subnetwork;

-- Finds operating trips for a route
-- Trips that have service IDs that do not operate on any day of week 
-- (according to info in calendar.txt) are left out.
   FUNCTION find_op_trips_for_a_route(network_name IN VARCHAR2,
                                      subnetwork_name IN VARCHAR2,
				      trip_table IN VARCHAR2,
				      route_id IN NUMBER) 
				      RETURN sdo_number_array IS
   trip_array				sdo_number_array := sdo_number_array();
   query_str				varchar2(512);
   schedule_id_table			varchar2(32);
   BEGIN
      schedule_id_table := get_schedule_id_table_name(network_name, subnetwork_name);
      query_str := 'SELECT distinct t1.trip_id FROM ' || 
                   trip_table ||' t1, '|| schedule_id_table || ' t2 ' ||
		   ' WHERE t1.route_id = :a AND ' ||
                   ' t1.service_id = t2.service_id AND ' ||
                   ' t2.schedule_id <> 0 ';
      execute immediate query_str bulk collect into trip_array using route_id;
      return trip_array;
   END find_op_trips_for_a_route;

--
--
--
   PROCEDURE create_service_links_table(network_name IN VARCHAR2,
				        service_link_table IN VARCHAR2) IS
   query_str 				varchar2(512);
   table_name				varchar2(32);
   BEGIN 
      table_name := service_link_table;
      if (table_name IS null) then
  	 table_name := network_name||'_SERVICE_LINK$';
      end if;
      if (table_exists(table_name)) then
	 execute immediate 'drop table ' || table_name || ' purge';
      end if;
--
--
      query_str := 'CREATE TABLE ' || table_name ||
		   ' (link_id number, start_node_id number, '||
                   ' end_node_id number,cost number,'||
                   ' geometry sdo_geometry, route_id number) ';
      execute immediate query_str;
   END create_service_links_table;

--
-- 
--
   FUNCTION create_links_for_a_route(network_name IN VARCHAR2,
                                     subnetwork_name IN VARCHAR2,
				     service_link_table IN VARCHAR2,
				     trip_table IN VARCHAR2,
				     route_trip_stop_table IN VARCHAR2,
				     route_id IN NUMBER,
				     max_link_id IN NUMBER, 
				     prev_link_id_incr IN NUMBER,
				     overwrite IN BOOLEAN,
				     log_loc  IN varchar2,
				     log_file IN varchar2,
				     open_mode IN varchar2) 
				     RETURN NUMBER IS
   stop_ids					sdo_number_array;  
   stop_seqs					sdo_number_array;
   agency_ids					sdo_number_array;
   dir_ids					sdo_number_array;
   arr_times					sdo_string_array;
   link_id_array				sdo_number_array := sdo_number_array();
   start_node_array				sdo_number_array := sdo_number_array();
   end_node_array 				sdo_number_array := sdo_number_array();
   link_cost_array				sdo_number_array := sdo_number_array();
   link_cost					number;
   stop_ids_in_order				number_assoc_array;
   agen_ids_in_order				number_assoc_array;
   dir_ids_in_order                             number_assoc_array;
   arr_times_in_order				string_assoc_array;
   query_str					varchar2(512);
   insert_str					varchar2(512);
   link_table					varchar2(32);
   temp_table 					varchar2(32);
   table_name					varchar2(32);
   query_csr					cursor_type;
   trip_array 					sdo_number_array;
   trip_id					number;
   link_id_incr					number;
   indx						integer;
   start_date					date;
   end_date					date;
   tmp_date					date;
   mm_log_file					utl_file.file_type := NULL;
   show_time					boolean;
   BEGIN
--    mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
--    mm_util.set_log_info(mm_log_file);
      start_date := sysdate;
-- here only those trips that operate are returned.
      trip_array := find_op_trips_for_a_route(network_name,subnetwork_name,trip_table,route_id);
      temp_table := 'TEMP_ROUTE_LINKS';
      table_name := service_link_table;
--  Create link table, if overwrite is true 
      if (table_name IS null) then
         table_name := subnetwork_name||'_SERVICE_RT_LINK$';
      end if;
      if (table_exists(table_name)) then
        if (overwrite) then
            execute immediate 'drop table ' || table_name || ' purge';
            query_str := 'CREATE TABLE ' || table_name ||
                    ' (agency_id number,route_id number,direction_id number,'||
                    ' link_id number,start_node_id number,end_node_id number,cost number) ';
            execute immediate query_str;
        end if;
      else
        query_str := 'CREATE TABLE ' || table_name ||
  		    ' (agency_id number,route_id number,direction_id number,'||
                    ' link_id number,start_node_id number,end_node_id number,cost number) ';
        dbms_output.put_line(query_str);
        execute immediate query_str;
      end if;

      insert_str := 'INSERT INTO ' || table_name ||
		  ' (agency_id,route_id,direction_id,link_id,start_node_id,end_node_id,cost) ' ||
		  ' VALUES (:a,:b,:c,:d,:e,:f,:g) ';

      indx := 1;
      for i IN 1 .. trip_array.count loop
         trip_id := trip_array(i);
         query_str := 'SELECT agency_id,direction_id,stop_id,stop_sequence,arrival_time FROM ' || 
		       route_trip_stop_table ||
		      ' WHERE route_id = :a AND trip_id = :b ' ||
                      ' ORDER BY stop_sequence ';
         open query_csr for query_str using route_id,trip_id;
         tmp_date := sysdate;
         LOOP
            FETCH query_csr BULK COLLECT INTO agency_ids,dir_ids,stop_ids,stop_seqs,arr_times LIMIT 1000;
            for j IN 1 .. stop_seqs.count loop
               stop_ids_in_order(stop_seqs(j)) := stop_ids(j);
	       agen_ids_in_order(stop_seqs(j)) := agency_ids(j);
	       dir_ids_in_order(stop_seqs(j)) := dir_ids(j);
               arr_times_in_order(stop_seqs(j)) := arr_times(j);
            end loop;
         EXIT WHEN query_csr%NOTFOUND;		
         END LOOP;
         close query_csr;
         for j IN 1 .. stop_seqs.count-1 loop
            link_id_array.extend;
            start_node_array.extend;
            end_node_array.extend;
            link_cost_array.extend;
 	    link_id_incr := prev_link_id_incr+indx;
            link_id_array(j) := max_link_id+link_id_incr;
            start_node_array(j) := stop_ids_in_order(stop_seqs(j));
            end_node_array(j) := stop_ids_in_order(stop_seqs(j+1));
--          Cost is calculated in seconds
            link_cost_array(j) := find_diff_between_time_strings(arr_times_in_order(j+1),arr_times_in_order(j));
            indx := indx+1;
         end loop; 
         forall j IN 1 .. start_node_array.count 
	    execute immediate insert_str 
	    using agen_ids_in_order(j),route_id,dir_ids_in_order(j),link_id_array(j),
		  start_node_array(j),end_node_array(j),link_cost_array(j);
         link_id_array.delete();
         start_node_array.delete();
         end_node_array.delete();
         link_cost_array.delete();
         agency_ids.delete();
	 dir_ids.delete();
         stop_ids.delete();
         stop_seqs.delete();
         arr_times.delete();
      end loop; 
      stop_ids_in_order.delete();
      agen_ids_in_order.delete();
      dir_ids_in_order.delete();
      arr_times_in_order.delete();
     
      tmp_date := sysdate; 
      commit;

      if (table_exists(temp_table)) then
         execute immediate 'drop table ' || temp_table || ' purge';
      end if;
      end_date := sysdate;
      --mm_util.log_message('Route : '||route_id ||'; Number of trips : '||trip_array.count,false);
      --mm_util.log_message('Create links table for route '|| route_id || ' : '||to_char((end_date-start_date)*24*60,'99999.999') || ' min.',false);
      --utl_file.fclose(mm_log_file);
      return link_id_incr;

    END create_links_for_a_route;
--
--
--
    PROCEDURE convert_stid_to_nid_in_links(input_table IN VARCHAR2,
					 stop_to_node_map_table IN VARCHAR2,
					 service_link_table IN VARCHAR2,
					 create_new_table IN BOOLEAN) IS
    query_str 						varchar2(512);
    create_str						varchar2(512);
    
    BEGIN
       create_str := 'CREATE TABLE ' || service_link_table ||
		     ' (link_id number, start_node_id number, '||
                     ' end_node_id number, cost number,'||
                     ' route_id number)';
       if (create_new_table) then
          if (table_exists(service_link_table)) then
	      execute immediate 'drop table ' || service_link_table ;
          end if;
	  execute immediate create_str;
       else 
          if (not(table_exists(service_link_table))) then
	     execute immediate create_str;
          end if;
       end if;
       query_str := 'INSERT INTO ' || service_link_table ||
		    ' SELECT t1.link_id link_id, t2.node_id start_node_id,'||
		    ' t3.node_id end_node_id,t1.cost cost, t1.route_id ' ||
		    ' FROM ' || input_table || ' t1, ' || 
                    stop_to_node_map_table || ' t2, ' ||
		    stop_to_node_map_table || ' t3 ' || ' WHERE ' ||
		    ' t1.start_node_id = t2.stop_id AND '||
		    ' t1.agency_id = t2.agency_id AND '||
		    ' t1.route_id = t2.route_id AND ' ||
		    ' t1.direction_id = t2.direction_id AND ' ||
		    ' t1.end_node_id = t3.stop_id AND ' ||
		    ' t1.agency_id = t3.agency_id AND '||
                    ' t1.route_id = t3.route_id AND ' ||
                    ' t1.direction_id = t3.direction_id ';
       execute immediate query_str; 
       
    END convert_stid_to_nid_in_links;
--
--					  
--
    PROCEDURE convert_stop_id_to_node_id(input_table IN VARCHAR2,
					 stop_to_node_map_table IN VARCHAR2,
					 node_time_table IN VARCHAR2) IS
    query_str					varchar2(512);
    BEGIN
       query_str := 'INSERT /*+ APPEND */ INTO ' || node_time_table ||
		    ' (node_id,service_id,arrival_time,departure_time) '||
		    ' SELECT t2.node_id,t1.service_id,'||
		    ' t1.arrival_time,t1.departure_time '||
		    ' FROM ' || input_table || ' t1, ' ||
		    stop_to_node_map_table || ' t2 ' ||
		    ' WHERE t1.stop_id = t2.stop_id AND ' ||
		    ' t1.agency_id = t2.agency_id AND '||
		    ' t1.route_id = t2.route_id AND ' ||
                    ' t1.direction_id = t2.direction_id ';
       execute immediate query_str;
       commit;
    END convert_stop_id_to_node_id;
--
-- 
--
   PROCEDURE create_route_trip_stop_table(network_name IN VARCHAR2,
                                          subnetwork_name IN VARCHAR2,
					  route_table IN VARCHAR2,
					  trip_table  IN VARCHAR2,
					  stop_time_table IN VARCHAR2) IS
   query_str					varchar2(512);
   route_trip_stop_table 			varchar2(32);
   BEGIN
       route_trip_stop_table := subnetwork_name||'_RT_TP_STP';
       if (table_exists(route_trip_stop_table)) then
          execute immediate 'drop table ' || route_trip_stop_table || ' purge';
       end if;
       query_str := 'CREATE TABLE ' || route_trip_stop_table ||
                    ' (agency_id number, route_id number,'||
                    ' trip_id number, stop_id number, '||
                    ' stop_sequence number, arrival_time varchar2(10),'||
		    ' direction_id number)';
       execute immediate query_str;
       query_str := 'INSERT INTO ' || route_trip_stop_table ||
                    ' (agency_id, route_id, trip_id,'||
                    ' stop_id, stop_sequence, arrival_time,direction_id)' ||
                    ' SELECT distinct r.agency_id agency_id, r.route_id route_id, '||
                    ' t.trip_id trip_id,st.stop_id stop_id, '||
                    ' st.stop_sequence stop_sequence,st.arrival_time,'||
		    ' t.direction_id direction_id '||
                    ' FROM ' || route_table || ' r, '|| trip_table || ' t,'||
                    stop_time_table || ' st ' || ' WHERE ' ||
		    ' r.route_id = t.route_id and st.trip_id = t.trip_id ' ||
                    ' order by r.route_id,t.trip_id,st.stop_sequence,t.direction_id ';
       execute immediate query_str;
       commit;
      
   END create_route_trip_stop_table;
--
--
--
    PROCEDURE create_subnet_service_links(network_name IN VARCHAR2,
                                          subnetwork_name IN VARCHAR2,
					  output_table IN VARCHAR2,
					  log_loc  IN varchar2,
					  log_file IN varchar2,
					  open_mode IN varchar2) IS
    route_id_array				sdo_number_array;
    query_str 					varchar2(512);
    query_csr					cursor_type;
    route_id					number;
    max_link_id 				number;
    link_id_incr				number;
    prev_link_id_incr				number;
    link_table 					varchar2(32);
    route_table					varchar2(32);
    trip_table					varchar2(32);
    stop_time_table				varchar2(32);
    service_links_table				varchar2(32);
    table_name				 	varchar2(32);
    route_trip_stop_table			varchar2(32);
    temp_link_table				varchar2(32);
    stop_to_node_map_table			varchar2(32);
    ltable_before_groupby		        varchar2(32);
    mm_link_table				varchar2(32);
    start_date					date;
    end_date					date;
    tmp_date					date;
    mm_log_file					utl_file.file_type := NULL;
    show_time					boolean;
    BEGIN
       mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
       mm_util.set_log_info(mm_log_file);
       start_date := sysdate;
       route_table := get_sub_route_table_name(network_name, subnetwork_name);
       trip_table := get_trip_table_name(network_name, subnetwork_name);
       stop_time_table := get_stop_times_table_name(network_name, subnetwork_name);
       stop_to_node_map_table := get_sub_node_map_table(network_name, subnetwork_name);
       create_route_trip_stop_table(network_name,subnetwork_name,route_table,trip_table,stop_time_table); 
       link_table := get_link_table_name(network_name);
       mm_link_table := get_mm_link_table_name(network_name);
       route_trip_stop_table := subnetwork_name||'_RT_TP_STP';
       temp_link_table	:= subnetwork_name||'_SERVICE_RT_LINK$';
       mm_util.log_message('****** START : Generation of all links for subnetwork '||subnetwork_name,true);

       service_links_table := output_table;
       if (trim(output_table) is null) then 
          service_links_table := subnetwork_name || '_SERVICE_LINK$';
       end if;
--     close log file; it will be opened in create_links_for_a_route
--     utl_file.fclose(mm_log_file);
--     Create a table for links with route ID, direction
       if (table_exists(temp_link_table)) then
	  execute immediate 'drop table ' || temp_link_table || ' purge';
       end if;
       query_str := 'CREATE TABLE ' || temp_link_table ||
		    ' (agency_id number,route_id number,direction_id number,'||
		    ' link_id number,start_node_id number,end_node_id number,'||
		    ' cost number)';
       execute immediate query_str;
       
       tmp_date := sysdate;
/*
       query_str := 'SELECT max(link_id) FROM ' || mm_link_table;
       execute immediate query_str into max_link_id;
*/
       max_link_id := 0;
       prev_link_id_incr := 0;
       query_str := 'SELECT distinct route_id FROM ' || route_table || ' ORDER BY route_id';
       open query_csr for query_str;
       LOOP
          fetch query_csr bulk collect into route_id_array limit 1000;
       EXIT WHEN query_csr%NOTFOUND;		
       END LOOP;
       close query_csr;
       for i IN 1 .. route_id_array.count loop
           route_id := route_id_array(i);
           link_id_incr := create_links_for_a_route(network_name,subnetwork_name,temp_link_table,trip_table,route_trip_stop_table,route_id,max_link_id,prev_link_id_incr,false,log_loc,log_file,'a');
           prev_link_id_incr := link_id_incr;
       end loop;
       end_date :=sysdate;
       
       ltable_before_groupby := subnetwork_name||'_INTMED_LINKS';
       if (table_exists(ltable_before_groupby)) then
	  execute immediate 'drop table ' || ltable_before_groupby || ' purge';
       end if;

--     reopen log file
--     mm_log_file := utl_file.fopen(log_loc,log_file,'a');
--     mm_util.set_log_info(mm_log_file);
       mm_util.log_message('Generation of links took '||to_char((sysdate-tmp_date)*24*60,'99999.999') || ' min.',false);

       tmp_date := sysdate;       
       convert_stid_to_nid_in_links(temp_link_table, stop_to_node_map_table, ltable_before_groupby, true);
       create_service_links_table(network_name,service_links_table);
       
       query_str := 'INSERT INTO ' || service_links_table ||
		    ' (link_id,start_node_id,end_node_id,cost,route_id) ' ||
		    ' SELECT min(link_id) link_id,start_node_id start_node_id ,'||
		    ' end_node_id end_node_id, min(cost) cost, min(route_id) ' 
                    || ' FROM ' || ltable_before_groupby || 
                    ' GROUP BY start_node_id,end_node_id ' ;
       execute immediate query_str;
       commit;
       mm_util.log_message('Convert to node IDs and insert with group by took '||to_char((sysdate-tmp_date)*24*60,'99999.999') || ' min.',false);
		    
       if (table_exists(temp_link_table)) then
	  execute immediate 'drop table ' || temp_link_table || ' purge';
       end if;
       if (table_exists(route_trip_stop_table)) then
          execute immediate 'drop table ' || route_trip_stop_table || ' purge';
       end if;
       if (table_exists(ltable_before_groupby)) then
          execute immediate 'drop table ' || ltable_before_groupby || ' purge';
       end if;

       mm_util.log_message('****** Insert Links in Multimodal Links Table',false);
       
--     Add geometry to service links
       tmp_date := sysdate;
       add_geometry_to_service_links(network_name, subnetwork_name, service_links_table, log_loc, log_file, 'a');

       query_str := 'UPDATE multimodal_subnetwork_metadata ' ||
                    ' SET service_link_table_name = :a '||
                    ' WHERE upper(network_name) = :b AND upper(subnetwork_name) = :c';
       execute immediate query_str using service_links_table, upper(network_name),
                                         subnetwork_name;
       commit;

--     Add service links to mm_links
       tmp_date := sysdate;
--     add_links_to_mm_links(network_name,service_links_table,mm_link_table,true,false,log_loc,log_file,'a');
--     mm_util.log_message('Adding links to MM_links table '||to_char((sysdate-tmp_date)*24*60,'99999.999') || ' min.',false);

       tmp_date := sysdate;
--     insert_in_link_type_table(network_name,service_links_table,1,false,log_loc,log_file,'a');
--     mm_util.log_message('Inserting Links is Link Type Table '||to_char((sysdate-tmp_date)*24*60,'99999.999') || ' min.',false);
       mm_util.log_message('Generation of service links took '||to_char((sysdate-start_date)*24*60,'99999.999') || ' min.',false);
       mm_util.log_message('****** END : Generation of Service Links for subnetwork '||subnetwork_name,true);
       utl_file.fclose(mm_log_file);
    END create_subnet_service_links;

--
-- Creating node schedules
--
-- (1) create a table with trip_id,agency_id,route_id,stop_id,direction_id,
--     arrival_time,departure_time
-- (2) create another table with agency_id,route_id,stop_id,direction_id
--     translated to node_id
-- (3) Create a table with nodes, schedules
    PROCEDURE create_node_times(network_name IN VARCHAR2,
                                subnetwork_name IN VARCHAR2,
				node_time_table IN VARCHAR2,
				log_loc  IN varchar2,
				log_file IN varchar2,
				open_mode IN varchar2) IS
    query_str					varchar2(1024);
    rt_stop_time_table				varchar2(32);
    route_table					varchar2(32);
    trip_table					varchar2(32);
    stop_time_table 				varchar2(32);
    stop_to_node_map_table			varchar2(32);
    schedule_id_table				varchar2(32);
    temp_node_time_table 			varchar2(32);
    mm_log_file					utl_file.file_type := NULL;
    show_time					boolean;
    BEGIN
       mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
       mm_util.set_log_info(mm_log_file);
       route_table := get_sub_route_table_name(network_name, subnetwork_name);
       trip_table := get_trip_table_name(network_name, subnetwork_name);
       stop_time_table := get_stop_times_table_name(network_name, subnetwork_name);
       stop_to_node_map_table := get_sub_node_map_table(network_name, subnetwork_name);
       rt_stop_time_table  := subnetwork_name||'_ROUTE_STOP_TIMES';
       schedule_id_table := get_schedule_id_table_name(network_name, subnetwork_name);
       mm_util.log_message('****** START : Create table with nodes and arrival times ',true);
       if (table_exists(rt_stop_time_table)) then
          execute immediate 'drop table '||rt_stop_time_table||' purge';
       end if;
       query_str := 'CREATE TABLE ' ||rt_stop_time_table||
		    ' (route_id number, agency_id number, '||
		    ' trip_id number, service_id number, ' ||
		    ' direction_id number,stop_id number,'||                
                    ' stop_sequence number, arrival_time varchar2(10), ' ||
                    ' departure_time varchar2(10)) ' || ' NOLOGGING ';
       execute immediate query_str;
       query_str := 'INSERT /*+ APPEND */ INTO ' || rt_stop_time_table ||
	            ' SELECT t1.route_id route_id, t1.agency_id agency_id,'||
                    ' t2.trip_id trip_id, t2.service_id service_id, ' ||
		    ' t2.direction_id direction_id,'||
		    ' t3.stop_id stop_id, t3.stop_sequence stop_sequence,'||
                    ' t3.arrival_time arrival_time,t3.departure_time departure_time ' ||
                    ' FROM '|| route_table || ' t1, ' || trip_table || ' t2, ' ||
                    stop_time_table || ' t3 ' ||
                    ' WHERE ' || ' t1.route_id=t2.route_id and ' ||
		    ' t2.trip_id=t3.trip_id and ' || 
                    ' t2.service_id in ' ||
		    ' (SELECT service_id from ' || schedule_id_table ||
		    '  WHERE schedule_id > 0) and ' ||
                    ' t1.route_id in ' || 
		    ' (SELECT distinct route_id FROM '|| route_table || ' ) '||
                    ' ORDER BY t3.stop_id,t2.direction_id,t3.arrival_time';	    
       execute immediate query_str;
       commit;
       
       temp_node_time_table := 'TEMP_NODE_TIMES';
       if (table_exists(temp_node_time_table)) then
          execute immediate 'drop table ' || temp_node_time_table || ' purge';
       end if;
       query_str := 'CREATE TABLE ' || temp_node_time_table || 
                    ' (node_id number,service_id number,arrival_time varchar2(10), '||
                    ' departure_time varchar2(10)) NOLOGGING ' ;
       execute immediate query_str;
       convert_stop_id_to_node_id(rt_stop_time_table, stop_to_node_map_table, temp_node_time_table);

-- Map service IDs to schedule IDs
       if (table_exists(node_time_table)) then
          execute immediate 'drop table ' || node_time_table || ' purge';
       end if;
       query_str := 'CREATE TABLE ' || node_time_table ||
                    ' (node_id number,schedule_id number,arrival_time varchar2(10), '||
                    ' departure_time varchar2(10)) NOLOGGING ' ;
       execute immediate query_str;
       query_str := 'INSERT INTO ' || node_time_table ||
		    ' SELECT t1.node_id,t2.schedule_id,t1.arrival_time, '||
		    ' t1.departure_time FROM ' || temp_node_time_table || ' t1, ' ||
		    schedule_id_table || ' t2 ' || 
		    ' WHERE t1.service_id = t2.service_id ' ;
       execute immediate query_str;
       commit;
 
       if (table_exists(temp_node_time_table)) then
           execute immediate 'drop table ' || temp_node_time_table || ' purge';
       end if;
       if (table_exists(rt_stop_time_table)) then
           execute immediate 'drop table ' || rt_stop_time_table || ' purge';
       end if;
       mm_util.log_message('****** END : Create table with nodes and arrival times ',true);
       utl_file.fclose(mm_log_file);

    END create_node_times;   
    
   FUNCTION get_service_node_ids(network_name IN VARCHAR2,
                                 subnetwork_name IN VARCHAR2) RETURN sdo_number_array IS
   node_ids				sdo_number_array;
   query_str				varchar2(512);
   service_node_table			varchar2(32);
   BEGIN
      service_node_table := get_sub_service_node_table(network_name, subnetwork_name);
      query_str := 'SELECT node_id FROM ' || service_node_table;
      execute immediate query_str bulk collect into node_ids;
      return node_ids;
   END;

-- Creating node_schedule for a schedule_id
   PROCEDURE create_node_schedule_for_an_id(network_name IN VARCHAR2,
                                            subnetwork_name IN VARCHAR2,
                                            node_sch_table_name IN VARCHAR2,
                                            schedule_id IN number,
					    log_loc  IN varchar2,
					    log_file IN varchar2,
					    open_mode IN varchar2) IS
   query_str                                   	varchar2(512);
   insert_str                                   varchar2(512);
   columns_str					varchar2(128);
   node_sch_table 			  	varchar2(32);
   node_time_table                             	varchar2(32);
   arrival_times                               	sdo_string_array;
   arrival_times_adjusted 			sdo_string_array;
   node_ids                                    	sdo_number_array;
   arrival_times_as_date 			date_array;
   node_id                                     	number;
   mm_log_file					utl_file.file_type := NULL;
   show_time					boolean;
   start_date					date;
   BEGIN
      mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
      mm_util.set_log_info(mm_log_file);
      start_date := sysdate;
      mm_util.log_message('****** START : Create node schedule for schedule ID '||schedule_id,false);
      node_time_table := subnetwork_name||'_NODE_TIME$';
      --node_sch_table := subnetwork_name||'_NODE_SCH_'||schedule_id;
      node_sch_table := node_sch_table_name;
      if (table_exists(node_sch_table)) then
         execute immediate 'drop table ' || node_sch_table || ' purge';
      end if;
      columns_str := ' (node_id number, node_schedule_'||schedule_id||'  sdo_string_array)';
      query_str := 'CREATE TABLE ' || node_sch_table ||columns_str||
		   ' NOLOGGING ';
      execute immediate query_str;
      columns_str := '(node_id, node_schedule_'||schedule_id||')';
      insert_str := 'INSERT /*+ APPEND */ INTO ' || node_sch_table ||
                    columns_str || ' VALUES ' || ' (:a,:b) ';
      node_ids := get_service_node_ids(network_name, subnetwork_name);
      for  i IN 1 .. node_ids.count loop
            node_id := node_ids(i);
            query_str := 'SELECT arrival_time from '|| node_time_table ||
                      ' WHERE node_id = :a AND schedule_id = :b' || 
		      ' ORDER BY arrival_time ';
            execute immediate query_str bulk collect into arrival_times using node_id,schedule_id;
--          arrival_times_as_date := convert_to_date_array(arrival_times);
            arrival_times_adjusted := adjust_times_to_format(arrival_times);
	    execute immediate insert_str using node_id,arrival_times_adjusted;
            commit;
      end loop;
      mm_util.log_message('Time taken :  '||to_char((sysdate-start_date)*24*60,'99999.999'),false);
      mm_util.log_message('****** END : Create node schedule for schedule ID '||schedule_id,false);
      utl_file.fclose(mm_log_file); 
   END create_node_schedule_for_an_id;

-- 
-- Create the node schedule table. (Node, varray of arrival times) 
-- 
    PROCEDURE create_subnet_node_schedules(network_name IN VARCHAR2,
                                               subnetwork_name IN VARCHAR2,
				               node_schedule_table IN VARCHAR2,
				               log_loc  IN varchar2,
				               log_file IN varchar2,
				               open_mode IN varchar2) IS
    query_str 					varchar2(4096);
    schedule_ids 				number_array;
    columns_str				        varchar2(4096);
    tables_str					varchar2(1024);
    sch_table_name				varchar2(32);
    select_str					varchar2(1024);
    condition_str				varchar2(1024);
    table_name					varchar2(32);
    node_time_table				varchar2(32);
    indx_name 					varchar2(32);
    sch_id					integer;
    start_date					date;
    mm_log_file					utl_file.file_type := NULL;
    show_time					boolean;
    BEGIN
      mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
      mm_util.set_log_info(mm_log_file);

      mm_util.log_message('****** START : Create node schedules',true);
      if (table_exists(node_schedule_table)) then
         execute immediate 'drop table ' || node_schedule_table || ' purge';
      end if;
      
      schedule_ids := get_schedule_ids(network_name, subnetwork_name);

--    Close log file so that it can be opened in called procedures
      utl_file.fclose(mm_log_file);

--    Create a table with nodes and arrival, departure times.
      node_time_table := subnetwork_name||'_NODE_TIME$';
      create_node_times(network_name,subnetwork_name,node_time_table,log_loc,log_file,'a');      

--    Create a table for each schedule ID
      for i IN 1 .. schedule_ids.count loop
          sch_table_name := subnetwork_name||'_NODE_SCH_'||i;
          create_node_schedule_for_an_id(network_name,subnetwork_name,sch_table_name,schedule_ids(i),log_loc,log_file,'a');
      end loop;

      columns_str := ' (node_id number, ';
      for i IN 1 .. schedule_ids.count loop
         sch_id := schedule_ids(i);
         columns_str := columns_str || 'schedule_'||sch_id||' sdo_string_array';
         if (i < schedule_ids.count) then
             columns_str := columns_str || ', ';
         end if;
      end loop;
      columns_str := columns_str||') ';
      query_str := 'CREATE TABLE ' || node_schedule_table ||
		   columns_str || ' NOLOGGING';
      execute immediate query_str;

      columns_str := ' node_id, ';
      tables_str := '';
      select_str := ' t1.node_id, ';
      condition_str := '';
      for i IN 1 .. schedule_ids.count loop
         sch_id := schedule_ids(i);
	 table_name := subnetwork_name||'_NODE_SCH_'||sch_id;
         columns_str := columns_str || 'schedule_'||sch_id;
         tables_str := tables_str||table_name || ' t'||sch_id|| ' ';
         select_str := select_str||' t'||i||'.node_schedule_'||sch_id;
         if (i < schedule_ids.count) then
             columns_str := columns_str || ', ';
             tables_str := tables_str||' , ';
             select_str := select_str||' , ';
             condition_str := condition_str||' t'||i||'.node_id=t'||(i+1)||'.node_id ';
         end if;
         if (i<schedule_ids.count-1) then
             condition_str := condition_str||' and ';
         end if;
      end loop;
      columns_str := ' ('||columns_str||') ';
      start_date := sysdate; 
      query_str := 'INSERT /*+ APPEND */ into '|| node_schedule_table ||
		   columns_str || ' SELECT ' || select_str ||
		   ' FROM ' || tables_str || ' WHERE ' ||
  		   condition_str;
      execute immediate query_str;
      commit;
--    Reopen log file
      mm_log_file := utl_file.fopen(log_loc,log_file,'a');
      mm_util.set_log_info(mm_log_file);
      mm_util.log_message('Insert into final node schedule table  : '||to_char((sysdate-start_date)*24*60,'99999.999') || ' min.',false);

--    Cleaning up; deleting intermediate schedule tables
      for j IN 1 .. schedule_ids.count loop
 	 table_name := subnetwork_name||'_NODE_SCH_'||j;
         if (table_exists(table_name)) then
           execute immediate 'drop table ' || table_name || ' purge';
         end if;
      end loop;

--    Update subnetwork metadata with node schedule table
      query_str := 'UPDATE multimodal_subnetwork_metadata t SET '||
                    ' t.node_schedule_table_name = :s '|| 
                    ' WHERE ' || ' upper(trim(t.network_name)) = upper(:a) AND '||
                    ' upper(trim(t.subnetwork_name)) = upper(:b)';
      execute immediate query_str using node_schedule_table, 
                                        network_name, subnetwork_name;
      commit;      

      mm_util.log_message('****** END : Create node schedules',true);
      utl_file.fclose(mm_log_file);
          
    END create_subnet_node_schedules;

    PROCEDURE insert_geom_metadata(table_name IN VARCHAR2, column_name IN VARCHAR2) IS
    query_str						varchar2(512);
    BEGIN
       query_str := 'DELETE FROM user_sdo_geom_metadata ' || ' WHERE ' ||
		    ' table_name = UPPER(:a) and column_name = UPPER(:b)';
       execute immediate query_str using table_name,column_name;

       query_str := 'INSERT INTO user_sdo_geom_metadata ' ||
		    ' (table_name,column_name,diminfo,srid) ' ||
		    ' VALUES ' ||
		    ' (:a,:b,'||
		    ' MDSYS.SDO_DIM_ARRAY(
                      MDSYS.SDO_DIM_ELEMENT(''X'',-180,180,0.05),
                      MDSYS.SDO_DIM_ELEMENT(''Y'',-90,90,0.05)), 8307)';
       execute immediate query_str using UPPER(table_name),UPPER(column_name);
    END insert_geom_metadata;

--  Inserts nodes from base node table and 
--  creates nodes for service networks
--  Node IDs of service nodes (which are 1 .. max value) are adjusted
--  The subnetwork service node tables are updated with new Node IDs
--  A service node table (view) is created that consists of all service nodes
--  for all subnetworks.
    PROCEDURE create_mm_node_tables(network_name IN VARCHAR2,
                                    final_node_table IN VARCHAR2,
                                    mm_service_node_table in VARCHAR2,
                                    mm_stop_node_map_table in VARCHAR2,
                                    log_loc IN VARCHAR2,
                                    log_file IN VARCHAR2,
                                    open_mode IN VARCHAR2) IS
    query_str						varchar2(512);
    create_str						varchar2(1024);
    mm_node_table					varchar2(32);
    service_node_table					varchar2(32);
    stop_node_map_table					varchar2(32);
    lrs_measure_table					varchar2(32);
    lrs_project_table					varchar2(32);
    final_service_node_table				varchar2(32);
    final_node_map_table				varchar2(32);
    temp_service_node_table				varchar2(32);
    temp_stop_node_map_table				varchar2(32);
    temp_lrs_project_table				varchar2(32);
    temp_lrs_measure_table				varchar2(32);
    base_node_table					varchar2(32);
    indx_name						varchar2(32);
    num_subnetworks					number;
    current_max_id					number;
    subnetwork_names					sdo_string_array;
    base_network_name					varchar2(32);
    subnetwork						varchar2(32);
    tables_str						varchar2(512);
    start_date						date;
    tmp_date						date;
    mm_log_file                                 	utl_file.file_type := NULL;
    BEGIN
       mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
       mm_util.set_log_info(mm_log_file);
       mm_util.log_message('***** START : Creating Node Table For the Entire MM network.',true);
       start_date := sysdate;
       mm_node_table := final_node_table;
       if (trim(mm_node_table) is null) then
          mm_node_table := network_name||'_NODE$';
       end if;
       if (table_exists(mm_node_table)) then
	   execute immediate 'drop table '|| mm_node_table || ' purge';
       end if;

--     Create mm node table
       query_str := 'CREATE TABLE ' || mm_node_table ||
		    ' (node_id number, geometry sdo_geometry, x number, y number) '||
                    ' NOLOGGING';
       execute immediate query_str;

--     Create node tables for sub networks

--     Get the subnetworks for the given network
       query_str := 'SELECT subnetwork_name FROM multimodal_subnetwork_metadata ' ||
                    ' WHERE upper(network_name) = :n';
       execute immediate query_str bulk collect into subnetwork_names
                                                using upper(network_name);
       
--     Creating nodes 
       for i in 1 .. subnetwork_names.count loop
          subnetwork := subnetwork_names(i);
          service_node_table := subnetwork||'_SERVICE_NODE$';
          stop_node_map_table := subnetwork||'_STOP_NODE_ID_MAP';
          base_network_name := get_base_network_name(network_name);
          mm_util.create_nodes_for_subnetwork(network_name, base_network_name, subnetwork, service_node_table, stop_node_map_table, log_loc, log_file, 'a');          
          mm_util.create_lrs_measures_for_stops(network_name, subnetwork, log_loc, log_file, 'a'); 
       end loop;

--    Inserting nodes into mm nodes table

--     Insert rows from base node table
       base_node_table := get_base_node_table_name(network_name);
       query_str := 'INSERT /*+ APPEND */ INTO '|| mm_node_table ||
 		    ' (node_id,geometry,x,y) ' ||
                    ' SELECT node_id,geometry,x,y FROM ' || base_node_table;
       execute immediate query_str;
       commit;

--     Insert service nodes in the mm node table; node IDs are updated.
       for i in 1 .. subnetwork_names.count loop
          query_str := 'SELECT max(node_id) FROM ' || mm_node_table;
          execute immediate query_str into current_max_id;

          subnetwork := subnetwork_names(i);

          service_node_table := get_sub_service_node_table(network_name, subnetwork);
          query_str := 'INSERT /*+ APPEND */ INTO '|| mm_node_table ||
 		       ' (node_id,geometry,x,y) ' ||
		       ' SELECT node_id+:m, geometry, x, y FROM ' || service_node_table;
          execute immediate query_str using current_max_id;
          commit;

--     Create a temp table tp update the node IDs of the subnetwork service node table
          temp_service_node_table := subnetwork||'_TEMP_SRVC_NODE';
          if (table_exists(temp_service_node_table)) then
             execute immediate 'drop table '||temp_service_node_table||' purge';
          end if;
  
          query_str := 'CREATE TABLE ' || temp_service_node_table||
		       ' (node_id number, x number, y number, '||
                       ' link_id number, percent number, ' ||
                       ' geometry sdo_geometry) NOLOGGING ';
          execute immediate query_str;
 
          query_str := 'INSERT /*+ APPEND */ INTO ' || 
                        temp_service_node_table ||
                        ' (node_id, x, y, link_id, percent, geometry) '||
                        ' SELECT node_id+:m, x, y , '||
                        ' link_id,  percent, geometry '||
                        ' FROM ' || service_node_table;
          execute immediate query_str using current_max_id;
          commit;

--     Create a temp table tp update the node IDs of the subnetwork stop-node map table
          stop_node_map_table := get_sub_node_map_table(network_name, subnetwork);
          temp_stop_node_map_table := subnetwork||'_TEMP_NODE_MAP';
          if (table_exists(temp_stop_node_map_table)) then
              execute immediate 'drop table '||temp_stop_node_map_table||' purge';
          end if;
     
          query_str := 'CREATE TABLE ' || temp_stop_node_map_table||
                       ' (node_id number, agency_id number, route_id number, '||
                       ' stop_id number, direction_id number, ' ||
                       ' stop_name varchar2(256)) NOLOGGING ';
          execute immediate query_str;

          query_str := 'INSERT /*+ APPEND */ INTO ' ||
                        temp_stop_node_map_table ||
                        ' (node_id, agency_id, route_id, '||
                        ' stop_id, direction_id, stop_name) '||
                        ' SELECT node_id+:m, agency_id, route_id, '||
                        ' stop_id, direction_id, stop_name '||
                        ' FROM ' || stop_node_map_table;
          execute immediate query_str using current_max_id;
          commit;

--     Create a temp table to update node IDs of lrs measure table
       lrs_measure_table := subnetwork||'_LRS_MEASURE$';
       temp_lrs_measure_table := subnetwork||'_TEMP_LRS_MEASURE';
       if (table_exists(temp_lrs_measure_table)) then
              execute immediate 'drop table '||temp_lrs_measure_table||' purge';
       end if;

       query_str := 'CREATE TABLE ' ||temp_lrs_measure_table||
                    ' (node_id number, shape_id number, '||
                    ' trip_id number, lrs_measure number)';
       execute immediate query_str;
      
       query_str := 'INSERT /*+ APPEND */ INTO ' || 
                    temp_lrs_measure_table ||
                    ' (node_id, shape_id, trip_id, lrs_measure) '||
                    ' SELECT node_id+:m, shape_id, trip_id, lrs_measure ' ||
                    ' FROM ' || lrs_measure_table;
       execute immediate query_str using current_max_id;
       commit;
                  
--     Create a temp table to update node IDs of lrs project table
       lrs_project_table := subnetwork||'_LRS_PROJECT$';
       temp_lrs_project_table := subnetwork||'_TEMP_LRS_PROJECT';
       if (table_exists(temp_lrs_project_table)) then
              execute immediate 'drop table '||temp_lrs_project_table||' purge';
       end if;

       query_str := 'CREATE TABLE ' ||temp_lrs_project_table||
                    ' (node_id number, shape_id number, '||
                    ' trip_id number, geometry sdo_geometry)';
       execute immediate query_str;
      
       query_str := 'INSERT /*+ APPEND */ INTO ' ||
                    temp_lrs_project_table ||
                    ' (node_id, shape_id, trip_id, geometry) '||
                    ' SELECT node_id+:m, shape_id, trip_id, geometry ' ||
                    ' FROM ' || lrs_project_table;
       execute immediate query_str using current_max_id;
       commit;  

--        Rename the temp table as subnetwork service node table
          if (table_exists(service_node_table)) then
             execute immediate 'drop table ' || service_node_table || ' purge';
          end if;
          query_str := 'ALTER TABLE ' || temp_service_node_table ||
                       ' RENAME TO ' || service_node_table;
          execute immediate query_str;
          commit;

--        Rename the temp table as subnetwork node stop map table
          if (table_exists(stop_node_map_table)) then
             execute immediate 'drop table ' || stop_node_map_table || ' purge';
          end if;
          query_str := 'ALTER TABLE ' || temp_stop_node_map_table ||
                       ' RENAME TO ' || stop_node_map_table;
          execute immediate query_str;
          commit;

--        Rename the temp table as subnetwork lrs measure table
          if (table_exists(lrs_measure_table)) then
             execute immediate 'drop table ' || lrs_measure_table || ' purge';
          end if;
          query_str := 'ALTER TABLE ' || temp_lrs_measure_table ||
                       ' RENAME TO ' || lrs_measure_table;
          execute immediate query_str;
          commit;

--        Rename the temp table as subnetwork lrs measure table
          if (table_exists(lrs_project_table)) then
             execute immediate 'drop table ' || lrs_project_table || ' purge';
          end if;
          query_str := 'ALTER TABLE ' || temp_lrs_project_table ||
                       ' RENAME TO ' || lrs_project_table;
          execute immediate query_str;
          commit;

       end loop;

       insert_geom_metadata(mm_node_table,'GEOMETRY');

       indx_name := network_name||'_mm_nid_idx';
       if (not(index_on_col_exists(mm_node_table,'node_id'))) then  
          if (not(index_exists(indx_name))) then
	     execute immediate 'create index '||indx_name||' on '||mm_node_table ||
			       ' (node_id) ';
          end if;
       end if;
      
       indx_name := network_name||'_mm_ngeom_idx';
       if (not(index_on_col_exists(mm_node_table,'geometry'))) then
          if (not(index_exists(indx_name))) then
             execute immediate 'create index '||indx_name||' on '||mm_node_table ||
                               ' (geometry) indextype is mdsys.spatial_index';
          end if;
       end if;

--     Update metadata with node table name
       query_str := 'UPDATE ndm_multimodal_metadata '||
                    ' SET node_table_name = :a '||
                    ' WHERE upper(network_name) = :b ';
       execute immediate query_str using mm_node_table, upper(network_name);

       final_service_node_table := mm_service_node_table;
       if (trim(final_service_node_table) is null) then
          final_service_node_table := network_name||'_SERVICE_NODE$';
       end if;
       if (view_exists(final_service_node_table)) then
           execute immediate 'drop view '|| final_service_node_table;
       end if;

--     Creating the service nodes table for the entire network as
--     a view
       tables_str := '';
       for i in 1 .. subnetwork_names.count loop
          subnetwork := subnetwork_names(i);
          service_node_table := get_sub_service_node_table(network_name, subnetwork);
          tables_str := tables_str || ' SELECT * FROM ' || service_node_table || ' ';
          if (i < subnetwork_names.count) then
             tables_str := tables_str || ' UNION ALL ';
          end if;   
       end loop;
       query_str := 'CREATE OR REPLACE VIEW ' || final_service_node_table || ' AS '||
		    tables_str || ' NOLOGGING';
       execute immediate query_str;
       commit;
     
--     Update metadata with service node table name
       query_str := 'UPDATE ndm_multimodal_metadata '||
                    ' SET service_node_table_name = :a '||
                    ' WHERE upper(network_name) = :b ';
       execute immediate query_str using final_service_node_table, 
                                         upper(network_name);
       commit;

--     Creating the node-stop map table for the entire network as
--     a view
       final_node_map_table :=  mm_stop_node_map_table;
       if (trim(final_node_map_table) is null) then
          final_node_map_table := network_name||'_STOP_NODE_ID_MAP';
       end if;
       if (view_exists(final_node_map_table)) then
           execute immediate 'drop view '|| final_node_map_table;
       end if;
       
       tables_str := '';
       for i in 1 .. subnetwork_names.count loop
          subnetwork := subnetwork_names(i);
          stop_node_map_table := get_sub_node_map_table(network_name, subnetwork);
          tables_str := tables_str || ' SELECT * FROM ' || stop_node_map_table || ' ';
          if (i < subnetwork_names.count) then
             tables_str := tables_str || ' UNION ALL ';
          end if;
       end loop;
       query_str := 'CREATE OR REPLACE VIEW ' || final_node_map_table || ' AS '||
                    tables_str || ' NOLOGGING';
       execute immediate query_str;
       commit;

--     Update metadata with service node table name
       query_str := 'UPDATE ndm_multimodal_metadata '||
                    ' SET service_node_table_name = :a '||
                    ' WHERE upper(network_name) = :b ';
       execute immediate query_str using final_service_node_table,
                                         upper(network_name);
       commit;

--     Update metadata with stop-node map table name
       query_str := 'UPDATE ndm_multimodal_metadata '||
                    ' SET stop_node_map_table_name = :a '||
                    ' WHERE upper(network_name) = :b ';
       execute immediate query_str using final_node_map_table,
                                         upper(network_name);
       commit;

--     Drop temporary tables
       if (table_exists(temp_lrs_measure_table)) then
          execute immediate 'drop table ' || temp_lrs_measure_table || ' purge';
       end if;
       if (table_exists(temp_lrs_project_table)) then
          execute immediate 'drop table ' || temp_lrs_project_table || ' purge';
       end if;
       if (table_exists(temp_service_node_table)) then
          execute immediate 'drop table ' || temp_service_node_table || ' purge';
       end if;
       if (table_exists(temp_stop_node_map_table)) then
          execute immediate 'drop table ' || temp_stop_node_map_table || ' purge';
       end if;

       mm_util.log_message('***** END : Creating Node Table For the Entire MM network.',true);

    END create_mm_node_tables;

    PROCEDURE create_mm_node_schedule_table(network_name IN VARCHAR2,
                                       output_table IN VARCHAR2,
                                       log_loc IN VARCHAR2,
                                       log_file IN VARCHAR2,
                                       open_mode IN VARCHAR2) IS
    node_sch_table 					varchar2(32);
    subnetwork_names					sdo_string_array;
    subnetwork						varchar2(32);
    tables_str						varchar2(512);
    query_str						varchar2(1024);
    subnetwork_sch_table				varchar2(32);
    sch_table						varchar2(32);
    start_date						date;
    tmp_date						date;
    mm_log_file                                         utl_file.file_type := NULL;
    BEGIN
        mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
        mm_util.set_log_info(mm_log_file);
        mm_util.log_message('***** START : Creating Node Schedule Table For the Entire MM network.',true);
        node_sch_table := output_table;
        if (trim(node_sch_table) is null) then
          node_sch_table := network_name||'_NODE_SCH$';
        end if;

--     Create schedule ID table
       mm_util.create_schedule_ids(network_name, log_loc, log_file, 'a');

--     Get the subnetworks for the given network
       query_str := 'SELECT subnetwork_name FROM multimodal_subnetwork_metadata ' ||
                    ' WHERE upper(network_name) = :n';
       execute immediate query_str bulk collect into subnetwork_names
                                                using upper(network_name);

       utl_file.fclose(mm_log_file);
--     Create node schedule tables for subnetworks
       for i IN 1 .. subnetwork_names.count loop
          subnetwork := subnetwork_names(i);
          subnetwork_sch_table := subnetwork||'_NODE_SCH$';
          mm_util.create_subnet_node_schedules(network_name, subnetwork, subnetwork_sch_table, log_loc, log_file, 'a');
       end loop;
--     Creating the nodes schedules table for the entire network as
--     a view
       tables_str := '';
       for i in 1 .. subnetwork_names.count loop
          subnetwork := subnetwork_names(i);
          sch_table := get_sub_node_sch_table(network_name, subnetwork);
          tables_str := tables_str || ' SELECT * FROM ' || sch_table || ' ';
          if (i < subnetwork_names.count) then
             tables_str := tables_str || ' UNION ALL ';
          end if;
       end loop;
       query_str := 'CREATE OR REPLACE VIEW ' || node_sch_table || ' AS '||
                    tables_str;
       execute immediate query_str;
       commit;

--     Update metadata with mm node schedule table name
       query_str := 'UPDATE ndm_multimodal_metadata '||
                    ' SET node_schedule_table_name = :a '||
                    ' WHERE upper(network_name) = :b ';
       execute immediate query_str using node_sch_table,
                                         upper(network_name);
       commit;
--     Reopen log file
       mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
       mm_util.set_log_info(mm_log_file);
       mm_util.log_message('***** END : Creating Node Schedule Table For the Entire MM network.',true);
       utl_file.fclose(mm_log_file);

    END create_mm_node_schedule_table;

-- To maintain the partitions of the original network, the new service nodes created 
-- would be assigned to the original partitions
-- the new node table (original nodes + service nodes) will NOT be re-partitioned
-- The assignment will be done based on its proximity to start/end node of the link
-- 
    PROCEDURE add_nodes_to_partitions(network_name IN VARCHAR2, log_loc IN VARCHAR2,
                                      log_file IN VARCHAR2, open_mode in VARCHAR2) IS
    query_str 					varchar2(512);
    part_table					varchar2(32);
    link_table					varchar2(32);
    service_node_table				varchar2(32);	
    base_node_table				varchar2(32);
    mm_network					varchar2(32);
    node_lvl_table				varchar2(32);
    smallest_part_id				number;
    BEGIN
       base_node_table := get_base_node_table_name(network_name);
       link_table := get_base_link_table_name(network_name);
       part_table := get_part_table_name(network_name);
       service_node_table := get_service_node_table_name(network_name); 

--     Remove nodes that were added (if any) 
       query_str := 'DELETE FROM ' || part_table || 
                    ' WHERE node_id NOT IN ' ||
                    ' (SELECT node_id FROM ' || base_node_table || ' )';
       dbms_output.put_line('Query : '||query_str);
       execute immediate query_str;
       commit;

--     Remove nodes with link level = 2 
       query_str := 'DELETE FROM ' || part_table ||
                    ' WHERE link_level = 2';
       execute immediate query_str;
       commit;

       query_str := 'INSERT /*+ APPEND */ INTO ' || part_table || 
                    ' (node_id,partition_id, link_level) ' ||
		    ' SELECT n.node_id node_id, p.partition_id partition_id, 1 ' ||
		    ' FROM ' || service_node_table || ' n, ' ||
		    link_table || ' l, ' || part_table || ' p ' ||
		    ' WHERE l.end_node_id=p.node_id and n.link_id=l.link_id and n.percent>0.5';
       execute immediate query_str;
       commit; 

       query_str := 'INSERT /*+ APPEND */ INTO ' || part_table || 
                    ' (node_id,partition_id, link_level) ' ||
                    ' SELECT n.node_id node_id, p.partition_id partition_id, 1 ' ||
                    ' FROM ' || service_node_table || ' n, ' ||
                    link_table || ' l, ' || part_table || ' p ' ||
                    ' WHERE l.start_node_id=p.node_id and n.link_id=l.link_id and n.percent<=0.5';
       execute immediate query_str;
       commit;

--  To insert nodes corresponding to link_level = 2
--  Run generate_node_levels
--  Find the partition with the least number of nodes
--  Add nodes with link_level = 2 in this partition.
    mm_network := network_name;
    node_lvl_table := mm_network||'_NLVL$';
    sdo_net.generate_node_levels(mm_network, node_lvl_table, true, log_loc, log_file,'a');
 
    query_str := 'SELECT t.partition_id ' ||
                 ' FROM ' || 
                 ' (SELECT partition_id partition_id, count(*) min_count '||
                 ' FROM ' || part_table ||
                 ' GROUP BY  partition_id ' ||
                 ' HAVING count(*) = '||
                 ' (SELECT min(count(*)) ' || ' FROM '||
                 part_table || ' GROUP BY partition_id)) t ' ||
                 ' WHERE rownum < 2 ';
    execute immediate query_str into smallest_part_id;

    query_str := 'INSERT INTO ' || part_table || 
                 ' (node_id,link_level,partition_id) ' ||
                 ' SELECT node_id, link_level, :p ' ||
                 ' FROM ' || node_lvl_table;
    execute immediate query_str using smallest_part_id;
    commit;

    END add_nodes_to_partitions;

--
-- This procedure removes all service nodes from partition table
-- Acts as a claen up procedure to counter add_nodes_to_partitions
-- Should be called before changing service nodes table
--
    PROCEDURE remove_srvc_nodes_from_part(network_name IN VARCHAR2,
					  log_loc IN VARCHAR2,
					  log_file IN VARCHAR2,
					  open_mode IN VARCHAR2) IS
    mm_log_file					utl_file.file_type := NULL;
    query_str					varchar2(512);
    part_table					varchar2(32);
    node_table				varchar2(32);
    BEGIN
       mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
       mm_util.set_log_info(mm_log_file);
       part_table := get_part_table_name(network_name);
       node_table := get_node_table_name(network_name);

       query_str := 'DELETE FROM ' || part_table ||
		    ' WHERE ' || ' node_id NOT IN ' ||
		    ' (SELECT node_id FROM ' || node_table || ')';
       execute immediate query_str;
       commit;

       query_str := 'DELETE FROM ' || part_table  ||
                    ' WHERE ' || ' link_level = 2';
       execute immediate query_str;
       commit;

       utl_file.fclose(mm_log_file); 
    END remove_srvc_nodes_from_part;
--
--
--
   PROCEDURE create_mm_link_tables(network_name IN VARCHAR2,
                                   output_link_table IN VARCHAR2,
                                   mm_service_link_table IN VARCHAR2,
                                   mm_connect_link_table IN VARCHAR2,
                                   log_loc IN VARCHAR2,
                                   log_file IN VARCHAR2,
                                   open_mode IN VARCHAR2) IS
    query_str						varchar2(1024);
    tables_str						varchar2(512);
    max_link_id						number;
    current_max_id					number;
    mm_link_table					varchar2(32);
    service_link_table					varchar2(32);
    connect_link_table					varchar2(32);
    final_service_link_table				varchar2(32);
    final_connect_link_table				varchar2(32);
    temp_service_link_table				varchar2(32);
    temp_connect_link_table				varchar2(32);
    base_link_table					varchar2(32);
    transfer_link_table					varchar2(32);
    indx_name						varchar2(32);
    subnetwork						varchar2(32);
    subnetwork_names 					sdo_string_array;
    BEGIN
       mm_link_table := output_link_table;
       if (trim(mm_link_table) is null) then
          mm_link_table := network_name||'_LINK$';
       end if;
       base_link_table := get_base_link_table_name(network_name);
       --service_link_table := get_service_link_table_name(network_name);
       --connect_link_table := get_connect_link_table_name(network_name);
       if (table_exists(mm_link_table)) then
	  execute immediate 'drop table ' || mm_link_table || ' purge';
       end if;

--     Create mm link table
       query_str := 'CREATE TABLE ' || mm_link_table ||
		    ' (link_id number, start_node_id number, end_node_id number,'||
                    ' link_level number, cost number, s number, f number,' ||
		    ' geometry sdo_geometry, name varchar2(128), divider varchar2(1)) '||
                    ' NOLOGGING';
       execute immediate query_str;
       commit;

--     Create service and connect link tables for sub networks

--     Get subnetworks for the given network
       query_str := 'SELECT subnetwork_name FROM multimodal_subnetwork_metadata '||
                    ' WHERE upper(network_name) = :n';
       execute immediate query_str bulk collect into subnetwork_names 
                                                using upper(network_name);

--     Creating links
       for i in 1 .. subnetwork_names.count loop
           subnetwork := subnetwork_names(i);
           service_link_table := subnetwork||'_SERVICE_LINK$';
           connect_link_table := subnetwork||'_CONNECT_LINK$';
           mm_util.create_subnet_service_links(network_name, subnetwork, service_link_table, log_loc, log_file, 'a');
           mm_util.create_subnet_connect_links(network_name, subnetwork, connect_link_table, log_loc, log_file, 'a');
       end loop;

--     Insert rows from base link table
       query_str := 'INSERT /*+ APPEND */ INTO ' || mm_link_table ||
                    ' (link_id, start_node_id, end_node_id, link_level,'||
                    ' cost, s, f, geometry, name, divider) ' ||
                    ' SELECT link_id, start_node_id, end_node_id,'||
                    ' link_level,length, s, f, geometry, name, divider '||
                    ' FROM ' || base_link_table;
       execute immediate query_str;
       commit;

--     Insert rows from service node table and connect link table
--     for all subnetworks
--     Link IDs are updated

       for i in 1 .. subnetwork_names.count loop
          
          subnetwork := subnetwork_names(i);

          query_str := 'SELECT max(link_id) FROM ' || mm_link_table;
          execute immediate query_str into current_max_id;
--        service links
          service_link_table := get_sub_service_link_table(network_name, subnetwork);
      
          query_str := 'INSERT /*+ APPEND */ INTO '|| mm_link_table ||
                       ' (link_id, start_node_id, end_node_id, cost,'|| 
                       'geometry) ' ||
                       ' SELECT link_id+:m, start_node_id, end_node_id, '||
                       ' cost, geometry '||' FROM ' || service_link_table;
          execute immediate query_str using current_max_id;
          commit;

--        Create a temp table to update the link IDs of the subnetwork service link table
          temp_service_link_table := subnetwork||'_TEMP_SRVC_LINK';
          if (table_exists(temp_service_link_table)) then
              execute immediate 'drop table '|| temp_service_link_table || ' purge';
          end if;
          query_str := 'CREATE TABLE ' || temp_service_link_table ||
                       ' (link_id number, start_node_id number, '||
                       ' end_node_id number, cost number, route_id number, '||
                       ' geometry sdo_geometry) ';
          execute immediate query_str;
          
          query_str := 'INSERT /*+ APPEND */ INTO ' ||
                       temp_service_link_table ||
                       ' (link_id, start_node_id, end_node_id,'||
                       '  cost, route_id, geometry) '||
                       ' SELECT link_id+:m, start_node_id, end_node_id,'||
                       ' cost, route_id, geometry '|| 
                       ' FROM ' || service_link_table;
          execute immediate query_str using current_max_id;
          commit;

--     Rename the temp table as subnetwork service link table
          if (table_exists(service_link_table)) then
             execute immediate 'drop table ' || service_link_table || ' purge';
          end if;
          query_str := 'ALTER TABLE ' || temp_service_link_table ||
                       ' RENAME TO ' || service_link_table;
          execute immediate query_str;
          commit;
       end loop;

--     Connect links
       for i in 1 .. subnetwork_names.count loop
          
          subnetwork := subnetwork_names(i);

          query_str := 'SELECT max(link_id) FROM ' || mm_link_table;
          execute immediate query_str into current_max_id;
          connect_link_table := get_sub_connect_link_table(network_name, subnetwork);
          query_str := 'INSERT /*+ APPEND */ INTO ' || mm_link_table ||
                    ' (link_id, start_node_id, end_node_id, cost, '||
                    ' geometry, s) '||
                    ' SELECT link_id+:m, start_node_id, end_node_id, '||
                    ' cost, geometry, s '||
                    ' FROM '|| connect_link_table;
          execute immediate query_str using current_max_id;
          commit;
--        Create a temp table to update the link IDs of the subnetwork connect link table
          temp_connect_link_table := subnetwork||'_TEMP_CONN_LINK';
          if (table_exists(temp_connect_link_table)) then
              execute immediate 'drop table '|| temp_connect_link_table || ' purge';
          end if;
          query_str := 'CREATE TABLE ' || temp_connect_link_table ||
                       ' (link_id number, start_node_id number, '||
                       ' end_node_id number, cost number, s number, '||
                       ' geometry sdo_geometry, node_id number, '||
                       ' base_link_id number) ';
          execute immediate query_str;
          
          query_str := 'INSERT /*+ APPEND */ INTO ' ||
                       temp_connect_link_table ||
                       ' (link_id, start_node_id, end_node_id,'||
                       '  cost, s, geometry, node_id, base_link_id) '||
                       ' SELECT link_id+:m, start_node_id, end_node_id,'||
                       ' cost, s, geometry, node_id, base_link_id '|| 
                       ' FROM ' || connect_link_table;
          execute immediate query_str using current_max_id;
          commit;

--     Rename the temp table as subnetwork service link table
          if (table_exists(connect_link_table)) then
             execute immediate 'drop table ' || connect_link_table || ' purge';
          end if;
          query_str := 'ALTER TABLE ' || temp_connect_link_table ||
                       ' RENAME TO ' || connect_link_table;
          execute immediate query_str;
          commit;
         
       end loop;

--     Update metadata with mm link table name
       query_str := 'UPDATE ndm_multimodal_metadata '||
                    ' SET link_table_name = :a '||
                    ' WHERE upper(network_name) = :b ';
       execute immediate query_str using mm_link_table, upper(network_name);

--     Insert mm_link_table in geom_metadata
       insert_geom_metadata(mm_link_table,'GEOMETRY');

--     Create the service links table for the entire network as a view
       final_service_link_table := mm_service_link_table;
       if (trim(final_service_link_table) is null) then
          final_service_link_table := network_name||'_SERVICE_LINK$';
       end if;
       if (view_exists(final_service_link_table)) then
          execute immediate 'drop view ' || final_service_link_table;
       end if;

       tables_str := '';
       for i in 1 .. subnetwork_names.count loop
          subnetwork := subnetwork_names(i);
          service_link_table := get_sub_service_link_table(network_name, subnetwork);
          tables_str := tables_str || ' SELECT * FROM ' || service_link_table || ' ';
          if (i < subnetwork_names.count) then
             tables_str := tables_str || ' UNION ALL ';
          end if;
       end loop;
       query_str := 'CREATE OR REPLACE VIEW ' || final_service_link_table || ' AS '||
                    tables_str || ' NOLOGGING';
       execute immediate query_str;
       commit;

--     Create the connect links table for the entire network as a view
       final_connect_link_table := mm_connect_link_table;
       if (trim(final_connect_link_table) is null) then
          final_connect_link_table := network_name||'_CONNECT_LINK$';
       end if;
       if (view_exists(final_connect_link_table)) then
          execute immediate 'drop view ' || final_connect_link_table;
       end if;

       tables_str := '';
       for i in 1 .. subnetwork_names.count loop
          subnetwork := subnetwork_names(i);
          connect_link_table := get_sub_connect_link_table(network_name, subnetwork);
          tables_str := tables_str || ' SELECT * FROM ' || connect_link_table || ' ';
          if (i < subnetwork_names.count) then
             tables_str := tables_str || ' UNION ALL ';
          end if;
       end loop;
       query_str := 'CREATE OR REPLACE VIEW ' || final_connect_link_table || ' AS '||
                    tables_str || ' NOLOGGING';
       execute immediate query_str;
       commit;

--     Update metadata with service link, connect link tables
       query_str := 'UPDATE ndm_multimodal_metadata '||
                    ' SET service_link_table_name = :a '||
                    ' WHERE upper(network_name) = :b ';
       execute immediate query_str using final_service_link_table,
                                         upper(network_name);
       commit;

       query_str := 'UPDATE ndm_multimodal_metadata '||
                    ' SET connect_link_table_name = :a '||
                    ' WHERE upper(network_name) = :b ';
       execute immediate query_str using final_connect_link_table,
                                         upper(network_name);
       commit;

    END create_mm_link_tables;

--
--  Add links to mm_links_table
--
    PROCEDURE add_links_to_mm_links(network_name IN VARCHAR2,
				    input_link_table IN VARCHAR2,
				    mm_link_table IN VARCHAR2,
                                    include_geometry IN boolean,
                                    include_s IN boolean,
                                    log_loc IN VARCHAR2,
                                    log_file IN VARCHAR2,
                                    open_mode IN VARCHAR2) IS
    mm_log_file                                 utl_file.file_type := NULL;
    start_date					date;
    tmp_date					date;
    output_table				varchar2(32);
    columns_str					varchar2(512);
    ins_columns_str				varchar2(512);
    query_str					varchar2(1024);
    max_link_id 				number;
    temp_tr_table				varchar2(32);
    BEGIN
       mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
       mm_util.set_log_info(mm_log_file);
       output_table := mm_link_table;

       start_date := sysdate;
       if (output_table is null) then
          output_table := network_name||'_LINK$';
       end if;

       if (not(table_exists(input_link_table))) then
          mm_util.log_message('*** ERROR : '||input_link_table||' DOES NOT EXIST!!',false);
          mm_util.log_message('*** Exiting the procedure.....',false);
          return;
       end if;

       if (not(table_exists(output_table))) then
          mm_util.log_message('*** ERROR : '||output_table||' DOES NOT EXIST!!',false);
          mm_util.log_message('*** Create the table and execute the procedure.....',false);
          mm_util.log_message('*** Exiting the procedure.....',false);
          return;
       end if;

       columns_str := ' link_id+:m,start_node_id,end_node_id,cost ';
       ins_columns_str := ' link_id,start_node_id,end_node_id,cost ';
       if (include_geometry) then
	  columns_str := columns_str||',geometry ';
	  ins_columns_str := ins_columns_str||',geometry ';
       end if;

       if (include_s) then
          columns_str := columns_str||' ,s ';
          ins_columns_str := ins_columns_str||' ,s ';
       end if;

       query_str := 'SELECT max(link_id) FROM ' || output_table;
       execute immediate query_str into max_link_id;

       query_str := 'INSERT /*+ APPEND */ INTO ' || output_table ||
		    ' ( ' || ins_columns_str || ' ) ' ||
		    ' SELECT ' || columns_str || ' FROM ' ||
		    input_link_table;
       execute immediate query_str using max_link_id;
       commit;

--     Updating link IDs in transfer link table
       temp_tr_table := 'TEMP_LINKS';
       if (table_exists(temp_tr_table)) then
          execute immediate 'drop table ' || temp_tr_table || ' purge';
       end if;

       query_str := 'CREATE TABLE ' || temp_tr_table ||
                    ' (link_id number, start_node_id number, '||
                    ' end_node_id number, cost number, '||
                    ' geometry sdo_geometry, s number) ';
       execute immediate query_str;

       query_str := 'INSERT /*+ APPEND */ INTO ' || temp_tr_table ||
                    ' (link_id, start_node_id, end_node_id, '||
                    ' cost, geometry, s) ' ||
                    ' SELECT link_id+:m, start_node_id, end_node_id, ' ||
                    ' cost, geometry, s '|| ' FROM ' ||
                    input_link_table;
       execute immediate query_str using max_link_id;
       commit;

       execute immediate 'drop table ' || input_link_table || ' purge';
       commit;

       query_str := 'ALTER TABLE ' || temp_tr_table || 
                    ' RENAME TO ' || input_link_table;
       execute immediate query_str;
       commit;
 
       mm_util.log_message('Inserting links from '||input_link_table||' in ' || output_table || ' took ' || to_char((sysdate-start_date)*24*60,'99999.999') || ' min.',false);
    END add_links_to_mm_links;

--
--  Correct service node geom after creating connect links 
--

    PROCEDURE correct_service_node_geom(network_name IN VARCHAR2,
			        	log_loc IN VARCHAR2,
			  		log_file IN VARCHAR2,
					open_mode IN VARCHAR2) IS
    mm_log_file					utl_file.file_type := NULL;
    query_str					varchar2(1024);
    temp_table					varchar2(32);
    service_node_table				varchar2(32);
    connect_link_table				varchar2(32);
    start_date					date;
    tmp_date					date;
    BEGIN
       mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
       mm_util.set_log_info(mm_log_file);
       temp_table := 'SERVICE_ND_WITH_NEW_GEOM';
       service_node_table := get_service_node_table_name(network_name);
       connect_link_table := get_connect_link_table_name(network_name);
       start_date := sysdate;
       if (table_exists(temp_table)) then
	   execute immediate 'drop table ' || temp_table || ' purge';
       end if;
       query_str := 'CREATE TABLE ' || temp_table || 
		    ' (node_id number, geometry sdo_geometry, '||
		    '  link_id number, percent number) '||
		    ' NOLOGGING ';
       execute immediate query_str;
       
       query_str := 'INSERT /*+ APPEND */ INTO '||temp_table ||
		    ' (node_id,geometry,link_id,percent) ' ||
		    ' SELECT n.node_id,'||
		    ' SDO_LRS.CONVERT_TO_STD_GEOM(sdo_lrs.geom_segment_end_pt(sdo_lrs.convert_to_lrs_geom(l1.geometry))),' ||
		    ' n.link_id,n.percent '||
		    ' FROM ' || service_node_table || ' n, ' || connect_link_table || ' l1, '||
		    ' (SELECT node_id,min(link_id) link_id FROM '||connect_link_table ||
		    ' WHERE geometry is not null '|| 
		    '  GROUP BY node_id) l ' || ' WHERE ' ||
		    ' n.node_id = l1.end_node_id and ' || 
		    ' l.node_id = n.node_id and l1.link_id = l.link_id ';		    
       execute immediate query_str;
       commit;
      
       query_str := 'INSERT /*+ APPEND */ INTO '||temp_table ||
                    ' (node_id,geometry,link_id,percent) ' ||
                    ' SELECT n.node_id,'||
                    ' SDO_LRS.CONVERT_TO_STD_GEOM(sdo_lrs.geom_segment_start_pt(sdo_lrs.convert_to_lrs_geom(l1.geometry))),' ||
                    ' n.link_id,n.percent '||
                    ' FROM ' || service_node_table || ' n, ' || connect_link_table || ' l1, '||
                    ' (SELECT node_id,max(link_id) link_id FROM '||connect_link_table ||
		    ' WHERE geometry is not null '||
                    '  GROUP BY node_id) l ' || ' WHERE ' ||
                    ' n.node_id = l1.start_node_id and ' ||
                    ' l.node_id = n.node_id and l1.link_id = l.link_id and '||
		    ' n.node_id NOT IN (SELECT node_id FROM '|| temp_table||')';
       execute immediate query_str;
       commit;

       query_str := 'INSERT /*+ APPEND */ INTO '||temp_table ||
                    ' (node_id,geometry,link_id,percent) ' ||
                    ' SELECT n.node_id,'||
                    ' SDO_LRS.CONVERT_TO_STD_GEOM(sdo_lrs.geom_segment_start_pt(sdo_lrs.convert_to_lrs_geom(l1.geometry))),' ||
                    ' n.link_id,n.percent '||
                    ' FROM ' || service_node_table || ' n, ' || connect_link_table || ' l1, '||
                    ' (SELECT node_id,min(link_id) link_id FROM '||connect_link_table ||
                    ' WHERE geometry is not null '||
                    '  GROUP BY node_id) l ' || ' WHERE ' ||
                    ' n.node_id = l1.start_node_id and ' ||
                    ' l.node_id = n.node_id and l1.link_id = l.link_id and '||
                    ' n.node_id NOT IN (SELECT node_id FROM '|| temp_table||')';
       execute immediate query_str;
       commit;

        query_str := 'INSERT /*+ APPEND */ INTO '||temp_table ||
                    ' (node_id,geometry,link_id,percent) ' ||
                    ' SELECT n.node_id,'||
                    ' SDO_LRS.CONVERT_TO_STD_GEOM(sdo_lrs.geom_segment_end_pt(sdo_lrs.convert_to_lrs_geom(l1.geometry))),' ||
                    ' n.link_id,n.percent '||
                    ' FROM ' || service_node_table || ' n, ' || connect_link_table || ' l1, '||
                    ' (SELECT node_id,max(link_id) link_id FROM '||connect_link_table ||
                    ' WHERE geometry is not null '||
                    '  GROUP BY node_id) l ' || ' WHERE ' ||
                    ' n.node_id = l1.end_node_id and ' ||
                    ' l.node_id = n.node_id and l1.link_id = l.link_id and '||
                    ' n.node_id NOT IN (SELECT node_id FROM '|| temp_table||')';
       execute immediate query_str;
       commit;

       execute immediate 'truncate table ' || service_node_table ;
       query_str := 'INSERT /*+ APPEND */ INTO ' || service_node_table ||
		    ' (node_id,geometry,x,y,link_id,percent) ' ||
		    ' SELECT n.node_id,n.geometry,n.geometry.sdo_point.x,'||
		    ' n.geometry.sdo_point.y,n.link_id,n.percent ' ||
		    ' FROM ' || temp_table || ' n ';
       execute immediate query_str;
       commit;

       if (table_exists(temp_table)) then
	   execute immediate 'drop table ' || temp_table || ' purge';
       end if;
       mm_util.log_message('Correcting geometry of service nodes took ' ||to_char((sysdate-start_date)*24*60,'99999.999') || ' min.',false);

    END correct_service_node_geom;
--
-- Create temp connect links by calling Java method through wrapper
--
    PROCEDURE create_connect_links_java(network_name IN VARCHAR2, 
                                        subnetwork_name IN VARCHAR2,
                                        output_table IN VARCHAR2) 
      AS LANGUAGE JAVA
      NAME 'oracle.spatial.network.apps.multimodal.NDMMultimodalWrapper.createConnectLinks(java.lang.String,java.lang.String,java.lang.String)';

-- 
--  Create connect links
--
    PROCEDURE create_subnet_connect_links(network_name IN VARCHAR2,
                                   	  subnetwork_name IN VARCHAR2,
                                   	  output_table IN VARCHAR2,
				   	  log_loc  IN varchar2,
				   	  log_file IN varchar2,
				   	  open_mode IN varchar2) IS
    query_csr					cursor_type;
    query_str 					varchar2(1024);
    insert_str					varchar2(512);
    link_table					varchar2(32);
    service_node_table				varchar2(32);
    connect_links_table				varchar2(32);
    temp_connect_link_table			varchar2(32);
    mm_link_table				varchar2(32);
    link_ids_table				varchar2(32);
    max_link_id					number;
    lcost					number;
    nid_array					number_array;
    lid_array					number_array;
    sid_array					number_array;
    eid_array					number_array;
    cost_array					number_array;
    s_array					number_array;  
    g_array					geom_array;
    rowid_array					rowidarray;
    lgeom1					sdo_geometry;
    lgeom2					sdo_geometry;
    res_geom_1					sdo_geometry;
    res_geom_2					sdo_geometry;
    incr					number;
    mm_log_file					utl_file.file_type := NULL;
    start_date					date;
    end_date					date;
    tmp_date 					date;
    show_time					boolean;
    BEGIN
       mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
       mm_util.set_log_info(mm_log_file);

       mm_util.log_message('****** START : Create connect links table',true);
       start_date := sysdate;

--     Create connect links table
       connect_links_table := output_table;
       if (trim(output_table) is null) then
          connect_links_table := subnetwork_name||'_CONNECT_LINK$';
       end if;
       if (table_exists(connect_links_table)) then
          execute immediate 'drop table ' || connect_links_table || ' purge';
       end if;
       query_str := 'CREATE TABLE ' || connect_links_table ||
                    ' (link_id number, start_node_id number, '||
                    ' end_node_id number, cost number, s number,'||
                    ' geometry sdo_geometry, node_id number, '||
                    ' base_link_id number) '|| ' NOLOGGING';
       execute immediate query_str;
       commit;
--     Close log file so that it can be opened in called procedures
--       utl_file.fclose(mm_log_file);
       tmp_date := sysdate;
       mm_util.log_message('**** START : Splitting links for Connect links',false);
       split_links(network_name, subnetwork_name, log_loc, log_file, open_mode);
       mm_util.log_message('Splitting links took '||to_char((sysdate-tmp_date)*24*60,'99999.999') || ' min.',false);
       mm_util.log_message('**** END : Splitting links for Connect links',false);

--     Reopen log file
--       mm_log_file := utl_file.fopen(log_loc,log_file,'a');

--     Create a temp table with link details
       temp_connect_link_table := 'TEMP_CONNECT_LINK$';
       tmp_date := sysdate;
       mm_util.log_message('**** START : Calling Java Method for Connect Links',false);
       create_connect_links_java(network_name, subnetwork_name, temp_connect_link_table);
       mm_util.log_message('Java method call took '||to_char((sysdate-tmp_date)*24*60,'99999.999') || ' min.',false);
       mm_util.log_message('**** END : Calling Java Method for Connect Links',false);

--     Find max link ID assigned so far and assign IDs to connect links
       mm_link_table := get_mm_link_table_name(network_name);
/*
       query_str := 'SELECT max(link_id) FROM ' || mm_link_table;
       execute immediate query_str into max_link_id;
*/
       max_link_id := 0;
       insert_str := 'INSERT /*+ APPEND */ INTO ' || connect_links_table ||
                     ' (link_id, start_node_id, end_node_id, cost, ' ||
                     ' s, geometry, node_id, base_link_id) '|| ' VALUES '||        
                     ' (:a,:b,:c,:d,:e,:f,:g,:h) '; 
       query_str := 'SELECT node_id, link_id, start_node_id, end_node_id,'||
                    ' geometry, cost, s, rowid ' || ' FROM ' || 
                    temp_connect_link_table;
       OPEN query_csr FOR query_str;
       incr := 1;
       LOOP
          fetch query_csr bulk collect into nid_array, lid_array, sid_array, eid_array, g_array, cost_array, s_array, rowid_array limit 1000;
          for i IN 1 .. rowid_array.count loop
             execute immediate insert_str using incr,
                                                sid_array(i), eid_array(i),
                                                cost_array(i), s_array(i),
                                                g_array(i), nid_array(i),
                                                lid_array(i);
             commit;
             incr := incr+1; 
          end loop;
          nid_array.delete;
          lid_array.delete;
          sid_array.delete;
          eid_array.delete;
          g_array.delete;
          cost_array.delete;
          s_array.delete;
          rowid_array.delete;
       EXIT WHEN query_csr%NOTFOUND;
       END LOOP;

       end_date := sysdate;
       mm_util.log_message('Create connect links took '||to_char((end_date-start_date)*24*60,'99999.999') || ' min.',false);
       mm_util.log_message('****** END : Create connect links',true);

--     Insert connect links table in metadata
       query_str := 'UPDATE multimodal_subnetwork_metadata ' ||
                    ' SET connect_link_table_name = :a '||
                    ' WHERE upper(network_name) = :b AND upper(subnetwork_name) = :c';
       execute immediate query_str using connect_links_table, upper(network_name),
                                         upper(subnetwork_name); 
       commit;

       if (table_exists(temp_connect_link_table)) then
           execute immediate 'drop table '|| temp_connect_link_table || ' purge';
       end if;

       utl_file.fclose(mm_log_file);
       -- add_links_to_mm_links(network_name,connect_links_table,mm_link_table,true,true,log_loc,log_file,'a');
       -- insert_in_link_type_table(network_name,connect_links_table,2,false,log_loc,log_file,'a');
    END create_subnet_connect_links;

    PROCEDURE create_clique(network_name IN VARCHAR2, 
                            link_id IN number,
			    node_array IN sdo_number_array,
			    output_table IN VARCHAR2,
			    log_loc IN VARCHAR2,
			    log_file IN VARCHAR2,
			    open_mode IN VARCHAR2) IS
    mm_log_file                                 utl_file.file_type := NULL;
    start_date					date;
    max_id					number;
    incr 					number;
    indx					number;
    num						number;
    query_str					varchar2(512);
    insert_str					varchar2(512);

    BEGIN
       --mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
      -- mm_util.set_log_info(mm_log_file);
       start_date := sysdate;
       query_str := 'SELECT max(id) FROM ' || output_table;
       execute immediate query_str into max_id;
       if (max_id is null) then
          max_id := 0;
       end if;
       incr := 1;
       insert_str := 'INSERT INTO ' || output_table ||
		     ' (id,link_id,start_node_id,end_node_id) ' ||
		     ' VALUES (:a,:b,:c,:d) ';
       for i IN 1 .. node_array.count loop
          for j IN 1 .. node_array.count-1 loop
              indx := mod(i+j,node_array.count);
              if (indx = 0) then
                 indx := node_array.count;
              end if;
	      execute immediate insert_str using max_id+incr,link_id,node_array(i),node_array(indx);
              incr := incr+1;
          end loop;
       end loop;
       --utl_file.fclose(mm_log_file);
    END create_clique;

    PROCEDURE create_transfers_on_links(network_name IN VARCHAR2,
                                        final_table IN VARCHAR2,
                                        log_loc in VARCHAR2, 
					log_file IN VARCHAR2, 
                                        open_mode IN VARCHAR2) IS
    mm_log_file                                 utl_file.file_type := NULL;
    tmp_date 					date;
    start_date					date;
    query_csr					cursor_type;
    query_str					varchar2(1024);
    stmt					varchar2(512);
    service_node_table				varchar2(32);
    link_table 					varchar2(32);
    mm_link_table 				varchar2(32);
    tmp_table1					varchar2(32);
    tmp_table2					varchar2(32);
    tmp_table3					varchar2(32);
    node_array					sdo_number_array;
    link_array					sdo_number_array;
    link_id					number;
    max_link_id					number;
    lid 					number;
    BEGIN
       --mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
       --mm_util.set_log_info(mm_log_file);
       start_date := sysdate;
       link_table := get_base_link_table_name(network_name);
       mm_link_table := get_mm_link_table_name(network_name);
       service_node_table := get_service_node_table_name(network_name);
       tmp_table2 := network_name||'_TRANSFER_TEMP$';
       tmp_table1 := network_name||'_LINKS_TMP_1';
       tmp_table3 := network_name||'_LINKS_TMP_3';
       --final_table := network_name||'_TRANSFER_ON_LINK$';
       mm_util.log_message('*** START : Creating tranfers on Links ',true);

       if (table_exists(tmp_table1)) then
	   execute immediate 'drop table ' || tmp_table1 || ' purge';
       end if;
       query_str := 'CREATE TABLE ' || tmp_table1 || 
		    ' (link_id number,node_count number) ';
       execute immediate query_str;      

       query_str := 'INSERT INTO ' || tmp_table1 ||
		    ' (link_id,node_count) ' ||
		    ' SELECT link_id link_id,count(*) node_count ' ||
		    ' FROM ' || service_node_table ||
		    ' GROUP BY link_id ' ||
		    ' ORDER BY link_id';
       execute immediate query_str;
       commit; 

       if (table_exists(tmp_table2)) then
	   execute immediate 'drop table ' || tmp_table2 || ' purge';
       end if;
       query_str := 'CREATE TABLE ' || tmp_table2 ||
                    ' (id number, link_id number,start_node_id number,end_node_id number) ' ||
		    ' NOLOGGING ';
       execute immediate query_str;

--     Closing log file; it will be opened in create_clique
       --utl_file.fclose(mm_log_file);

--     Forming links between service nodes on every link             
       query_str := 'SELECT link_id FROM ' || tmp_table1;
       OPEN query_csr FOR query_str;
       LOOP
          fetch query_csr bulk collect into link_array limit 1000;
          for i IN 1 .. link_array.count loop
             link_id := link_array(i);
             stmt := 'SELECT node_id FROM ' || service_node_table || 
		     ' WHERE link_id=:a';
             execute immediate stmt bulk collect into node_array using link_id; 
             create_clique(network_name,link_id,node_array,tmp_table2,log_loc,log_file,'a');
          end loop;
       EXIT WHEN query_csr%NOTFOUND;
       END LOOP;

--     Reopening log file
       --mm_log_file := utl_file.fopen(log_loc,log_file,'a');
       --mm_util.set_log_info(mm_log_file);

       query_str := 'SELECT max(link_id) FROM ' || mm_link_table;
       execute immediate query_str into max_link_id;

       if (table_exists(tmp_table3)) then
	  execute immediate 'drop table ' || tmp_table3 || ' purge';
       end if;
       query_str := 'CREATE TABLE ' || tmp_table3 ||
		    ' (link_id number, start_node_id number, '||
                    ' end_node_id number, percent_diff number, '||
                    ' geometry sdo_geometry, parent_link_id number)'||
		    ' NOLOGGING';
       execute immediate query_str;
  
       query_str := 'INSERT /*+ APPEND */ INTO ' || tmp_table3 ||
                    ' (link_id,start_node_id,end_node_id,percent_diff,'||
		    ' geometry,parent_link_id) ' ||
		    ' SELECT t1.id link_id,t1.start_node_id start_node_id,'||
		    ' t1.end_node_id end_node_id,'||
		    ' abs(t2.percent-t3.percent) percent_diff,'||
		    ' sdo_geometry(2002,8307,null,SDO_ELEM_INFO_ARRAY(1,2,1),'||
		    ' SDO_ORDINATE_ARRAY(t2.x,t2.y,t3.x,t3.y)) geometry,'||
		    ' t1.link_id parent_link_id '||
		    ' FROM ' || tmp_table2 || ' t1, ' ||
		    service_node_table || ' t2, ' || service_node_table || ' t3 ' ||
		    ' WHERE t1.start_node_id=t2.node_id and t1.end_node_id = t3.node_id';
--    execute immediate query_str using max_link_id;
      execute immediate query_str;
      commit;
 
--    Creating the final link table
      if (table_exists(final_table)) then
	  execute immediate 'drop table ' || final_table || ' purge';
      end if;
      query_str := 'CREATE TABLE ' || final_table ||
		    ' (link_id number, start_node_id number, end_node_id number,'||
		    ' cost number, geometry sdo_geometry, parent_link_id number) '||
		    ' NOLOGGING';
      execute immediate query_str;
      
      query_str := 'INSERT /*+ APPEND */ INTO '|| final_table ||
		    ' (link_id, start_node_id, end_node_id,'||
		    ' cost, geometry, parent_link_id) '||
                   ' SELECT t1.link_id link_id,t1.start_node_id start_node_id,'||
		   ' t1.end_node_id end_node_id,t1.percent_diff*t2.length cost,'||
		   ' t1.geometry geometry,t1.parent_link_id parent_link_id ' ||
		   ' FROM ' || tmp_table3 || ' t1, ' || link_table || ' t2 ' ||
		   ' WHERE t1.parent_link_id=t2.link_id';
      execute immediate query_str;
      commit;

      if (table_exists(tmp_table1)) then
	  execute immediate 'drop table ' || tmp_table1 || ' purge';
      end if;
      if (table_exists(tmp_table2)) then
	  execute immediate 'drop table ' || tmp_table2 || ' purge';
      end if;
      if (table_exists(tmp_table3)) then
	  execute immediate 'drop table ' || tmp_table3 || ' purge';
      end if;

      mm_util.log_message('Creating transfers on links took '||to_char((sysdate-start_date)*24*60,'99999.999') || ' min.',false);
      mm_util.log_message('*** END : Creating tranfers on Links ',true);
      --utl_file.fclose(mm_log_file);
      --add_links_to_mm_links(network_name,final_table,mm_link_table,true,true,log_loc,log_file,'a');
    END create_transfers_on_links;

--
--  Create transfer links using a Java method through wrapper procedure
--  Java method uses withinCost analysis
--
    PROCEDURE create_transfer_links_java(network_name IN VARCHAR2,
                                         output_table IN VARCHAR2,
                                         transfer_radius in number,
                                         walking_speed in number)
      AS LANGUAGE JAVA
      NAME 'oracle.spatial.network.apps.multimodal.NDMMultimodalWrapper.createTransferLinks(java.lang.String,java.lang.String, int, double)';

    PROCEDURE create_transfer_links(network_name IN VARCHAR2,
                                    output_table IN varchar2,
                                    transfer_radius IN integer,
                                    walking_speed IN number,
                                    config_file_loc IN VARCHAR2,
                                    config_file IN VARCHAR2,
				    log_loc IN VARCHAR2,
				    log_file IN VARCHAR2,
			            open_mode IN VARCHAR2) IS
    mm_log_file						utl_file.file_type := NULL;
    query_str						varchar2(512);
    mm_link_table 					varchar2(32);
    service_node_table					varchar2(32);
    stop_node_map_table					varchar2(32);
    transfers_on_links_table				varchar2(32);
    transfer_link_table					varchar2(32);
    temp_transfer_link_table                     	varchar2(32);
    max_link_id						number;
    max_tlink_id                                        number;
    tmp_date						date;

    BEGIN
       mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
       mm_util.set_log_info(mm_log_file);
       service_node_table := get_service_node_table_name(network_name);
       mm_link_table := get_mm_link_table_name(network_name);
       stop_node_map_table := get_stop_node_map_table_name(network_name);
       transfers_on_links_table := network_name||'_TRANSFER_ON_LINK$';
       transfer_link_table := output_table;

       if (trim(output_table) is null) then  
          transfer_link_table := network_name||'_TRANSFER_LINK$';
       end if;

       temp_transfer_link_table := network_name || '_TEMP_TR_LINK$';
       mm_util.log_message('****** START: Generation of Transfer Links **',true);
       if (not(table_exists(service_node_table))) then
          mm_util.log_message('Service nodes table '||service_node_table ||' Does Not Exist!!',false);
          mm_util.log_message('Make sure that this table exists before calling this procedure..',false);
  	  return;
       end if;

--     Create user data required for the generation of transfer links
       mm_util.log_message('-- Start : Create user data for transfer link generation', false);
       mm_util.generate_tlink_user_data(network_name, log_loc, log_file, 'a');
       mm_util.log_message('-- End : Create user data for transfer link generation', false);

--     Create transfers on same link
       mm_util.log_message('-- Start : Create transfer links that connect nodes on the same link', false);
       create_transfers_on_links(network_name, transfers_on_links_table, log_loc,
                                 log_file, 'a');
       mm_util.log_message('-- End : Create transfer links that connect nodes on the same link', false);

--     Load config file
       mm_util.log_message('-- Start : Load Config file : '||config_file_loc||' :: '||config_file, false);
       load_config(config_file_loc, config_file);
       mm_util.log_message('-- End : Load Config file ', false);

       mm_util.log_message('-- Start : Creation of Transfer links using withinCost Analysis ',true);
       tmp_date := sysdate;
       create_transfer_links_java(network_name, temp_transfer_link_table,
                                  transfer_radius, walking_speed);
       commit;
       mm_util.log_message('Creation Using Within Cost Analysis  took '||to_char((sysdate-tmp_date)*24*60,'99999.999') || ' min.',false);
       mm_util.log_message('-- End : Creation of Transfer links using withinCost Analysis ',true);
       mm_util.log_message('**** START : Create Final Transfer Table ',true);
--     Delete transfer links that connect nodes on the same link from transfer links table
       query_str := 'DELETE FROM ' || temp_transfer_link_table || ' t ' || 
	            ' WHERE t.link_id IN ' ||
		    ' (SELECT t1.link_id FROM ' || temp_transfer_link_table || ' t1, ' ||
		       service_node_table || ' t2, ' || service_node_table || ' t3 ' ||
		    ' WHERE t1.start_node_id=t2.node_id and '||
                    ' t1.end_node_id=t3.node_id and '||
		    ' t2.link_id = t3.link_id)';
       dbms_output.put_line('Query : '||query_str);
       execute immediate query_str;
       commit;

--     There could be transfer links that connect stops on the same route and same direction
--     deleting those links
       query_str := 'DELETE FROM ' || temp_transfer_link_table || 
                    ' WHERE link_id IN '||
		    ' (SELECT t.link_id FROM ' || temp_transfer_link_table || ' t, ' ||
		    stop_node_map_table || ' m1, ' || stop_node_map_table || ' m2 ' ||
		    ' WHERE t.start_node_id = m1.node_id AND ' ||
		    ' t.end_node_id = m2.node_id AND m1.route_id = m2.route_id AND ' ||
		    ' m1.direction_id = m2.direction_id) ';
       dbms_output.put_line('Query : '||query_str);
       execute immediate query_str;
       commit; 

--     Create final transfer links table
       if (table_exists(transfer_link_table)) then
           execute immediate 'drop table ' || transfer_link_table || ' purge';
       end if;
       query_str := 'CREATE TABLE ' || transfer_link_table || 
                    ' (link_id number, start_node_id number,'||
                    ' end_node_id number, cost number,'||
                    ' geometry sdo_geometry, s number) ' ||
                    ' NOLOGGING ';
       execute immediate query_str;
       commit;

       query_str := 'INSERT /*+ APPEND */ INTO ' || transfer_link_table ||
                    ' (link_id,start_node_id,end_node_id,cost,geometry,s) '||
                    ' SELECT link_id,start_node_id,end_node_id,cost,'||
                    ' geometry,s ' || ' FROM ' || temp_transfer_link_table;
--                  ||  ' WHERE cost > :c ';
       execute immediate query_str;
       commit;

       query_str := 'SELECT max(link_id) FROM ' || transfer_link_table;
       execute immediate query_str into max_tlink_id;

       query_str := 'INSERT /*+ APPEND */ INTO ' || transfer_link_table ||
                    ' (link_id,start_node_id,end_node_id,cost,geometry,s) '||
                    ' SELECT link_id+:m,start_node_id,end_node_id,cost,'||
                    ' geometry,:w ' || ' FROM ' || transfers_on_links_table;
       execute immediate query_str using max_tlink_id, walking_speed;
       commit;

       query_str := 'DELETE FROM ' || transfer_link_table || 
                    ' WHERE link_id IN '||
		    ' (SELECT t.link_id FROM ' || transfer_link_table || ' t, ' ||
		    stop_node_map_table || ' m1, ' || stop_node_map_table || ' m2 ' ||
		    ' WHERE t.start_node_id = m1.node_id AND ' ||
		    ' t.end_node_id = m2.node_id AND m1.route_id = m2.route_id AND ' ||
		    ' m1.direction_id = m2.direction_id) ';
       execute immediate query_str;
 
       mm_util.log_message('**** END : Create Final Transfer Table ',true);

       query_str := 'UPDATE ndm_multimodal_metadata ' ||
                    ' SET transfer_link_table_name = :a '||
                    ' WHERE upper(network_name) = :b ';
       execute immediate query_str using transfer_link_table, upper(network_name);

       add_links_to_mm_links(network_name,transfer_link_table,mm_link_table,true,true,log_loc,log_file,'a');
       insert_in_link_type_table(network_name,transfer_link_table,3,false,log_loc,log_file,'a');
       
--     Drop temporary tables
       if (table_exists(temp_transfer_link_table)) then
          execute immediate 'drop table ' || temp_transfer_link_table || ' purge';
       end if;

       utl_file.fclose(mm_log_file);
    END create_transfer_links;

--
--  The following procedure processes the transfer links generated by the
--  java method outside PL SQL Wrapper. Used in cases where java call is 
--  faster than calling the method form inside the wrapper. 
--  This procedure is the same as create_transfer_links except 
--  the call to create_transfer_links_java (wrapper procedure)
--
    PROCEDURE process_transfer_links(network_name IN VARCHAR2,
                                     input_tlink_table IN VARCHAR2,
                                     output_table IN varchar2,
                                     transfer_radius IN integer,
                                     walking_speed IN number,
                                     log_loc IN VARCHAR2,
                                     log_file IN VARCHAR2,
                                     open_mode IN VARCHAR2) IS
    mm_log_file                                         utl_file.file_type := NULL;
    query_str                                           varchar2(512);
    mm_link_table                                       varchar2(32);
    service_node_table                                  varchar2(32);
    stop_node_map_table                                 varchar2(32);
    transfers_on_links_table                            varchar2(32);
    transfer_link_table                                 varchar2(32);
    temp_transfer_link_table                            varchar2(32);
    max_link_id                                         number;
    max_tlink_id                                        number;
    tmp_date                                            date;

    BEGIN
       mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
       mm_util.set_log_info(mm_log_file);
       service_node_table := get_service_node_table_name(network_name);
       mm_link_table := get_mm_link_table_name(network_name);
       stop_node_map_table := get_stop_node_map_table_name(network_name);
       transfers_on_links_table := network_name||'_TRANSFER_ON_LINK$';
       transfer_link_table := output_table;

       if (trim(output_table) is null) then
          transfer_link_table := network_name||'_TRANSFER_LINK$';
       end if;

       temp_transfer_link_table := input_tlink_table;
       mm_util.log_message('****** START: Generation of Transfer Links **',true);
       if (not(table_exists(service_node_table))) then
          mm_util.log_message('Service nodes table '||service_node_table ||' Does Not Exist!!',false);
          mm_util.log_message('Make sure that this table exists before calling this procedure..',false);
          return;
       end if;

--     create_transfers_on_links(network_name, transfers_on_links_table, log_loc,log_file, 'a'); 
--
       mm_util.log_message('**** START : Create Final Transfer Table ',true);
--     Delete transfer links that connect nodes on the same link from transfer links table
       query_str := 'DELETE FROM ' || temp_transfer_link_table || ' t ' ||
                    ' WHERE t.link_id IN ' ||
                    ' (SELECT t1.link_id FROM ' || temp_transfer_link_table || ' t1, ' ||
                       service_node_table || ' t2, ' || service_node_table || ' t3 ' ||
                    ' WHERE t1.start_node_id=t2.node_id and '||
                    ' t1.end_node_id=t3.node_id and '||
                    ' t2.link_id = t3.link_id)';
       dbms_output.put_line('Query : '||query_str);
       execute immediate query_str;
       commit;

--     There could be transfer links that connect stops on the same route and same direction
--     deleting those links
       query_str := 'DELETE FROM ' || temp_transfer_link_table ||
                    ' WHERE link_id IN '||
                    ' (SELECT t.link_id FROM ' || temp_transfer_link_table || ' t, ' ||
                    stop_node_map_table || ' m1, ' || stop_node_map_table || ' m2 ' ||
                    ' WHERE t.start_node_id = m1.node_id AND ' ||
                    ' t.end_node_id = m2.node_id AND m1.route_id = m2.route_id AND ' ||
                    ' m1.direction_id = m2.direction_id) ';
       dbms_output.put_line('Query : '||query_str);
       execute immediate query_str;
       commit;

--     Create final transfer links table
       if (table_exists(transfer_link_table)) then
           execute immediate 'drop table ' || transfer_link_table || ' purge';
       end if;
       query_str := 'CREATE TABLE ' || transfer_link_table ||
                    ' (link_id number, start_node_id number,'||
                    ' end_node_id number, cost number,'||
                    ' geometry sdo_geometry, s number) ' ||
                    ' NOLOGGING ';
       execute immediate query_str;
       commit;

       query_str := 'INSERT /*+ APPEND */ INTO ' || transfer_link_table ||
                    ' (link_id,start_node_id,end_node_id,cost,geometry,s) '||
                    ' SELECT link_id,start_node_id,end_node_id,cost,'||
                    ' geometry,s ' || ' FROM ' || temp_transfer_link_table;
--                  ||  ' WHERE cost > :c ';
       execute immediate query_str;
       commit;

       query_str := 'SELECT max(link_id) FROM ' || transfer_link_table;
       execute immediate query_str into max_tlink_id;

       query_str := 'INSERT /*+ APPEND */ INTO ' || transfer_link_table ||
                    ' (link_id,start_node_id,end_node_id,cost,geometry,s) '||
                    ' SELECT link_id+:m,start_node_id,end_node_id,cost,'||
                    ' geometry,:w ' || ' FROM ' || transfers_on_links_table;
       execute immediate query_str using max_tlink_id, walking_speed;
       commit;

       query_str := 'DELETE FROM ' || transfer_link_table ||
                    ' WHERE link_id IN '||
                    ' (SELECT t.link_id FROM ' || transfer_link_table || ' t, ' ||
                    stop_node_map_table || ' m1, ' || stop_node_map_table || ' m2 ' ||
                    ' WHERE t.start_node_id = m1.node_id AND ' ||
                    ' t.end_node_id = m2.node_id AND m1.route_id = m2.route_id AND ' ||
                    ' m1.direction_id = m2.direction_id) ';
       execute immediate query_str;

       mm_util.log_message('**** END : Create Final Transfer Table ',true);

       query_str := 'UPDATE ndm_multimodal_metadata ' ||
                    ' SET transfer_link_table_name = :a '||
                    ' WHERE upper(network_name) = :b ';
       execute immediate query_str using transfer_link_table, upper(network_name);

       add_links_to_mm_links(network_name,transfer_link_table,mm_link_table,true,true,log_loc,log_file,'a');
       insert_in_link_type_table(network_name,transfer_link_table,3,false,log_loc,log_file,'a');
       utl_file.fclose(mm_log_file);
    END process_transfer_links;

--
--  Create link type table
--
    PROCEDURE create_link_type_table(network_name IN VARCHAR2,
                                     output_table IN VARCHAR2,
                                     log_loc IN VARCHAR2,
                                     log_file IN VARCHAR2,
                                     open_mode IN VARCHAR2) IS
    link_type_table                             varchar2(32);
    road_link_table                             varchar2(32);
    service_link_table				varchar2(32);
    connect_link_table				varchar2(32);
    query_str					varchar2(512);
    mm_log_file                                 utl_file.file_type := NULL;
    BEGIN
       mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
       mm_util.set_log_info(mm_log_file);
       mm_util.log_message('**** START : Create Link Type Table',true);
       link_type_table := output_table;
       if (trim(link_type_table) is null) then
           link_type_table := network_name||'_LINK_TYPE$';
       end if;
       road_link_table := get_base_link_table_name(network_name);
       service_link_table := get_service_link_table_name(network_name);
       connect_link_table := get_connect_link_table_name(network_name);
       if (table_exists(link_type_table)) then
          execute immediate 'drop table ' || link_type_table || ' purge';
       end if;
       query_str := 'CREATE TABLE ' || link_type_table ||
                    ' (link_id number, link_type number, link_category varchar2(32)) ' ||
                    ' NOLOGGING ';
       execute immediate query_str;

       query_str := 'INSERT /*+ APPEND */ INTO ' || link_type_table ||
                    ' (link_id, link_type, link_category) ' ||
                    ' SELECT link_id,0,''road_link'' ' ||
                    ' FROM ' || road_link_table;
       execute immediate query_str;
       commit;

       query_str := 'INSERT /*+ APPEND */ INTO ' || link_type_table ||
                    ' (link_id, link_type, link_category) ' ||
                    ' SELECT link_id, 1, ''service_link'' ' ||
                    ' FROM ' || service_link_table;
       execute immediate query_str;
       commit;

       query_str := 'INSERT /*+ APPEND */ INTO ' || link_type_table ||
                    ' (link_id, link_type, link_category) ' ||   
                    ' SELECT link_id, 2, ''connect_link'' ' ||
                    ' FROM ' || connect_link_table;
       execute immediate query_str;
       commit;

       query_str := 'UPDATE ndm_multimodal_metadata '||
                    ' SET link_type_table_name = :a ' ||
                    ' WHERE upper(network_name) = :b';
       execute immediate query_str using link_type_table,upper(network_name); 
       mm_util.log_message('**** END : Create Link Type Table',true);
    END create_link_type_table;

--  Road links    - category 0
--  Service links - category 1
--  Connect links - category 2
--  Transfer links - category 3
    PROCEDURE insert_in_link_type_table(network_name IN VARCHAR2,
                                        link_table IN VARCHAR2,
                                        link_type  IN NUMBER,
                                        rewrite IN BOOLEAN,
				        log_loc IN VARCHAR2,
				        log_file IN VARCHAR2,
				        open_mode IN VARCHAR2) IS
    link_type_table				varchar2(32);
    road_link_table				varchar2(32);
    transfer_link_table				varchar2(32);
    connect_link_table				varchar2(32);
    service_link_table				varchar2(32);
    query_str					varchar2(512);
    link_category				varchar2(32);
    start_date					date;
    mm_log_file                                 utl_file.file_type := NULL;
    BEGIN
       --mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
       --mm_util.set_log_info(mm_log_file);
       start_date := sysdate;
       --mm_util.log_message('**** START : Insert in Link Type Table',true);
       link_type_table := get_link_type_table_name(network_name);
       road_link_table := get_base_link_table_name(network_name);
       transfer_link_table := get_transfer_link_table_name(network_name);
       connect_link_table := get_connect_link_table_name(network_name);
       service_link_table := get_service_link_table_name(network_name);

       if (rewrite) then
          if (table_exists(link_type_table)) then
             execute immediate 'drop table ' || link_type_table || ' purge';
          end if;
          create_link_type_table(network_name, link_type_table, log_loc, log_file, 'a');
       else
           if (not(table_exists(link_type_table))) then
               mm_util.log_message('Link Type Table '||link_type_table||
                                  ' does not exist!!', false);
               mm_util.log_message('Create the table OR run the procedure '||
                                  'with rewrite option set to TRUE',false);
               return;
           else
               query_str := 'delete from ' || link_type_table || ' where link_type=:t';
               execute immediate query_str using link_type;
               commit;
           end if;
       end if;

       case (link_type)
         when 1 then link_category := 'service_link';
         when 2 then link_category := 'connect_link';
         when 3 then link_category := 'transfer_link';
         else mm_util.log_message('Invalid type; Use 1, 2, 3 for'||
                                  ' service links, connect links, transfer links'||
                                  ' respectively.', false);
              return;
       end case;

       query_str := 'INSERT /*+ APPEND */ INTO '|| link_type_table ||
                    ' (link_id, link_type, link_category) ' ||
                    ' SELECT link_id, :t, :c ' || ' FROM ' ||
                    link_table;
       execute immediate query_str using link_type, link_category;
       commit;

       --mm_util.log_message('Inserting Links in Link Type Table took '||to_char((sysdate-start_date)*24*60,'99999.999') || ' min.',false);
       --mm_util.log_message('**** END : Insert Link Type Table',true);
       --utl_file.fclose(mm_log_file);
    END insert_in_link_type_table;

    PROCEDURE create_node_pairs_for_sp(network_name IN VARCHAR2,
				      log_loc IN VARCHAR2,
				      log_file IN VARCHAR2,
				      open_mode IN VARCHAR2) IS
    mm_log_file                                 utl_file.file_type := NULL;
    query_str					varchar2(512);
    table_name 					varchar2(32);
    service_link_table				varchar2(32);
    service_node_table				varchar2(32);
    base_link_table				varchar2(32);
    BEGIN
       mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
       mm_util.set_log_info(mm_log_file);

       service_link_table := get_service_link_table_name(network_name);
       service_node_table := get_service_node_table_name(network_name);
       base_link_table := get_base_link_table_name(network_name);    

       table_name := network_name||'_SP_NODE_PAIRS';
       if (table_exists(table_name)) then
           execute immediate 'drop table ' || table_name || ' purge';
       end if;
       query_str := 'CREATE TABLE ' || table_name ||
		    ' (link_id number,sp_start_node_id number, sp_end_node_id number) ' ||
		    ' NOLOGGING ';
       execute immediate query_str;
       commit;

       query_str := 'INSERT /*+ APPEND */ INTO ' || table_name ||
		    ' SELECT l.link_id link_id,rl1.start_node_id sp_start_node_id, '||
		    ' rl2.end_node_id sp_end_node_id '|| ' FROM ' ||
		    service_link_table || ' l, ' ||
		    service_node_table || ' n1, '||
		    service_node_table || ' n2, ' ||
		    base_link_table || ' rl1, '||
		    base_link_table || ' rl2 '|| ' WHERE ' ||
		    ' l.start_node_id = n1.node_id and l.end_node_id = n2.node_id and '||
		    ' n1.link_id = rl1.link_id and n2.link_id = rl2.link_id ';
       execute immediate query_str;
       commit;

    END create_node_pairs_for_sp;

    PROCEDURE project_service_node_to_link(network_name IN VARCHAR2,
			                   log_loc IN VARCHAR2,
			  	           log_file IN VARCHAR2,
				           open_mode IN VARCHAR2) IS
    mm_log_file                                 utl_file.file_type := NULL;
    query_str					varchar2(512);
    service_node_table				varchar2(32);
    temp_table					varchar2(32);
    BEGIN
       mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
       mm_util.set_log_info(mm_log_file);
       service_node_table := get_service_node_table_name(network_name);
       temp_table := 'SERVICE_NODE_PROJ_GEOM';
       if (not(table_exists(service_node_table))) then
          mm_util.log_message('Cannot find service node table ' || service_node_table,false);
          return;
       end if;
       if (table_exists(temp_table)) then
	   execute immediate 'drop table ' || temp_table || ' purge';
       end if;
       query_str := 'CREATE TABLE ' || temp_table || 
		    ' (node_id number,geometry sdo_geometry,'||
		    ' link_id number, percent number) ' || ' NOLOGGING';
       execute immediate query_str;

       query_str := 'INSERT /*+ APPEND */ INTO ' || temp_table ||
		    ' (node_id,geometry,link_id,percent) ' ||
		    ' SELECT node_id,sdo_net.get_pt(:n,link_id,percent),'||
		    ' link_id,percent FROM ' ||
		    service_node_table;
       execute immediate query_str using network_name;
       commit;

       if (table_exists(service_node_table)) then
          execute immediate 'truncate table ' || service_node_table;
       end if;
       query_str := 'INSERT /*+ APPEND */ INTO ' || service_node_table ||
                    ' (node_id,geometry,link_id,percent,x,y) ' ||
		    ' SELECT n.node_id,n.geometry,n.link_id,n.percent,'||
		    ' n.geometry.sdo_point.x,n.geometry.sdo_point.y '||
		    ' FROM ' || temp_table || ' n ';
       execute immediate query_str;
       commit;

       if (table_exists(temp_table)) then
           execute immediate 'drop table ' || temp_table || ' purge';
       end if;
       
       utl_file.fclose(mm_log_file);
   END  project_service_node_to_link;

   PROCEDURE correct_node_geom_from_shapes(network_name IN VARCHAR2,
                                           subnetwork_name IN VARCHAR2,
                                           lrs_project_table IN VARCHAR2,
                                           log_loc IN VARCHAR2,
                                           log_file IN VARCHAR2,
                                           open_mode IN VARCHAR2) IS
   mm_log_file                                 utl_file.file_type := NULL;
   query_str					varchar2(512);
   service_node_table                          	varchar2(32);
   -- lrs_project_table				varchar2(32);
   temp_table					varchar2(32);
   temp_project_table				varchar2(32);
   final_service_node_table			varchar2(32);
   
   BEGIN
       mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
       mm_util.set_log_info(mm_log_file);
       service_node_table := get_sub_service_node_table(network_name, subnetwork_name);
       -- lrs_project_table := network_name||'_LRS_PROJECT$';
       temp_table := 'TEMP_SERVICE_NODE_TABLE';
       final_service_node_table := 'FINAL_SERVICE_NODE_TABLE';
       temp_project_table := 'TEMP_NODE_PROJECT_TABLE';

       if (table_exists(temp_table)) then
          execute immediate 'drop table '||temp_table || ' purge';
       end if;
       if (table_exists(temp_project_table)) then
          execute immediate 'drop table '||temp_project_table || ' purge';
       end if;
       if (table_exists(final_service_node_table)) then
          execute immediate 'drop table '||final_service_node_table || ' purge';
       end if;

       query_str := 'CREATE TABLE ' || temp_table ||
                    ' (node_id number, geometry sdo_geometry, '||
                    ' link_id number, percent number) '||
                    ' NOLOGGING ' ;
       execute immediate query_str;

       query_str := 'CREATE TABLE ' || temp_project_table || ' AS '||
                    ' SELECT * FROM ' || lrs_project_table;
       execute immediate query_str;

      query_str := 'DELETE FROM '||temp_project_table||' t1 '||
                   ' WHERE rowid > ' ||
                   ' (SELECT min(rowid) FROM ' || temp_project_table||' t2 '||
                   ' WHERE t1.node_id = t2.node_id) ';
      execute immediate query_str;
      commit;
 
      query_str := 'INSERT /*+ APPEND */ INTO ' || temp_table ||
                    ' (node_id,link_id,percent,geometry) '||
                    ' SELECT t1.node_id,t1.link_id,'||
                    ' t1.percent,'||
                    ' sdo_lrs.convert_to_std_geom(t2.geometry) ' || 
                    ' FROM '||
                    service_node_table || ' t1, '||
                    temp_project_table || ' t2 ' ||
                    ' WHERE ' ||
                    ' t1.node_id = t2.node_id';
      execute immediate query_str;
      commit;

      query_str := 'CREATE TABLE ' || final_service_node_table ||
                    ' (node_id number, x number, y number, '||
                    ' link_id number, percent number, '||
                    ' geometry sdo_geometry) '|| ' NOLOGGING';
      execute immediate query_str;
      commit;

      query_str := 'INSERT /*+ APPEND */ INTO ' || final_service_node_table ||
                   ' (node_id,x,y,link_id,percent,geometry) '||
                   ' SELECT n.node_id node_id, n.geometry.sdo_point.x x, '||
                   ' n.geometry.sdo_point.y y, n.link_id link_id,'||
                   ' n.percent percent, n.geometry geometry '||
                   ' FROM ' || temp_table || ' n ';
      execute immediate query_str;
      commit;

      if (table_exists(service_node_table)) then
         execute immediate 'drop table '|| service_node_table||' purge';
      end if;
      commit;

      execute immediate 'alter table ' || final_service_node_table ||
                        ' rename to '||service_node_table;
      commit;

-- Dropping temp tables
      if (table_exists(temp_table)) then
         execute immediate 'drop table ' || temp_table || ' purge';
      end if;
      if (table_exists(temp_project_table)) then
         execute immediate 'drop table ' || temp_project_table || ' purge';
      end if;
   END correct_node_geom_from_shapes;

   PROCEDURE create_lrs_measures_for_stops(network_name IN VARCHAR2,
                                           subnetwork_name IN VARCHAR2,
                                     	   log_loc IN VARCHAR2,
                                           log_file IN VARCHAR2,
                                           open_mode IN VARCHAR2) IS
   mm_log_file                                 	utl_file.file_type := NULL;
   start_date					date;
   end_date					date;
   tmp_date					date;
   temp_table					varchar2(32);
   temp_node_table				varchar2(32);
   temp_shape_table				varchar2(32);
   trip_shape_table				varchar2(32);
   trip_table 					varchar2(32);
   route_table					varchar2(32);
   service_node_table				varchar2(32);
   stop_time_table				varchar2(32);
   lrs_measure_table				varchar2(32);
   lrs_project_table                            varchar2(32);
   node_map_table				varchar2(32);
   query_str					varchar2(512);
   BEGIN
       mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
       mm_util.set_log_info(mm_log_file);

       trip_shape_table := subnetwork_name || '_TRIP_SHAPE$';
       trip_table := get_trip_table_name(network_name, subnetwork_name);
       route_table := get_sub_route_table_name(network_name, subnetwork_name);
       stop_time_table := get_stop_times_table_name(network_name, subnetwork_name);
       service_node_table := get_sub_service_node_table(network_name, subnetwork_name);
       node_map_table := get_sub_node_map_table(network_name, subnetwork_name);
       lrs_measure_table := subnetwork_name || '_LRS_MEASURE$';
       lrs_project_table := subnetwork_name || '_LRS_PROJECT$';
       temp_table := 'TEMP_LRS_TABLE';
       temp_node_table := 'TEMP_NODE_LRS_TABLE';
       temp_shape_table := 'TEMP_SHAPE_TABLE';

       mm_util.log_message('*****Start : Creating LRS measure table '||subnetwork_name,true);
       start_date := sysdate;
       if (table_exists(trip_shape_table)) then
          execute immediate 'drop table '||trip_shape_table || ' purge';
       end if;

       if (table_exists(lrs_measure_table)) then
          execute immediate 'drop table ' || lrs_measure_table || ' purge';
       end if;
       if (table_exists(lrs_project_table)) then
          execute immediate 'drop table ' || lrs_project_table || ' purge';
       end if;
       if (table_exists(temp_table)) then
          execute immediate 'drop table ' || temp_table || ' purge';
       end if;
       if (table_exists(temp_node_table)) then
          execute immediate 'drop table ' || temp_node_table || ' purge';
       end if;
       if (table_exists(temp_shape_table)) then
          execute immediate 'drop table ' || temp_shape_table || ' purge';
       end if;

--     Create trip shape table
--     Close log file; to be opened in the called procedure
--       utl_file.fclose(mm_log_file);
       compute_geometry_for_trips('NAVTEQ_DC_MM',subnetwork_name,trip_shape_table,log_loc,log_file,'a');

--     Reopen log file
--     mm_log_file := utl_file.fopen(log_loc,log_file,'a');
       
       query_str := 'CREATE TABLE ' || temp_shape_table || ' AS ' ||
                    ' SELECT shape_id shape_id, min(trip_id) trip_id ' ||
                    ' FROM ' || trip_shape_table || ' GROUP BY shape_id ' ||
		    ' ORDER BY shape_id';
       execute immediate query_str;

       query_str := 'CREATE TABLE ' || temp_table ||
                    ' (trip_id number, route_id number, direction_id number, '||
                    ' agency_id number, stop_id number, stop_sequence number, '||
                    ' shape_id number)';
       execute immediate query_str;

       query_str := 'INSERT /*+ APPEND */ INTO ' || temp_table ||
                    ' (trip_id, route_id, direction_id, '||
                    ' agency_id, stop_id, stop_sequence, '||
                    ' shape_id) ' || 
                    ' SELECT t1.trip_id, t2.route_id, t2.direction_id, '||
                    ' t3.agency_id, t4.stop_id, t4.stop_sequence, t1.shape_id '||
                    ' FROM ' || temp_shape_table ||' t1, '||
                    trip_table || ' t2, '|| route_table || ' t3, ' ||
                    stop_time_table || ' t4 ' || 
                    ' WHERE ' || ' t1.trip_id = t2.trip_id AND ' ||
                    ' t2.route_id = t3.route_id AND ' || ' t2.trip_id = t4.trip_id';
       execute immediate query_str;
       commit; 
  
       query_str := 'CREATE TABLE ' || temp_node_table || ' AS ' ||
                    ' SELECT t1.trip_id trip_id,t1.shape_id shape_id,'||
                    ' t2.node_id node_id, t1.stop_sequence stop_sequence ' ||
                    ' FROM ' || temp_table || ' t1, ' ||
                    node_map_table || ' t2 ' ||
                    ' WHERE t1.route_id = t2.route_id AND ' ||
                    ' t1.direction_id = t2.direction_id AND ' ||
                    ' t1.agency_id = t2.agency_id  AND ' ||
                    ' t1.stop_id = t2.stop_id ';
       execute immediate query_str;
       commit;
 
       query_str := 'CREATE TABLE ' || lrs_project_table || ' AS ' ||
                    ' SELECT t2.node_id node_id, t3.shape_id shape_id, '||
                    ' t3.trip_id trip_id, ' ||
                    --' sdo_lrs.convert_to_std_geom('||
                    ' sdo_lrs.project_pt(sdo_lrs.convert_to_lrs_geom(t1.geometry),'||
                    '  t2.geometry) geometry '||
                    --' ) geometry ' ||
                    ' FROM ' || trip_shape_table || ' t1, ' ||
                    service_node_table || ' t2, '|| temp_node_table || ' t3 ' ||
                    ' WHERE ' || ' t1.trip_id = t3.trip_id AND '||
                    ' t2.node_id = t3.node_id ' || ' ORDER BY t2.node_id ';
       execute immediate query_str;
       commit;

       query_str := 'CREATE TABLE ' || lrs_measure_table || ' AS ' ||
                    ' SELECT t.node_id node_id, t.shape_id shape_id, '||
                    ' t.trip_id trip_id, '||
                    ' sdo_lrs.get_measure(t.geometry) lrs_measure '||
                    ' FROM ' || lrs_project_table || ' t ' ;
       execute immediate query_str;
       commit;

       if (table_exists(temp_table)) then
          execute immediate 'drop table ' || temp_table || ' purge';
       end if;
       if (table_exists(temp_node_table)) then
          execute immediate 'drop table ' || temp_node_table || ' purge';
       end if;
       if (table_exists(temp_shape_table)) then
          execute immediate 'drop table ' || temp_shape_table || ' purge';
       end if;
       
       mm_util.log_message('Creating LRS measure table'||to_char((sysdate-start_date)*24*60,'99999.999') || ' min.',false);
       tmp_date := sysdate;
       correct_node_geom_from_shapes(network_name, subnetwork_name, lrs_project_table, log_loc, log_file,'a');
       mm_util.log_message('Correcting node geometry in service nodes table'||to_char((sysdate-tmp_date)*24*60,'99999.999') || ' min.',false);
       mm_util.log_message('***** End : Creating LRS measure table '||subnetwork_name,true);
       utl_file.fclose(mm_log_file);
   END create_lrs_measures_for_stops;

   PROCEDURE add_geometry_to_service_links(network_name IN VARCHAR2,
                                           subnetwork_name IN VARCHAR2,
                                           service_link_table IN VARCHAR2,
					   log_loc IN VARCHAR2,
					   log_file IN VARCHAR2,
					   open_mode IN VARCHAR2) IS
   mm_log_file                                 	utl_file.file_type := NULL;
   start_date					date;
   end_date					date;
   temp_table1					varchar2(32);
   temp_table2					varchar2(32);
   temp_service_link_table			varchar2(32);
   lrs_measure_table				varchar2(32);
   shape_geom_table				varchar2(32);
   query_str					varchar2(1024);
   BEGIN
       -- mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
       -- mm_util.set_log_info(mm_log_file);
       -- mm_util.log_message('**** START : Add geometry to service links',true);

       lrs_measure_table := subnetwork_name||'_LRS_MEASURE$';
       shape_geom_table := subnetwork_name||'_SHAPE_GEOM$';

       temp_table1 := 'TEMP_LINK_LRS_MEASURE';
       temp_table2 := 'TEMP_LINK_SHAPE_ID';
       temp_service_link_table := 'TEMP_SERVICE_LINKS';

       start_date := sysdate;
       if (table_exists(temp_table1)) then
          execute immediate 'drop table '||temp_table1 || ' purge';
       end if;
       if (table_exists(temp_table2)) then
          execute immediate 'drop table '||temp_table2 || ' purge';
       end if;
       if (table_exists(temp_service_link_table)) then
          execute immediate 'drop table '||temp_service_link_table || ' purge';
       end if;
     
       query_str := 'CREATE TABLE ' || temp_table1 || ' AS ' ||
                    ' SELECT t1.link_id link_id, ' ||
		    ' t1.start_node_id start_node_id,'||
                    ' t1.end_node_id end_node_id, '||
                    ' t2.shape_id shape_id,'||
                    ' t2.lrs_measure sid_measure,t3.lrs_measure eid_measure '||
                    ' FROM ' || service_link_table || ' t1, '||
                    lrs_measure_table || ' t2, '||
                    lrs_measure_table || ' t3 '||
                    ' WHERE ' || ' t1.start_node_id = t2.node_id AND '||
                    ' t1.end_node_id = t3.node_id AND ' ||
                    ' t2.shape_id = t3.shape_id ';
        dbms_output.put_line('Query Str : ' || query_str);
       execute immediate query_str;
       commit;

       query_str := 'CREATE TABLE ' || temp_table2 || ' AS ' ||
                    ' SELECT t.link_id, t.start_node_id, t.end_node_id, '||
                    ' t.shape_id,'||
                    ' min(t1.sid_measure) sid_measure,'||
                    ' min(t1.eid_measure) eid_measure ' ||
                    ' FROM ' ||
                    ' (SELECT link_id link_id, start_node_id start_node_id,'||
                    '  end_node_id end_node_id, min(shape_id) shape_id '||
                    ' FROM ' || temp_table1 ||
                    ' GROUP BY link_id,start_node_id,end_node_id) t,'||
                    temp_table1 || ' t1 ' ||
                    ' WHERE ' || ' t.link_id=t1.link_id AND '||
                    ' t.start_node_id = t1.start_node_id AND '||
                    ' t.end_node_id = t1.end_node_id AND ' ||
                    ' t.shape_id = t1.shape_id ' ||
                    ' GROUP BY t.link_id,t.start_node_id,t.end_node_id,'||
                    ' t.shape_id';
       execute immediate query_str;
       commit;

       query_str := 'CREATE TABLE '|| temp_service_link_table||
                    ' (link_id number, start_node_id number,'||
                    ' end_node_id number, cost number, route_id number,'||
                    ' geometry sdo_geometry) NOLOGGING';
       execute immediate query_str;
       commit;

       query_str := 'INSERT /*+ APPEND */ INTO '|| temp_service_link_table||
                    ' (link_id, start_node_id, end_node_id, '||
                    ' cost, route_id, geometry) ' ||
                    ' SELECT t1.link_id link_id, '||
                    ' t1.start_node_id start_node_id,' ||
                    ' t1.end_node_id end_node_id,'||
                    ' t1.cost cost, t1.route_id route_id, '||
                    ' sdo_lrs.convert_to_std_geom('||
                    ' sdo_lrs.clip_geom_segment('||
                    ' sdo_lrs.convert_to_lrs_geom(t2.geometry),'||
                    ' t3.sid_measure,t3.eid_measure)) geometry '||
                    ' FROM ' || service_link_table || ' t1, ' ||
                    shape_geom_table || ' t2, '|| temp_table2 || ' t3 ' ||
                    ' WHERE ' || ' t1.link_id = t3.link_id AND ' ||
                    ' t2.shape_id = t3.shape_id';
       execute immediate query_str;
       commit;

--  Drop existing service links table and rename temp service links table
       if (table_exists(service_link_table)) then
           execute immediate 'drop table ' || service_link_table || ' purge';
       end if;
       execute immediate 'alter table '||temp_service_link_table|| 
                         ' rename to ' || service_link_table;
       commit;

       if (table_exists(temp_table1)) then
           execute immediate 'drop table ' || temp_table1 || ' purge';
       end if;
       if (table_exists(temp_table2)) then
           execute immediate 'drop table ' || temp_table2 || ' purge';
       end if;
       
       end_date := sysdate;
       -- mm_util.log_message('Adding geometry to service links took '||to_char((end_date-start_date)*24*60,'99999.999') || ' min.',false);
       -- mm_util.log_message('**** END : Add geometry to service links',true);
       -- utl_file.fclose(mm_log_file);
   END add_geometry_to_service_links;

   PROCEDURE split_links(network_name IN VARCHAR2, 
                         subnetwork_name IN VARCHAR2,
			 log_loc IN VARCHAR2,
		         log_file IN VARCHAR2,
		         open_mode IN VARCHAR2) IS
   mm_log_file                                 	utl_file.file_type := NULL;
   service_link_table 				varchar2(32);
   link_table					varchar2(32);
   split_link_table				varchar2(32);
   service_node_table				varchar2(32);
   temp_table1					varchar2(32);
   temp_table2					varchar2(32);
   split_geom_1					sdo_geometry;
   split_geom_2                                 sdo_geometry;
   query_str					varchar2(512);
   insert_str					varchar2(512);
   query_csr					cursor_type;
   node_id_array				number_array;
   link_id_array				number_array;
   measure_array				number_array;
   link_geom_array				geom_array;
   geom1_array					geom_array := geom_array();
   geom2_array					geom_array := geom_array();
   BEGIN
       --mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
       --mm_util.set_log_info(mm_log_file);
       --mm_util.log_message('**** START : Splitting links for Connect links',true);
       service_link_table := get_sub_service_link_table(network_name,subnetwork_name);
       service_node_table := get_sub_service_node_table(network_name,subnetwork_name);
       link_table := get_base_link_table_name(network_name);
       split_link_table := subnetwork_name ||'_SPLIT_LINK$';

       temp_table1 := 'TEMP_LINK_ID_MEASURE';
       temp_table2 := 'TEMP_SPLIT_LINK';
       if (table_exists(temp_table1)) then
           execute immediate 'drop table ' || temp_table1 || ' purge';
       end if;
       if (table_exists(temp_table2)) then
           execute immediate 'drop table ' || temp_table2 || ' purge';
       end if;
       if (table_exists(split_link_table)) then
           execute immediate 'drop table ' || split_link_table || ' purge';
       end if;
       
       query_str := 'CREATE TABLE ' || temp_table1 ||
                    ' (node_id number, link_id number, link_geometry sdo_geometry, '||
                    ' lrs_measure number) '||
                    ' NOLOGGING ';
       execute immediate query_str;

       query_str := 'CREATE TABLE ' || temp_table2 ||
                    ' (node_id number, link_id number, lrs_measure number, '||
                    ' geometry_1 sdo_geometry, geometry_2 sdo_geometry) '||
                    ' NOLOGGING ';
       execute immediate query_str;

       query_str := 'CREATE TABLE ' || split_link_table ||
                    ' (node_id number, node_geometry sdo_geometry,'||
                    ' link_id number, lrs_measure number, '||
                    ' geometry_1 sdo_geometry, geometry_2 sdo_geometry) '||
                    ' NOLOGGING ';
       execute immediate query_str;

       query_str := 'INSERT /*+ APPEND */ INTO ' || temp_table1 ||
                    ' SELECT t1.node_id node_id, t1.link_id link_id,'||
                    ' t2.geometry link_geometry, '||
                    ' sdo_lrs.get_measure('||
                    ' sdo_lrs.project_pt(sdo_lrs.convert_to_lrs_geom(t2.geometry),'||
                    ' t1.geometry)) lrs_measure ' || ' FROM ' ||
                    service_node_table || ' t1, '|| link_table || ' t2 ' ||
                    ' WHERE ' || ' t1.link_id = t2.link_id ';
       execute immediate query_str;
       commit;

       insert_str := 'INSERT INTO ' || temp_table2 ||
		  ' (node_id,link_id,lrs_measure,geometry_1,geometry_2) ' ||
		  ' VALUES (:a,:b,:c,:d,:e) ';

       query_str := 'SELECT node_id, link_id, link_geometry, lrs_measure FROM ' ||
                    temp_table1;
       open query_csr for query_str;
       LOOP
          fetch query_csr bulk collect into node_id_array,link_id_array,link_geom_array,measure_array limit 1000;
          for i IN 1 .. node_id_array.count loop
              sdo_lrs.split_geom_segment(sdo_lrs.convert_to_lrs_geom(link_geom_array(i)),
                                         measure_array(i), split_geom_1, split_geom_2);
              geom1_array.extend;
              geom2_array.extend;
              geom1_array(i) := sdo_lrs.convert_to_std_geom(split_geom_1); 
              geom2_array(i) := sdo_lrs.convert_to_std_geom(split_geom_2); 
          end loop;
          forall j IN 1 .. node_id_array.count 
	    execute immediate insert_str 
	    using node_id_array(j),link_id_array(j),measure_array(j),
		  geom1_array(j),geom2_array(j);
          
       EXIT WHEN query_csr%NOTFOUND;		
       END LOOP;
       close query_csr;
       commit;

       insert_str := 'INSERT /*+ APPEND */ INTO ' || split_link_table ||
                    ' SELECT t1.node_id node_id, t2.geometry node_geometry,'||
                    ' t1.link_id link_id, '||
                    ' t1.lrs_measure lrs_measure,' || 
                    ' t1.geometry_1 geometry_1, '||
                    ' t1.geometry_2 geometry_2 '||
                    ' FROM ' ||
                    temp_table2 || ' t1, '|| service_node_table || ' t2 ' ||
                    ' WHERE ' || ' t1.node_id = t2.node_id ';
       execute immediate insert_str;
       commit;

       if (table_exists(temp_table1)) then
           execute immediate 'drop table ' || temp_table1 || ' purge';
       end if;
       if (table_exists(temp_table2)) then
           execute immediate 'drop table '|| temp_table2 || ' purge';
       end if;

       --mm_util.log_message('**** END : Splitting links for Connect links',true);
       --utl_file.fclose(mm_log_file);
   END split_links;
--
-- Create table with trip geometries by calling Java method through wrapper
--
    PROCEDURE compute_trip_geometry_java(network_name IN VARCHAR2, 
                                         subnetwork_name IN VARCHAR2,
                                         output_table IN VARCHAR2) 
      AS LANGUAGE JAVA
      NAME 'oracle.spatial.network.apps.multimodal.NDMMultimodalWrapper.computeGeometryForTrips(java.lang.String,java.lang.String,java.lang.String)';

--
-- Compute geometries of trips
--
   PROCEDURE compute_geometry_for_trips(network_name IN VARCHAR2,
                                        subnetwork_name IN VARCHAR2,
                                        output_table IN VARCHAR2,
                                        log_loc IN VARCHAR2,
				        log_file IN VARCHAR2,
				        open_mode IN VARCHAR2) IS
   mm_log_file				utl_file.file_type := NULL;
   tmp_date				date;
   BEGIN
      --mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
      --mm_util.set_log_info(mm_log_file);
      mm_util.log_message('****** START : Computing Geometry for Trips '||subnetwork_name,false);
      tmp_date := sysdate;
      compute_trip_geometry_java(network_name, subnetwork_name, output_table);
      mm_util.log_message('*** Geometry computation took '||to_char((sysdate-tmp_date)*24*60,'99999.999') || ' min.',false);
      mm_util.log_message('****** END : Computing Geometry for Trips '||subnetwork_name,false);
      --utl_file.fclose(mm_log_file);
   END compute_geometry_for_trips;

--
-- Wrapper procedure to generate multimodal user data
--
   PROCEDURE generate_mm_user_data_java(network_name IN VARCHAR2,
                                        output_table IN VARCHAR2)
      AS LANGUAGE JAVA
      NAME 'oracle.spatial.network.apps.multimodal.NDMMultimodalWrapper.writeMultimodalUserData(java.lang.String,
                                               java.lang.String)';

--
-- Wrapper procedure to
-- generate user data just for the purpose of transfer link generation
-- The user data table can be dropped after transfer link generation
--
   PROCEDURE generate_tlink_user_data_java(network_name IN VARCHAR2,
                                           output_table IN VARCHAR2)
      AS LANGUAGE JAVA
      NAME 'oracle.spatial.network.apps.multimodal.NDMMultimodalWrapper.writePreTLinkUserData(java.lang.String,
                                               java.lang.String)';

-- 
-- Generates multimodal user data
--
   PROCEDURE generate_mm_user_data(network_name IN VARCHAR2,
                                   log_loc IN VARCHAR2,
                                   log_file IN VARCHAR2,
                                   open_mode IN VARCHAR2) IS
   output_table					varchar2(32);
   mm_log_file                                 	utl_file.file_type := NULL;
   start_date					date;	
   BEGIN
      mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
      mm_util.set_log_info(mm_log_file);

      output_table := network_name||'_USER_DATA';

      mm_util.log_message('**** START : Generation of Multimodal User Data',true);
      start_date := sysdate;
      generate_mm_user_data_java(network_name, output_table);
      mm_util.log_message('Generation of user data '||to_char((sysdate-start_date)*24*60,'99999.999') || ' min.',false);
      mm_util.log_message('**** END : Generation of Multimodal User Data',true);

   END generate_mm_user_data;

-- 
-- Generates user data for transfer link generation
--
   PROCEDURE generate_tlink_user_data(network_name IN VARCHAR2,
                                          log_loc IN VARCHAR2,
                                          log_file IN VARCHAR2,
                                          open_mode IN VARCHAR2) IS
   output_table                                 varchar2(32);
   mm_log_file                                  utl_file.file_type := NULL;
   start_date                                   date;
   BEGIN
      mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
      mm_util.set_log_info(mm_log_file);

      output_table := network_name||'_TLINK_USER_DATA';

      mm_util.log_message('**** START : Generation of User Data for Transfer links',true);
      start_date := sysdate;
      generate_tlink_user_data_java(network_name, output_table);
      mm_util.log_message('Generation of user data '||to_char((sysdate-start_date)*24*60,'99999.999') || ' min.',false);
      mm_util.log_message('**** END : Generation of User Data for Transfer links',true);

   END generate_tlink_user_data;

   PROCEDURE create_indexes(network_name IN VARCHAR2,
                            log_loc IN VARCHAR2,
                            log_file IN VARCHAR2,
                            open_mode IN VARCHAR2) IS
   mm_link_table			varchar2(32);
   indx_name				varchar2(32);
   BEGIN
       mm_link_table := get_mm_link_table_name(network_name);
       indx_name := network_name||'_mm_lid_idx';
       if (not(index_on_col_exists(mm_link_table,'link_id'))) then  
          if (not(index_exists(indx_name))) then
	     execute immediate 'create index '||indx_name||' on '||mm_link_table ||
			       ' (link_id) ';
          end if;
       end if;
      
       indx_name := network_name||'_mm_lgeom_idx';
       if (not(index_on_col_exists(mm_link_table,'geometry'))) then
          if (not(index_exists(indx_name))) then
             execute immediate 'create index '||indx_name||' on '||mm_link_table ||
                               ' (geometry) indextype is mdsys.spatial_index';
          end if;
       end if;
      
   END create_indexes;

   PROCEDURE create_subnet_schedule_ids(network_name IN VARCHAR2,
                                        subnetwork_name IN VARCHAR2,
                                        output_table IN VARCHAR2,
                                        log_loc IN VARCHAR2,
 		                        log_file IN VARCHAR2,
			   	        open_mode IN VARCHAR2) IS
   calendar_table                       varchar2(32);
   schedule_id_table                    varchar2(32);
   query_str                            varchar2(512);
   insert_str                           varchar2(512);
   schedule_id                          number;
   sid_array                            number_array;
   mon_array                            char_array;
   tues_array                           char_array;
   wed_array                            char_array;
   thurs_array                          char_array;
   fri_array                            char_array;
   sat_array                            char_array;
   sun_array                            char_array;
   query_csr                            cursor_type;
   BEGIN
      calendar_table := get_calendar_table_name(network_name, subnetwork_name);
      schedule_id_table := output_table;

      if (table_exists(schedule_id_table)) then
         execute immediate 'drop table '|| schedule_id_table || ' purge';
      end if;

      query_str := 'CREATE TABLE '||schedule_id_table||
                   ' (schedule_id number, service_id number) '||
                   ' NOLOGGING';
      execute immediate query_str;
      commit;

      insert_str := 'INSERT INTO '||schedule_id_table||
                    ' (schedule_id, service_id) '||
                    ' VALUES (:a, :b) ';
      query_str := 'SELECT service_id, monday, tuesday, wednesday,'||
                    ' thursday, friday, saturday, sunday '|| ' FROM ' ||
                    calendar_table;
      OPEN query_csr FOR query_str;
      FETCH query_csr BULK COLLECT INTO sid_array, mon_array,
                                        tues_array, wed_array,
                                        thurs_array, fri_array,
                                        sat_array, sun_array;
      for i IN 1 .. sid_array.count loop
         case
            when 
               mon_array(i) = '1' and tues_array(i) = '1' and
               wed_array(i) = '1' and thurs_array(i) = '1' and
               fri_array(i) = '1' and sat_array(i) = '0' and
               sun_array(i) = '0'
            then schedule_id := 1;
                 execute immediate insert_str using schedule_id, sid_array(i);
            when
               mon_array(i) = '1' and tues_array(i) = '1' and
               wed_array(i) = '1' and thurs_array(i) = '1' and
               fri_array(i) = '0' and sat_array(i) = '0' and
               sun_array(i) = '0'
            then schedule_id := 2;
                 execute immediate insert_str using schedule_id, sid_array(i);
            when
               mon_array(i) = '0' and tues_array(i) = '0' and
               wed_array(i) = '0' and thurs_array(i) = '0' and
               fri_array(i) = '1' and sat_array(i) = '0' and
               sun_array(i) = '0'
            then schedule_id := 3;
                 execute immediate insert_str using schedule_id, sid_array(i);
            when
               mon_array(i) = '0' and tues_array(i) = '0' and
               wed_array(i) = '0' and thurs_array(i) = '0' and
               fri_array(i) = '0' and sat_array(i) = '1' and
               sun_array(i) = '0'
            then schedule_id := 4;
                 execute immediate insert_str using schedule_id, sid_array(i);
            when
               mon_array(i) = '0' and tues_array(i) = '0' and
               wed_array(i) = '0' and thurs_array(i) = '0' and
               fri_array(i) = '0' and sat_array(i) = '0' and
               sun_array(i) = '1'
            then schedule_id := 5;
                 execute immediate insert_str using schedule_id, sid_array(i);
            when
               mon_array(i) = '0' and tues_array(i) = '0' and
               wed_array(i) = '0' and thurs_array(i) = '0' and
               fri_array(i) = '0' and sat_array(i) = '1' and
               sun_array(i) = '1'
            then schedule_id := 6;
                 execute immediate insert_str using schedule_id, sid_array(i);
            when
               mon_array(i) = '0' and tues_array(i) = '0' and
               wed_array(i) = '0' and thurs_array(i) = '0' and
               fri_array(i) = '0' and sat_array(i) = '0' and
               sun_array(i) = '0'
            then schedule_id := 0;
                 execute immediate insert_str using schedule_id, sid_array(i);
         end case;
      end loop; 

--    Update subnetwork metadata with schedule id table
       query_str := 'UPDATE multimodal_subnetwork_metadata t SET '||
                    ' t.schedule_id_table_name = :s '|| 
                    ' WHERE ' || ' upper(trim(t.network_name)) = upper(:a) AND '||
                    ' upper(trim(t.subnetwork_name)) = upper(:b)';
       execute immediate query_str using output_table, network_name, subnetwork_name;
       commit;

   END create_subnet_schedule_ids;

   PROCEDURE create_schedule_ids(network_name IN VARCHAR2,
                                 log_loc IN VARCHAR2,
 		                 log_file IN VARCHAR2,
			   	 open_mode IN VARCHAR2) IS
   query_str					varchar2(512);
   subnetwork_names				sdo_string_array;
   subnetwork					varchar2(32);
   schedule_table				varchar2(32);
   sub_sch_table				varchar2(32);
   BEGIN
      query_str := 'SELECT subnetwork_name FROM multimodal_subnetwork_metadata '||
                   ' WHERE upper(network_name) = :n ';
      execute immediate query_str bulk collect into subnetwork_names
                                               using upper(network_name);

      for i in 1 .. subnetwork_names.count loop
         subnetwork := subnetwork_names(i);
         sub_sch_table := subnetwork||'_SCHEDULE_ID$';
         mm_util.create_subnet_schedule_ids(network_name, subnetwork, sub_sch_table, log_loc, log_file, 'a');
      end loop;
   END create_schedule_ids;

   PROCEDURE load_gtfs_data(network_name IN VARCHAR2,
                            sub_network_name IN VARCHAR2,
                            csv_file_loc IN VARCHAR2,
                            agency_csv_file IN VARCHAR2,
                            calendar_csv_file IN VARCHAR2,
                            routes_csv_file IN VARCHAR2,
                            shapes_csv_file IN VARCHAR2,
                            stop_times_csv_file IN VARCHAR2,
                            stops_csv_file IN VARCHAR2,
                            trips_csv_file IN VARCHAR2, 
                            log_loc IN VARCHAR2,
                            log_file IN VARCHAR2,
                            open_mode IN VARCHAR2) IS
   ext_table					varchar2(32);
   table_name				 	varchar2(32);
   agency_table					varchar2(32);
   calendar_table                               varchar2(32);
   route_table                                  varchar2(32);
   shape_table                                  varchar2(32);
   stop_times_table                             varchar2(32);
   stop_table                                   varchar2(32);
   trip_table                                   varchar2(32);
   csv_file_name				varchar(32);
   query_str					varchar2(512);
   BEGIN
      ext_table := sub_network_name||'_AGENCY_EXTERNAL';
      if (table_exists(ext_table)) then
         execute immediate 'drop table '||ext_table||' purge';
      end if;
      agency_table := sub_network_name || '_AGENCY$';
      if (table_exists(agency_table)) then
         execute immediate 'drop table '||agency_table||' purge';
      end if;

      csv_file_name := agency_csv_file;
      query_str := 'CREATE TABLE ' || ext_table ||
                    ' (agency_id number, agency_name varchar2(128), '||
                    ' agency_url varchar2(512), agency_timezone varchar2(256), '||
                    ' agency_lang varchar2(64), agency_phone varchar2(16)) '||
                    ' ORGANIZATION EXTERNAL '||
                    ' ( TYPE ORACLE_LOADER '||
                    ' DEFAULT DIRECTORY '|| csv_file_loc ||
                    ' ACCESS PARAMETERS '||
                    ' (RECORDS delimited by newline ' ||
                    '  FIELDS terminated by '','') '   ||
                    ' LOCATION (''' || csv_file_name || ''') ) ' ||
                    ' REJECT LIMIT UNLIMITED ';
      execute immediate query_str;

      query_str := 'CREATE TABLE ' || agency_table ||
                   ' (agency_id number, agency_name varchar2(128), '||
                    ' agency_url varchar2(512), agency_timezone varchar2(256), '||
                    ' agency_lang varchar2(64), agency_phone varchar2(16)) ';
      execute immediate query_str;

      query_str := 'INSERT INTO ' || agency_table ||
                   ' SELECT * FROM ' || ext_table;
      execute immediate query_str;

      if (table_exists(ext_table)) then
         execute immediate 'drop table '||ext_table||' purge';
      end if;
-----------
-----------
      ext_table := sub_network_name||'_CAL_EXTERNAL';
      if (table_exists(ext_table)) then
         execute immediate 'drop table '||ext_table||' purge';
      end if;
      calendar_table := sub_network_name || '_CALENDAR$';
      if (table_exists(calendar_table)) then
         execute immediate 'drop table '||calendar_table||' purge';
      end if;

      csv_file_name := calendar_csv_file;
      query_str := 'CREATE TABLE ' || ext_table ||
                   ' (service_id number, monday varchar2(1), '||
                    ' tuesday varchar2(1), wednesday varchar2(1),'||
                    ' thursday varchar2(1), friday varchar2(1),'||
                    ' saturday varchar2(1), sunday varchar2(1),'||
                    ' start_date varchar2(8), end_date varchar(8))'||
                    ' ORGANIZATION EXTERNAL '||
                    ' ( TYPE ORACLE_LOADER '||
                    ' DEFAULT DIRECTORY '|| csv_file_loc ||
                    ' ACCESS PARAMETERS '||
                    ' (RECORDS delimited by newline ' ||
                    '  FIELDS terminated by '','') '   ||
                    ' LOCATION (''' || csv_file_name || ''') ) ' ||
                    ' REJECT LIMIT UNLIMITED ';
      execute immediate query_str;

      query_str := 'CREATE TABLE ' || calendar_table ||
                   ' (service_id number, monday varchar2(1), '||
                    ' tuesday varchar2(1), wednesday varchar2(1),'||
                    ' thursday varchar2(1), friday varchar2(1),'||
                    ' saturday varchar2(1), sunday varchar2(1),'||
                    ' start_date varchar2(8), end_date varchar(8))';
      execute immediate query_str;

      query_str := 'INSERT INTO ' || calendar_table ||
                   ' SELECT * FROM ' || ext_table;
      execute immediate query_str;

      if (table_exists(ext_table)) then
         execute immediate 'drop table '||ext_table||' purge';
      end if;
-----------
-----------
      ext_table := sub_network_name||'_ROUTES_EXTERNAL';
      if (table_exists(ext_table)) then
         execute immediate 'drop table '||ext_table||' purge';
      end if;
      route_table := sub_network_name || '_ROUTE$';
      if (table_exists(route_table)) then
         execute immediate 'drop table '||route_table||' purge';
      end if;

      csv_file_name := routes_csv_file;
      query_str := 'CREATE TABLE ' || ext_table ||
                   ' (route_id number,agency_id number, '|| 
                   ' route_short_name varchar2(64), '||
                   ' route_long_name varchar2(256), '||
                   ' route_type number, route_url varchar2(4),'||
                   ' route_color varchar2(16)) '||
                    ' ORGANIZATION EXTERNAL '||
                    ' ( TYPE ORACLE_LOADER '||
                    ' DEFAULT DIRECTORY '|| csv_file_loc ||
                    ' ACCESS PARAMETERS '||
                    ' (RECORDS delimited by newline ' ||
                    '  FIELDS terminated by '','') '   ||
                    ' LOCATION (''' || csv_file_name || ''') ) ' ||
                    ' REJECT LIMIT UNLIMITED ';
      execute immediate query_str;

      query_str := 'CREATE TABLE ' || route_table ||
                   ' (route_id number,agency_id number, '|| 
                   ' route_short_name varchar2(64), '||
                   ' route_long_name varchar2(256), '||
                   ' route_type number, route_url varchar2(4),'||
                   ' route_color varchar2(16)) ';
      execute immediate query_str;

      query_str := 'INSERT INTO ' || route_table ||
                   ' SELECT * FROM ' || ext_table;
      execute immediate query_str;

      if (table_exists(ext_table)) then
         execute immediate 'drop table '||ext_table||' purge';
      end if;
-----------
-----------
      ext_table := sub_network_name||'_SHAPES_EXTERNAL';
      if (table_exists(ext_table)) then
         execute immediate 'drop table '||ext_table||' purge';
      end if;
      shape_table := sub_network_name || '_SHAPE$';
      if (table_exists(shape_table)) then
         execute immediate 'drop table '||shape_table||' purge';
      end if;

      csv_file_name := shapes_csv_file;
      query_str := 'CREATE TABLE ' || ext_table ||
                   ' (shape_id number,shape_pt_lat number,'||
                   ' shape_pt_lon number, '|| 
                   ' shape_pt_sequence number,'||
                   ' shape_dist_traveled number) '||
                    ' ORGANIZATION EXTERNAL '||
                    ' ( TYPE ORACLE_LOADER '||
                    ' DEFAULT DIRECTORY '|| csv_file_loc ||
                    ' ACCESS PARAMETERS '||
                    ' (RECORDS delimited by newline ' ||
                    '  FIELDS terminated by '','') '   ||
                    ' LOCATION (''' || csv_file_name || ''') ) ' ||
                    ' REJECT LIMIT UNLIMITED ';
      execute immediate query_str;

      query_str := 'CREATE TABLE ' || shape_table ||
                   ' (shape_id number,shape_pt_lat number,'||
                   ' shape_pt_lon number, '|| 
                   ' shape_pt_sequence number,'||
                   ' shape_dist_traveled number) ';
      execute immediate query_str;

      query_str := 'INSERT INTO ' || shape_table ||
                   ' SELECT * FROM ' || ext_table;
      execute immediate query_str;

      if (table_exists(ext_table)) then
         execute immediate 'drop table '||ext_table||' purge';
      end if;
-----------
-----------
      ext_table := sub_network_name||'_STOP_TIMES_EXTERNAL';
      if (table_exists(ext_table)) then
         execute immediate 'drop table '||ext_table||' purge';
      end if;
      stop_times_table := sub_network_name || '_STOP_TIME$';
      if (table_exists(stop_times_table)) then
         execute immediate 'drop table '||stop_times_table||' purge';
      end if;

      csv_file_name := stop_times_csv_file;
      query_str := 'CREATE TABLE ' || ext_table ||
                   ' (trip_id number,arrival_time varchar2(10),' || 
                   ' departure_time varchar2(10), '||
                   ' stop_id number,stop_sequence number, '||
                   ' pickup_type number,drop_off_type number, '||
                   ' shape_dist_traveled number) ' ||
                    ' ORGANIZATION EXTERNAL '||
                    ' ( TYPE ORACLE_LOADER '||
                    ' DEFAULT DIRECTORY '|| csv_file_loc ||
                    ' ACCESS PARAMETERS '||
                    ' (RECORDS delimited by newline ' ||
                    '  FIELDS terminated by '','') '   ||
                    ' LOCATION (''' || csv_file_name || ''') ) ' ||
                    ' REJECT LIMIT UNLIMITED ';
      execute immediate query_str;

      query_str := 'CREATE TABLE ' || stop_times_table ||
                   ' (trip_id number,arrival_time varchar2(10),' || 
                   ' departure_time varchar2(10), '||
                   ' stop_id number,stop_sequence number, '||
                   ' pickup_type number,drop_off_type number, '||
                   ' shape_dist_traveled number) ';
      execute immediate query_str;

      query_str := 'INSERT INTO ' || stop_times_table ||
                   ' SELECT * FROM ' || ext_table;
      execute immediate query_str;

      if (table_exists(ext_table)) then
         execute immediate 'drop table '||ext_table||' purge';
      end if;
-----------
-----------
      ext_table := sub_network_name||'_STOPS_EXTERNAL';
      if (table_exists(ext_table)) then
         execute immediate 'drop table '||ext_table||' purge';
      end if;
      stop_table := sub_network_name || '_STOP$';
      if (table_exists(stop_table)) then
         execute immediate 'drop table '||stop_table||' purge';
      end if;

      csv_file_name := stops_csv_file;
      query_str := 'CREATE TABLE ' || ext_table ||
                   ' (stop_id number,stop_name varchar2(256),' ||
                   ' stop_desc varchar2(256), '||
                   ' stop_lat number, stop_lon number, '||
                   ' zone_id number) '||
                    ' ORGANIZATION EXTERNAL '||
                    ' ( TYPE ORACLE_LOADER '||
                    ' DEFAULT DIRECTORY '|| csv_file_loc ||
                    ' ACCESS PARAMETERS '||
                    ' (RECORDS delimited by newline ' ||
                    '  FIELDS terminated by '','') '   ||
                    ' LOCATION (''' || csv_file_name || ''') ) ' ||
                    ' REJECT LIMIT UNLIMITED ';
      execute immediate query_str;

      query_str := 'CREATE TABLE ' || stop_table ||
                   ' (stop_id number,stop_name varchar2(256),' ||
                   ' stop_desc varchar2(256), '||
                   ' stop_lat number, stop_lon number, '||
                   ' zone_id number) ';
      execute immediate query_str;

      query_str := 'INSERT INTO ' || stop_table ||
                   ' SELECT * FROM ' || ext_table;
      execute immediate query_str;

      if (table_exists(ext_table)) then
         execute immediate 'drop table '||ext_table||' purge';
      end if;
-----------
-----------
      ext_table := sub_network_name||'_TRIPS_EXTERNAL';
      if (table_exists(ext_table)) then
         execute immediate 'drop table '||ext_table||' purge';
      end if;
      trip_table := sub_network_name || '_TRIP$';
      if (table_exists(trip_table)) then
         execute immediate 'drop table '||trip_table||' purge';
      end if;

      csv_file_name := trips_csv_file;
      query_str := 'CREATE TABLE ' || ext_table ||
                   ' (route_id number,service_id number,'||
                   ' trip_id number,trip_headsign varchar2(64),'||
                   ' direction_id number,block_id varchar2(32),'||
                   ' shape_id number) '||
                    ' ORGANIZATION EXTERNAL '||
                    ' ( TYPE ORACLE_LOADER '||
                    ' DEFAULT DIRECTORY '|| csv_file_loc ||
                    ' ACCESS PARAMETERS '||
                    ' (RECORDS delimited by newline ' ||
                    '  FIELDS terminated by '','') '   ||
                    ' LOCATION (''' || csv_file_name || ''') ) ' ||
                    ' REJECT LIMIT UNLIMITED ';
      execute immediate query_str;

      query_str := 'CREATE TABLE ' || trip_table ||
                   ' (route_id number,service_id number,'||
                   ' trip_id number,trip_headsign varchar2(64),'||
                   ' direction_id number,block_id varchar2(32),'||
                   ' shape_id number) ';
      execute immediate query_str;

      query_str := 'INSERT INTO ' || trip_table ||
                   ' SELECT * FROM ' || ext_table;
      execute immediate query_str;

      if (table_exists(ext_table)) then
         execute immediate 'drop table '||ext_table||' purge';
      end if;

--
--    Update metadata with GTFS table name
--
      query_str := 'UPDATE multimodal_subnetwork_metadata SET '||
                   ' agency_table_name=:a, '||
                   ' calendar_table_name=:b, '||
                   ' route_table_name=:c,'||
                   ' shape_table_name=:d,'||
                   ' stop_times_table_name=:e,'||
                   ' stop_table_name=:f,'||
                   ' trip_table_name=:g ' ||
                   ' WHERE upper(network_name) = :n ' ||
                   ' AND upper(subnetwork_name) = :s ';
       execute immediate query_str using agency_table,calendar_table,
                                         route_table,shape_table,
                                         stop_times_table,stop_table,
                                         trip_table, upper(network_name),
                                         upper(sub_network_name);
       commit;

--     Set subnetwork_id = agency_id 
       query_str := 'UPDATE multimodal_subnetwork_metadata t SET '||
                    ' t.subnetwork_id = '||
                    ' (SELECT t1.agency_id FROM '|| 
                      agency_table || ' t1 ' || ' WHERE ' ||
                    ' upper(trim(t.subnetwork_name)) = upper(trim(t1.agency_name)))';
       execute immediate query_str;
       commit;

   END load_gtfs_data;

   PROCEDURE set_max_memory_size(bytes NUMBER)
   AS LANGUAGE JAVA NAME
    'oracle.aurora.vm.OracleRuntime.setMaxMemorySize(long)';

   PROCEDURE create_multimodal_metadata IS
   query_str 			varchar2(4096);
   table_name			varchar2(32) := 'NDM_MULTIMODAL_METADATA';
   BEGIN
      if (table_exists(table_name)) then
         execute immediate 'drop table '||table_name|| ' purge';
      end if;

      query_str := 'CREATE TABLE ' || table_name ||
                   ' (network_name varchar2(32) PRIMARY KEY, '||
                   ' node_table_name varchar2(32),'||
                   ' link_table_name varchar2(32), '||
                   ' base_network_name varchar2(32), '||
                   ' base_node_table_name varchar2(32), ' ||
                   ' base_link_table_name varchar2(32), ' ||
                   ' service_node_table_name varchar2(32), '||
                   ' service_link_table_name varchar2(32), '||
                   ' stop_node_map_table_name varchar2(32), '||
                   ' node_schedule_table_name varchar2(32), '||
                   ' connect_link_table_name varchar2(32), '||
                   ' transfer_link_table_name varchar2(32), '||
                   ' link_type_table_name varchar2(32), ' || 
                   ' route_table_name varchar2(32)) ';
      execute immediate query_str;
      commit;     
   END create_multimodal_metadata;

   PROCEDURE create_mm_subnetwork_metadata IS
   query_str				varchar2(4096);
   table_name				varchar2(32):='MULTIMODAL_SUBNETWORK_METADATA';
   BEGIN
      if (table_exists(table_name)) then
         execute immediate 'drop table ' || table_name || ' purge';
      end if;
      query_str := 'CREATE TABLE ' || table_name ||
                   ' (network_name varchar2(32), '||
                   ' subnetwork_name varchar2(32), '||
                   ' subnetwork_id number, '||
                   ' agency_table_name varchar2(32),'||
                   ' calendar_table_name varchar2(32), '||
                   ' route_table_name varchar2(32), '||
                   ' shape_table_name varchar2(32), '||
                   ' stop_times_table_name varchar2(32), '||
                   ' stop_table_name varchar2(32), '||
                   ' trip_table_name varchar2(32), '||
                   ' schedule_id_table_name varchar2(32), '||
                   ' service_node_table_name varchar2(32), '||
                   ' stop_node_map_table_name  varchar2(32), '||
                   ' service_link_table_name varchar2(32), '||
                   ' connect_link_table_name varchar2(32), '||
                   ' node_schedule_table_name varchar2(32), '||
                   ' PRIMARY KEY (network_name,subnetwork_name))';
      execute immediate query_str;
   END create_mm_subnetwork_metadata;

   PROCEDURE insert_multimodal_metadata(network_name IN varchar2,
                                         node_table_name IN varchar2,
                                         link_table_name IN varchar2,
                                         base_network_name IN varchar2,
                                         base_node_table_name IN varchar2,
                                         base_link_table_name IN varchar2,
                                         service_node_table_name IN varchar2,
                                         service_link_table_name IN varchar2,
                                         stop_node_map_table_name IN varchar2,
                                         node_schedule_table_name IN varchar2,
                                         connect_link_table_name IN varchar2,
                                         transfer_link_table_name IN varchar2,
                                         link_type_table_name IN varchar2,
                                         route_table_name IN varchar2,
                                         log_loc IN varchar2,
                                         log_file IN varchar2,
                                         open_mode IN varchar2) IS
   query_str 					varchar2(4096);
   table_name					varchar2(32);
   mm_log_file                                 	utl_file.file_type := NULL;
   BEGIN
      mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
      mm_util.set_log_info(mm_log_file);
      table_name := 'NDM_MULTIMODAL_METADATA';
      if (not(table_exists(table_name))) then
         mm_util.log_message('Metadata table does not exist!!',true);
         mm_util.log_message('Create the table and then proceed to insert metadata',false);
         return;
      end if;

      query_str := 'DELETE FROM ' || table_name || ' WHERE ' ||
                   ' network_name = :a';
      execute immediate query_str using UPPER(network_name);

      query_str := 'INSERT INTO ' || table_name ||
                   ' (network_name,'||
                   ' node_table_name,'||
                   ' link_table_name, '||
                   ' base_network_name, '||
                   ' base_node_table_name,'||
                   ' base_link_table_name,'||
                   ' service_node_table_name,'||
                   ' service_link_table_name,'||
                   ' stop_node_map_table_name, '||
                   ' node_schedule_table_name, '||
                   ' connect_link_table_name,'||
                   ' transfer_link_table_name,'||
                   ' link_type_table_name, '||
                   ' route_table_name) '||
                   ' VALUES ' ||
                   ' (:c1,:c2,:c3,:c4,:c5,:c6,:c7,:c8,:c9,'||
                   ' :c10,:c11, :c12, :c13, :c14) ';
       execute immediate query_str using network_name, 
                                         node_table_name,
                                         link_table_name,
                                         base_network_name,
                                         base_node_table_name,
                                         base_link_table_name,
                                         service_node_table_name,
                                         service_link_table_name,
                                         stop_node_map_table_name,
                                         node_schedule_table_name,
                                         connect_link_table_name,
                                         transfer_link_table_name,
                                         link_type_table_name,
                                         route_table_name;
      commit;
      mm_util.log_message('**** Metadata values inserted ****',true);
      utl_file.fclose(mm_log_file);
   END insert_multimodal_metadata;

   PROCEDURE insert_mm_subnetwork_metadata(network_name IN varchar2,
                                           subnetwork_name IN varchar2,
                                           subnetwork_id IN number,
                                           agency_table_name IN varchar2,
                                           calendar_table_name IN varchar2,
                                           route_table_name IN varchar2, 
                                           shape_table_name IN varchar2, 
                                           stop_times_table_name IN varchar2,
                                           stop_table_name IN varchar2,
                                           trip_table_name IN varchar2,
                                           schedule_id_table_name varchar2,
                                           service_node_table_name IN varchar2,
                                           stop_node_map_table_name  varchar2,
                                           service_link_table_name IN varchar2,
                                           connect_link_table_name IN varchar2,
                                           node_schedule_table_name IN varchar2,
                                           log_loc IN varchar2,
                                           log_file IN varchar2,
                                           open_mode IN varchar2) IS
   query_str					varchar2(4096);
   table_name					varchar2(32);
   mm_log_file                                  utl_file.file_type := NULL;
   BEGIN
      mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
      mm_util.set_log_info(mm_log_file);
      table_name := 'MULTIMODAL_SUBNETWORK_METADATA';
      if (not(table_exists(table_name))) then
         mm_util.log_message('Subnetwork Metadata table does not exist!!',true);
         mm_util.log_message('Create the table and then proceed to insert metadata',false);
         mm_util.log_message('(using create_mm_subnetwork_metadata procedure)', false);
         return;
      end if;

      query_str := 'DELETE FROM '||table_name||
                   ' WHERE subnetwork_name = :a';
      execute immediate query_str using upper(subnetwork_name);
      commit;

      query_str := 'INSERT INTO ' || table_name || 
                   ' (network_name, '||
                   ' subnetwork_name, subnetwork_id, '||
                   ' agency_table_name, calendar_table_name, '||
                   ' route_table_name, shape_table_name, '||
                   ' stop_times_table_name, stop_table_name,'||
                   ' trip_table_name, schedule_id_table_name, '||
                   ' service_node_table_name,  stop_node_map_table_name,'|| 
                   ' service_link_table_name, '||
                   ' connect_link_table_name, node_schedule_table_name) '||
                   ' VALUES ' || ' (:a,:b,:c,:d,:e,:f,:g,:h,:i,:j,:k,:l,:m,:n,:o,:p) ';
      execute immediate query_str using network_name, 
                                        subnetwork_name, subnetwork_id,
                                        agency_table_name, calendar_table_name,
                                        route_table_name, shape_table_name,
                                        stop_times_table_name, stop_table_name,
                                        trip_table_name, schedule_id_table_name,
                                        service_node_table_name, stop_node_map_table_name,
                                        service_link_table_name, 
                                        connect_link_table_name, node_schedule_table_name;
      commit;
      mm_util.log_message('Metadata inserted for subnetwork '||subnetwork_name||
                          '; network '||network_name, false);
      utl_file.fclose(mm_log_file);
   END insert_mm_subnetwork_metadata;

   FUNCTION get_mm_node_table_name(network_name IN varchar2) RETURN varchar2 IS
   query_str 					varchar2(512);
   network					varchar2(32);
   node_table_name				varchar2(32);
   BEGIN
      network := upper(network_name);
      query_str := 'SELECT node_table_name FROM ndm_multimodal_metadata ' ||
                   ' WHERE network_name = :a';
      execute immediate query_str into node_table_name using network;
      return node_table_name;
   END get_mm_node_table_name;

   FUNCTION get_mm_link_table_name(network_name IN varchar2) RETURN varchar2 IS 
   query_str 					varchar2(512);
   network					varchar2(32);
   link_table_name				varchar2(32);
   BEGIN
      network := upper(network_name);
      query_str := 'SELECT link_table_name FROM ndm_multimodal_metadata ' ||
                   ' WHERE network_name = :a';
      execute immediate query_str into link_table_name using network;
      return link_table_name;
   END get_mm_link_table_name;

   FUNCTION get_base_network_name(network_name IN VARCHAR2) RETURN varchar2 IS
   query_str					varchar2(512);
   network                                      varchar2(32);
   base_network_name				varchar2(32);
   BEGIN
      network := UPPER(network_name);
      query_str := 'SELECT base_network_name FROM ndm_multimodal_metadata '||
                   ' WHERE network_name = :n ';
      execute immediate query_str into base_network_name using network;
      return base_network_name;
   
   END get_base_network_name;

   FUNCTION get_base_node_table_name(network_name IN varchar2) RETURN varchar2 IS
   query_str					varchar2(512);
   network					varchar2(32);
   base_node_table_name				varchar2(32);
   BEGIN
      network := UPPER(network_name);
      query_str := 'SELECT base_node_table_name FROM ndm_multimodal_metadata '||
                   ' WHERE network_name = :n ';
      execute immediate query_str into base_node_table_name using network;
      return base_node_table_name;
   END get_base_node_table_name;

   FUNCTION get_base_link_table_name(network_name IN varchar2) RETURN varchar2 IS
   query_str                                    varchar2(512);
   network                                      varchar2(32);
   base_link_table_name                         varchar2(32);
   BEGIN
      network := UPPER(network_name);
      query_str := 'SELECT base_link_table_name FROM ndm_multimodal_metadata '||
                   ' WHERE network_name = :n ';
      execute immediate query_str into base_link_table_name using network;
      return base_link_table_name;
   END get_base_link_table_name;

   FUNCTION get_service_node_table_name(network_name IN varchar2) RETURN varchar2 IS
   query_str                                    varchar2(512);
   network                                      varchar2(32);
   srvc_node_table_name                         varchar2(32);
   BEGIN
      network := UPPER(network_name);
      query_str := 'SELECT service_node_table_name FROM ndm_multimodal_metadata '||
                   ' WHERE network_name = :n ';
      execute immediate query_str into srvc_node_table_name using network;
      return srvc_node_table_name;
   END get_service_node_table_name;

   FUNCTION get_service_link_table_name(network_name IN varchar2) RETURN varchar2 IS
   query_str                                    varchar2(512);
   network                                      varchar2(32);
   srvc_link_table_name                         varchar2(32);
   BEGIN
      network := UPPER(network_name);
      query_str := 'SELECT service_link_table_name FROM ndm_multimodal_metadata '||
                   ' WHERE network_name = :n ';
      execute immediate query_str into srvc_link_table_name using network;
      return srvc_link_table_name;
   END get_service_link_table_name;

   FUNCTION get_stop_node_map_table_name(network_name IN varchar2) RETURN varchar2 IS
   query_str					varchar2(512);
   network					varchar2(32);
   map_table_name				varchar2(32);
   BEGIN
      network := upper(network_name);
      query_str := 'SELECT stop_node_map_table_name FROM ndm_multimodal_metadata '||
                   ' WHERE network_name = :n';
      execute immediate query_str into map_table_name using network;
      return map_table_name;
   END get_stop_node_map_table_name;

   FUNCTION get_node_schedule_table_name(network_name IN varchar2) RETURN varchar2 IS
   query_str                                    varchar2(512);
   network                                      varchar2(32);
   table_name                               varchar2(32);
   BEGIN
      network := upper(network_name);
      query_str := 'SELECT node_schedule_table_name FROM ndm_multimodal_metadata '||
                   ' WHERE network_name = :n';
      execute immediate query_str into table_name using network;
      return table_name;
   END get_node_schedule_table_name;

   FUNCTION get_connect_link_table_name(network_name IN varchar2) RETURN varchar2 IS
   query_str                                    varchar2(512);
   network                                      varchar2(32);
   ct_link_table_name                         	varchar2(32);
   BEGIN
      network := UPPER(network_name);
      query_str := 'SELECT connect_link_table_name FROM ndm_multimodal_metadata '||
                   ' WHERE network_name = :n ';
      execute immediate query_str into ct_link_table_name using network;
      return ct_link_table_name;
   END get_connect_link_table_name;

   FUNCTION get_transfer_link_table_name(network_name IN varchar2) RETURN varchar2 IS
   query_str                                    varchar2(512);
   network                                      varchar2(32);
   tr_link_table_name                         	varchar2(32);
   BEGIN
      network := UPPER(network_name);
      query_str := 'SELECT transfer_link_table_name FROM ndm_multimodal_metadata '||
                   ' WHERE network_name = :n ';
      execute immediate query_str into tr_link_table_name using network;
      return tr_link_table_name;
   END get_transfer_link_table_name;

   FUNCTION get_link_type_table_name(network_name IN varchar2) RETURN varchar2 IS
   query_str					varchar2(512);
   network					varchar2(32);
   ltype_table_name				varchar2(32);
   BEGIN
      network := upper(network_name);
      query_str := 'SELECT link_type_table_name FROM ndm_multimodal_metadata ' ||
                   ' WHERE upper(network_name) = :n';
      execute immediate query_str into ltype_table_name using network_name;
      return ltype_table_name;
   END get_link_type_table_name;

   FUNCTION get_route_table_name(network_name IN VARCHAR2) RETURN varchar2 IS
   query_str                                    varchar2(512);
   network                                      varchar2(32);
   table_name					varchar2(32);
   BEGIN
      network := upper(network_name);
      query_str := 'SELECT route_table_name FROM ndm_multimodal_metadata ' ||
                   ' WHERE upper(network_name) = :n';
       execute immediate query_str into table_name using network_name;
       return table_name;
   END get_route_table_name;

   FUNCTION get_agency_table_name(network_name IN varchar2,
                                  subnetwork_name IN varchar2) RETURN varchar2 IS
   query_str          				varchar2(512);
   network              	                varchar2(32);
   subnetwork                                   varchar2(32);
   agency_table_name  	                        varchar2(32);
   BEGIN
      network := UPPER(network_name);
      subnetwork := UPPER(subnetwork_name);
      query_str := 'SELECT agency_table_name FROM multimodal_subnetwork_metadata '||
                   ' WHERE network_name = :n AND subnetwork_name = :s ';
      execute immediate query_str into agency_table_name using network, subnetwork;
      return agency_table_name;
   END get_agency_table_name;

   FUNCTION get_calendar_table_name(network_name IN varchar2,
                                    subnetwork_name IN varchar2) RETURN varchar2 IS
   query_str                                    varchar2(512);
   network                                      varchar2(32);
   subnetwork                                   varchar2(32);
   calendar_table_name                          varchar2(32);
   BEGIN
      network := UPPER(network_name);
      subnetwork := UPPER(subnetwork_name);
      query_str := 'SELECT calendar_table_name FROM multimodal_subnetwork_metadata '||
                   ' WHERE network_name = :n  AND subnetwork_name = :s ';
      execute immediate query_str into calendar_table_name using network, subnetwork;
      return calendar_table_name;
   END get_calendar_table_name;

   FUNCTION get_sub_route_table_name(network_name IN varchar2, 
                                 subnetwork_name IN varchar2) RETURN varchar2 IS
   query_str                                    varchar2(512);
   network                                      varchar2(32);
   subnetwork                                   varchar2(32);
   route_table_name                             varchar2(32);
   BEGIN
      network := UPPER(network_name);
      subnetwork := UPPER(subnetwork_name);
      query_str := 'SELECT route_table_name FROM multimodal_subnetwork_metadata '||
                   ' WHERE network_name = :n  AND subnetwork_name = :s ';
      execute immediate query_str into route_table_name using network, subnetwork;
      return route_table_name;
   END get_sub_route_table_name;

   FUNCTION get_shape_table_name(network_name IN varchar2,
                                 subnetwork_name IN varchar2) RETURN varchar2 IS
   query_str                                    varchar2(512);
   network                                      varchar2(32);
   subnetwork                                   varchar2(32);
   shape_table_name                             varchar2(32);
   BEGIN
      network := UPPER(network_name);
      subnetwork := UPPER(subnetwork_name);
      query_str := 'SELECT shape_table_name FROM multimodal_subnetwork_metadata '||
                   ' WHERE network_name = :n AND subnetwork_name = :s';
      execute immediate query_str into shape_table_name using network, subnetwork;
      return shape_table_name;
   END get_shape_table_name;

   FUNCTION get_stop_times_table_name(network_name IN varchar2,
                                      subnetwork_name IN varchar2) RETURN varchar2 IS
   query_str                                    varchar2(512);
   network                                      varchar2(32);
   subnetwork                                   varchar2(32);
   st_table_name                             	varchar2(32);
   BEGIN
      network := UPPER(network_name);
      subnetwork := UPPER(subnetwork_name);
      query_str := 'SELECT stop_times_table_name FROM multimodal_subnetwork_metadata '||
                   ' WHERE network_name = :n AND subnetwork_name = :s ';
      execute immediate query_str into st_table_name using network, subnetwork;
      return st_table_name;
   END get_stop_times_table_name;

   FUNCTION get_stop_table_name(network_name IN varchar2,
                                subnetwork_name IN varchar2) RETURN varchar2 IS
   query_str                    		varchar2(512);
   network                                      varchar2(32);
   subnetwork                                   varchar2(32);
   st_table_name                             	varchar2(32);
   BEGIN
      network := UPPER(network_name);
      subnetwork := UPPER(subnetwork_name);
      query_str := 'SELECT stop_table_name FROM multimodal_subnetwork_metadata '||
                   ' WHERE network_name = :n AND subnetwork_name = :s ';
      execute immediate query_str into st_table_name using network, subnetwork;
      return st_table_name;
   END get_stop_table_name;

   FUNCTION get_trip_table_name(network_name IN varchar2,
                                subnetwork_name IN varchar2) RETURN varchar2 IS
   query_str                                    varchar2(512);
   network                                      varchar2(32);
   subnetwork                                   varchar2(32);
   tr_table_name                                varchar2(32);
   BEGIN
      network := UPPER(network_name);
      subnetwork := UPPER(subnetwork_name);
      query_str := 'SELECT trip_table_name FROM multimodal_subnetwork_metadata '||
                   ' WHERE network_name = :n AND subnetwork_name = :s ';
      execute immediate query_str into tr_table_name using network, subnetwork;
      return tr_table_name;
   END get_trip_table_name;

   FUNCTION get_schedule_id_table_name(network_name IN varchar2,
                                       subnetwork_name IN varchar2) RETURN varchar2 IS
   query_str                                    varchar2(512);
   network                                      varchar2(32);
   subnetwork                                   varchar2(32);
   schid_table_name                             varchar2(32);
   BEGIN
      network := UPPER(network_name);
      subnetwork := UPPER(subnetwork_name);
      query_str := 'SELECT schedule_id_table_name FROM multimodal_subnetwork_metadata '||
                   ' WHERE network_name = :n AND subnetwork_name = :s ';
      execute immediate query_str into schid_table_name using network, subnetwork;
      return schid_table_name;
   END get_schedule_id_table_name;

   FUNCTION get_sub_service_node_table(network_name IN varchar2, 
                                       subnetwork_name IN varchar2)  RETURN varchar2 IS
   query_str                                    varchar2(512);
   network                                      varchar2(32);
   subnetwork                                   varchar2(32);
   table_name                                   varchar2(32);
   BEGIN
      network := UPPER(network_name);
      subnetwork := UPPER(subnetwork_name);
      query_str := 'SELECT service_node_table_name FROM multimodal_subnetwork_metadata ' ||
                   ' WHERE network_name = :n AND subnetwork_name = :s ';
      execute immediate query_str into table_name using network, subnetwork;
      return table_name;
   END get_sub_service_node_table;

   FUNCTION get_sub_service_link_table(network_name IN varchar2,
                                       subnetwork_name IN varchar2)  RETURN varchar2 IS
   query_str                                    varchar2(512);
   network                                      varchar2(32);
   subnetwork                                   varchar2(32);
   table_name                                   varchar2(32);
   BEGIN
      network := UPPER(network_name);
      subnetwork := UPPER(subnetwork_name);
      query_str := 'SELECT service_link_table_name FROM multimodal_subnetwork_metadata ' ||
                   ' WHERE network_name = :n AND subnetwork_name = :s ';
      execute immediate query_str into table_name using network, subnetwork;
      return table_name;
   END get_sub_service_link_table;

   FUNCTION get_sub_connect_link_table(network_name IN varchar2,
                                       subnetwork_name IN varchar2)  RETURN varchar2 IS
   query_str                                    varchar2(512);
   network                                      varchar2(32);
   subnetwork                                   varchar2(32);
   table_name                                   varchar2(32);
   BEGIN
      network := UPPER(network_name);
      subnetwork := UPPER(subnetwork_name);
      query_str := 'SELECT connect_link_table_name FROM multimodal_subnetwork_metadata ' ||
                   ' WHERE network_name = :n AND subnetwork_name = :s ';
      execute immediate query_str into table_name using network, subnetwork;
      return table_name;
   END get_sub_connect_link_table;

   FUNCTION get_sub_node_map_table(network_name IN varchar2, 
                                   subnetwork_name IN varchar2) RETURN varchar2 IS
   query_str                                    varchar2(512);
   network                                      varchar2(32);
   subnetwork                                   varchar2(32);
   table_name                                   varchar2(32);
   BEGIN
      network := UPPER(network_name);
      subnetwork := UPPER(subnetwork_name);
      query_str := 'SELECT stop_node_map_table_name FROM multimodal_subnetwork_metadata ' ||
                   ' WHERE network_name = :n AND subnetwork_name = :s ';
      execute immediate query_str into table_name using network, subnetwork;
      return table_name;
   END get_sub_node_map_table;

   FUNCTION get_sub_node_sch_table(network_name IN varchar2,
                                   subnetwork_name IN varchar2) RETURN varchar2 IS
   query_str                                    varchar2(512);
   network                                      varchar2(32);
   subnetwork                                   varchar2(32);
   table_name                                   varchar2(32);
   BEGIN
      network := UPPER(network_name);
      subnetwork := UPPER(subnetwork_name);
      query_str := 'SELECT node_schedule_table_name FROM multimodal_subnetwork_metadata ' ||
                   ' WHERE network_name = :n AND subnetwork_name = :s ';
      execute immediate query_str into table_name using network, subnetwork;
      return table_name;
   END get_sub_node_sch_table;

--
-- Create route table for the entire network
--
   PROCEDURE create_mm_route_table(network_name IN VARCHAR2,
                                   output_table IN VARCHAR2,
                                   log_loc IN VARCHAR2,
                                   log_file IN VARCHAR2,
                                   open_mode IN VARCHAR2) IS
   route_table					VARCHAR2(32);
   query_str					VARCHAR2(512);
   subnetwork_names				sdo_string_array;
   subnetwork					VARCHAR2(32);
   subnet_route_table				VARCHAR2(32);
   tables_str					VARCHAR2(512);
   mm_log_file                                  utl_file.file_type := NULL;
   BEGIN
      mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
      mm_util.set_log_info(mm_log_file);
   
      mm_util.log_message('**** START : Create Route Table',true);
      route_table := output_table;
      if (trim(route_table) is null) then
         route_table := network_name || '_ROUTE$';
      end if;

      query_str := 'SELECT subnetwork_name FROM multimodal_subnetwork_metadata ' ||
                   ' WHERE upper(network_name) = :a';
      execute immediate query_str bulk collect into subnetwork_names 
                                           using upper(network_name);
      tables_str := '';
      for i in 1 .. subnetwork_names.count loop
         subnetwork := subnetwork_names(i);
         subnet_route_table := get_sub_route_table_name(network_name, subnetwork);
         tables_str := tables_str || ' SELECT * FROM ' || subnet_route_table || ' ';
         if (i < subnetwork_names.count) then
            tables_str := tables_str || ' UNION ALL ';
         end if;
      end loop;

      query_str := 'CREATE OR REPLACE VIEW ' || route_table || ' AS ' ||
                   tables_str || ' NoLOGGING';
      dbms_output.put_line('Query str : '||query_str);
      execute immediate query_str;
      commit;

      query_str := 'UPDATE ndm_multimodal_metadata SET '||
                   ' route_table_name = :a ' || 
                   ' WHERE upper(network_name) = :n ';
      execute immediate query_str using route_table, upper(network_name);
      commit;

   END create_mm_route_table;

--
-- Create mm views 
--
   PROCEDURE create_mm_views(network_name IN VARCHAR2,
                             log_loc IN VARCHAR2,
                             log_file IN VARCHAR2,
                             open_mode IN VARCHAR2) IS 
   query_str						varchar2(1024);
   subnetwork_names					sdo_string_array;
   subnetwork						varchar2(32);
   tables_str						varchar2(512);
   subnet_srvc_node_table				varchar2(32);
   subnet_node_map_table				varchar2(32);
   subnet_node_sch_table                                varchar2(32);
   subnet_srvc_link_table				varchar2(32);
   subnet_conn_link_table				varchar2(32);
   subnet_route_table 					varchar2(32);
   service_node_table					varchar2(32);
   node_map_table					varchar2(32);
   service_link_table					varchar2(32);
   connect_link_table					varchar2(32);
   node_sch_table					varchar2(32);
   route_table						varchar2(32);
   BEGIN
   query_str := 'SELECT subnetwork_name FROM multimodal_subnetwork_metadata '||
                   ' WHERE upper(network_name) = :n';
      execute immediate query_str bulk collect into subnetwork_names
                                               using upper(network_name);
--    Service nodes
      tables_str := '';
      service_node_table := get_service_node_table_name(network_name);
       for i in 1 .. subnetwork_names.count loop
          subnetwork := subnetwork_names(i);
          subnet_srvc_node_table := get_sub_service_node_table(network_name, subnetwork);
          tables_str := tables_str || ' SELECT * FROM ' || subnet_srvc_node_table || ' ';
          if (i < subnetwork_names.count) then
             tables_str := tables_str || ' UNION ALL ';
          end if;
       end loop;
       if (trim(service_node_table) is null) then
          service_node_table := network_name || '_SERVICE_NODE$';
       end if;
       query_str := 'CREATE OR REPLACE VIEW ' || service_node_table || ' AS '||
                    tables_str || ' NOLOGGING';
       execute immediate query_str;
       commit;

--    Node map 
      tables_str := '';
      node_map_table := get_stop_node_map_table_name(network_name);
      for i in 1 .. subnetwork_names.count loop
         subnetwork := subnetwork_names(i);
         subnet_node_map_table := get_sub_node_map_table(network_name, subnetwork);
         tables_str := tables_str || ' SELECT * FROM ' || subnet_node_map_table || ' ';
         if (i < subnetwork_names.count) then
             tables_str := tables_str || ' UNION ALL ';
         end if;
      end loop;
       if (trim(node_map_table) is null) then
          node_map_table := network_name || '_STOP_NODE_ID_MAP';
       end if;
      query_str := 'CREATE OR REPLACE VIEW ' || node_map_table || ' AS '||
                    tables_str || ' NOLOGGING';
      execute immediate query_str;
      commit;

--  Node schedule table
    tables_str := '';
    node_sch_table := get_node_schedule_table_name(network_name);
    for i in 1 .. subnetwork_names.count loop
         subnetwork := subnetwork_names(i);
         subnet_node_sch_table := get_sub_node_sch_table(network_name, subnetwork);
         tables_str := tables_str || ' SELECT * FROM ' || subnet_node_sch_table || ' ';
         if (i < subnetwork_names.count) then
             tables_str := tables_str || ' UNION ALL ';
         end if;
    end loop;
    if (trim(node_sch_table) is null) then
        node_sch_table := network_name || '_NODE_SCH$';
    end if;
    query_str := 'CREATE OR REPLACE VIEW ' || node_sch_table || ' AS '||
                    tables_str || ' NOLOGGING';
    execute immediate query_str;
    commit;  

--   Service links view
    tables_str := ''; 
    service_link_table := get_service_link_table_name(network_name);
    for i in 1 .. subnetwork_names.count loop
         subnetwork := subnetwork_names(i);
         subnet_srvc_link_table := get_sub_service_link_table(network_name, subnetwork);
         tables_str := tables_str || ' SELECT * FROM ' || subnet_srvc_link_table || ' ';
         if (i < subnetwork_names.count) then
             tables_str := tables_str || ' UNION ALL ';
         end if;
    end loop;
    if (trim(service_link_table) is null) then
        service_link_table := network_name || '_SERVICE_LINK$';
    end if;

    query_str := 'CREATE OR REPLACE VIEW ' || service_link_table || ' AS '||
                    tables_str || ' NOLOGGING';
    execute immediate query_str;
    commit;

--  Connect links view
    tables_str := '';
    connect_link_table := get_connect_link_table_name(network_name);
    for i in 1 .. subnetwork_names.count loop
       subnetwork := subnetwork_names(i);
       subnet_conn_link_table := get_sub_connect_link_table(network_name, subnetwork);
       tables_str := tables_str || ' SELECT * FROM ' || subnet_conn_link_table || ' ';
       if (i < subnetwork_names.count) then
             tables_str := tables_str || ' UNION ALL ';
       end if;
    end loop;
    if (trim(connect_link_table) is null) then
        connect_link_table := network_name || '_CONNECT_LINK$';
    end if;

    query_str := 'CREATE OR REPLACE VIEW ' || connect_link_table || ' AS '||
                  tables_str || ' NOLOGGING';
    execute immediate query_str;
    commit;

-- Routes view 
   tables_str := '';
   route_table := get_route_table_name(network_name);
   for i in 1 .. subnetwork_names.count loop
      subnetwork := subnetwork_names(i);
      subnet_route_table := get_sub_route_table_name(network_name, subnetwork);
      tables_str := tables_str || ' SELECT * FROM ' || subnet_route_table || ' ' ;
      if (i < subnetwork_names.count) then
         tables_str := tables_str || ' UNION ALL ' ;
      end if;
   end loop;
   if (trim(route_table) is null) then
       route_table := network_name || '_ROUTE$';
   end if;
   
   query_str := 'CREATE OR REPLACE VIEW ' || route_table || ' AS ' ||
                tables_str || ' NOLOGGING';
   execute immediate query_str;
   commit;
         
   END create_mm_views;

--
-- Procedure removes a subnetwork
-- If remove_subnet_tables is set to true, all tables that exclusively
-- belong to the subnetwork will be dropped.
-- The nodes and links that correspond to the subnetwork are deleted
-- from the mm node and link tables.
-- Views for the entire multimodal network are redefined.
-- Transfer links that connect to service nodes in the deleted
-- network are deleted. These transfer links are also deleted from 
-- the MM link table
-- Partition blobs are regenerated and multimodal user data is generated.
--
   PROCEDURE remove_subnetwork(network_name IN VARCHAR2,
                               subnetwork_name IN VARCHAR2,
                               remove_subnet_tables IN BOOLEAN,
                               log_loc IN VARCHAR2,
                               log_file IN VARCHAR2,
                               open_mode IN VARCHAR2) IS
   mm_node_table				varchar2(32);
   mm_link_table				varchar2(32);
   link_type_table				varchar2(32);
   service_node_table				varchar2(32);
   service_link_table				varchar2(32);
   node_map_table				varchar2(32);
   connect_link_table				varchar2(32);
   subnet_srvc_node_table			varchar2(32);
   subnet_srvc_link_table                       varchar2(32);
   subnet_node_map_table	                varchar2(32);
   subnet_node_sch_table	                varchar2(32);
   subnet_conn_link_table			varchar2(32);
   subnet_sch_id_table				varchar2(32);
   transfer_link_table				varchar2(32);
   query_str					varchar2(1024);
   agency_table					varchar2(32);
   calendar_table				varchar2(32);
   route_table					varchar2(32);
   shape_table					varchar2(32);
   stop_times_table				varchar2(32);
   stop_table					varchar2(32);
   trip_table					varchar2(32);
   table_name					varchar2(32);
   tables_str					varchar2(512);
   subnetwork_names				sdo_string_array;
   subnetwork					varchar2(32);				
   pblob_table					varchar2(32);
   BEGIN
      mm_node_table := get_mm_node_table_name(network_name);      
      mm_link_table := get_mm_link_table_name(network_name);
      link_type_table := get_link_type_table_name(network_name);
      service_node_table := get_service_node_table_name(network_name);
      node_map_table := get_stop_node_map_table_name(network_name);
      service_link_table := get_service_link_table_name(network_name);
      connect_link_table := get_connect_link_table_name(network_name);
      transfer_link_table := get_transfer_link_table_name(network_name);

      subnet_srvc_node_table := get_sub_service_node_table(network_name, subnetwork_name);
      subnet_srvc_link_table := get_sub_service_link_table(network_name, subnetwork_name);
      subnet_conn_link_table := get_sub_connect_link_table(network_name, subnetwork_name);
      subnet_node_map_table := get_sub_node_map_table(network_name, subnetwork_name);
      subnet_node_sch_table := get_sub_node_sch_table(network_name, subnetwork_name);
      subnet_sch_id_table := get_schedule_id_table_name(network_name, subnetwork_name);

      agency_table := get_agency_table_name(network_name, subnetwork_name);
      calendar_table := get_calendar_table_name(network_name, subnetwork_name);
      route_table := get_sub_route_table_name(network_name, subnetwork_name);
      shape_table := get_shape_table_name(network_name, subnetwork_name);
      stop_times_table := get_stop_times_table_name(network_name, subnetwork_name);
      stop_table := get_stop_table_name(network_name, subnetwork_name);
      trip_table := get_trip_table_name(network_name, subnetwork_name);

      query_str := 'DELETE FROM multimodal_subnetwork_metadata '||
                   ' WHERE upper(network_name)=:n AND upper(subnetwork_name)=:s';
      execute immediate query_str using upper(network_name),
                                        upper(subnetwork_name);
      commit;

--    Remove the subnetwork service nodes from mm node table
      query_str := 'DELETE FROM ' || mm_node_table || ' WHERE ' ||
                   ' node_id IN ' || ' (SELECT node_id FROM ' ||
                   subnet_srvc_node_table || ')';
      execute immediate query_str;
      commit;

--    Remove the subnetwork service links from mm link table and link type table
      query_str := 'DELETE FROM ' || mm_link_table || ' WHERE ' ||
                   ' link_id IN ' || ' (SELECT link_id FROM ' ||
                   subnet_srvc_link_table || ')';
      execute immediate query_str;
      commit;

      query_str := 'DELETE FROM ' || link_type_table || ' WHERE ' ||
                   ' link_id IN ' || ' (SELECT link_id FROM ' ||
                   subnet_srvc_link_table || ')';
      execute immediate query_str;
      commit;

--    Remove the subnetwork connect links from mm link table and link type tablee
      query_str := 'DELETE FROM ' || mm_link_table || ' WHERE ' ||
                   ' link_id IN ' || ' (SELECT link_id FROM ' ||
                   subnet_conn_link_table || ')';
      execute immediate query_str;
      commit;

      query_str := 'DELETE FROM ' || link_type_table || ' WHERE ' ||
                   ' link_id IN ' || ' (SELECT link_id FROM ' ||
                   subnet_conn_link_table || ')';
      execute immediate query_str;
      commit;

--    Remove the subnetwork transfer links from mm link table and link type table
--    Transfer links with start or end nodes in the removed subnetwork will be removed
--    and the new set of transfer links will be added to mm links
      query_str := 'DELETE FROM ' || mm_link_table || ' WHERE ' ||
                   ' link_id IN ' || ' (SELECT link_id FROM ' ||
                   transfer_link_table || ')';
      execute immediate query_str;
      commit;

      query_str := 'DELETE FROM ' || link_type_table || ' WHERE ' ||
                   ' link_id IN ' || ' (SELECT link_id FROM ' ||
                   transfer_link_table || ')';
      execute immediate query_str;
      commit;

--    Remove the transfer links with start/end nodes in the removed subnetwork
      query_str := 'DELETE FROM ' || transfer_link_table || ' WHERE '||
                   ' start_node_id IN ' || ' (SELECT node_id FROM ' ||
                   subnet_srvc_node_table|| ')' || ' OR ' ||
                   ' end_node_id IN ' || ' (SELECT node_id FROM ' ||
                   subnet_srvc_node_table|| ')';
      execute immediate query_str;
      commit;

--    Reinsert transfer links in mm link table and link type table
      query_str := 'INSERT /*+ APPEND */ INTO ' || mm_link_table ||
                   ' (link_id, start_node_id, end_node_id,cost,'||
                   ' geometry, s) '||
                   ' SELECT link_id, start_node_id, end_node_id, '||
                   ' cost, geometry, s FROM ' || transfer_link_table;
      execute immediate query_str;
      commit;

      query_str := 'INSERT /*+ APPEND */ INTO ' || link_type_table ||
                   ' (link_id, link_type, link_category) '||
                   ' SELECT link_id, 3, ''transfer_link'' '||
                   ' FROM ' || transfer_link_table;
      execute immediate query_str;
      commit;

      if (remove_subnet_tables) then
        execute immediate 'drop table '||agency_table||' purge'; 
        execute immediate 'drop table '||calendar_table||' purge'; 
        execute immediate 'drop table '||route_table||' purge'; 
        execute immediate 'drop table '||shape_table||' purge'; 
        execute immediate 'drop table '||stop_times_table||' purge'; 
        execute immediate 'drop table '||stop_table||' purge'; 
        execute immediate 'drop table '||trip_table||' purge'; 
        execute immediate 'drop table '||subnet_srvc_node_table||' purge';
        execute immediate 'drop table '||subnet_srvc_link_table||' purge';
        execute immediate 'drop table '||subnet_node_map_table||' purge';
        execute immediate 'drop table '||subnet_node_sch_table||' purge';
        execute immediate 'drop table '||subnet_conn_link_table||' purge';
        execute immediate 'drop table '||subnet_sch_id_table||' purge';
      end if;

--    Redefine the views
      mm_util.create_mm_views(network_name, log_loc, log_file, 'a');

--    Regenerate partition blobs
      pblob_table := get_pblob_table_name(network_name);
      sdo_net.generate_partition_blobs(network_name, 1, pblob_table, true, true, log_loc, log_file ,'a');
      sdo_net.generate_partition_blobs(network_name, 2, pblob_table, true, true, log_loc, log_file ,'a');

--    Regenerate multimodal user data
      mm_util.generate_mm_user_data(network_name, log_loc, log_file, 'a');

   END remove_subnetwork;

--
-- Adds nodes of the subnetwork to the MM node table
--
   PROCEDURE add_nodes_to_mm_nodes(network_name IN VARCHAR2,
                                   subnetwork_name IN VARCHAR2,
                                   input_node_table IN VARCHAR2,
				   mm_node_table IN VARCHAR2,
				   log_loc IN VARCHAR2,
				   log_file IN VARCHAR2,
				   open_mode IN VARCHAR2) IS
   query_str					varchar2(1024);
   output_table					varchar2(32);
   node_map_table				varchar2(32);
   max_node_id					number;
   temp_table					varchar2(32);
   lrs_measure_table				varchar2(32);
   lrs_project_table				varchar2(32);
   start_date					date;
   BEGIN
      mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
      mm_util.set_log_info(mm_log_file);

      start_date := sysdate;
      output_table := mm_node_table;
      if (trim(output_table) is null) then
         output_table := network_name || '_LINK$';
      end if;
 
      if (not(table_exists(input_node_table))) then
          mm_util.log_message('*** ERROR : '||input_node_table||' DOES NOT EXIST!!',false);
          mm_util.log_message('*** Exiting the procedure.....',false);
          return;
      end if;

      if (not(table_exists(output_table))) then
          mm_util.log_message('*** ERROR : '||output_table||' DOES NOT EXIST!!',false);
          mm_util.log_message('*** Create the table and execute the procedure.....',false);
          mm_util.log_message('*** Exiting the procedure.....',false);
          return;
      end if;

      query_str := 'SELECT max(node_id) FROM ' || output_table;
      execute immediate query_str into max_node_id;

      query_str := 'INSERT /*+ APPEND */ INTO ' || output_table ||
                   ' (node_id, geometry, x, y) ' ||
                   ' SELECT node_id+:m, geometry, x, y FROM '||
                   input_node_table;
      execute immediate query_str using max_node_id;
      commit;

--    Updating node IDs in service link table
      temp_table := 'TEMP_SERVICE_NODE$';
      if (table_exists(temp_table)) then
          execute immediate 'drop table ' || temp_table || ' purge';
      end if;
      
      query_str := 'CREATE TABLE ' || temp_table ||
                    ' (node_id number, geometry sdo_geometry, '||
                    ' x number, y number) ';
      execute immediate query_str;

      query_str := 'INSERT /*+ APPEND */ INTO ' || temp_table ||
                   ' (node_id, geometry, x, y) ' ||
                   ' SELECT node_id+:m, geometry, x, y FROM '||
                   input_node_table;
      execute immediate query_str using max_node_id;
      commit;

      execute immediate 'drop table ' || input_node_table || ' purge';
      commit;

      query_str := 'ALTER TABLE ' || temp_table || ' RENAME TO ' ||
                   input_node_table;
      execute immediate query_str;
      commit;

--    Updating node IDs in stop node map table
      node_map_table := get_sub_node_map_table(network_name, subnetwork_name);
      temp_table := 'TEMP_STOP_NODE_MAP';
      if (table_exists(temp_table)) then
          execute immediate 'drop table ' || temp_table || ' purge';
      end if;
  
      query_str := 'CREATE TABLE ' || temp_table ||
                    ' (node_id number, agency_id number, '||
                    ' route_id number, stop_id number, '||
                    ' direction_id number, stop_name varchar2(256)) ';
      execute immediate query_str;

      query_str := 'INSERT /*+ APPEND */ INTO ' || temp_table ||
                   ' (node_id, agency_id, route_id, '||
                   ' stop_id, direction_id, stop_name) '||
                   ' SELECT node_id+:m, agency_id, route_id, '||
		   ' stop_id, direction_id, stop_name '||
                   ' FROM ' || node_map_table;
      execute immediate query_str using max_node_id;
      commit;

      if (table_exists(node_map_table)) then
          execute immediate 'drop table ' || node_map_table || ' purge';
      end if;

      query_str := 'ALTER TABLE ' || temp_table ||
                   ' RENAME TO ' || node_map_table;
      execute immediate query_str;
      commit;

--    Updating node IDs in LRS measure table
      lrs_measure_table := subnetwork_name||'_LRS_MEASURE$';
      temp_table := 'TEMP_LRS_MEASURE';
      if (table_exists(temp_table)) then
              execute immediate 'drop table '||temp_table||' purge';
      end if;
      query_str := 'CREATE TABLE ' ||temp_table||
                    ' (node_id number, shape_id number, '||
                    ' trip_id number, lrs_measure number)';
      execute immediate query_str;

       query_str := 'INSERT /*+ APPEND */ INTO ' || temp_table ||
                    ' (node_id, shape_id, trip_id, lrs_measure) '||
                    ' SELECT node_id+:m, shape_id, trip_id, lrs_measure ' ||
                    ' FROM ' || lrs_measure_table;
       execute immediate query_str using max_node_id;
      
       if (table_exists(lrs_measure_table)) then
             execute immediate 'drop table ' || lrs_measure_table || ' purge';
       end if;
       query_str := 'ALTER TABLE ' || temp_table ||
                    ' RENAME TO ' || lrs_measure_table;
       execute immediate query_str;
       commit;

--     Updating node IDs in LRS project table
       lrs_project_table := subnetwork_name||'_LRS_PROJECT$';
       temp_table := 'TEMP_LRS_PROJECT';
       if (table_exists(temp_table)) then
              execute immediate 'drop table '||temp_table||' purge';
       end if;
       query_str := 'CREATE TABLE ' ||temp_table||
                    ' (node_id number, shape_id number, '||
                    ' trip_id number, geometry sdo_geometry)';
       execute immediate query_str;

       query_str := 'INSERT /*+ APPEND */ INTO ' || temp_table ||
                    ' (node_id, shape_id, trip_id, geometry) '||
                    ' SELECT node_id+:m, shape_id, trip_id, geometry ' ||
                    ' FROM ' || lrs_project_table;
       execute immediate query_str using max_node_id;
       commit;

       if (table_exists(lrs_project_table)) then
             execute immediate 'drop table ' || lrs_project_table || ' purge';
       end if;
       query_str := 'ALTER TABLE ' || temp_table ||
                    ' RENAME TO ' || lrs_project_table;
       execute immediate query_str;
       commit;

      mm_util.log_message('Inserting links from '||input_node_table||' in ' || output_table || ' took ' || to_char((sysdate-start_date)*24*60,'99999.999') || ' min.',false);

   END add_nodes_to_mm_nodes;

--
-- Add subnetwork links to MM links table
--  
--
   PROCEDURE add_links_to_mm_links(network_name IN VARCHAR2,
                                   subnetwork_name IN VARCHAR2,
                                   input_link_table IN VARCHAR2,
                                   mm_link_table IN VARCHAR2,
                                   include_geometry IN boolean,
                                   include_s IN boolean,
                                   log_loc IN VARCHAR2,
                                   log_file IN VARCHAR2,
                                   open_mode IN VARCHAR2) IS
    mm_log_file                                 utl_file.file_type := NULL;
    start_date                                  date;
    tmp_date                                    date;
    output_table                                varchar2(32);
    columns_str                                 varchar2(512);
    ins_columns_str                             varchar2(512);
    create_columns                              varchar2(512);
    query_str                                   varchar2(1024);
    max_link_id                                 number;
    temp_table	                                varchar2(32);
    BEGIN
       mm_log_file := utl_file.fopen(log_loc,log_file,open_mode);
       mm_util.set_log_info(mm_log_file);
       output_table := mm_link_table;

       start_date := sysdate;
       if (output_table is null) then
          output_table := network_name||'_LINK$';
       end if;

       if (not(table_exists(input_link_table))) then
          mm_util.log_message('*** ERROR : '||input_link_table||' DOES NOT EXIST!!',false);
          mm_util.log_message('*** Exiting the procedure.....',false);
          return;
       end if;

       if (not(table_exists(output_table))) then
          mm_util.log_message('*** ERROR : '||output_table||' DOES NOT EXIST!!',false);
          mm_util.log_message('*** Create the table and execute the procedure.....',false);
          mm_util.log_message('*** Exiting the procedure.....',false);
          return;
       end if;

       columns_str := ' link_id+:m,start_node_id,end_node_id,cost ';
       ins_columns_str := ' link_id,start_node_id,end_node_id,cost ';
       create_columns := ' link_id number,start_node_id number,end_node_id number,cost number ';
       if (include_geometry) then
          columns_str := columns_str||',geometry ';
          ins_columns_str := ins_columns_str||',geometry ';
          create_columns := create_columns||', geometry sdo_geometry ';
       end if;

       if (include_s) then
          columns_str := columns_str||' ,s ';
          ins_columns_str := ins_columns_str||' ,s ';
          create_columns := create_columns||' ,s ';
       end if;

       query_str := 'SELECT max(link_id) FROM ' || output_table;
       execute immediate query_str into max_link_id;

       query_str := 'INSERT /*+ APPEND */ INTO ' || output_table ||
                    ' ( ' || ins_columns_str || ' ) ' ||
                    ' SELECT ' || columns_str || ' FROM ' ||
                    input_link_table;
       execute immediate query_str using max_link_id;
       commit;

--     Updating link IDs in input link table
       temp_table := 'TEMP_LINKS';
       if (table_exists(temp_table)) then
          execute immediate 'drop table ' || temp_table || ' purge';
       end if;

       query_str := 'CREATE TABLE ' || temp_table || create_columns;
       execute immediate query_str;

       query_str := 'INSERT /*+ APPEND */ INTO ' || temp_table ||
                    ' ( '|| ins_columns_str || ' ) ' ||
                    ' SELECT ' || columns_str || ' FROM ' || 
                    input_link_table;
       execute immediate query_str using max_link_id;
       commit;

       execute immediate 'drop table ' || input_link_table || ' purge';
       commit;

       query_str := 'ALTER TABLE ' || temp_table ||
                    ' RENAME TO ' || input_link_table;
       execute immediate query_str;
       commit;

       mm_util.log_message('Inserting links from '||input_link_table||' in ' || output_table || ' took ' || to_char((sysdate-start_date)*24*60,'99999.999') || ' min.',false);
    END add_links_to_mm_links;
--
-- Add a subnetwork
--
   PROCEDURE add_subnetwork(network_name IN VARCHAR2,
                            base_network_name IN VARCHAR2,
                            subnetwork_name IN VARCHAR2,
                            transfer_radius IN VARCHAR2,
                            walking_speed IN VARCHAR2,
                            config_file_loc in VARCHAR2,
                            config_file IN VARCHAR2,
                            log_loc IN VARCHAR2,
                            log_file IN VARCHAR2,
                            open_mode IN VARCHAR2) IS
   query_str 						varchar2(1024);
   sub_service_node_table				varchar2(32);
   sub_node_map_table					varchar2(32);
   sub_service_link_table				varchar2(32);
   sub_conn_link_table					varchar2(32);
   transfer_link_table					varchar2(32);
   link_type_table					varchar2(32);
   mm_node_table					varchar2(32);
   mm_link_table					varchar2(32);
   pblob_table						varchar2(32);
   BEGIN
      query_str := 'INSERT INTO multimodal_subnetwork_metadata ' ||
                   ' (network_name, subnetwork_name) ' ||
                   ' VALUES (:n, :sn) ';
      execute immediate query_str using network_name, subnetwork_name;
      commit;

      sub_service_node_table := subnetwork_name||'_SERVICE_NODE$';
      sub_node_map_table := subnetwork_name||'_STOP_NODE_ID_MAP';

--    Create service nodes
      mm_util.create_nodes_for_subnetwork(network_name, base_network_name, subnetwork_name, sub_service_node_table, sub_node_map_table, log_loc, log_file, 'a');
      mm_util.create_lrs_measures_for_stops(network_name, subnetwork_name, log_loc, log_file, 'a');
      
--    Update subnetwork metadata with service node table and node map table
      query_str := 'UPDATE multimodal_subnetwork_metadata '||
                   ' SET service_node_table_name = :a '||
                   ' WHERE upper(network_name) = :b AND upper(subnetwork_name) = :c ';
      execute immediate query_str using sub_service_node_table, network_name, subnetwork_name;
      commit;

      query_str := 'UPDATE multimodal_subnetwork_metadata '||
                   ' SET stop_node_map_table_name = :a '||
                   ' WHERE upper(network_name) = :b AND upper(subnetwork_name) = :c ';
      execute immediate query_str using sub_node_map_table, network_name, subnetwork_name;
      commit;
      
--    Add service nodes to MM  node table
      mm_node_table := get_mm_node_table_name(network_name);
      mm_util.add_nodes_to_mm_nodes(network_name, subnetwork_name, sub_service_node_table, mm_node_table, log_loc, log_file, 'a');

--    Create service links
      sub_service_link_table := subnetwork_name || '_SERVICE_LINK$';
      mm_util.create_subnet_service_links(network_name, subnetwork_name, sub_service_link_table, log_loc, log_file, 'a'); 

--    Update subnetwork metadata with service link table
      query_str := 'UPDATE multimodal_subnetwork_metadata '||
                   ' SET service_link_table_name = :a '||
                   ' WHERE upper(network_name) = :b AND upper(subnetwork_name) = :c ';
      execute immediate query_str using sub_service_link_table, network_name, subnetwork_name;
      commit;

--    Add service links to MM links table
      mm_link_table := get_mm_link_table_name(network_name);
      mm_util.add_links_to_mm_links(network_name, subnetwork_name, sub_service_link_table, mm_link_table, true, false, log_loc, log_file, 'a');

--    Create connect links
      sub_conn_link_table := subnetwork_name || '_CONNECT_LINK$';
      mm_util.create_subnet_connect_links(network_name, subnetwork_name, sub_conn_link_table, log_loc, log_file, 'a'); 
 
--   Update subnetwork metadata with connect link table
     query_str := 'UPDATE multimodal_subnetwork_metadata '||
                   ' SET connect_link_table_name = :a '||
                   ' WHERE upper(network_name) = :b AND upper(subnetwork_name) = :c ';
      execute immediate query_str using sub_conn_link_table, network_name, subnetwork_name;
      commit;

--   Add connect links to MM links table
     mm_util.add_links_to_mm_links(network_name, subnetwork_name, sub_conn_link_table, mm_link_table, true, true, log_loc, log_file, 'a');

--   Link type table
     link_type_table := get_link_type_table_name(network_name);
     mm_util.create_link_type_table(network_name, link_type_table, log_loc, log_file, 'a');

--   Create transfer links
     transfer_link_table := get_transfer_link_table_name(network_name);
     mm_util.create_transfer_links(network_name, transfer_link_table, transfer_radius, walking_speed, config_file_loc, config_file, log_loc, log_file, 'a');
     
--   Redefine views
     create_mm_views(network_name, log_loc, log_file, 'a'); 

--   Regenerate partition blobs
     pblob_table := get_pblob_table_name(network_name);
     sdo_net.generate_partition_blobs(network_name, 1, pblob_table, true, true, log_loc, log_file ,'a');
     sdo_net.generate_partition_blobs(network_name, 2, pblob_table, true, true, log_loc, log_file ,'a');

--   Regenerate multimodal user data
     mm_util.generate_mm_user_data(network_name, log_loc, log_file, 'a');

   END add_subnetwork;

END mm_util;
/
grant execute on mm_util to public;
show error;
