-- --------------------------------------------------------------------------
-- 6) Initialize the metadata for the topology
-- --------------------------------------------------------------------------
exec sdo_topo.initialize_metadata('US_LAND_USE');

-- This is a required step!
-- If not done topo queries will be slow and spatial queries fail
-- drops and re-creates the sequences <topology_name>_NODE_S, <topology_name>_EDGE_S, <topology_name>_FACE_S,
-- initializes the sequences to the max id of each table +2
-- create spatial indexes on the geometry columns in the topology primitive tables (node, edge, face)
-- creates secondary indexes on primitive tables
--   EDGES: start node, end node, left face, right face
--   NODES: face id
--   FACES: -NONE-

