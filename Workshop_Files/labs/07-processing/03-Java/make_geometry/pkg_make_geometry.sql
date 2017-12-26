create or replace package make_geometry as
  function point (x number, y number, srid number) return sdo_geometry;
  function line (coordinates varchar2, srid number) return sdo_geometry;
end;
/
show errors

create or replace package body make_geometry as

  function point (x number, y number, srid number) return sdo_geometry as
    language java
    name 'MakeGeometry.point (float, float, int) return java.sql.Struct';
    
  function line (coordinates varchar2, srid number) return sdo_geometry as
    language java
    name 'MakeGeometry.line (java.lang.String, int) return java.sql.Struct';
end;
/
show errors
