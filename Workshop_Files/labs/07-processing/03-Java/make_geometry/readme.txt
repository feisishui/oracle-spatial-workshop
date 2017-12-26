================================================================================
Example to illustrate using the Oracle Spatial Java API from SQL
================================================================================

This example show how you can use Java and the Oracle Spatial Java API to construct geometries so they can be read in SQL.

You need the following

1) A Java class that implements the methods we need

This is class MakeGeometry. It has two methods:

- point returns a geometric point given an pair of coordinates

- line returns a geometric line given a string that contains a comma-separated list of coordinates

Both methods are static. This is required for them to be invoked from SQL. Both return a java.sql.Struct: this is how database objects are passed to and from Java.

For example, method "point" is like this:

  public static Struct point (
    float x,
    float y,
    int srid
  )
  throws Exception
  {
    // Construct new geometry
    JGeometry geometry = new JGeometry(x,y,srid);
    // Make it into a java.sql.Struct
    OracleDriver ora = new OracleDriver(); 
    Struct SDOgeometry = JGeometry.storeJS(geometry,ora.defaultConnection()); 
    // Return it
    return SDOgeometry;
  }

Notice that method JGeometry.storeJS needs a database connection. This is because it needs to access the descriptors of the object type (SDO_GEOMETRY) we want to produce.

Notice also that we are using a "default" connection. This is because the code executes inside the database. The default connection uses he database-side internal driver to connect to the database where the java code runs.

You need to load the class into the database. Use the following syntax

loadjava -user <username>/<tiger>@<database> -resolve -force MakeGeometry.java -verbose


2) PL/SQL wwrapper functions around the methods.

Define a wrapper function for each method you want to expose to SQL. Here we will use a package ("make_geometry") to group those functions. The body of function "point" is like this:

  function point (x number, y number, srid number) return sdo_geometry as
    language java
    name 'MakeGeometry.point (float, float, int) return java.sql.Struct';

Script pkg_make_geometry.sql creates the package.


3) Examples of use

- to make a geometric point:

SQL> select make_geometry.point(45.3, 27.6, 4326) from dual;

SDO_GEOMETRY(2001, 4326, SDO_POINT_TYPE(45.2999992, 27.6000004, NULL), NULL, NULL)

1 row selected.

SQL> select make_geometry.line('-85.981201, 42.812271, -85.983688, 42.812271, -85.98645, 42.812271', 4326) from dual;

SDO_GEOMETRY(2002, 4326, NULL, SDO_ELEM_INFO_ARRAY(1, 2, 1), SDO_ORDINATE_ARRAY(-85.981201, 42.812271, -85.983688, 42.812271, -85.98645, 42.812271))

1 row selected.
