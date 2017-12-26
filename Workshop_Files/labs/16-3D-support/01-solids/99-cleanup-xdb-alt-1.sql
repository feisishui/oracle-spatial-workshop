-- Delete a folder and all resources in that folder (recursively)

-- WARNING: this triggers a delete of the actual resources,
-- i.e. a DELETE FROM the tables that contain the resources (if any)
-- i.e. a DELETE FROM BUILDINGS_EXT_XML

exec DBMS_XDB.deleteresource('/public/Buildings/', dbms_xdb.delete_recursive_force);
commit;

