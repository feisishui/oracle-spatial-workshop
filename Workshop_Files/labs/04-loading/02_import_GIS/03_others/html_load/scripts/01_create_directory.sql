-- Run as SYS or SYSTEM

-- Create a directory that points to the KML files
create or replace directory html_data_dir as '/media/sf_Spatial-Workshop/labs/04-loading/02_import_GIS/03_others/html_load/data';

-- Grant access to the database user that will load the files
grant read, write on directory html_data_dir to scott;

-- Also grant access via java (to get file names)
call dbms_java.grant_permission('SCOTT', 'SYS:java.io.FilePermission', '/media/sf_Spatial-Workshop/labs/04-loading/02_import_GIS/03_others/html_load/data', 'read');
