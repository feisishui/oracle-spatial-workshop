create or replace package body sdo_rtree as

-- =========================================================================
-- PRIVATE FUNCTIONS AND PROCEDURES
-- =========================================================================

rowid_column          varchar2(30) := 'ROWID';
data_rowid_column     varchar2(30) := 'ROWID';
index_metadata        varchar2(30) := 'USER_SDO_INDEX_METADATA';
index_info            varchar2(30) := 'USER_SDO_INDEX_INFO';

----------------------------------------------------------------------------
-- FORMAT_MBR
----------------------------------------------------------------------------
function format_mbr (
  g sdo_geometry
)
return varchar2
is
  s varchar2(2000);
begin
  s := 'SDO_GEOMETRY ('||g.sdo_gtype||', '||nvl(to_char(g.sdo_srid),'NULL')||', NULL, SDO_ELEM_INFO_ARRAY(';
  for i in 1..g.sdo_elem_info.count() loop
    s := s || g.sdo_elem_info(i);
    if i < g.sdo_elem_info.count then
      s :=  s || ', ';
    end if;
  end loop;
  s := s || '), SDO_ORDINATE_ARRAY(';

  for i in 1..g.sdo_ordinates.count() loop
    s := s || g.sdo_ordinates(i);
    if i < g.sdo_ordinates.count then
      s := s || ', ';
    end if;
  end loop;
  s := s || '))';

  return s;
end;

----------------------------------------------------------------------------
-- CREATE_RESULTS_TABLE
----------------------------------------------------------------------------
procedure create_results_table (
  p_result_table        varchar2,
  p_num_partitions      number default 1
)
is
begin
  if p_result_table is not null then
    -- First try and drop the table. Ignore any exception
    begin
      execute immediate 'DROP TABLE '||p_result_table;
    exception
      when others then null;
    end;
    -- Now create the table
    if p_num_partitions > 1 then
      execute immediate
        'CREATE TABLE '||p_result_table||
        ' (PARTITION_ID NUMBER, NODE_ROWID ROWID, NODE_ID NUMBER, NODE_LEVEL NUMBER, ENTRY_SEQUENCE NUMBER, ENTRY_ROWID ROWID, ENTRY_GEOM SDO_GEOMETRY)';
    else
      execute immediate
        'CREATE TABLE '||p_result_table||
        ' (NODE_ROWID ROWID, NODE_ID NUMBER, NODE_LEVEL NUMBER, ENTRY_SEQUENCE NUMBER, ENTRY_ROWID ROWID, ENTRY_GEOM SDO_GEOMETRY)';
    end if;
  end if;
end;

----------------------------------------------------------------------------
-- PROCESS_NODE
--   Process an index node and optionally process child nodes recursively
----------------------------------------------------------------------------

procedure process_node (
  p_index_owner         varchar2,
  p_index_table         varchar2,
  p_node_rowid          rowid,
  p_node_mbr            sdo_geometry,
  p_node_level          number,
  p_parent_node_id      number,
  p_parent_entry        number,
  p_dimensionality      number,
  p_recursive           boolean default false,
  p_max_level           number,
  p_verbose             number default 0,
  p_num_partitions      number,
  p_partition_id        number,
  p_result_table        varchar2 default null,
  p_check_data          varchar2 default 'FALSE',
  p_data_table          varchar2 default null
)
is
  node_id               number;
  node_level            number;
  actual_rowid          rowid;
  child_rowids          sys.odciridlist;
  child_mbrs            mdsys.sdo_geometry;
  child_rowid           rowid;
  child_mbr             mdsys.sdo_geometry;
  data_count            number;

begin

  -- Fetch index node
  begin
    execute immediate
      'SELECT NODE_ID, NODE_LEVEL, ROWID FROM ' || p_index_table ||
      ' WHERE ' || rowid_column || ' = :id'
      into node_id, node_level, actual_rowid
      using p_node_rowid;
  exception
    when NO_DATA_FOUND then
      node_id := null;
  end;

  -- Perform validation checks

  -- Node must exist
  if node_id is null then
    dbms_output.put_line ('**** error in node_id: '||p_parent_node_id||' entry: '||p_parent_entry);
    dbms_output.put_line ('**** child node with rowid: '||p_node_rowid||' does not exist ');
    return;
  end if;

  -- Node must be at the expected level
  if node_level <> p_node_level then
    dbms_output.put_line ('**** error in node with rowid: '||p_node_rowid || ' node_id: '|| node_id);
    dbms_output.put_line ('**** wrong node level - expected '||p_node_level || ' found '|| node_level);
  end if;

  /*
  -- Node id must be set (non-zero)
  if node_id = 0 then
    dbms_output.put_line ('**** error in node with rowid: '||p_node_rowid || ' node_id: '|| node_id);
    dbms_output.put_line ('**** node id not set');
  end if;
  */

  -- Extract child MBRs from the node
  child_mbrs := sdo_rtree_admin.sdo_rtree_childmbrs (
    schemaname  => p_index_owner,
    indextable  => p_index_table,
    dim         => p_dimensionality,
    rid         => actual_rowid);
  -- dbms_output.put_line('DBG> '||sdo_tools.format(child_mbrs));
  
  -- Extract child rowids from the node
  child_rowids := sdo_rtree_admin.sdo_rtree_childrids (
    schemaname  => p_index_owner,
    indextable  => p_index_table,
    dim         => p_dimensionality,
    rid         => actual_rowid);

  -- Dump node details
  if p_verbose > 1 then
    dbms_output.put_line ('Node :         '|| node_id);
    dbms_output.put_line ('- Rowid:       '|| p_node_rowid);
    dbms_output.put_line ('- Level:       '|| node_level);
    dbms_output.put_line ('- Num Entries: '|| child_rowids.count());
  end if;

  -- Process node entries
  if child_rowids.count() > 0 then
    for i in child_rowids.first()..child_rowids.last() loop
      child_rowid := child_rowids(i);
      -- dbms_output.put_line('DBG> '||'i='||i);
      child_mbr := sdo_util.extract(child_mbrs, i);
      -- dbms_output.put_line('DBG> '||sdo_tools.format(child_mbr));

      -- Dump entry details
      if p_verbose > 1 then
        dbms_output.put_line ('-- Entry('||i|| ') Rowid: '|| child_rowid);
        if p_verbose > 2 then
          dbms_output.put_line ('--- MBR: '|| format_mbr(child_mbr));
        end if;
      end if;

      -- If requested, write entry details into result table
      if p_result_table is not null then
        if p_num_partitions > 1 then
          execute immediate 'insert into ' || p_result_table || ' values (:1,:2,:3,:4,:5,:6,:7) '
            using
              p_partition_id,                -- Partition ID
              p_node_rowid,                  -- ROWID of index node
              node_id,                       -- Node ID
              node_level,                    -- Node level
              i,                             -- Sequence of entry in indes node
              child_rowid,                   -- object rowid
              child_mbr;                     -- object mbr
        else
          execute immediate 'insert into ' || p_result_table || ' values (:1,:2,:3,:4,:5,:6) '
            using
              p_node_rowid,                  -- ROWID of index node
              node_id,                       -- Node ID
              node_level,                    -- Node level
              i,                             -- Sequence of entry in indes node
              child_rowid,                   -- object rowid
              child_mbr;                     -- object mbr
        end if;
      end if;

      -- If requested, check the validity of keys in leaf (level 1) nodes
      if p_check_data = 'TRUE' and node_level = 1 then
        execute immediate
          'select count(*) from ' || p_data_table ||
          ' where ' || data_rowid_column || ' = :1'
        into data_count
        using child_rowid;

        if data_count = 0 then
          dbms_output.put_line ('**** error in node_id: '||node_id||' entry: '||i);
          dbms_output.put_line ('**** data record with rowid: '||child_rowid||' does not exist ');
        end if;

      end if;

    end loop;

    -- Process children nodes recursively
    for i in child_rowids.first()..child_rowids.last() loop
      child_rowid := child_rowids(i);
      child_mbr := sdo_util.extract(child_mbrs, i);
      if p_recursive and node_level > p_max_level and node_level > 1 then
        process_node (
          p_index_owner    => p_index_owner,
          p_index_table    => p_index_table,
          p_node_rowid     => child_rowid,
          p_node_mbr       => child_mbr,
          p_node_level     => node_level-1,
          p_parent_node_id => node_id,
          p_parent_entry   => i,
          p_dimensionality => p_dimensionality,
          p_recursive      => p_recursive,
          p_max_level      => p_max_level,
          p_verbose        => p_verbose,
          p_num_partitions => p_num_partitions,
          p_partition_id   => p_partition_id,
          p_result_table   => p_result_table,
          p_check_data     => p_check_data,
          p_data_table     => p_data_table
        );
      end if;
    end loop;
  end if;
end;

-- =========================================================================
-- PUBLIC FUNCTIONS AND PROCEDURES
-- =========================================================================

----------------------------------------------------------------------------
-- SCAN_INDEX procedure
----------------------------------------------------------------------------
procedure scan_index (
  p_table_name          varchar2,
  p_column_name         varchar2,
  p_verbose             number default 1,
  p_depth               number default 0,
  p_result_table        varchar2 default null,
  p_check_data          varchar2 default 'FALSE',
  p_mode                varchar2 default 'LIVE'
)
is
  current_user          varchar2(30) := sys_context('userenv', 'current_user');
  index_name            varchar2(30);
  num_partitions        number;
  partition_id          number;
  scan_depth            number;
  data_table_name       varchar2(30);
  index_table_name      varchar2(30);

  type ref_cursor is ref cursor;
  index_metadata_cursor  ref_cursor;

  r user_sdo_index_metadata%rowtype;

begin

  if p_mode = 'LIVE' then
    rowid_column := 'ROWID';
    data_rowid_column := 'ROWID';
    index_metadata := 'USER_SDO_INDEX_METADATA';
    index_info := 'USER_SDO_INDEX_INFO';
  else
    rowid_column := 'NODE_ROWID';
    data_rowid_column := 'DATA_ROWID';
    index_metadata := 'PROB_SDO_INDEX_METADATA';
    index_info := 'PROB_SDO_INDEX_INFO';
  end if;

  -- Verify if the index exists and if it is partitionned
  begin
    execute immediate
      'SELECT INDEX_NAME, COUNT(*)' ||
      ' FROM   ' || index_info ||
      ' WHERE  TABLE_NAME = UPPER(:1)' ||
      ' AND    COLUMN_NAME = UPPER(:2)' ||
      ' AND    SDO_INDEX_TYPE = ''RTREE''' ||
      ' GROUP  BY INDEX_NAME'
    into index_name, num_partitions
    using p_table_name, p_column_name;
  exception
    when no_data_found then
      raise_application_error (-20000, 'No rtree index on table ' || upper(p_table_name) || ', column ' || upper(p_column_name));
  end;

  -- Create the results table if required
  if p_result_table is not null then
    create_results_table (p_result_table, num_partitions);
  end if;

  -- Dump generic index information
  if p_verbose > 0 then
    dbms_output.put_line ('Dump of rtree index');
    dbms_output.put_line ('- Table name:      '|| upper(p_table_name));
    dbms_output.put_line ('- Column name:     '|| upper(p_column_name));
    dbms_output.put_line ('- Index name:      '|| index_name);
    if num_partitions > 1 then
      dbms_output.put_line ('- Partitions:      '|| num_partitions);
    end if;
  end if;

  -- Range over rtrees (one tree per partition)
  partition_id := 1;
  open index_metadata_cursor for
    'SELECT *' ||
    ' FROM  ' || index_metadata  ||
    ' WHERE SDO_INDEX_NAME = :1 ' ||
    ' ORDER BY SDO_INDEX_PARTITION'
    using index_name;
  loop
     -- Get the metadata row
     fetch index_metadata_cursor into r;
      exit when index_metadata_cursor%notfound;

    -- Get actual name of index and data tables
    if p_mode = 'LIVE' then
      index_table_name := r.sdo_index_table;
      data_table_name := p_table_name;
    else
      index_table_name := 'PROB_' || r.sdo_index_table || '_IND';
      data_table_name := 'PROB_' || r.sdo_index_table || '_DAT';
    end if;

    -- Dump rtree details
    if p_verbose > 0 then
      if num_partitions > 1 then
        dbms_output.put_line ('Partition:         '|| r.sdo_index_partition);
      end if;
      dbms_output.put_line ('- Index table:     '|| index_table_name);
      dbms_output.put_line ('- Levels:          '|| r.sdo_rtree_height);
      dbms_output.put_line ('- Nodes:           '|| r.sdo_rtree_num_nodes);
      dbms_output.put_line ('- Dimensionality:  '|| r.sdo_rtree_dimensionality);
      dbms_output.put_line ('- Fanout:          '|| r.sdo_rtree_fanout);
      dbms_output.put_line ('- Root rowid:      '|| r.sdo_rtree_root);
      if p_verbose > 1 then
        dbms_output.put_line ('- Root MBR:        '|| format_mbr (r.sdo_root_mbr));
      end if;
    end if;

    -- Process index tree, starting from root
    if p_depth > 0 then
      process_node (
        p_index_owner    => current_user,
        p_index_table    => index_table_name,
        p_node_rowid     => r.sdo_rtree_root,
        p_node_mbr       => r.sdo_root_mbr,
        p_node_level     => r.sdo_rtree_height,
        p_parent_node_id => null,
        p_parent_entry   => null,
        p_dimensionality => r.sdo_rtree_dimensionality,
        p_recursive      => true,
        p_max_level      => r.sdo_rtree_height - p_depth + 1,
        p_verbose        => p_verbose,
        p_num_partitions => num_partitions,
        p_partition_id   => partition_id,
        p_result_table   => p_result_table,
        p_check_data     => p_check_data,
        p_data_table     => data_table_name
      );
    end if;

    -- Next partition
    partition_id := partition_id + 1;
  end loop;

  if p_result_table is not null then
    dbms_output.put_line ('Index structure dumped into table '||p_result_table);
    -- Commit the writes to the result table
    commit;
  end if;

end;

----------------------------------------------------------------------------
-- SCAN_INDEX_TABLE
----------------------------------------------------------------------------

procedure scan_index_table (
  p_index_table         varchar2,
  p_dimensionality      number default 2,
  p_verbose             number default 1,
  p_depth               number default 0,
  p_result_table        varchar2 default null,
  p_check_data          varchar2 default 'FALSE',
  p_data_table          varchar2 default null,
  p_mode                varchar2 default 'LIVE'

)
is
  current_user          varchar2(30) := sys_context('userenv', 'current_user');
  root_node_id          number;
  root_rowid            rowid;
  root_mbr              sdo_geometry;
  root_level            number;
  num_nodes             number;
begin

  if p_mode = 'LIVE' then
    rowid_column := 'ROWID';
    data_rowid_column := 'ROWID';
    index_metadata := 'USER_SDO_INDEX_METADATA';
    index_info := 'USER_SDO_INDEX_INFO';
  else
    rowid_column := 'NODE_ROWID';
    data_rowid_column := 'DATA_ROWID';
    index_metadata := 'PROB_SDO_INDEX_METADATA';
    index_info := 'PROB_SDO_INDEX_INFO';
  end if;

  -- Locate root node
  execute immediate
    'select count(*), max(node_level) from ' || p_index_table
    into num_nodes, root_level;
  execute immediate
    'select '||rowid_column||', node_id from ' || p_index_table ||
    ' where node_level = :1'
    into root_rowid, root_node_id
    using root_level;

  -- Dump generic index information
  if p_verbose > 0 then
    dbms_output.put_line ('Dump of rtree index');
    dbms_output.put_line ('- Index Table name: '|| upper(p_index_table));
    dbms_output.put_line ('- Levels:           '|| root_level);
    dbms_output.put_line ('- Nodes:            '|| num_nodes);
    dbms_output.put_line ('- Root rowid:       '|| root_rowid);
  end if;

  -- Create the results table if required
  if p_result_table is not null then
    create_results_table (p_result_table);
  end if;

  -- Process index tree
  process_node (
    p_index_owner    => current_user,
    p_index_table    => p_index_table,
    p_node_rowid     => root_rowid,
    p_node_mbr       => root_mbr,
    p_node_level     => root_level,
    p_parent_node_id => null,
    p_parent_entry   => null,
    p_dimensionality => p_dimensionality,
    p_recursive      => true,
    p_max_level      => root_level - p_depth + 1,
    p_verbose        => p_verbose,
    p_num_partitions => 1,
    p_partition_id   => 1,
    p_result_table   => p_result_table,
    p_check_data     => p_check_data,
    p_data_table     => p_data_table
  );

  if p_result_table is not null then
    dbms_output.put_line ('Index structure dumped into table '||p_result_table);
    -- Commit the writes to the result table
    commit;
  end if;

end;

----------------------------------------------------------------------------
-- SCAN_INDEX_NODES
----------------------------------------------------------------------------

procedure scan_index_nodes (
  p_index_table         varchar2,
  p_dimensionality      number default 2,
  p_verbose             number default 1,
  p_result_table        varchar2 default null,
  p_check_data          varchar2 default 'FALSE',
  p_data_table          varchar2 default null,
  p_mode                varchar2 default 'LIVE'
)
is
  current_user          varchar2(30) := sys_context('userenv', 'current_user');
  root_node_id          number;
  root_rowid            rowid;
  root_level            number;
  num_nodes             number;
  node_rowid            rowid;

  -- Cursors used to fetch index nodes
  type ref_cursor is ref cursor;
  index_cursor       ref_cursor;

begin

  if p_mode = 'LIVE' then
    rowid_column := 'ROWID';
    data_rowid_column := 'ROWID';
    index_metadata := 'USER_SDO_INDEX_METADATA';
    index_info := 'USER_SDO_INDEX_INFO';
  else
    rowid_column := 'NODE_ROWID';
    data_rowid_column := 'DATA_ROWID';
    index_metadata := 'PROB_SDO_INDEX_METADATA';
    index_info := 'PROB_SDO_INDEX_INFO';
  end if;

  -- Locate root node
  execute immediate
    'select count(*), max(node_level) from ' || p_index_table
    into num_nodes, root_level;
  execute immediate
    'select ' || rowid_column || ', node_id from ' || p_index_table ||
    ' where node_level = :1'
    into root_rowid, root_node_id
    using root_level;

  -- Dump generic index information
  if p_verbose > 0 then
    dbms_output.put_line ('Dump of rtree index');
    dbms_output.put_line ('- Index Table name: '|| upper(p_index_table));
    dbms_output.put_line ('- Levels:           '|| root_level);
    dbms_output.put_line ('- Nodes:            '|| num_nodes);
    dbms_output.put_line ('- Root rowid:       '|| root_rowid);
  end if;

  -- Create the results table if required
  if p_result_table is not null then
    create_results_table (p_result_table);
  end if;

  -- Range over index nodes in the layer
  open index_cursor for
    'select ' || rowid_column || ' from ' || p_index_table || ' order by node_level desc, node_id asc';
  loop
    -- Get the rowid of the index node
    fetch index_cursor into node_rowid;
      exit when index_cursor%notfound;

    -- Process index node (non recursive)
    process_node (
      p_index_owner    => current_user,
      p_index_table    => p_index_table,
      p_node_rowid     => node_rowid,
      p_node_mbr       => null,
      p_node_level     => null,
      p_parent_node_id => null,
      p_parent_entry   => null,
      p_dimensionality => p_dimensionality,
      p_recursive      => false,
      p_max_level      => 0,
      p_verbose        => p_verbose,
      p_num_partitions => 1,
      p_partition_id   => 1,
      p_result_table   => p_result_table,
      p_check_data     => p_check_data,
      p_data_table     => p_data_table
    );

  end loop;
  close index_cursor;

  if p_result_table is not null then
    dbms_output.put_line ('Index structure dumped into table '||p_result_table);
    -- Commit the writes to the result table
    commit;
  end if;

end;

----------------------------------------------------------------------------
-- SCAN_INDEX Pipelined function
----------------------------------------------------------------------------
function scan_index (
  p_table_name          varchar2,
  p_column_name         varchar2,
  p_mode                varchar2 default 'LIVE'
)
return sdo_index_entry_set pipelined
is
  current_user          varchar2(30) := sys_context('userenv', 'current_user');
  index_name            varchar2(30);
  index_table_name      varchar2(30);
  num_partitions        number;
  partition_id          number;
  type ref_cursor is ref cursor;
  index_metadata_cursor ref_cursor;
  index_cursor          ref_cursor;
  r user_sdo_index_metadata%rowtype;
  index_entry           sdo_index_entry;

  node_id               number;
  node_level            number;
  actual_rowid          rowid;

  child_rowids          sys.odciridlist;
  child_mbrs            mdsys.sdo_geometry;
  child_rowid           rowid;
  child_mbr             mdsys.sdo_geometry;

begin

  if p_mode = 'LIVE' then
    rowid_column := 'ROWID';
    data_rowid_column := 'ROWID';
    index_metadata := 'USER_SDO_INDEX_METADATA';
    index_info := 'USER_SDO_INDEX_INFO';
  else
    rowid_column := 'NODE_ROWID';
    data_rowid_column := 'DATA_ROWID';
    index_metadata := 'PROB_SDO_INDEX_METADATA';
    index_info := 'PROB_SDO_INDEX_INFO';
  end if;

  -- Verify if the index exists and if it is partitionned
  begin
    execute immediate
      'SELECT INDEX_NAME, COUNT(*)' ||
      ' FROM   ' || index_info ||
      ' WHERE  TABLE_NAME = UPPER(:1)' ||
      ' AND    COLUMN_NAME = UPPER(:2)' ||
      ' AND    SDO_INDEX_TYPE = ''RTREE''' ||
      ' GROUP  BY INDEX_NAME'
    into index_name, num_partitions
    using p_table_name, p_column_name;
  exception
    when no_data_found then
      raise_application_error (-20000, 'No rtree index on table ' || upper(p_table_name) || ', column ' || upper(p_column_name));
  end;

  -- Range over rtrees (one tree per partition)
  partition_id := 1;
  open index_metadata_cursor for
    'SELECT *' ||
    ' FROM  ' || index_metadata  ||
    ' WHERE SDO_INDEX_NAME = :1 ' ||
    ' ORDER BY SDO_INDEX_PARTITION'
    using index_name;
  loop
     -- Get the metadata row
     fetch index_metadata_cursor into r;
      exit when index_metadata_cursor%notfound;

    -- Get actual name of index and data tables
    if p_mode = 'LIVE' then
      index_table_name := r.sdo_index_table;
    else
      index_table_name := 'PROB_' || r.sdo_index_table || '_IND';
    end if;

    -- Process index table sequentially
    open index_cursor for
      'SELECT NODE_ID, NODE_LEVEL, ROWID FROM ' || index_table_name;

    loop
      -- Get index node
      fetch index_cursor into node_id, node_level, actual_rowid;
        exit when index_cursor%notfound;

      -- Extract child MBRs from the node
      child_mbrs := sdo_rtree_admin.sdo_rtree_childmbrs (
        schemaname  => current_user,
        indextable  => index_table_name,
        dim         => r.sdo_rtree_dimensionality,
        rid         => actual_rowid
      );

      -- Extract child rowids from the node
      child_rowids := sdo_rtree_admin.sdo_rtree_childrids (
        schemaname  => current_user,
        indextable  => index_table_name,
        dim         => r.sdo_rtree_dimensionality,
        rid         => actual_rowid
      );

      -- Process node entries
      if child_rowids.count() > 0 then
        for i in child_rowids.first()..child_rowids.last()
        loop
          child_rowid := child_rowids(i);
          child_mbr := sdo_util.extract(child_mbrs, i);
          index_entry := sdo_index_entry (
            actual_rowid,                  -- ROWID of index node
            node_id,                       -- Node ID
            node_level,                    -- Node level
            i,                             -- Sequence of entry in indes node
            child_rowid,                   -- object rowid
            child_mbr                      -- object mbr
          );
          pipe row (index_entry);
        end loop;
      end if;

    end loop;

    -- Next partition
    partition_id := partition_id + 1;
  end loop;

end;

----------------------------------------------------------------------------
-- SAVE_STATE
----------------------------------------------------------------------------

procedure save_state
is
begin
  -- Save index metadata
  execute immediate
    'CREATE TABLE PROB_SDO_INDEX_METADATA AS' ||
    '  SELECT *' ||
    '  FROM USER_SDO_INDEX_METADATA';
  execute immediate
    'CREATE TABLE PROB_SDO_INDEX_INFO AS' ||
    '  SELECT *' ||
    '  FROM USER_SDO_INDEX_INFO';

  -- Save tables
  for t in (select * from user_sdo_index_info)
  loop
    execute immediate
      'CREATE TABLE PROB_'||t.sdo_index_table||'_DAT AS' ||
      '  SELECT ROWID DATA_ROWID,' || t.column_name ||
      '  FROM ' || t.table_name;
    end loop;
  -- Save spatial indexes
  for t in (select * from user_sdo_index_info)
  loop
    execute immediate
      'CREATE TABLE PROB_'||t.sdo_index_table||'_IND AS' ||
      '  SELECT ROWID NODE_ROWID, NODE_ID, NODE_LEVEL, INFO' ||
      '  FROM ' || t.sdo_index_table;
    end loop;
end;

end sdo_rtree;
/
show errors
