-- Connect as SYS or SYSTEM

-- Change the file specification below to match your environment

-- Example for Windows:
call dbms_java.revoke_permission('SCOTT', 'java.io.FilePermission', 'D:\Courses\Spatial11g-Workshop\data\11-georaster\tiff\*', 'read');
call dbms_java.revoke_permission('MDSYS', 'java.io.FilePermission', '<<ALL FILES>>', 'read');
-- Example for Linux :
call dbms_java.revoke_permission('SCOTT', 'SYS:java.io.FilePermission', '/media/sf_Spatial-Workshop/data/11-georaster/tiff/*', 'read');
call dbms_java.revoke_permission('MDSYS', 'SYS:java.io.FilePermission', '<<ALL FILES>>', 'read');
