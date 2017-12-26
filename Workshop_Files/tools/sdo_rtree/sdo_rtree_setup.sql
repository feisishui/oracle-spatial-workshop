CREATE OR REPLACE TYPE SDO_INDEX_ENTRY AS OBJECT (
  NODE_ROWID      VARCHAR2(18),       -- Rowid of original index node
  NODE_ID         NUMBER,             -- ID of index node
  NODE_LEVEL      NUMBER,             -- Level of index node
  ENTRY_SEQUENCE  NUMBER,             -- Sequence number of entry in node
  ENTRY_ROWID     VARCHAR2(18),       -- Rowid of entry
  ENTRY_GEOM      SDO_GEOMETRY        -- Geometry (MBR) of entry
);
/
CREATE OR REPLACE TYPE SDO_INDEX_ENTRY_SET AS TABLE OF SDO_INDEX_ENTRY;
/
