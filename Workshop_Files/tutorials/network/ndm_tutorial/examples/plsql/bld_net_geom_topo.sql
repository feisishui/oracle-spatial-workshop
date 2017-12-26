------------------------------
-- Main steps for building a network from Spatial
-- geometry data through Spatial Topology.  
------------------------------
-- 1. Prepare the example for running.
-- 2. Construct the topology from Spatial line string geometry data.
-- 3. Construct the network from the topology.
-- 4. Verify the constructed network.
-- 5. Clean up the intermediate topology.


-- This example is adapted from the Oracle Spatial Topology
-- and Network Data Models Developer's Guide, Section 1.12.2.

--
--1. Prepare the example for running.
--

-- Create spatial tables of geometry features.
CREATE TABLE city_streets_geom ( 
  name VARCHAR2(30) PRIMARY KEY,
  geometry SDO_GEOMETRY);

-- Update the Spatial metadata (USER_SDO_GEOM_METADATA).
INSERT INTO user_sdo_geom_metadata
    (TABLE_NAME,
     COLUMN_NAME,
     DIMINFO,
     SRID)
  VALUES (
    'CITY_STREETS_GEOM',
    'GEOMETRY',
    SDO_DIM_ARRAY(
      SDO_DIM_ELEMENT('X', 0, 65, 0.005),
      SDO_DIM_ELEMENT('Y', 0, 45, 0.005)
      ),
    NULL -- SRID
  );
  
-- Load data into the spatial tables.
-- R1 
INSERT INTO city_streets_geom VALUES('R1',
  SDO_GEOMETRY(2002, NULL, NULL, SDO_ELEM_INFO_ARRAY(1, 2, 1),
    SDO_ORDINATE_ARRAY(9,14, 21,14, 35,14, 47,14)));
 
-- R2
INSERT INTO city_streets_geom VALUES('R2',
  SDO_GEOMETRY(2002, NULL, NULL, SDO_ELEM_INFO_ARRAY(1, 2, 1),
    SDO_ORDINATE_ARRAY(36,38, 38,35, 41,34, 42,33, 45,32, 47,28, 50,28, 52,32,
57,33, 57,36, 59,39, 61,38, 62,41, 47,42, 45,40, 41,40)));
 
-- R3
INSERT INTO city_streets_geom VALUES('R3',
  SDO_GEOMETRY(2002, NULL, NULL, SDO_ELEM_INFO_ARRAY(1, 2, 1),
    SDO_ORDINATE_ARRAY(9,35, 13,35)));
 
-- R4
INSERT INTO city_streets_geom VALUES('R4',
  SDO_GEOMETRY(2002, NULL, NULL, SDO_ELEM_INFO_ARRAY(1, 2, 1),
    SDO_ORDINATE_ARRAY(25,30, 25,35)));
    
-- Validate the spatial data (validate the layers).
create table val_results (sdo_rowid ROWID, result VARCHAR2(2000));
call 
SDO_GEOM.VALIDATE_LAYER_WITH_CONTEXT('CITY_STREETS_GEOM','GEOMETRY','VAL_RESULTS
');
SELECT * from val_results;
drop table val_results;

-- Create the spatial indexes.
CREATE INDEX city_streets_geom_idx ON city_streets_geom(geometry)
  INDEXTYPE IS MDSYS.SPATIAL_INDEX;
  
--
-- 2. Construct the topology from Spatial line string geometry data.
--
-- Create the topology. (Null SRID in this example.)
EXECUTE SDO_TOPO.CREATE_TOPOLOGY('CITY_DATA', 0.00005);

-- Insert the universe face (F0). (id = -1, not 0)
INSERT INTO CITY_DATA_FACE$ values (
  -1, NULL, SDO_LIST_TYPE(), SDO_LIST_TYPE(), NULL);

-- Create feature tables. 
CREATE TABLE city_streets ( -- City streets/roads
  feature_name VARCHAR2(30) PRIMARY KEY,
  feature SDO_TOPO_GEOMETRY);
  
-- Associate feature tables with the topology. 
EXECUTE SDO_TOPO.ADD_TOPO_GEOMETRY_LAYER('CITY_DATA', 'CITY_STREETS', 
'FEATURE','LINE');  

-- Create a TopoMap object and load the whole topology into cache for updating. 
EXECUTE SDO_TOPO_MAP.CREATE_TOPO_MAP('CITY_DATA', 'CITY_DATA_TOPOMAP');
EXECUTE SDO_TOPO_MAP.LOAD_TOPO_MAP('CITY_DATA_TOPOMAP', 'true');

-- Load feature tables, inserting data from the spatial tables and 
--     using SDO_TOPO_MAP.CREATE_FEATURE.
 
BEGIN
  FOR street_rec IN (SELECT name, geometry FROM city_streets_geom) LOOP
   INSERT INTO city_streets VALUES(street_rec.name,
     SDO_TOPO_MAP.CREATE_FEATURE('CITY_DATA', 'CITY_STREETS', 'FEATURE',
         street_rec.geometry));
  END LOOP;
END;
/
 
CALL SDO_TOPO_MAP.COMMIT_TOPO_MAP();
CALL SDO_TOPO_MAP.DROP_TOPO_MAP('CITY_DATA_TOPOMAP');

-- Initialize topology metadata.
EXECUTE SDO_TOPO.INITIALIZE_METADATA('CITY_DATA');

-- Query the data.
SELECT a.feature_name, a.feature.tg_id, a.feature.get_geometry()
FROM city_streets a;

--
-- 3. Construct the network from the topology 
--
create table city_streets_link$(link_id number primary key, 
  start_node_id number, end_node_id number, geometry mdsys.sdo_geometry);
insert into city_streets_link$  
  select edge_id, start_node_id, end_node_id, geometry from city_data_edge$;
  
create table city_streets_node$(node_id number primary key,
  geometry mdsys.sdo_geometry);
insert into city_streets_node$
  select node_id, geometry from city_data_node$;

-- Update the geometry metadata.
insert into user_sdo_geom_metadata 
  select 'CITY_STREETS_LINK$', 'GEOMETRY', a.diminfo, a.srid
    from user_sdo_geom_metadata a
    where a.table_name = 'CITY_STREETS_GEOM';

insert into user_sdo_geom_metadata 
  select 'CITY_STREETS_NODE$', 'GEOMETRY', a.diminfo, a.srid
    from user_sdo_geom_metadata a
    where a.table_name = 'CITY_STREETS_GEOM';
    
-- Update the network metadata, assuming this is a directed network.
insert into user_sdo_network_metadata(network, network_category, 
  node_table_name, link_table_name, link_direction)
  values('CITY_STREETS_NETWORK', 'SPATIAL', 'CITY_STREETS_NODE$',
    'CITY_STREETS_LINK$', 'DIRECTED');

--
-- 4. Verify the constructed network.
--
select sdo_net.validate_network('CITY_STREETS_NETWORK', 'TRUE') from dual;


--
-- 5. Clean up the intermediate topology.
--  
EXECUTE SDO_TOPO.DELETE_TOPO_GEOMETRY_LAYER('CITY_DATA', 'CITY_STREETS', 
'FEATURE');  
EXECUTE SDO_TOPO.DROP_TOPOLOGY('CITY_DATA');
drop table city_streets;
