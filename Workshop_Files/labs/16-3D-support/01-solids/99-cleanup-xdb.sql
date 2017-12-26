-- Delete all resources in a folder:

-- WARNING: this triggers a delete of the actual resources,
-- i.e. a DELETE FROM the tables that contain the resources (if any)
-- i.e. a DELETE FROM BUILDINGS_EXT_XML

-- WARNING: the delete will fail if the table that contains a resource no longer exists
-- i.e. if you dropped BUILDINGS_EXT_XML
-- If this happens, use the following syntax to force the deletion:
-- exec DBMS_XDB.deleteresource('/public/Buildings/', dbms_xdb.delete_recursive_force);

delete from resource_view
where under_path (res, '/public/Buildings') = 1;
commit;

-- Delete the folder:

-- NOTE: the folder must be empty (contains no resources or sub-folders)
delete from resource_view
where equals_path(res, '/public/Buildings') = 1;
commit;
