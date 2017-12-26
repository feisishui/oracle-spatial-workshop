create table html_pages (
  id number primary key,
  file_name varchar2(40),
  table_name varchar2(30),
  html CLOB,
  mbr sdo_geometry
);
