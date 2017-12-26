drop table fields purge;
create table fields (
  id number primary key,
  file_name varchar2(40),
  kml CLOB,
  geometry sdo_geometry
);
