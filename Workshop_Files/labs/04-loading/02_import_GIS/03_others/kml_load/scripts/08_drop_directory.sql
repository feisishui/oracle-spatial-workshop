-- Run as SYS or SYSTEM

-- Revoke access from the database user
revoke read, write on directory html_data_dir from scott;

-- Also revoke access via java (to get file names)
call dbms_java.revoke_permission('SCOTT', 'SYS:java.io.FilePermission', '/media/sf_Spatial-Workshop/labs/04-loading/02_import_GIS/03_others/html/data', 'read');

-- Drop the directory
drop directory kml_data_dir;

