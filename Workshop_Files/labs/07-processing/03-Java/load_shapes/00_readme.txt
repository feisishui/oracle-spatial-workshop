======================================================================================
This example illustrates how to load a shape file from SQL by calling the java loader.
======================================================================================

1) 01_LOAD_CLASS.BAT or 01_LOAD_CLASS.SH

Loads class SdoLoadShape.java in the database and compiles it.

This is the same class as in the "programs"
directory. It can be used as a stand-alone program from the command line, or
it can be invoked by calling method loadShapeFile:

  public static void loadShapeFile(
    String shapeFileName, int srid, String tableName, String geoColumn, String idColumn,
    int createTable, int commitFrequency, int fastPickle, int verbose
  )


2) 02_PROC_LOAD_SHAPEFILE.SQL

This is the stand-alone procedure that acts as a wrapper to call the jave method.

3) 03_GRANT_RIGHTS.SQL

This script grants the rights needed by the database user to be allowed to read the
shape files from disk. It must be run by a privileged user (system or sys).

4) 04_SHOW_RIGHTS.SQL

Shows the rights granted. Use it to verify that the rights are correctly granted.

5) 05_LOAD_SHAPE.SQL

Loads shape file WORLD_COUNTRIES into the database.

6) 06_PACKAGE_SHAPE_FILES.SQL

This defines a package SHAPE_FILES with one procedure LOAD. This procedure provides
default values before calling the actual wrapper on the java method. This is to
overcome a current limitation that prevents us from specifying default values
on wrappers to java method calls.

7) 07_LOAD_SHAPE_PACKAGE.SQL

Shows how to use the packaged procedure with default values.

08) 08_REVOKE_RIGHTS.SQL

Revokes the rights you granted previously