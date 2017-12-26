-- NOTES:
--   Connect as SYS or SYSTEM to run this
--   Change the file specification below to match your environment

call dbms_java.revoke_permission('SCOTT', 'java.io.FilePermission', 'D:\Courses\Spatial11g-Workshop\data\04-loading\shape\*', 'read');
call dbms_java.revoke_permission('MDSYS', 'java.io.FilePermission', '<<ALL FILES>>', 'read');

