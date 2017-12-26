-- Run as MDSYS, SYSTEM or SYS

-- Define a directory
create or replace directory WFS_XML as 'D:\Courses\Spatial11g-Workshop\labs\16-Web-Services\02-WFS';

-- Load the capabilities from the provided template
begin
  SDO_WFS_PROCESS.insertCapabilitiesInfo(
    xmltype(
      bfilename('WFS_XML', 'WFScapabilitiesTemplate.xml'),
      nls_charset_id('AL32UTF8')
    )
  );
end;
/

-- Commit the change
commit;
