======================================================================================
Example to illustrate the usage of the Oracle Spatial Java API from SQL
======================================================================================

1) 01_LOAD_CLASS.BAT or 01_LOAD_CLASS.SH

Loads class SdoTest.java in the database and compiles it.

This class invokes a number of "get" methods on a JGeometry object.

2) 02_PKG_SDO_TEST.SQL

PL/SQL package that defines the "wrappers" on the java methods

3) Example of use:

Isolate the geometries that contain any circular arc:

select ... from ... where sdo_test.has_circular_arcs(geom) = 'TRUE';

