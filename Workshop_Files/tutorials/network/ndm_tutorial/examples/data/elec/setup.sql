Rem
Rem $Header: sdo/demo/network/examples/data/elec/setup.sql /main/2 2012/07/16 13:22:55 hgong Exp $
Rem
Rem setup.sql
Rem
Rem Copyright (c) 2011, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
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
Rem    hgong       09/22/11 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

drop user elec cascade;

grant connect, resource, create view, unlimited tablespace to elec identified by elec;
--alter user elec default tablespace USERS quota unlimited on USERS;

conn elec/elec
--network tables
create table node$(node_id number primary key, geometry sdo_geometry);
create table link$(link_id number primary key, start_node_id number, end_node_id number, geometry sdo_geometry);
--feature tables
create table cable(id number primary key, type varchar2(30), geometry sdo_geometry); 
create table joint(id number primary key, type varchar2(30), geometry sdo_geometry);
create table switch(id number primary key, status varchar2(10), geometry sdo_geometry);
create table equipment(id number primary key, type varchar2(30), geometry sdo_geometry);
create table substation(id number primary key, geometry sdo_geometry);
--geometry metadata
insert into user_sdo_geom_metadata (table_name,column_name,diminfo,srid)
  values ('node$', 'geometry',
          MDSYS.SDO_DIM_ARRAY(
            MDSYS.SDO_DIM_ELEMENT('X', 0, 99999, 0.1),
            MDSYS.SDO_DIM_ELEMENT('Y', 0, 99999, 0.1)),
          null);
insert into user_sdo_geom_metadata (table_name,column_name,diminfo,srid)
  values ('link$', 'geometry',
          MDSYS.SDO_DIM_ARRAY(
            MDSYS.SDO_DIM_ELEMENT('X', 0, 99999, 0.1),
            MDSYS.SDO_DIM_ELEMENT('Y', 0, 99999, 0.1)),
          null);
insert into user_sdo_geom_metadata (table_name,column_name,diminfo,srid)
  values ('cable', 'geometry',
          MDSYS.SDO_DIM_ARRAY(
            MDSYS.SDO_DIM_ELEMENT('X', 0, 99999, 0.1),
            MDSYS.SDO_DIM_ELEMENT('Y', 0, 99999, 0.1)),
          null);
insert into user_sdo_geom_metadata (table_name,column_name,diminfo,srid)
  values ('joint', 'geometry',
          MDSYS.SDO_DIM_ARRAY(
            MDSYS.SDO_DIM_ELEMENT('X', 0, 99999, 0.1),
            MDSYS.SDO_DIM_ELEMENT('Y', 0, 99999, 0.1)),
          null);
insert into user_sdo_geom_metadata (table_name,column_name,diminfo,srid)
  values ('switch', 'geometry',
          MDSYS.SDO_DIM_ARRAY(
            MDSYS.SDO_DIM_ELEMENT('X', 0, 99999, 0.1),
            MDSYS.SDO_DIM_ELEMENT('Y', 0, 99999, 0.1)),
          null);
insert into user_sdo_geom_metadata (table_name,column_name,diminfo,srid)
  values ('equipment', 'geometry',
          MDSYS.SDO_DIM_ARRAY(
            MDSYS.SDO_DIM_ELEMENT('X', 0, 99999, 0.01),
            MDSYS.SDO_DIM_ELEMENT('Y', 0, 99999, 0.01)),
          null);
insert into user_sdo_geom_metadata (table_name,column_name,diminfo,srid)
  values ('substation', 'geometry',
          MDSYS.SDO_DIM_ARRAY(
            MDSYS.SDO_DIM_ELEMENT('X', 0, 99999, 0.01),
            MDSYS.SDO_DIM_ELEMENT('Y', 0, 99999, 0.01)),
          null);

--network metadata
insert into user_sdo_network_metadata(
  network, network_category, node_table_name, link_table_name, link_direction)
values('elec', 'SPATIAL', 'NODE$', 'LINK$', 'DIRECTED');

--create feature layers
create or replace view cable$ as
  select id feature_id, type type, geometry geometry
  from cable;
exec sdo_net.add_feature_layer('elec', 'cable', 9, 'cable$', 'cable_rel$', null);

create or replace view joint$ as
  select id feature_id, type type, geometry geometry
  from joint;
exec sdo_net.add_feature_layer('elec', 'joint', 1, 'joint$', 'joint_rel$', null);

create or replace view switch$ as
  select id feature_id, status status, geometry geometry
  from switch;
exec sdo_net.add_feature_layer('elec', 'switch', 1, 'switch$', 'switch_rel$', null);

create or replace view equipment$ as
  select id feature_id, type type, geometry geometry
  from equipment;
exec sdo_net.add_feature_layer('elec', 'equipment', 1, 'equipment$', 'equipment_rel$', null);

create or replace view substation$ as
  select id feature_id, geometry geometry
  from substation;
exec sdo_net.add_feature_layer('elec', 'substation', 1, 'substation$', null, 'substation_hier$');

--feature user data
insert into user_sdo_network_user_data (network, table_type, data_name, data_type, category_id)
values('ELEC', 'CABLE$', 'TYPE', 'VARCHAR2', 0);
insert into user_sdo_network_user_data (network, table_type, data_name, data_type, category_id)
values('ELEC', 'CABLE$', 'GEOMETRY', 'SDO_GEOMETRY', 0);

insert into user_sdo_network_user_data (network, table_type, data_name, data_type, category_id)
values('ELEC', 'JOINT$', 'TYPE', 'VARCHAR2', 0);
insert into user_sdo_network_user_data (network, table_type, data_name, data_type, category_id)
values('ELEC', 'JOINT$', 'GEOMETRY', 'SDO_GEOMETRY', 0);

insert into user_sdo_network_user_data (network, table_type, data_name, data_type, category_id)
values('ELEC', 'SWITCH$', 'STATUS', 'VARCHAR2', 0);
insert into user_sdo_network_user_data (network, table_type, data_name, data_type, category_id)
values('ELEC', 'SWITCH$', 'GEOMETRY', 'SDO_GEOMETRY', 0);

insert into user_sdo_network_user_data (network, table_type, data_name, data_type, category_id)
values('ELEC', 'EQUIPMENT$', 'TYPE', 'VARCHAR2', 0);
insert into user_sdo_network_user_data (network, table_type, data_name, data_type, category_id)
values('ELEC', 'EQUIPMENT$', 'GEOMETRY', 'SDO_GEOMETRY', 0);

insert into user_sdo_network_user_data (network, table_type, data_name, data_type, category_id)
values('ELEC', 'SUBSTATION$', 'GEOMETRY', 'SDO_GEOMETRY', 0);

--geometry indexes
create index node_geom_idx on node$(geometry) indextype is mdsys.spatial_index parameters('layer_gtype=POINT');
create index link_geom_idx on link$(geometry) indextype is mdsys.spatial_index;
create index cable_geom_idx on cable(geometry) indextype is mdsys.spatial_index;
create index joint_geom_idx on joint(geometry) indextype is mdsys.spatial_index parameters('layer_gtype=POINT');
create index switch_geom_idx on switch(geometry) indextype is mdsys.spatial_index parameters('layer_gtype=POINT');
create index equipment_geom_idx on equipment(geometry) indextype is mdsys.spatial_index parameters('layer_gtype=POINT');
create index substation_geom_idx on substation(geometry) indextype is mdsys.spatial_index parameters('layer_gtype=POINT');

--nodes
insert into node$(node_id, geometry)
values(901, sdo_geometry(2001, null, sdo_point_type(0,0,null), null, null));
insert into node$(node_id, geometry)
values(902, sdo_geometry(2001, null, sdo_point_type(4,5,null), null, null));
insert into node$(node_id, geometry)
values(903, sdo_geometry(2001, null, sdo_point_type(10,13,null), null, null));
insert into node$(node_id, geometry)
values(904, sdo_geometry(2001, null, sdo_point_type(25,20,null), null, null));
insert into node$(node_id, geometry)
values(905, sdo_geometry(2001, null, sdo_point_type(23,23,null), null, null));
insert into node$(node_id, geometry)
values(906, sdo_geometry(2001, null, sdo_point_type(27,22,null), null, null));
insert into node$(node_id, geometry)
values(907, sdo_geometry(2001, null, sdo_point_type(28,10,null), null, null));
insert into node$(node_id, geometry)
values(908, sdo_geometry(2001, null, sdo_point_type(24,8,null), null, null));

insert into node$(node_id, geometry)
values(951, sdo_geometry(2001, null, sdo_point_type(0,0,null), null, null));
insert into node$(node_id, geometry)
values(952, sdo_geometry(2001, null, sdo_point_type(10,7,null), null, null));
insert into node$(node_id, geometry)
values(954, sdo_geometry(2001, null, sdo_point_type(10.4,7,null), null, null));
insert into node$(node_id, geometry)
values(955, sdo_geometry(2001, null, sdo_point_type(10.6,7,null), null, null));
insert into node$(node_id, geometry)
values(956, sdo_geometry(2001, null, sdo_point_type(11,7.4,null), null, null));
insert into node$(node_id, geometry)
values(958, sdo_geometry(2001, null, sdo_point_type(11,7,null), null, null));
insert into node$(node_id, geometry)
values(960, sdo_geometry(2001, null, sdo_point_type(20,15,null), null, null));
insert into node$(node_id, geometry)
values(961, sdo_geometry(2001, null, sdo_point_type(20,0,null), null, null));

--links
insert into link$(link_id, start_node_id, end_node_id, geometry)
values(801, 901, 902, sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(0,0,4,5)));
insert into link$(link_id, start_node_id, end_node_id, geometry)
values(802, 902, 903, sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(4,5,10,13)));
insert into link$(link_id, start_node_id, end_node_id, geometry)
values(803, 903, 904, sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(10,13,25,20)));
insert into link$(link_id, start_node_id, end_node_id, geometry)
values(804, 904, 906, sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(25,20,27,22)));
insert into link$(link_id, start_node_id, end_node_id, geometry)
values(805, 904, 905, sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(25,20,23,23)));
insert into link$(link_id, start_node_id, end_node_id, geometry)
values(806, 904, 907, sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(25,20,28,10)));
insert into link$(link_id, start_node_id, end_node_id, geometry)
values(807, 904, 908, sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(25,20,24,8)));

insert into link$(link_id, start_node_id, end_node_id, geometry)
values(851, 951, 952, sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(0,0,10,7)));
insert into link$(link_id, start_node_id, end_node_id, geometry)
values(852, 952, 954, sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(10,7,10.4,7)));
insert into link$(link_id, start_node_id, end_node_id, geometry)
values(854, 954, 955, sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(10.4,7,10.6,7)));
insert into link$(link_id, start_node_id, end_node_id, geometry)
values(855, 955, 956, sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(10.6,7,11,7.1,11,7.4)));
insert into link$(link_id, start_node_id, end_node_id, geometry)
values(858, 955, 958, sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(10.6,7,11,7)));
insert into link$(link_id, start_node_id, end_node_id, geometry)
values(856, 956, 960, sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(11,7.4,20,16)));
insert into link$(link_id, start_node_id, end_node_id, geometry)
values(859, 958, 961, sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(11,7,21,5)));

--cables
insert into cable(id, type, geometry)
values(101, 'main', sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(0,0,4,5)));
insert into cable(id, type, geometry)
values(102, 'main', sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(4,5,10,13)));
insert into cable(id, type, geometry)
values(103, 'main', sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(10,13,25,20,27,22)));
insert into cable(id, type, geometry)
values(104, 'service', sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(25,20,23,23)));
insert into cable(id, type, geometry)
values(105, 'service', sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(25,20,28,10)));
insert into cable(id, type, geometry)
values(106, 'service', sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(25,20,24,8)));

insert into cable(id, type, geometry)
values(151, 'main', sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(0,0,10,7)));
insert into cable(id, type, geometry)
values(152, 'main', sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(11,7.4,20,16)));
insert into cable(id, type, geometry)
values(153, 'main', sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(11,7,21,5)));
insert into cable(id, type, geometry)
values(601, 'internal', sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(10,7,10.4,7)));
insert into cable(id, type, geometry)
values(602, 'internal', sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(10.4,7,10.6,7)));
insert into cable(id, type, geometry)
values(603, 'internal', sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(10.6,7,11,7)));
insert into cable(id, type, geometry)
values(604, 'internal', sdo_geometry(2002, null, null, sdo_elem_info_array(1, 2, 1), sdo_ordinate_array(10.6,7,11,7.1,11,7.4)));

--joints
insert into joint(id, type, geometry)
values(201, 'straight', sdo_geometry(2001, null, sdo_point_type(10,13,null), null, null));
insert into joint(id, type, geometry)
values(202, 'non-breaking splice', sdo_geometry(2001, null, sdo_point_type(25,20,null), null, null));

insert into joint(id, type, geometry)
values(501, 'connector', sdo_geometry(2001, null, sdo_point_type(10,7,null), null, null));
insert into joint(id, type, geometry)
values(502, 'connector', sdo_geometry(2001, null, sdo_point_type(11,7.4,null), null, null));
insert into joint(id, type, geometry)
values(503, 'connector', sdo_geometry(2001, null, sdo_point_type(11,7,null), null, null));

--switches
insert into switch(id, status, geometry)
values(301, 'open', sdo_geometry(2001, null, sdo_point_type(4,5,null), null, null));

--equipments
insert into equipment(id, type, geometry)
values(401, 'circuit breaker', sdo_geometry(2001, null, sdo_point_type(10.4,7,null), null, null));
insert into equipment(id, type, geometry)
values(402, 'transformer', sdo_geometry(2001, null, sdo_point_type(10.6,7,null), null, null));

--substation
insert into substation(id, geometry)
values(701, sdo_geometry(2001, null, sdo_point_type(10.5,7,null), null, null));

--add feature elements
DECLARE
  cable_feature_layer_id NUMBER;
  joint_feature_layer_id NUMBER;
  switch_feature_layer_id NUMBER;
  equipment_feature_layer_id NUMBER;
  substation_feature_layer_id NUMBER;
  --elements SDO_NET_FEAT_ELEM_ARRAY := SDO_NET_FEAT_ELEM_ARRAY();
BEGIN
  --cables
  cable_feature_layer_id := sdo_net.get_feature_layer_id('elec', 'cable');
  sdo_net.add_feature_elements(cable_feature_layer_id, 101, 
    SDO_NET_FEAT_ELEM_ARRAY(
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 901, null, null),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_LINE, 801, 0, 1.0),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 902, null, null)
    )
  );
  sdo_net.add_feature_elements(cable_feature_layer_id, 102, 
    SDO_NET_FEAT_ELEM_ARRAY(
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 902, null, null),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_LINE, 802, 0, 1.0),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 903, null, null)
    )
  );
  sdo_net.add_feature_elements(cable_feature_layer_id, 103,
    SDO_NET_FEAT_ELEM_ARRAY(
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 903, null, null),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_LINE, 803, 0, 1.0),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 904, null, null),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_LINE, 804, 0, 1.0),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 906, null, null)
    )
  );
  sdo_net.add_feature_elements(cable_feature_layer_id, 104,
    SDO_NET_FEAT_ELEM_ARRAY(
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 904, null, null),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_LINE, 805, 0, 1.0),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 905, null, null)
    )
  );
  sdo_net.add_feature_elements(cable_feature_layer_id, 105,
    SDO_NET_FEAT_ELEM_ARRAY(
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 904, null, null),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_LINE, 806, 0, 1.0),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 907, null, null)
    )
  );
  sdo_net.add_feature_elements(cable_feature_layer_id, 106,
    SDO_NET_FEAT_ELEM_ARRAY(
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 904, null, null),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_LINE, 807, 0, 1.0),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 908, null, null)
    )
  );

  sdo_net.add_feature_elements(cable_feature_layer_id, 151,
    SDO_NET_FEAT_ELEM_ARRAY(
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 951, null, null),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_LINE, 851, 0, 1.0),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 952, null, null)
    )
  );
  sdo_net.add_feature_elements(cable_feature_layer_id, 152,
    SDO_NET_FEAT_ELEM_ARRAY(
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 956, null, null),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_LINE, 856, 0, 1.0),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 960, null, null)
    )
  );
  sdo_net.add_feature_elements(cable_feature_layer_id, 153,
    SDO_NET_FEAT_ELEM_ARRAY(
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 958, null, null),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_LINE, 859, 0, 1.0),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 961, null, null)
    )
  );
  sdo_net.add_feature_elements(cable_feature_layer_id, 601,
    SDO_NET_FEAT_ELEM_ARRAY(
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 952, null, null),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_LINE, 852, 0, 1.0),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 954, null, null)
    )
  );
  sdo_net.add_feature_elements(cable_feature_layer_id, 602,
    SDO_NET_FEAT_ELEM_ARRAY(
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 954, null, null),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_LINE, 854, 0, 1.0),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 955, null, null)
    )
  );
  sdo_net.add_feature_elements(cable_feature_layer_id, 603,
    SDO_NET_FEAT_ELEM_ARRAY(
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 955, null, null),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_LINE, 858, 0, 1.0),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 958, null, null)
    )
  );
  sdo_net.add_feature_elements(cable_feature_layer_id, 604,
    SDO_NET_FEAT_ELEM_ARRAY(
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 955, null, null),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_LINE, 855, 0, 1.0),
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 956, null, null)
    )
  );

  --joints
  joint_feature_layer_id := sdo_net.get_feature_layer_id('elec', 'joint');
  sdo_net.add_feature_elements(joint_feature_layer_id, 201,
    SDO_NET_FEAT_ELEM_ARRAY(
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 903, null, null)
    )
  );
  sdo_net.add_feature_elements(joint_feature_layer_id, 202,
    SDO_NET_FEAT_ELEM_ARRAY(
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 904, null, null)
    )
  );

  sdo_net.add_feature_elements(joint_feature_layer_id, 501,
    SDO_NET_FEAT_ELEM_ARRAY(
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 952, null, null)
    )
  );
  sdo_net.add_feature_elements(joint_feature_layer_id, 502,
    SDO_NET_FEAT_ELEM_ARRAY(
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 956, null, null)
    )
  );
  sdo_net.add_feature_elements(joint_feature_layer_id, 503,
    SDO_NET_FEAT_ELEM_ARRAY(
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 958, null, null)
    )
  );

  --switches
  switch_feature_layer_id := sdo_net.get_feature_layer_id('elec', 'switch');
  sdo_net.add_feature_elements(switch_feature_layer_id, 301,
    SDO_NET_FEAT_ELEM_ARRAY(
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 902, null, null)
    )
  );

  --equipments
  equipment_feature_layer_id := sdo_net.get_feature_layer_id('elec', 'equipment');
  sdo_net.add_feature_elements(equipment_feature_layer_id, 401,
    SDO_NET_FEAT_ELEM_ARRAY(
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 954, null, null)
    )
  );
  sdo_net.add_feature_elements(equipment_feature_layer_id, 402,
    SDO_NET_FEAT_ELEM_ARRAY(
      SDO_NET_FEAT_ELEM(SDO_NET.FEAT_ELEM_TYPE_PON, 955, null, null)
    )
  );

  --substation
  substation_feature_layer_id := sdo_net.get_feature_layer_id('elec', 'substation');
  sdo_net.add_child_features(substation_feature_layer_id, 701,
    SDO_NET_LAYER_FEAT_ARRAY(
      SDO_NET_LAYER_FEAT(cable_feature_layer_id, 601),
      SDO_NET_LAYER_FEAT(cable_feature_layer_id, 602),
      SDO_NET_LAYER_FEAT(cable_feature_layer_id, 603),
      SDO_NET_LAYER_FEAT(cable_feature_layer_id, 604),
      SDO_NET_LAYER_FEAT(joint_feature_layer_id, 501),
      SDO_NET_LAYER_FEAT(joint_feature_layer_id, 502),
      SDO_NET_LAYER_FEAT(joint_feature_layer_id, 503),
      SDO_NET_LAYER_FEAT(equipment_feature_layer_id, 401),
      SDO_NET_LAYER_FEAT(equipment_feature_layer_id, 402)
    )
  );

END;
/

host imp elec/elec file=styles_themes_maps.dmp full=y

insert into user_sdo_styles select * from styles;
insert into user_sdo_themes select * from themes;
insert into user_sdo_maps select * from maps;
commit;

