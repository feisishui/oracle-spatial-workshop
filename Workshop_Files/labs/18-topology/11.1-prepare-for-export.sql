-- Prepare for export
-- This will create a table called US_LAND_USE_EXP$ that contains the same information as
-- the USER_SDO_TOPO_INFO view (i.e. a list of all features tables in that topology)
exec sdo_topo.prepare_for_export ('US_LAND_USE');
