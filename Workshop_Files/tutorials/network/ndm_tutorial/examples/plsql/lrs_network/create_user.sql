-- As a DBA user, create a user for this example with necessary privileges.
sqlplus system/manager

grant connect,resource, create view to mdnetwork identified by mdnetwork;

create or replace directory WORK_DIR as 'c:\temp';

grant read,write on directory WORK_DIR to mdnetwork;

exit;

