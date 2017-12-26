-- Run as SYS or SYSTEM
-- If necessary, modify file spec to match your environment
call  dbms_java.revoke_permission('PUBLIC', 'SYS:java.io.FilePermission', '/media/sf_Spatial-Workshop/labs/11-georaster/temperature/*', 'read' );
