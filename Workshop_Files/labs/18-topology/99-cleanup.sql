-- --------------------------------------------------------------------------
-- Deregister the layers
-- --------------------------------------------------------------------------

-- Deregister hierarchical features
EXEC SDO_TOPO.DELETE_TOPO_GEOMETRY_LAYER ('US_LAND_USE', 'US_STATES_TOPO',  'FEATURE');

-- Deregister base features
EXEC SDO_TOPO.DELETE_TOPO_GEOMETRY_LAYER ('US_LAND_USE', 'US_COUNTIES_TOPO',  'FEATURE');
EXEC SDO_TOPO.DELETE_TOPO_GEOMETRY_LAYER ('US_LAND_USE', 'US_CITIES_TOPO',  'FEATURE');
EXEC SDO_TOPO.DELETE_TOPO_GEOMETRY_LAYER ('US_LAND_USE', 'US_INTERSTATES_TOPO',  'FEATURE');

-- Deregister feature used to record errord
EXEC SDO_TOPO.DELETE_TOPO_GEOMETRY_LAYER ('US_LAND_USE', 'TOPO_ERRORS',  'FEATURE');

-- After all feature layers are deregistered, then you can
-- drop the topology called US_LAND_USE, if it exists

EXEC SDO_TOPO.DROP_TOPOLOGY ('US_LAND_USE')

-- Finally, drop the feature tables
DROP TABLE US_CITIES_TOPO PURGE;
DROP TABLE US_COUNTIES_TOPO PURGE;
DROP TABLE US_INTERSTATES_TOPO PURGE;
DROP TABLE US_STATES_TOPO PURGE;

-- Drop the export table if it exists
-- Ignore any error
drop table US_LAND_USE_EXP$ purge;

