-- --------------------------------------------------------------------------
-- 3) Create hierarchical feature tables
-- --------------------------------------------------------------------------

--
-- Create feature table for US_STATES
--

DROP TABLE US_STATES_TOPO;
CREATE TABLE US_STATES_TOPO (
  ID         NUMBER PRIMARY KEY,
  STATE      VARCHAR2(30),
  STATE_ABRV VARCHAR2(2),
  FEATURE    SDO_TOPO_GEOMETRY
);

--
-- Register the feature layer with the topology
--
DECLARE
  child_layer_id number;
BEGIN
  SELECT tg_layer_id INTO child_layer_id
  FROM user_sdo_topo_info
  WHERE TOPOLOGY = 'US_LAND_USE'
  AND TABLE_NAME = 'US_COUNTIES_TOPO'
  AND COLUMN_NAME = 'FEATURE';
  SDO_TOPO.ADD_TOPO_GEOMETRY_LAYER(
    'US_LAND_USE',
    'US_STATES_TOPO',
    'FEATURE',
    'POLYGON',
    NULL,
    child_layer_id);
END;
/
