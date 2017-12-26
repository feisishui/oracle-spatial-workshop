Rem
Rem $Header: sdo/demo/network/examples/data/ndmdemo/ndmdemo_util.sql /main/7 2010/12/16 09:17:03 hgong Exp $
Rem
Rem ndmdemo_util.sql
Rem
Rem Copyright (c) 2009, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      ndmdemo_util.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      This plsql script creates the ndmdemo_util package,
Rem      which contains functions and procedures to create
Rem      NDM network for router data, and other utilities
Rem      for ndmdemo.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       06/10/10 - add feature demo
Rem    hgong       10/21/09 - remove unused procedures
Rem    hgong       08/20/09 - Created
Rem

CREATE OR REPLACE PACKAGE ndmdemo_util AUTHID current_user AS

  --
  --
  -- Creates an index
  PROCEDURE create_index(
    index_name  VARCHAR2,
    tab_name    VARCHAR2,
    col_name    VARCHAR2,
    index_type  VARCHAR2 := NULL,
    parameters  VARCHAR2 := NULL);

  --
  -- Creates necessary indexes on the NAVTEQ ODF tables.
  -- Skip an index if the index already exists.
  --
  PROCEDURE create_indexes;

  --
  -- Creates ndmdemo views when a network is selected
  --
  PROCEDURE create_ndmdemo_views(network_user IN VARCHAR2,
                                 network_name IN VARCHAR2);

  --
  -- Computes partition boundaries (convex hull)
  --
  PROCEDURE create_partition_convexhull(network IN VARCHAR2,
                                        force   IN BOOLEAN DEFAULT FALSE);

  --
  -- Defines necessary geometry metadata on NAVTEQ ODF tables
  --
  PROCEDURE define_geometry_metadata;

  --
  -- Defines necessary geometry metadata on NDM tables/views
  --
  PROCEDURE define_geom_metadata_for_net(network_name IN VARCHAR2);

  --
  -- Deletes geometry metadata on the specified table column.
  --
  PROCEDURE delete_geometry_metadata(tab_name VARCHAR2, col_name VARCHAR2);

  --
  -- Inserts geometry metadata for the specified table column using the 
  -- geodetic system whose SRID equals 8307.
  --
  PROCEDURE insert_geometry_metadata(tab_name VARCHAR2, col_name VARCHAR2);

  -- The following two procedures are featured-related and will be available in 12.1.
  --
  -- Creates a POI feature layer for the given feature_code
  -- using the gc_poi_nvt table
  --
  PROCEDURE create_poi_feature_layer(
    network_name       in varchar2,
    feature_layer_name in varchar2,
    feature_code       in number,
    feature_view       in varchar2,
    relation_view      in varchar2);

  -- This is a work around for NAVTEQ data that does not have the correct poi
  -- percent filled in their poi table.
  PROCEDURE update_gc_poi_percent(gc_poi_table VARCHAR2,
                                  gc_road_segment_table VARCHAR2);

END ndmdemo_util;
/
show errors;

CREATE OR REPLACE PACKAGE BODY ndmdemo_util AS

  --
  -- check if the given index exists
  --
  FUNCTION index_exists(index_name IN VARCHAR2)
    RETURN VARCHAR2
  IS
    stmt  VARCHAR2(256);
    no    NUMBER := 0;
  BEGIN
    stmt := 'SELECT COUNT(*) FROM IND WHERE INDEX_NAME = :name';
    EXECUTE IMMEDIATE stmt into no using UPPER(index_name);
    IF (no = 1) THEN
      RETURN 'TRUE';
    ELSE
      RETURN 'FALSE';
    END IF;
  END index_exists;

  --
  -- check if the given index exists
  --
  FUNCTION index_on_col_exists(
    tab_name IN VARCHAR2,
    col_name IN VARCHAR2)
    RETURN VARCHAR2
  IS
    stmt  VARCHAR2(256);
    no    NUMBER := 0;
  BEGIN
    stmt := 'SELECT COUNT(*) FROM USER_IND_COLUMNS WHERE TABLE_NAME = :tab_name AND COLUMN_NAME = :col_name';
    EXECUTE IMMEDIATE stmt into no using UPPER(tab_name), UPPER(col_name);
    IF (no >= 1) THEN
      RETURN 'TRUE';
    ELSE
      RETURN 'FALSE';
    END IF;
  END index_on_col_exists;

  --
  -- check if the given table exists
  --
  FUNCTION table_exists(tab_name IN VARCHAR2)
    RETURN VARCHAR2
  IS
    stmt  VARCHAR2(256);
   no    NUMBER := 0;
  BEGIN
    stmt := 'SELECT COUNT(*) FROM TAB' ||
            ' WHERE TNAME = :name';
    EXECUTE IMMEDIATE stmt into no using UPPER(tab_name);
    IF (no = 1) THEN
      RETURN 'TRUE';
    ELSE
      RETURN 'FALSE';
    END IF;
  END table_exists;

  --
  -- check if the given table exists
  --
  FUNCTION table_exists_in_schema(schema_name IN VARCHAR2,
                               tab_name IN VARCHAR2)
    RETURN VARCHAR2
  IS
    stmt  VARCHAR2(256);
   no    NUMBER := 0;
  BEGIN
    stmt := 'SELECT COUNT(*) FROM ALL_TABLES' ||
            ' WHERE OWNER = :owner AND TABLE_NAME = :tab_name';
    EXECUTE IMMEDIATE stmt into no using UPPER(schema_name), UPPER(tab_name);
    IF (no = 1) THEN
      RETURN 'TRUE';
    ELSE
      RETURN 'FALSE';
    END IF;
  END table_exists_in_schema;

  --
  -- check if the given view exists
  --
  FUNCTION view_exists(view_name IN VARCHAR2)
    RETURN VARCHAR2
  IS
    stmt  VARCHAR2(256);
    no    NUMBER := 0;
  BEGIN
    stmt := 'SELECT COUNT(*) FROM USER_VIEWS' ||
            ' WHERE VIEW_NAME = :name';
    EXECUTE IMMEDIATE stmt into no using UPPER(view_name);
    IF (no = 1) THEN
      RETURN 'TRUE';
    ELSE
      RETURN 'FALSE';
    END IF;
  END view_exists;

  --
  -- Create index.
  -- If the index already exists, do nothing.
  --
  PROCEDURE create_index(
    index_name  VARCHAR2,
    tab_name    VARCHAR2,
    col_name    VARCHAR2,
    index_type  VARCHAR2 := NULL,
    parameters  VARCHAR2 := NULL)
  IS
    stmt        VARCHAR2(512);
  BEGIN
    IF (index_exists(index_name) <> 'TRUE' AND
        index_on_col_exists(tab_name, col_name) <> 'TRUE') THEN
      stmt := 'create index '||index_name||
              ' on '||tab_name||' ( '||col_name||' )';
      IF (index_type IS NOT NULL) THEN
        stmt := stmt||' indextype is '||index_type;
      END IF;
      IF (parameters IS NOT NULL) THEN
        stmt := stmt||' parameters('''|| parameters ||''')';
      END IF;
      dbms_output.put_line('creating index using: '||stmt);
      EXECUTE IMMEDIATE stmt;
    END IF;
  END;

  FUNCTION geometry_metadata_exists(tab_name IN VARCHAR2, col_name VARCHAR2)
    RETURN VARCHAR2
  IS
    stmt  VARCHAR2(256);
    no    NUMBER := 0;
  BEGIN
    stmt := 'SELECT COUNT(*) FROM user_sdo_geom_metadata 
             where table_name = :tab_name and column_name = :col_name';

    EXECUTE IMMEDIATE stmt into no using UPPER(tab_name), UPPER(col_name);
    IF (no = 1) THEN
      RETURN 'TRUE';
    ELSE
      RETURN 'FALSE';
    END IF;
  END geometry_metadata_exists;

  PROCEDURE delete_geometry_metadata(tab_name VARCHAR2, col_name VARCHAR2)
  IS
    stmt VARCHAR2(1024);
    no   NUMBER;
  BEGIN
    IF (geometry_metadata_exists(tab_name, col_name)='TRUE') THEN
      stmt := 'delete from user_sdo_geom_metadata 
               where table_name = :tab_name and column_name = :col_name';
      execute immediate stmt using UPPER(tab_name), UPPER(col_name);
    END IF;
  END;

  PROCEDURE insert_geometry_metadata(tab_name VARCHAR2, col_name VARCHAR2)
  IS
    stmt VARCHAR2(1024);
    no   NUMBER;
  BEGIN
    IF (geometry_metadata_exists(tab_name, col_name)<>'TRUE') THEN
      stmt := 'insert into user_sdo_geom_metadata (table_name,column_name,diminfo,srid)
               values ( :tab_name, :col_name,
                 MDSYS.SDO_DIM_ARRAY(
                   MDSYS.SDO_DIM_ELEMENT(''X'',-180,180,0.05),
                   MDSYS.SDO_DIM_ELEMENT(''Y'',-90,90,0.05)),
                   8307)';
      execute immediate stmt using UPPER(tab_name), UPPER(col_name);
    END IF;
  END;

  PROCEDURE copy_geometry_metadata(old_schema_name VARCHAR2, old_tab_name VARCHAR2, old_col_name VARCHAR2, 
                                   new_tab_name VARCHAR2, new_col_name VARCHAR2)
  IS
    stmt VARCHAR2(1024);
    no   NUMBER;
  BEGIN
    -- if geometry metadata exists for the new table, delete it.
    IF (geometry_metadata_exists(new_tab_name, new_col_name)='TRUE') THEN
      delete_geometry_metadata(new_tab_name, new_col_name);
    END IF;

    -- if the geometry metadata exists for the old table, copy it. if not, insert new.
    stmt := 'select count(*) from all_sdo_geom_metadata 
             where owner = :owner and table_name = :tab_name and column_name = :col_name';
    execute immediate stmt into no using UPPER(old_schema_name), UPPER(old_tab_name), UPPER(old_col_name);

    IF (no=0) THEN
      insert_geometry_metadata(new_tab_name, new_col_name);
    ELSE
      stmt := 'insert into user_sdo_geom_metadata (table_name,column_name,diminfo,srid)
                (select :new_tab_name, :new_col_name, diminfo, srid 
                 from all_sdo_geom_metadata
                 where owner = :owner and table_name = :old_tab_name and column_name = :old_col_name)';
      execute immediate stmt using UPPER(new_tab_name), UPPER(new_col_name), 
                                   UPPER(old_schema_name), UPPER(old_tab_name), UPPER(old_col_name);
    END IF;
  END;


  --
  -- Define geometry metadata
  --
  PROCEDURE define_geometry_metadata
  IS
  BEGIN
    insert_geometry_metadata('NODE','GEOMETRY');
    insert_geometry_metadata('EDGE','GEOMETRY');
  END;

  --
  -- Define geometry metadata
  --
  PROCEDURE define_geom_metadata_for_net(network_name varchar2)
  IS
    l_network_name  VARCHAR2(256);
    stmt VARCHAR2(1024);
    node_table_name VARCHAR2(1024);
    link_table_name VARCHAR2(1024);
    node_geom_column VARCHAR2(1024);
    link_geom_column VARCHAR2(1024);
  BEGIN
    l_network_name := UPPER(DBMS_ASSERT.SIMPLE_SQL_NAME(network_name));

    stmt := 'select node_table_name, node_geom_column, link_table_name, link_geom_column
             from user_sdo_network_metadata
             where network = :network_name';
    execute immediate stmt into node_table_name, node_geom_column, 
                                link_table_name, link_geom_column 
                           using l_network_name;
    insert_geometry_metadata(node_table_name, node_geom_column);
    insert_geometry_metadata(link_table_name, link_geom_column);
  END;
  
  --
  -- Create indexes
  --
  PROCEDURE create_indexes
  IS
  BEGIN
    -- node indexes
    create_index('NODE_ID_INDEX', 'NODE', 'NODE_ID');
    create_index('NODE_PARTITION_INDEX', 'NODE', 'PARTITION_ID');
    create_index('NODE_GEOMETRY_INDEX', 'NODE', 'GEOMETRY', 'MDSYS.SPATIAL_INDEX', 'layer_gtype=POINT');

    -- edge indexes
    create_index('EDGE_ID_IDX', 'EDGE', 'EDGE_ID');
    --create_index('EDGE_NAME_IDX', 'EDGE', 'NAME');
    create_index('START_NODE_ID_IDX', 'EDGE', 'START_NODE_ID');
    create_index('END_NODE_ID_IDX', 'EDGE', 'END_NODE_ID');
    create_index('START_END_NODE_ID_IDX', 'EDGE', 'START_NODE_ID, END_NODE_ID');
    create_index('EDGE_GEOMETRY_INDEX', 'EDGE', 'GEOMETRY', 'MDSYS.SPATIAL_INDEX');

    --Remove the following two statements, because these two indexes will 
    --be created when create_router_network is called.
    --create_index('EDGE_FUNC_CLASS_IDX', 'EDGE', 'FUNC_CLASS');
    --create_index('EDGE_LEVEL_IDX', 'EDGE', 'DECODE(FUNC_CLASS,1,3,2,2,1)');

    -- partition indexes
    create_index('PARTITION_P_IDX', 'PARTITION', 'PARTITION_ID');
 
  END;

  -- returns the partition convex hull table name
  FUNCTION get_pch_table_name(networkName IN VARCHAR2)
  RETURN VARCHAR2
  IS
  BEGIN
    RETURN networkName || '_PCH$';
    --RETURN 'NDM_PCH$';
  END;

  --These ndmdemo views are created only for mapviewer themes.
  PROCEDURE create_ndmdemo_views(network_user IN VARCHAR2,
                                 network_name IN VARCHAR2) IS
    node_tab_name VARCHAR2(32);
    node_geom_col VARCHAR2(32);
    link_tab_name VARCHAR2(32);
    link_geom_col VARCHAR2(32);
    l_pch_tab_name VARCHAR2(32);

    stmt VARCHAR2(1024);
    no   NUMBER;
  BEGIN
    stmt := ' SELECT node_table_name, node_geom_column, link_table_name, link_geom_column ' ||
            ' FROM all_sdo_network_metadata a ' ||
            ' WHERE NLS_UPPER(a.owner) = :owner AND  NLS_UPPER(a.network) = :net ';
    EXECUTE IMMEDIATE stmt into node_tab_name, node_geom_col, link_tab_name, link_geom_col
      using NLS_UPPER(network_user), NLS_UPPER(network_name);

    execute immediate 'create or replace view NDMDEMO_NODE$
      as select * from ' || network_user||'.'|| node_tab_name ; 
    -- insert geom metadata for NDMDEMO_NODE$
    copy_geometry_metadata(network_user, node_tab_name, node_geom_col, 'NDMDEMO_NODE$', node_geom_col);

    --execute immediate 'create or replace view NDMDEMO_LINK$
    --  as select * from ' || link_tab_name ;
    -- insert geom metadata for NDMDEMO_LINK$
    --copy_geometry_metadata(network_user, link_tab_name, link_geom_col, 'NDMDEMO_LINK$', link_geom_col);

    l_pch_tab_name := get_pch_table_name(network_name);
    IF(table_exists_in_schema(network_user, l_pch_tab_name)<>'TRUE') THEN
      dbms_output.put_line(network_user||'.'||l_pch_tab_name||'does not exist. return.');
      RETURN;
    END IF;

    execute immediate 'create or replace view NDMDEMO_PCH$ '||
      ' as select * from ' ||network_user||'.'|| l_pch_tab_name ;

    -- insert geometry metadata for NDMDEMO_PCH$
    copy_geometry_metadata(network_user, l_pch_tab_name, 'GEOMETRY', 'NDMDEMO_PCH$', 'GEOMETRY');
    
  END;

  PROCEDURE create_partition_convexhull(network IN VARCHAR2,
                                        force   IN BOOLEAN) IS
    stmt           VARCHAR2(1024);
    node_tab       VARCHAR2(32);
    part_tab       VARCHAR2(32);
    l_pch_tab_name VARCHAR2(32);
    index_name     VARCHAR2(64);
  BEGIN
    l_pch_tab_name := get_pch_table_name(network);

    -- create the partition convexhull table for nodes
    IF (table_exists(l_pch_tab_name) = 'TRUE') THEN
      IF(force=TRUE) THEN
        --drop existing table
        stmt := 'drop table '||l_pch_tab_name;
        execute immediate stmt;
      ELSE
        --simply return
        dbms_output.put_line(l_pch_tab_name || ' already exists. Do nothing.');
        RETURN;
      END IF;
    END IF;

    stmt := 'create table '||l_pch_tab_name|| 
              '(partition_id number primary key,
                link_level number, 
                geometry mdsys.sdo_geometry)';
    execute immediate stmt;

    node_tab := sdo_net.get_node_table_name(network);
    part_tab := sdo_net.get_partition_table_name(network);

    -- insert convexhull geometry for partitions
    stmt := 'insert into '||l_pch_tab_name||
               '(select a.partition_id, a.link_level, 
                   sdo_aggr_convexhull(sdoaggrtype(b.geometry,0.005))
                  from '||part_tab||' a, '||node_tab||' b 
                  where a.node_id = b.node_id 
                  group by link_level,partition_id)';
    execute immediate stmt;

    -- insert partition convexhull geometry metadata
    delete_geometry_metadata(l_pch_tab_name, 'GEOMETRY');
    insert_geometry_metadata(l_pch_tab_name, 'GEOMETRY');

    -- clean up partition convexhull geometry spatial index
    index_name := l_pch_tab_name ||'_idx$';
    IF (index_exists(index_name) = 'TRUE') THEN
      stmt := 'drop index '|| index_name;
      execute immediate stmt;
    END IF;

    -- create spatial index on partition convexhull geometry
    stmt := 'create index '|| index_name || ' on '||l_pch_tab_name||'(geometry)
             INDEXTYPE IS MDSYS.SPATIAL_INDEX';
    execute immediate stmt;
  END;

-- The following two procedures are features-related and will be available in future 
-- releases.
PROCEDURE create_poi_feature_layer(
  network_name       in varchar2,
  feature_layer_name in varchar2,
  feature_code       in number,
  feature_view       in varchar2,
  relation_view      in varchar2)
IS
  stmt varchar2(1024);
  poi_table varchar2(32) := 'GC_POI_NVT';
BEGIN
  -- create index on network element ids (link_id in this case)
  create_index(poi_table||'_RSI', poi_table, 'ROAD_SEGMENT_ID', NULL, NULL);

  -- create feature table view
  stmt := 'create or replace view '|| feature_view ||
  ' as select '||
   ' poi_id feature_id, '||
   ' 1 feature_type, '||
   ' loc_long x, '||
   ' loc_lat y '||
   ' from ' || poi_table ||
   ' where feature_code = '||feature_code;

  dbms_output.put_line('Creating feature table view: '||stmt);
  execute immediate stmt;

  -- create relation table view
  stmt := 'create or replace view '|| relation_view ||
  ' as select '||
   ' poi_id feature_id, '||
   ' 2 feat_elem_type, '||
   ' road_segment_id net_elem_id, '||
   ' percent start_percentage, '||
   ' 0 end_percentage, '||
   ' 1 sequence '||
   ' from ' || poi_table ||
   ' where feature_code = '||feature_code;

  dbms_output.put_line('Creating relation table view: '||stmt);
  execute immediate stmt;

  -- create feature layer
  sdo_net.add_feature_layer(
             network_name,
             feature_layer_name,
             1,             --feature layer type: point 
             feature_view,
             relation_view,
             null);

  -- insert feature user data
  stmt := 'insert into user_sdo_network_user_data '||
          '  (network, table_type, data_name, data_type, category_id) '||
          'values(:p1, :p2, :p3, :p4, :p5)';
  dbms_output.put_line('Inserting feature user data: '||stmt);
  execute immediate stmt using network_name, feature_layer_name, 'X', 'NUMBER', 3;
  execute immediate stmt using network_name, feature_layer_name, 'Y', 'NUMBER', 3;
END;

PROCEDURE update_gc_poi_percent(gc_poi_table VARCHAR2, 
                                gc_road_segment_table VARCHAR2)
IS
  stmt VARCHAR2(1024);
BEGIN
stmt := 
'update '||gc_poi_table||' p
set p.percent =
(
  select
    sdo_lrs.find_measure(
        lrsgeom,
        sdo_geometry(2001, 8307,
          SDO_POINT_TYPE(lon, lat, NULL),
          NULL, NULL)
    ) / 
    sdo_lrs.geom_segment_end_measure(lrsgeom)
  from
  (
    select * from
    (
      select
             poi.poi_id poi_id,
             poi.loc_long lon,
             poi.loc_lat lat,
             sdo_lrs.convert_to_lrs_geom(rs.GEOMETRY) lrsgeom,
             row_number() over (partition by poi_id order by loc_long) rn
      from
        '||gc_poi_table||' poi, '||
        gc_road_segment_table||' rs
      where poi.ROAD_SEGMENT_ID = rs.ROAD_SEGMENT_ID
    ) 
    where rn=1
  ) gp
  where p.poi_id = gp.poi_id
)';
execute immediate stmt;
END;
END ndmdemo_util;
/
show errors;
/

grant execute on ndmdemo_util to public;

