-- Run as SYS or SYSTEM
-- If necessary, modify file specs to match your environment
call  dbms_java.grant_permission( 
  'PUBLIC', 
  'SYS:java.io.FilePermission', 
  '/media/sf_Spatial-Workshop/labs/11-georaster/temperature/*', 'read' 
);
