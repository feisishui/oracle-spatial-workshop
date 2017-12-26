-- (Run as SYSTEM or SYS)

-- This script allows you to change the ports used by XDB for the HTTP and FTP protocols
-- The default ports (after database creation) are 8080 for HTTP and 2100 for FTP

-- Check the current port settings
select dbms_xdb.gethttpport as "HTTP-Port",
       dbms_xdb.getftpport as "FTP-Port"
from   dual;

-- Set HTTP and FTP Ports for XDB to standard ports
exec dbms_xdb.setHTTPPort(8090);
exec dbms_xdb.setFTPPort(21);

-- If you want, you can restrict access to local system only (it is enabled by default)
exec dbms_xdb.setlistenerlocalaccess(false);

-- Verify settings
select dbms_xdb.gethttpport as "HTTP-Port",
       dbms_xdb.getftpport as "FTP-Port"
from   dual;

-- Optionally add mime type mappings for KML
begin
  dbms_xdb.deletemimemapping('kml');
  dbms_xdb.deletemimemapping('kmz');
end;
/
begin
  dbms_xdb.addmimemapping('kml','application/vnd.google-earth.kml+xml');
  dbms_xdb.addmimemapping('kmz','application/vnd.google-earth.kmz');
end;
/
commit;

-- Check the full XDB configuration:
select DBMS_XDB.cfg_get() from dual;
