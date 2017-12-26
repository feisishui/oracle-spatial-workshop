--
-- Cleanup
--

-- Use this script to remove all traces from the workshop
-- Will remove all tables, views, metadata, etc created during the workshop
--

-- NOTE: You can ignore any errors due to non-existing structures>

drop table US_STATES purge;
drop table US_RIVERS purge;
drop table US_PARKS purge;
drop table US_INTERSTATES purge;
drop table US_COUNTIES purge;
drop table US_CITIES purge;
drop table US_STREETS purge;
drop table US_POIS purge;
drop table US_BLOCKGROUPS purge;
drop table WORLD_COUNTRIES purge;
drop table WORLD_CONTINENTS purge;

drop table US_STATES_P purge;
drop table US_RIVERS_P purge;
drop table US_PARKS_P purge;
drop table US_INTERSTATES_P purge;
drop table US_COUNTIES_P purge;
drop table US_CITIES_P purge;

-- Advanced indexing
drop table YELLOW_PAGES purge;
drop table YELLOW_PAGES_PART purge;
drop table PARTITIONING_GRID purge;
drop table YELLOW_PAGES_PART_SPATIAL purge;
drop table US_CITIES_XY purge;

-- Network
drop table NET_NODES purge;
drop table NET_LINKS purge;
drop table NET_PARTITIONS purge;
drop table NET_PARTITIONS_BLOBS purge;
drop table NET_PATHS purge;
drop table NET_PATH_LINKS purge;

-- Router
drop table EDGE purge;
drop table NODE purge;
drop table PARTITION purge;
drop table SIGN_POST purge;
drop table SDO_ROUTER_DATA_VERSION purge;
drop VIEW ROUTE_SF_LINK$;
drop VIEW ROUTE_SF_NODE$;
drop VIEW ROUTE_SF_PART$;
drop VIEW ROUTE_SF_PBLOB$;

-- Geocoding
drop table GC_PARSER_PROFILES purge;
drop table GC_PARSER_PROFILEAFS purge;
drop table GC_COUNTRY_PROFILE purge;

drop table GC_ROAD_SEGMENT_US purge;
drop table GC_ROAD_US purge;
drop table GC_POSTAL_CODE_US purge;
drop table GC_POI_US purge;
drop table GC_INTERSECTION_US purge;
drop table GC_AREA_US purge;
drop table GC_ADDRESS_POINT_US purge;

drop table GC_ROAD_SEGMENT_UK purge;
drop table GC_ROAD_UK purge;
drop table GC_POSTAL_CODE_UK purge;
drop table GC_POI_UK purge;
drop table GC_INTERSECTION_UK purge;
drop table GC_AREA_UK purge;

drop table GC_ROAD_SEGMENT_NL purge;
drop table GC_ROAD_NL purge;
drop table GC_POSTAL_CODE_NL purge;
drop table GC_POI_NL purge;
drop table GC_INTERSECTION_NL purge;
drop table GC_AREA_NL purge;

drop table GC_ROAD_SEGMENT_FR purge;
drop table GC_ROAD_FR purge;
drop table GC_POSTAL_CODE_FR purge;
drop table GC_POI_FR purge;
drop table GC_INTERSECTION_FR purge;
drop table GC_AREA_FR purge;

drop table GC_ROAD_SEGMENT_DE purge;
drop table GC_ROAD_DE purge;
drop table GC_POSTAL_CODE_DE purge;
drop table GC_POI_DE purge;
drop table GC_INTERSECTION_DE purge;
drop table GC_AREA_DE purge;

drop table GC_ROAD_SEGMENT_BE purge;
drop table GC_ROAD_BE purge;
drop table GC_POSTAL_CODE_BE purge;
drop table GC_POI_BE purge;
drop table GC_INTERSECTION_BE purge;
drop table GC_AREA_BE purge;

-- Georaster
drop table US_RASTERS purge;
drop table US_RASTERS_RDT_01 purge;
drop table US_SRTM purge;
drop table US_SRTM_RDT_01 purge;

-- 3D
drop table BUILDING_FOOTPRINTS purge;
drop table BUILDINGS_EXT purge;
drop table BUILDINGS purge;

-- LRS
drop table US_ROAD_CONDITIONS purge;
drop table US_INTERSTATES_LRS purge;
drop view  US_INTERSTATES_LRS_CONDITION;

-- WS
drop table OLS_DIR_SYNONYMS purge;
drop table OLS_DIR_CATEGORIZATIONS purge;
drop table OLS_DIR_BUSINESSES purge;
drop table OLS_DIR_BUSINESS_CHAINS purge;
drop table OLS_DIR_CATEGORIES purge;
drop table OLS_DIR_CATEGORY_TYPES purge;

-- All metadata
delete from user_sdo_geom_metadata;
delete from user_sdo_network_metadata;
delete from user_sdo_network_user_data;
delete from user_sdo_cached_maps;
delete from user_sdo_maps;
delete from user_sdo_themes;
delete from user_sdo_styles;
commit;

-- Procedures and packages
drop PROCEDURE FORMAT_GEO_ADDR;
drop PROCEDURE FORMAT_ADDR_ARRAY;
drop PACKAGE SDO_TOOLS;
drop JAVA CLASS "SdoTest";
drop PACKAGE BODY SDO_TEST;
drop PACKAGE SDO_TEST;

-- XDB Repository
exec DBMS_XDB.deleteresource('/public/Buildings/', dbms_xdb.delete_recursive_force);

-- Clear the recycle bin
purge recyclebin;
