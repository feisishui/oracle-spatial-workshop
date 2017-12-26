drop type sdo_route;
drop type sdo_route_segments;
drop type sdo_route_segment;

create or replace type sdo_route_segment as object (
  sequence      number,
  instruction   varchar2(256),
  distance      number,
  time          number
);
/

create or replace type sdo_route_segments as varray(32768) of sdo_route_segment;
/

create or replace type sdo_route as object (
  distance      number,
  time          number,
  directions    sdo_route_segments,
  geometry      sdo_geometry
);
/
show errors
