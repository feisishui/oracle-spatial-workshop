-- Run as SYSTEM or SYS

create or replace directory CSW_XML as 'D:\Courses\Spatial11g-Workshop\labs\16-Web-Services\03-CSW';

begin
  mdsys.SDO_CSW_PROCESS.insertCapabilitiesInfo(
    xmltype(
      bfilename('CSW_XML', 'CSWcapabilitiesTemplate.xml'),
      nls_charset_id('AL32UTF8')
    )
  );
end;
/
commit;

