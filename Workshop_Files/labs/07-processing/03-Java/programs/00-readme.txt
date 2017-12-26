======================================================================================
Sample java programs that illustrate the usage of the Oracle Spatial Java API
======================================================================================

1) SdoPrint
-----------

Prints out the geometries in a table. Shows how to read geometries and examine their content.

* Usage:

SdoPrint - Oracle Spatial (SDO) read
Parameters:
<Connection>:    JDBC connection string
                 e.g: jdbc:oracle:thin:@server:port:sid
<User>:          User name
<Password>:      User password
<Table name>:    Table to print
<Geo column>:    Name of geometry colum,
<Predicate>:     WHERE clause
<Print Style>:   0=none, 1=raw, 2=format, 4=details
<Fast Unpickle>: 0=no, 1=yes

* Examples:

- Print out the geometry of Denver county:

java SdoPrint jdbc:oracle:thin:@127.0.0.1:1521:orcl111 scott tiger us_counties geom "where county='Denver'" 4


2) SdoExport
------------

Exports the geometries in a variety of formats (WKT, WKB, GML, ...). Shows how to read geometries and convert them to a variety of formats.

* Usage:

SdoExport - Oracle Spatial (SDO) export
Parameters:
<Connection>:    JDBC connection string
                 e.g: jdbc:oracle:thin:@server:port:sid
<User>:          User name
<Password>:      User password
<Table name>:    Table to export
<Geo column>:    Name of geometry colum,
<Predicate>:     WHERE clause
<Output File>:   Name of output file
<Output Format>: Format to be used for the output
                 JAVA = serialized Java objects
                 WKT = OGC Well-Known Text
                 WKB = OGC Well-Known Binary
                 GML = OGC GML
                 GML3 = OGC GML3
<Fast Pickle>:  [0=no], 1=yes

* Examples:

Export all counties in Colorado in GML:

java SdoExport jdbc:oracle:thin:@127.0.0.1:1521:orcl111 scott tiger us_counties geom "where state='Colorado'" us_counties_co.xml gml


3) SdoImport
------------

Imports back previously exported geometries. Shows how to convert geometries from various formats (GML, WKT, WKB, ...) and insert them into an existing database table.

* Usage:

SdoImport - Oracle Spatial (SDO) Import
Parameters:
<Connection>:   JDBC connection string
                e.g: jdbc:oracle:thin:@server:port:sid
<User>:         User name
<Password>:     User password
<Table name>:   Table to import (must already exist)
<Geo column>:   Name of geometry colum,
<ID column>:    Name of gid colum,
<Input File>:   Name of input file
<Input Format>: Format to be used for the output
                  JAVA = serialized Java objects
                  WKT = OGC Well-Known Text
                  WKB = OGC Well-Known Binary
                  GML = OGC GML
                  GML3 = OGC GML3
<Commit>:       [0=commit once], 1=autocommit, other= commit interval
<Truncate>:     [0=no], 1=yes
<Fast Pickle>:  [0=no], 1=yes

* Example:

Import the counties from Colorado back into a table that you need to create first:

CREATE TABLE US_COUNTIES_CO (
  ID NUMBER,
  GEOM SDO_GEOMETRY
);

java SdoImport jdbc:oracle:thin:@127.0.0.1:1521:orcl111 scott tiger us_counties_co geom id us_counties_co.xml gml

4) SdoLoadShape
---------------

Load an ESRI shape file into a database table. Shows how you can write your own loader.

* Usage:

SdoLoadShape - Oracle Spatial (SDO) Shapefile loader
Parameters:
<Connection>:   JDBC connection string
                e.g: jdbc:oracle:thin:@server:port:sid
<User>:         User name
<Password>:     User password
<Table name>:   Table to load into
<Geo column>:   Name of geometry colum,
<ID column>:    Name of id colum,
<Shape File>:   Name of shape file (without .SHP extension)
<SRID>:         SRID to be used for geometries
<Create>:       [0=no], 1=yes
<Commit>:       [0=commit once], 1=autocommit, other= commit interval
<Fast Pickle>:  [0=no], 1=yes
<Verbose>:      [0=no], 1=yes

* Example

Load world countries from shape file WORLD_COUNTRIES.SHP into a new table called COUNTRIES.

java SdoLoadShape jdbc:oracle:thin:@127.0.0.1:1521:orcl111 scott tiger countries geom id world_countries 8307 1

5) SdoCall
----------

Shows how to call a stored function or procedure that returns a geometry object.

* Usage:

SdoCall - Oracle Spatial (SDO) procedure call tests
Parameters:
<Connection>:  JDBC connection string
               e.g: jdbc:oracle:thin:@server:port:sid
<User>:        User name
<Password>:    User password
<Procedure>:   Stored procedure to call

* Example:

java SdoCall jdbc:oracle:thin:@127.0.0.1:1521:orcl111 scott tiger "{? = call sdo_geom.sdo_buffer(sdo_geometry('point(-123 45.7)',8307),4000,0.05)}"

NOTE:

Prior to compiling and running the examples, make sure your Java class path
is correctly set. You can run SETUP_111.BAT to do this for you.