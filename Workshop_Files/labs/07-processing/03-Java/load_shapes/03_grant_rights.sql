-- NOTES:
--   Connect as SYS or SYSTEM to run this
--   Change the file specification below to match your environment

-- Grant SCOTT the right to access all files in the directory containing the files to load:
call dbms_java.grant_permission('SCOTT', 'SYS:java.io.FilePermission', 'D:\Courses\Spatial11g-Workshop\data\04-loading\shape\*', 'read');

-- Grant MDSYS access to all files on the server:
call dbms_java.grant_permission('MDSYS', 'SYS:java.io.FilePermission', '<<ALL FILES>>', 'read');
