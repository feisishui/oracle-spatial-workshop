create or replace package sdo_rtree authid current_user as

/*

The procedures in this package can be used to analyze, verify and examine
the structures of RTREE indexes.

They can operate in two modes: "LIVE" or "DEBUG"

* In "LIVE" mode, the procedures use all information (metadata, indexes, data tables
  in their original location

* In "DEBUG" mode, the procedures use a copy of the information extracted from
  the original database and exported to another database.

  In this mode, the procedures use the following tables:

  PROB_SDO_INDEX_INFO = copy of the USER_SDO_INDEX_INFO view
  PROB_SDO_INDEX_METADATA = copy of the USER_SDO_INDEX_METADATA view

  For each rtree index:

  PROB_MDRT_xxxxxx$_IND = copy of the MDRT_xxxxxx$ table

  That table has the following structure:

    NODE_ROWID    ROWID
    NODE_ID       NUMBER
    NODE_LEVEL    NUMBER
    INFO          BLOB

  where NODE_ID, NODE_LEVEL, INFO come from the original index table, and
  NODE_ROWID contains the ROWID of the row in the original index table.

  PROB_MDRT_xxxxxx$_DAT = copy of the geometries from the original data table

  That table has the following structure:

    DATA_ROWID    ROWID
    GEOM          SDO_GEOMETRY

  where GEOMETRY contains the geometry in the original data row, and
  DATA_ROWID is the rowid of the original data row.

  Procedure SAVE_STATE can be used to create the above tables from a
  live environment.
  
Examples of use:

1) Find out the fullness of nodes

First extract the index structure into a flat table:

SQL> exec sdo_rtree.scan_index('us_parks_p','geom',1,9,'us_parks_sx')

Dump of rtree index
- Table name:      US_PARKS_P
- Column name:     GEOM
- Index name:      US_PARKS_P_SX
- Index table:     MDRT_18009$
- Levels:          3
- Nodes:           214
- Dimensionality:  2
- Fanout:          34
- Root rowid:      AAAYAKAAGAABDWEAAB
Index structure dumped into table us_parks_sx

Then analyze that table:

select count(*), numkeys 
from (
  select node_id, count(*) numkeys 
  from us_parks_sx 
  group by node_id
) 
group by numkeys;

  COUNT(*)    NUMKEYS
---------- ----------
       210         31
         1         20
         1         24
         1         23
         1          7

5 rows selected.

*/

/*
  NAME:
    SCAN_INDEX

  DESCRIPTION:
    This procedure scans and dumps the contents of an RTREE index.
    It starts from the root node and walks its way down all the nodes
    of the RTREE, reporting any errors it discovers.

    Optionally, it can dump the structure of the index to your SQLPLUS
    console. This will only work for small indices, since the amount of
    output that can be produced is limited by the setting of the SERVEROUTPUT
    parameter.

    It can also write the details of all nodes to a table. If the table does
    not exist, the procedure will create it like this:

    CREATE TABLE <p_result_table> (
      NODE_ROWID      ROWID,              -- Rowid of original index node
      NODE_ID         NUMBER,             -- ID of index node
      NODE_LEVEL      NUMBER,             -- Level of index node
      ENTRY_SEQUENCE  NUMBER,             -- Sequence number of entry in node
      ENTRY_ROWID     ROWID,              -- Rowid of entry
      ENTRY_GEOM      SDO_GEOMETRY        -- Geometry (MBR) of entry
    );

    You can choose the depth at which to perform the index analysis. The
    default is 0, i.e. do not process the index table at all. Depth levels
    are computed from the top, where 1 is the root node, 2 are the nodes
    under the root node, etc.

 ARGUMENTS:
    p_table_name:
      the name of the spatial table on which the index is defined.
    p_column_name:
      the name of the spatial column.on which the index is defined.
    p_verbose:
      specifies the amount of information the procedure will print
        0 = do not print any details
        1 = print an overview of the index (number of levels, number of nodes, ...)
            This is the default setting.
        2 = print the structure of all  index nodes
        3 = print also the geometry of the MBRs in each node
    p_depth:
      the depth of the analysis to perform.
    p_result_table:
      the name of a result table in which to write a copy of the index. If not specified, then
      no output is produced. If the table already exists, it will be dropped first.
    p_check_data
      Set to TRUE or FALSE (default is FALSE). If set to TRUE, the procedure will check that the
      rowid of a leaf key is valid, i.e. that the corresponding table row exists.
    p_mode: ('LIVE' or 'DEBUG')
      specifies whether the processing happens on a live index table or on a copy of the table.

  RETURNS
    none
*/

procedure scan_index (
  p_table_name          varchar2,
  p_column_name         varchar2,
  p_verbose             number default 1,
  p_depth               number default 0,
  p_result_table        varchar2 default null,
  p_check_data          varchar2 default 'FALSE',
  p_mode                varchar2 default 'LIVE'
);

procedure scan_index_table (
  p_index_table         varchar2,
  p_dimensionality      number default 2,
  p_verbose             number default 1,
  p_depth               number default 0,
  p_result_table        varchar2 default null,
  p_check_data          varchar2 default 'FALSE',
  p_data_table          varchar2 default null,
  p_mode                varchar2 default 'LIVE'
);

procedure scan_index_nodes (
  p_index_table         varchar2,
  p_dimensionality      number default 2,
  p_verbose             number default 1,
  p_result_table        varchar2 default null,
  p_check_data          varchar2 default 'FALSE',
  p_data_table          varchar2 default null,
  p_mode                varchar2 default 'LIVE'
);

function scan_index (
  p_table_name          varchar2,
  p_column_name         varchar2,
  p_mode                varchar2 default 'LIVE'
)
return sdo_index_entry_set pipelined;

procedure save_state;

end;
/
show errors
