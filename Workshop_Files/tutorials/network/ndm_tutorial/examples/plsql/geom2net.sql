SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 1000
SET SERVEROUTPUT ON

-- generate a NDM network from the given SDO line geometry table
-- parameters:
--   tab_name: name of table that has line geometries
--   net: name of output network, the length of name should be less 
--        than 10
--   is_directed: specify whether the generated network is directed
--example:
--  exec geom2net('CITY_STREETS_GEOM', 'CITY_NET',true);
--note:
--  for large number of geometries, use SDO_TOPO_MAP.SET_MAX_MEMORY_SIZE
--  to set OJVM maximum heap size   

create or replace procedure geom2net(tab_name VARCHAR2,
  net VARCHAR2, is_directed boolean)
is
  dim           sdo_dim_array;
  geom          mdsys.sdo_geometry;
  geom_column   varchar2(100);
  id            number;
  link_tab      varchar2(20);
  node_tab      varchar2(20);
  path_tab      varchar2(20);
  ref_cursor    SYS_REFCURSOR;
  srid          number;
  stmt          varchar2(500);
  stmt1         varchar2(500);
  tolerance     number := 0.0000005;
  topo_feature  varchar2(20);
  topo_geom     mdsys.sdo_topo_geometry;
  topo_map      varchar2(20);
  topo          varchar2(20);
begin

  dbms_output.put_line('...start the process..');

  -- step 1: construct the topology from the geometry
  --get metadata
  stmt := 'select column_name, diminfo, srid'||
    ' from user_sdo_geom_metadata ' ||
    ' where table_name = :tab';
  execute immediate stmt into geom_column, dim, srid using tab_name;
  
  topo := substr(tab_name,1,3) || '_topo';
  sdo_topo.create_topology(topo, tolerance, srid); 
    
  -- insert the universe face (F0)
  execute immediate 'insert into  '||topo||'_face$'||
    ' values(-1, null, sdo_list_type(), sdo_list_type(),null)';
    
  -- create feature table
  topo_feature := topo || '_f';
  execute immediate 'create table ' || topo_feature ||
    '(id number primary key, feature sdo_topo_geometry)';
  sdo_topo.add_topo_geometry_layer(topo, topo_feature, 'FEATURE',
    'LINE');

  -- create a TopoMap object and load the topology into memory for updating 
  topo_map := topo || '_map';
  sdo_topo_map.create_topo_map(topo, topo_map);
  sdo_topo_map.load_topo_map(topo_map, 'true');

  -- loading feature tables with data from spatial tables
  stmt := 'select rownum id, ' || geom_column || ' geom from ' || tab_name;
  stmt1 := 'insert into ' || topo_feature || ' values(:id, :geom)';

  open ref_cursor for stmt;
  loop
    fetch ref_cursor into id, geom;
    topo_geom := sdo_topo_map.create_feature(
      topo, topo_feature, 'feature', geom);
    exit when ref_cursor%NOTFOUND;
    execute immediate stmt1 using id, topo_geom;
  end loop;
  close ref_cursor;

  sdo_topo_map.commit_topo_map();
  sdo_topo_map.drop_topo_map(topo_map);

  -- initialize topology metadata
  sdo_topo.initialize_metadata(topo);

  -- step 2: construct the network from the topology
  sdo_net.create_sdo_network(net,1,is_directed);
  link_tab := net||'_link$';
  stmt := 'insert into '||link_tab||' (link_id, start_node_id, '||
    'end_node_id, geometry) select edge_id, start_node_id, '||
    'end_node_id, geometry from '||topo||'_edge$';
  execute immediate stmt;

  node_tab := net||'_node$';
  stmt := 'insert into '||node_tab||' (node_id, geometry) ' ||
    ' select node_id, geometry  from '||topo||'_node$';
  execute immediate stmt;

  -- populate network metadata and create indexes
  path_tab := net||'_path$';
  stmt := 'insert into user_sdo_geom_metadata values' ||
    '(:tab_name, :col_name, :dim, :srid)';
  execute immediate stmt using link_tab, 'GEOMETRY', dim, srid;
  execute immediate stmt using node_tab, 'GEOMETRY', dim, srid;
  execute immediate stmt using path_tab, 'GEOMETRY', dim, srid;

  execute immediate
    'create index '||node_tab||'_sidx on '||node_tab||
    '(geometry) indextype is mdsys.spatial_index';

  execute immediate
    'create index '||link_tab||'_sidx on '||link_tab||
    '(geometry) indextype is mdsys.spatial_index';
  
  execute immediate
    'create index '||path_tab||'_sidx on '||path_tab||
    '(geometry) indextype is mdsys.spatial_index';

  dbms_output.put_line('the resultant network is valid?'||
    sdo_net.validate_network(net,'TRUE'));
  dbms_output.put_line('...complete process...');

  -- cleanup
  sdo_topo.delete_topo_geometry_layer(topo,topo_feature,'feature');
  sdo_topo.drop_topology(topo);
  execute immediate 'drop table ' || topo_feature;

end;
/
show errors;
