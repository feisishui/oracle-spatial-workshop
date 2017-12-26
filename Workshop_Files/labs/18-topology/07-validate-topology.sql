-- Note: calling this function in a SELECT ... FROM DUAL is not allowed.!
-- Will fail with:
--   ORA-29532: Java call terminated by uncaught Java exception:
--   java.sql.SQLException:
--   ORA-14551: cannot perform a DML operation inside a query; use a call statement or a PL/SQL program to execute the function

VARIABLE validation_result VARCHAR2(256);

-- Validate at level 0 only
CALL sdo_topo_map.validate_topology('US_LAND_USE','FALSE',0) into :validation_result;
PRINT validation_result;

-- Validate at level 0 and level 1
CALL sdo_topo_map.validate_topology('US_LAND_USE','FALSE',1) into :validation_result;
PRINT validation_result;
