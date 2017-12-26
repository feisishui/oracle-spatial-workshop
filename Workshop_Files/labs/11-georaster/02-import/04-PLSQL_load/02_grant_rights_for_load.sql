-- NOTES:
--   Connect as SYS or SYSTEM to run this
--   or run from a regular user with JAVA_ADMIN rights:
--   	grant java_admin to scott;
--   Change the file specifications below to match your environment

-- Example for Windows:
-- Grant SCOTT the right to access all files in the directory containing the images to load:
call dbms_java.grant_permission('SCOTT', 'SYS:java.io.FilePermission', 'D:\Courses\Spatial-Workshop\data\11-georaster\tiff\*', 'read');
-- Grant MDSYS access to all files on the server:
call dbms_java.grant_permission('MDSYS', 'SYS:java.io.FilePermission', '<<ALL FILES>>', 'read');
-- Example for Linux :
-- Grant SCOTT the right to access all files in the directory containing the images to load:
call dbms_java.grant_permission('SCOTT', 'SYS:java.io.FilePermission', '/media/sf_Spatial-Workshop/data/11-georaster/tiff/*', 'read');
-- Grant MDSYS access to all files on the server:
call dbms_java.grant_permission('MDSYS', 'SYS:java.io.FilePermission', '<<ALL FILES>>', 'read');
