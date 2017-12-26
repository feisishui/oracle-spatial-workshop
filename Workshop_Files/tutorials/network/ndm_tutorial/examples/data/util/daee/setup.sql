Rem
Rem $Header: sdo/demo/network/examples/data/util/daee/setup.sql /main/1 2012/03/08 05:58:44 begeorge Exp $
Rem
Rem setup.sql
Rem
Rem Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved. 
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
Rem    begeorge    03/07/12 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

set echo on

-- drop user DAEE, if exists
DROP USER daee CASCADE;

-- create the tablespace daee_poa; change the directory of dbf file suitably
create bigfile tablespace daee_poa datafile 'daee_poa.dbf' size 128M autoextend on;

-- Create user daee
create user daee identified by daee default tablespace daee_poa quota unlimited on daee_poa;

grant connect, resource, create view to daee;

-- delete SRID 81989002, if it exists
delete from MDSYS.SDO_COORD_REF_SYStem where srid = 81989002;

-- Insert SRID = 81989002
insert into MDSYS.SDO_COORD_REF_SYStem (
       SRID,
       COORD_REF_SYS_NAME,
       COORD_REF_SYS_KIND,
       COORD_SYS_ID,
       DATUM_ID,
       GEOG_CRS_DATUM_ID,
       SOURCE_GEOG_SRID,
       PROJECTION_CONV_ID,
       CMPD_HORIZ_SRID,
       CMPD_VERT_SRID,
       INFORMATION_SOURCE,
       DATA_SOURCE,
       IS_LEGACY,
       LEGACY_CODE,
       LEGACY_WKTEXT,
       LEGACY_CS_BOUNDS,
       IS_VALID,
       SUPPORTS_SDO_GEOMETRY)
     VALUES (
       81989002,
       'Gauss Krueger (Porto Alegre)',
       'PROJECTED',
       4530,
       NULL,
       6225,
       4225,
       16377,
       NULL,
       NULL,
       'GEMPI',
       'EPSG',
       'TRUE',
       NULL,
      'PROJCS[
         "GaussKruger_POA",
         GEOGCS[
           "GK_CartaGeral",
           DATUM[
             "<custom>",
             SPHEROID[
               "International_1924",
               6378388.0,
               297.0]],
           PRIMEM["Greenwich",0.0],
           UNIT["Decimal Degree",0.0174532925199433]],
         PROJECTION["Transverse Mercator"],
         PARAMETER["False_Easting",200000.0],
         PARAMETER["False_Northing",5000000.0],
         PARAMETER["Central_Meridian",-51.0],
         PARAMETER["Scale_Factor",1.0],
         PARAMETER["Latitude_Of_Origin",0.0],
         UNIT["Meter",1.0]]',
       NULL,
       'TRUE',
       'TRUE');

commit;

select sdo_cs.transform(
 SDO_GEOMETRY( 2001, 4326, SDO_POINT_TYPE( -51, 0, NULL), NULL, NULL), 81989002)
from dual;

commit;

-- Import data;
host imp daee/daee file=DAEE_ENTIRE_SCHEMA.DMP full=y ignore=y;

-- ***** IF YOU ARE USING DATABASE VERSION 12.1.0.0.1 *****
-- Create a directory object and make sure that the dmp file is in the 
-- directory corresponding to this directory object.
-- Example :
-- Login as user SYS
-- create or replace directory WORK_DIR as '/tmp';
-- grant read,write on directory WORK_DIR to daee;
-- commit;
-- To import use the command (make sure dmp file is in WORK_DIR) :
-- host impdp daee/daee dumpfile=DAEE_ENTIRE_SCHEMA.DMP directory=WORK_DIR version=12.1.0.0.1;

conn daee/daee

insert into USER_SDO_NETWORK_METADATA
(NETWORK,
 NETWORK_CATEGORY,
 GEOMETRY_TYPE,
 NETWORK_TYPE,
 NODE_TABLE_NAME,
 NODE_GEOM_COLUMN,
 LINK_TABLE_NAME,
 LINK_GEOM_COLUMN,
 LINK_DIRECTION,
 LINK_COST_COLUMN,
 PARTITION_TABLE_NAME,
 PARTITION_BLOB_TABLE_NAME,
 NODE_LEVEL_TABLE_NAME,
 USER_DEFINED_DATA)
values
('DAEE',
 'SPATIAL',
 'SDO_GEOMETRY',
 'WATER',
 'DAEE_NODE$',
 'GEOMETRY',
 'DAEE_LINK$',
 'GEOMETRY',
 'DIRECTED',
 'LINK_COST',
 'DAEE_PART$',
 'DAEE_PBLOB$',
 'DAEE_NLVL$',
 'Y');

commit;

-- Insert rows in geom metadata and create indexes
@create_indexes.sql;

commit;

create table node nologging as
select t1.node_id node_id, t1.geometry geometry, t2.partition_id
from daee_node$ t1, daee_part$ t2
where t1.node_id = t2.node_id;
commit;

-- Insert user data metadata rows
insert into user_sdo_network_user_data
(network, table_type, data_name, data_type)
values
('DAEE', 'LINK', 'LINK_LEVEL', 'NUMBER');

insert into user_sdo_network_user_data
(network, table_type, data_name, data_type)
values
('DAEE', 'NODE', 'X', 'NUMBER');

insert into user_sdo_network_user_data
(network, table_type, data_name, data_type)
values
('DAEE', 'NODE', 'Y', 'NUMBER');

commit;

-- Insert content of styles, themes and maps tables into corresponding mapviewer table
insert into USER_SDO_STYLES select * from BKP_STYLES;
insert into USER_SDO_THEMES select * from BKP_THEMES;
insert into USER_SDO_MAPS select * from BKP_MAPS;
commit;

-- Import the map tile layers
host imp daee/daee file=daee_cached_maps.dmp full=y ignore=y;
commit;

insert into USER_SDO_CACHED_MAPS select * from DAEE_CACHED_MAPS;
commit;

