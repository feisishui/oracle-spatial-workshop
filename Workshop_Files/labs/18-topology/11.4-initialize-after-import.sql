-- Restore the topology metadata and other structures after an import
-- This will read a table called US_LAND_USE_EXP$ that contains the same information as
-- the USER_SDO_TOPO_INFO view (i.e. a list of all features tables in that topology)
exec sdo_topo.initialize_after_import ('US_LAND_USE');
