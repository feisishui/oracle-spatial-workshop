-- --------------------------------------------------------------------------
-- 1) Create the topology called US_LAND_USE
-- --------------------------------------------------------------------------

EXECUTE SDO_TOPO.CREATE_TOPOLOGY ('US_LAND_USE', 1, 8307);

-- Creates topology tables <topology_name>_NODE$, <topology_name>_EDGE$, <topology_name>_FACE$ as well as <topology_name>_HISTORY$
-- Defines primary keys on each table (node_id, edge_id, face_id, ...)
-- Creates sequences <topology_name>_NODE_S, <topology_name>_EDGE_S, <topology_name>_FACE_S,
-- Sets up spatial metadata (user_sdo_geom_metadata) for the three tables.

--
-- Fix bounds (incorrectly set by the previous call)
--

update user_sdo_geom_metadata
   set diminfo = SDO_DIM_ARRAY(
                   SDO_DIM_ELEMENT('X', -180, 180, 1),
                   SDO_DIM_ELEMENT('Y', -90, 90, 1))
where  table_name like 'US_LAND_USE%$';
commit;

--
-- Create the universal face
--

INSERT INTO US_LAND_USE_face$ (
  face_id,
  boundary_edge_id,
  island_edge_id_list,
  island_node_id_list,
  mbr_geometry)
VALUES (
  -1,
  NULL,
  SDO_LIST_TYPE(),
  SDO_LIST_TYPE(),
  NULL
);

commit;
