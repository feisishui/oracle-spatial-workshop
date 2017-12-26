-- Run as SYS or SYSTEM

-- Create a directory that points to the KML files
create or replace directory kml_data_dir as '/media/sf_Workshop_Files/labs/04-loading/02_import_GIS/03_others/kml_load/data/';

-- Grant access to the database user that will load the files
grant read, write on directory kml_data_dir to scott;

-- Also grant access via java (to get file names)
call dbms_java.grant_permission('SCOTT', 'SYS:java.io.FilePermission', '/media/sf_Workshop_Files/labs/04-loading/02_import_GIS/03_others/kml_load/data/' , 'read');
