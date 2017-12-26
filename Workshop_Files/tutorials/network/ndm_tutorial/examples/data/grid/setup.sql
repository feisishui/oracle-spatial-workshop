Rem
Rem $Header: sdo/demo/network/examples/data/grid/setup.sql /main/2 2012/10/11 20:44:10 hgong Exp $
Rem
Rem setup.sql
Rem
Rem Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      setup.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Creates a grid network with 10x10 nodes, i.e. 9x9 links. 
Rem      Adds a hotel feature layer to the grid network.
Rem      Adds, updates and deletes hotel features to the hotel feature layer.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       06/12/12 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

--connect with sysdba user and
--create database user grid
grant connect, resource to grid identified by grid;

conn grid/grid;

--drop node table
drop table grid_node;

--create node table
create table grid_node (node_id number, active varchar2(1), geometry sdo_geometry);

begin
for y in 0..9
loop
  for x in 0..9
  loop
    insert into grid_node (node_id, active, geometry) 
    values ( y*10+x, 'Y', sdo_geometry(2001, null, sdo_point_type(x, y, null), null, null) );
  end loop;
end loop;
end;
/
show errors;

--drop link table
drop table grid_link;

--create link table
create table grid_link (link_id number, start_node_id number, end_node_id number, cost number, active varchar2(1), geometry sdo_geometry);

begin
for y in 0..9
loop
  for x in 0..9
  loop
    --horizontal links
    if(x<9) then
      insert into grid_link (link_id, start_node_id, end_node_id, cost, active, geometry)
      values ( (y*10+x)*100+(y*10+x+1), y*10+x, y*10+x+1, 1, 'Y', 
               sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), 
                 sdo_ordinate_array(x, y, x+1, y)) );
    end if;
    --vertical links
    if(y<9) then
      insert into grid_link (link_id, start_node_id, end_node_id, cost, active, geometry)
      values ( (y*10+x)*100+(y+1)*10+x, y*10+x, (y+1)*10+x, 1, 'Y', 
               sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), 
                 sdo_ordinate_array(x, y, x, y+1)) );
    end if;
  end loop;
end loop;
end;
/
show errors;

--register geom metadata
insert into user_sdo_geom_metadata (table_name,column_name,diminfo,srid)
  values ('grid_node', 'geometry',
          MDSYS.SDO_DIM_ARRAY(
            MDSYS.SDO_DIM_ELEMENT('X', 0, 99999, 0.1),
            MDSYS.SDO_DIM_ELEMENT('Y', 0, 99999, 0.1)),
          null);
insert into user_sdo_geom_metadata (table_name,column_name,diminfo,srid)
  values ('grid_link', 'geometry',
          MDSYS.SDO_DIM_ARRAY(
            MDSYS.SDO_DIM_ELEMENT('X', 0, 99999, 0.1),
            MDSYS.SDO_DIM_ELEMENT('Y', 0, 99999, 0.1)),
          null);

--geometry indexes
create index grid_node_geom_idx on grid_node(geometry) indextype is mdsys.spatial_index parameters('layer_gtype=POINT');
create index grid_link_geom_idx on grid_link(geometry) indextype is mdsys.spatial_index;

--register network metadata
DELETE
FROM user_sdo_network_metadata
WHERE network = 'GRID';

INSERT INTO user_sdo_network_metadata
    (network,
     network_category,
     geometry_type,
     node_table_name,
     node_geom_column,
     link_table_name,
     link_geom_column,
     link_direction,
     link_cost_column,
     user_defined_data)
VALUES
    ('GRID',
     'SPATIAL',
     'SDO_GEOMETRY',
     'GRID_NODE',
     'GEOMETRY',
     'GRID_LINK',
     'GEOMETRY',
     'BIDIRECTED',
     'COST',
     'Y');

SELECT sdo_net.validate_network('GRID')
FROM dual;

--Create feature layer
BEGIN
  sdo_net.add_feature_layer(
    'GRID',                 --network name
    'HOTEL',                --feature layer name
    SDO_NET.FEAT_TYPE_POL,  --feature layer type is point on link
    'HOTEL',                --feature table/view name
    'HOTEL_REL$',           --relation table name
    NULL                    --hierarchy table name
  );
END;
/ 

--Add optional columns for the feature table
alter table hotel add (HOTEL_NAME VARCHAR2(32), HOTEL_CHAIN VARCHAR2(32));

--Register feature user data
INSERT INTO user_sdo_network_user_data
  (network, table_type, data_name, data_type, category_id)
VALUES
  ('GRID', 'HOTEL', 'HOTEL_NAME', 'VARCHAR2', 0);

INSERT INTO user_sdo_network_user_data
  (network, table_type, data_name, data_type, category_id)
VALUES
  ('GRID', 'HOTEL', 'HOTEL_CHAIN', 'VARCHAR2', 0);


DECLARE
  feature_layer_id NUMBER;
BEGIN
  --Add a feature using SDO_NET.ADD_FEATURE api, and then
  --update the optional fields of the feature in the feature table.
  feature_layer_id := sdo_net.get_feature_layer_id('GRID', 'HOTEL');
  sdo_net.add_feature(
    feature_layer_id, 
    1, 
    SDO_NET_FEAT_ELEM_ARRAY(SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_POL, 102, 0.2, null) ), 
    null);

  update hotel set hotel_name='Blackberry', hotel_chain='Merry Berry';

  --Insert a feature directly into the feature table, and then use
  --SDO_NET.ADD_FEATURE_ELEMENTS to manage feature-network element relationship.
  insert into hotel (feature_id, hotel_name, hotel_chain)
    values (2, 'Blueberry', 'Merry Berry');
  sdo_net.add_feature_elements(
    feature_layer_id, 
    2,
    SDO_NET_FEAT_ELEM_ARRAY(SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_POL, 4353, 0.2, null) ) 
  );

  --Insert more features to be used in feature analysis demo later
  insert into hotel (feature_id, hotel_name, hotel_chain)
    values (3, 'Chuckleberry', 'Merry Berry');
  sdo_net.add_feature_elements(
    feature_layer_id,
    3,
    SDO_NET_FEAT_ELEM_ARRAY(SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_POL, 4748, 0.2, null) )
  );
  insert into hotel (feature_id, hotel_name, hotel_chain)
    values (4, 'Strawberry', 'Merry Berry');
  sdo_net.add_feature_elements(
    feature_layer_id,
    4,
    SDO_NET_FEAT_ELEM_ARRAY(SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_POL, 8586, 0.2, null) )
  );

  insert into hotel (feature_id, hotel_name, hotel_chain)
    values (5, 'Mac', 'Simple Apple');
  sdo_net.add_feature_elements(
    feature_layer_id,
    5,
    SDO_NET_FEAT_ELEM_ARRAY(SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_POL, 5556, 0.1, null) )
  );
  insert into hotel (feature_id, hotel_name, hotel_chain)
    values (6, 'Fuji', 'Simple Apple');
  sdo_net.add_feature_elements(
    feature_layer_id,
    6,
    SDO_NET_FEAT_ELEM_ARRAY(SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_POL, 809, 0.1, null) )
  );
END;
/
select feature_id from hotel;
select * from hotel_rel$;


----update feature
--DECLARE
--  feature_layer_id NUMBER;
--BEGIN
--  feature_layer_id := sdo_net.get_feature_layer_id('GRID', 'HOTEL');
--  sdo_net.update_feature(
--    feature_layer_id,
--    6,
--    SDO_NET_FEAT_ELEM_ARRAY(SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_POL, 809, 0.3, null) )
--  );
--END;
--/
select feature_id from hotel;
select * from hotel_rel$;


----delete feature
--DECLARE
--  feature_layer_id NUMBER;
--BEGIN
--  feature_layer_id := sdo_net.get_feature_layer_id('GRID', 'HOTEL');
--  --delete feature
--  sdo_net.delete_features(feature_layer_id, SDO_NUMBER_ARRAY(6));
--END;
--/
--select feature_id from hotel;
--select * from hotel_rel$;


--BEGIN
--  --drop feature layer, including the feature and relation tables
--  sdo_net.drop_feature_layer('GRID', 'HOTEL', TRUE);
--END;
--/


