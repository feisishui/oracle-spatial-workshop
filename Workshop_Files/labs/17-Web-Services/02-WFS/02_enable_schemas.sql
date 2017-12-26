-- Run as MDSYS, SYSTEM or SYS
exec SDO_WFS_PROCESS.GrantMDAccessToUser('SCOTT');

-- Not sure if commit is necessary
commit;