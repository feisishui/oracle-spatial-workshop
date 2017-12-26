create or replace package sdo_test as
  function has_circular_arcs (g sdo_geometry) return varchar2;
  function is_circle (g sdo_geometry) return varchar2;
  function is_geodetic_mbr (g sdo_geometry) return varchar2;
  function is_lrs_geometry (g sdo_geometry) return varchar2;
  function is_point (g sdo_geometry) return varchar2;
  function is_multi_point (g sdo_geometry) return varchar2;
  function is_oriented_point (g sdo_geometry) return varchar2;
  function is_oriented_multi_point (g sdo_geometry) return varchar2;
  function is_rectangle (g sdo_geometry) return varchar2;
end;
/
show errors

create or replace package body sdo_test as
  function has_circular_arcs (g sdo_geometry) return varchar2 as
    language java
    name 'SdoTest.hasCircularArcs (oracle.sql.STRUCT) return String';

  function is_circle (g sdo_geometry) return varchar2 as
    language java
    name 'SdoTest.isCircle (oracle.sql.STRUCT) return String';

  function is_geodetic_mbr (g sdo_geometry) return varchar2 as
    language java
    name 'SdoTest.isGeodeticMBR (oracle.sql.STRUCT) return String';

  function is_lrs_geometry (g sdo_geometry) return varchar2 as
    language java
    name 'SdoTest.isLRSGeometry (oracle.sql.STRUCT) return String';

  function is_point (g sdo_geometry) return varchar2 as
    language java
    name 'SdoTest.isPoint (oracle.sql.STRUCT) return String';

  function is_multi_point (g sdo_geometry) return varchar2 as
    language java
    name 'SdoTest.isMultiPoint (oracle.sql.STRUCT) return String';

  function is_oriented_point (g sdo_geometry) return varchar2 as
    language java
    name 'SdoTest.isOrientedPoint (oracle.sql.STRUCT) return String';

  function is_oriented_multi_point (g sdo_geometry) return varchar2 as
    language java
    name 'SdoTest.isOrientedMultiPoint (oracle.sql.STRUCT) return String';

  function is_rectangle (g sdo_geometry) return varchar2 as
    language java
    name 'SdoTest.isRectangle (oracle.sql.STRUCT) return String';
end;
/
show errors
