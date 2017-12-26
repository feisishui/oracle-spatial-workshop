ESRI Shapefile to Oracle spatial converter 4.7
==============================================

(Last updated by: Albert Godfrind on: 20-Feb-2005)

1. Warning
----------

The shape-to-sdo program is a simple tool that allows you to convert ESRI
shapefiles into a format suitable for loading in an Oracle database for use
by Oracle spatial.

The shapefile converter is UNSUPPORTED and provided on an "AS-IS" basis. It
is provided with source code and a makefile, and can be built on any Unix or
NT platform. The distribution includes an executable for the WIN32 (NT/W2K/XP)
platform.

See sections 5.6 to 5.8 for important notes on decimal points vs. commas,
character sets and reserved words.

2. Files included in this package
---------------------------------

   shp2sdo.c         main program
   dbfopen.c         reads and decodes DBF files
   shpopen.c         reads and decodes SHP and SHX files
   shapefil.h        descibes the structures of shapefiles
   shp2sdo.exe       executable for Windows NT
   makefile
   readme.txt        this file

3. Description
--------------

The converter reads the geometries and attributes in an ESRI shape file and
generates:
 - An SQL script for creating the spatial layer in the Oracle database and
   updating the spatial metadata
 - An SQL script for generating the spatial index
 - The SQL Loader control file(s) for loading the spatial layers
 - Data file(s) ready for loading into the database.

It will generate a single table containing all attributes and a geometry
column. It can optionally add an identification column to the table.

The data can either be generated as a separate data file (the default),
or can be generated within the control file.

The converter will automatically generate the updates to the spatial metadata.
Dimension bounds are extracted from the source shape file, but can be
overriden.

It also generates the definition of the spatial index (RTREE).

Note that the converter does not generate any storage parameters (tablespaces,
extent size, etc).

See the end of this note for a history of changes.

4. Usage notes
--------------

Arguments are supplied on the command line as arguments and options. The ordering
of options and arguments is generally irrelevant. The command performs minimal
checking of the validity of the options and arguments. The option "-h" will
display the usage of the command.

If the program is invoked without any arguments, then you will be prompted for
options and names to be used. Most prompts will provide reasonable default
values.


4.1 Command line syntax
-----------------------

Usage:

 shp2sdo <shapefile> <out_table>
         -g <geometry column>
         -i <id_column>
         -n <start_id> -p -d -f <nr decimals> -s <srid>
         -v <version>
         -x (Xmin,Xmax) -y (Ymin,Ymax)
         -t <tolerance>
         -l <loading mode>
         -V

    shapefile            Name of input shape file
                         (Do not include suffix .shp .dbf or .shx)

    out_table            Name of spatial table in the database. This name will
                         also be used to prefix the generated files. If not
                         specified, then the name of the shape file will be
                         used.

    -g geometry column   Name of the column used for the SDO_GEOMETRY object.
                         If not specified, then the geometry column will be
                         called GEOM

    -i [id column]       If specified, the converter will add a numeric column
                         to the table created in the database. If the option is
                         specified without any name, then the column will be
                         called ID. Note that this column will be defined as the
                         primary key of the resulting table.

    -n start_id          This is the starting value for the automatic numbering
                         of the id column. If not specified, then the numbering
                         starts at 1

    -v version           Version of Oracle for which the output will be generated.
                         Can be specified as 8.1.5 or later. This will affect the
                         generation of metadata updates: for 8.1.5, updates go to
                         SDO_GEOM_METADATA, for others, they go to USER_SDO_GEOM_
                         METADATA. If no version is specified, 8.1.7 will be used.

                         Also, for 8.1.5, single-digit GTYPES will be generated.
                         For 8.1.6 and later, 4-digit GTYPES are generated.

                         See also the section on restrictions at the end of this
                         note.

    -p                   By default, single points are generated to use the
                         optimized SDO_POINT attribute in the geometry object.
                         Specifying this option will tell the converter to
                         use the same mechanism as the other geometries (SDO_
                         ELEM_INFO and SDO_ORDINATES)

    -d                   By default, the converter will separate the output data
                         from the control file. Specifying this option tells
                         it to include the data within the control file instead.

    -s                   Specify the SRID (spatial reference system ID to be used).

    -f nr_decimals       Specify the number of decimals for the coordinates in the
                         output data. The default is 6 decimals on most platforms.

                         See also the section on restrictions at the end of this
                         note.

    -l loading_mode      Specify the loading mode to be used by SQL*Loader, as one
                         of INSERT, APPEND, REPLACE, or TRUNCATE.
                         If none specified, then SQL*Loader uses INSERT by default

    -x (Xmin,Xmax)       By default, dimension bounds are extracted from the
    -y (Ymin,Ymax)       shapefile. However, there is a possibility that multiple
                         files will have different bounds. This is not allowed
                         by Oracle Spatial, if those layers have to be joined in
                         spatial queries. The -x and -y options allow you to
                         override the bounds during the conversion. The
                         alternative solution is to manually correct the generated
                         SQL scripts prior to executing them.

                         Note that the bounds must be specified exactly as shown,
                         i.e. without space, with a comma separator, and within
                         parentheses. Also, both -x and -y have tyo be specified.

    -t tolerance         Specify the tolerance setting for the layer. If not specified
                         0.00000005 will be used.

    -V                   Verbose: will cause additional information to be
                         displayed during the conversion.

Output files:

   <layer>.sql - creates the spatial table and populates the USER_SDO_GEOM_METADATA table
   <layer>_sx.sql - creates the spatial index
   <layer>.ctl - control file for loading the table
   <layer>.dat - data file for loading the table (*)

   (*) not generated if -d is specified. In this case, the data is included
       inside the control file.

4.2 Examples
------------

(1) Simple conversion of the STATES shapefile into a table with the same
    name. Use all defaults.

    shp2sdo states

    shp2sdo - Shapefile(r) To Oracle Spatial Converter
    Version 2.8 01-May-2000
    Copyright 1997,1998,1999 Oracle Corporation

    Processing shapefile STATES into spatial table STATES
    Data model is OBJECT/RELATIONAL
      Oracle version is 8.1.5
      Geometry column is GEOM
      Points stored in SDO_POINT attributes
      Data is in a separate file(s)
    Conversion complete : 56 polygons processed
    The following files have been created:
      STATES.sql :  SQL script to create the table
      STATES.ctl :  Control file for loading the table
      STATES.dat :  Data file

(2) Convert shapefile HIWAYS into the ROADS spatial table. Generate unique IDs
    and override the layer bounds. The "verbose" option gives additional
    details about the conversion process.

    shp2sdo hiways roads -i -x (-180,180) -y (-90,90) -V

    shp2sdo - Shapefile(r) To Oracle Spatial Converter
    Version 2.8 01-May-2000
    Copyright 1997,1998,1999 Oracle Corporation

    Processing shapefile HIWAYS into spatial table ROADS
    Data model is OBJECT/RELATIONAL
      Oracle version is 8.1.5
      Geometry column is GEOM
      Id column is ID
      Numbered from 1
      Points stored in SDO_POINT attributes
      Data is in a separate file(s)
      Bounds set to X=[-180.000000,180.000000] Y=[-90.000000,90.000000]
    Shape File:
      Size : 4125804 bytes
      Number of shapes : 239
      Shape type : 3 = Linestring(s)
      Bounds : X=[-123.392487,-67.781715] Y=[25.748760,49.000599]
      Bounds used: X=[-180.000000,-90.000000] Y=[180.000000,90.000000]
    Attribute file:
      Number of records : 239
      Number of attributes : 1
      Header length : 65
      Record length : 36
    Processing Object 100 of 239...
    Processing Object 200 of 239...
    Processing Object 239 of 239...
    Conversion complete : 239 linestrings processed
    The following files have been created:
      ROADS.sql :   SQL script to create the table
      ROADS.ctl :   Control file for loading the table
      ROADS.dat :   Data file

(3) Convert the CITIES shapefile. The geometry column will be called LOCATION
    and column CITY_NR will be used to number the rows. Data should be kept
    inside the control file. Generate output for version 8.1.6

    shp2sdo cities -g location -i city_nr -d -v 8.1.6

    shp2sdo - Shapefile(r) To Oracle Spatial Converter
    Version 2.8 01-May-2000
    Copyright 1997,1998,1999 Oracle Corporation

    Processing shapefile CITIES into spatial table CITIES
    Data model is OBJECT/RELATIONAL
      Oracle version is 8.1.6
      Geometry column is LOCATION
      Id column is CITY_NR
      Numbered from 1
      Points stored in SDO_POINT attributes
      Data is in the control file(s)
    Conversion complete : 195 points processed
    The following files have been created:
      CITIES.sql :  SQL script to create the table
      CITIES.ctl :  Control file for loading the table

(4) Convert the COUNTIES shapefile. Let the program guide you using prompts:
    the output table will be called COUNTY, the geometry column will be called
    SHAPE, column COUNTY_NR will be used to number the output rows, generate
    data inside the control files, and override the bounds.

    shp2sdo

    shp2sdo - Shapefile(r) To Oracle Spatial Converter
    Version 2.8 01-May-2000
    Copyright 1997,1998,1999 Oracle Corporation

    Input shapefile (no extension): counties
       Shape file counties.shp contains 3230 polygons
    Output layer [counties]: county
    Output data model [O]:
    Oracle version [8.1.5]:
    Geometry column [GEOM]: shape
    ID column []: county_nr
    Starting number [1]:
    Generate data inside control files ? [N]: y
    Bounds: X=[-179.144806,179.764160] Y=[-14.605210,71.332649]
    Override ? [N]: y
    Xmin [-179.144806]: -180
    Xmax [179.764160]: +180
    Ymin [-14.605210]: -90
    Ymax [71.332649]: +90
    Processing shapefile counties into spatial table COUNTY
    Data model is OBJECT/RELATIONAL
      Oracle version is 8.1.5
      Geometry column is SHAPE
      Id column is COUNTY_NR
      Numbered from 1
      Points stored in SDO_POINT attributes
      Data is in the control file(s)
      Bounds set to X=[-180.000000,180.000000] Y=[-90.000000,90.000000]
    Conversion complete : 3230 polygons processed
    The following files have been created:
      COUNTY.sql :  SQL script to create the table
      COUNTY.ctl :  Control file for loading the table


5. Restrictions and limitations.
--------------------------------

5.1 Supported shapes

The converter only support the simple 2D shapes:

  SHPT_POINT        1
  SHPT_ARC          3
  SHPT_POLYGON      5
  SHPT_MULTIPOINT   8


5.2 Precision of coordinates

The coordinates in the shape file are converted to decimal notation in the
output file using standard C printf() functions with the "%f" format
specifier. The binary-to-decimal conversion may not produce the exact same
decimals as in the original 64-bit floating point numbers used in the shape
files.

The coordinates are rounded to the number of decimals you specify using
the '-f' option. If this option is not specified, then the conversion takes
place according to the conversion rules for the "%f" format, which may vary
from one platform to another, but will produce 6 decimals on most platforms.


5.3 Polygon orientation and ring identification

The shape file structure does not distinguish between ring types. The only
way to identify an outer ring from an inner ring is by checking their
orientation: outer rings are in clockwise orientation, while inner rings are
in counter-clockwise orientation. Note that Oracle Spatial uses the opposite
convention.

The shape file converter will find the orientation of each ring in a polygon,
identify it as as "outer" (element type 1003) or "inner" (element type 2003)
ring. It will also invert the orientation to match Oracle requirements.

The geometry type is derived from the number of outer rings in the geometry.
If the geometry contains only one outer ring (element type 1003), with any
number of inner rings, then it is coded as geometry type 3. If it contains
more than one outer ring, then it is coded as geometry type 7.

Oracle Spatial expects inner rings (i.e. voids) of a polygon with voids to
directly follow their outer ring (polygon contour). However the shape file
structure does not impose such a convention. There is no attempt in the
shapefile converter to re-order the rings in the correct order. However, most
GIS systems that generate shapefiles follow that convention, so the rings
in the shapefiles tend to be in the correct order.

There is also no attempt to verify that voids (inner rings) are actually
contained inside outer rings. Any invalid orientation in the source shape
file will be carried along in the resulting Oracle table.


5.4 SQL*Loader restrictions

The data for each output row is broken down into multiple physical records.
This is necessary since physical records processed by SQL*Loader are limited
in size..

Bug 1078976 prevents SQL*Loader from working correctly when a VARRAY is broken
down into multiple physical records. The converter automatically compensates
for that problem by inserting a dummy record ("#+) before the first physical
record of each VARRAY that needs multiple physical records.

The problem exists in all versions of SQL*Loader in 8i (8.1.5, 8.1.6, 8.1.7).
It no longer exists in 9I. Therefore, the converter only performs this
correction if the Oracle version specified when running SHP2SDO is 8.x.

Note however that the problem exists in the SQL*Loader tool. If you use an
8.1.7 SQL*Loader client, then you will need to specify version 8.1.7 when
running SHP2SDO, so that the output can be correctly processed by that version
of SQL Loader.


5.5 Null values

It is possible for the DBF file to contain blank values for some attributes.
Blank attributes are set to NULL inside the database.


5.6 Language dependencies: decimal point vs comma

The numbers generated in the data files use the point character as a decimal
separator. However the client environment where SQL*Loader is running may be
using a comma as decimal separator. This will be the case for all w
windows-based systems that use a western european language other than english
such as France, Germany, Italy, Spain, Sweden, etc.

When this is the case, then SQL/loader may fail to load the data and report
"invalid number" errors in the log.

To get the data loaded correctly, you can temporarily override the default
language parameters by setting the NLS_LANG environment prior to running
SQL*Loader.

On Windows, just set it using syntax such as the following:

  C:\> SET NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1

To get back to the default behaviour, unset the environment variable.
On Windows do it like this:

  C:\> SET NLS_LANG=

You can also set it permanently for all users by modifying the NLS_LANG
setting in the registry key HKEY_LOCAL_MACHINE\SOFTWARE\ORACLE\HOMEn.

The last element of the NLS_LANG setting is the character set used for
reading the strings in the data file. See 5.7 for a discussion on this.


5.7 Character set dependency

When SQL*Loader loads the data, it assumes that all strings in the input
file are encoded in the character set specified in the NLS_LANG parameter.
On Windows platforms, this is automatically set by the Oracle installer to
WE8MSWIN1252, which includes support for the ISO Latin 1 ,alphabet, i.e.
supports all accented letters and other diacritical marks used in western
european languages.

However, the default language setting on Unix platforms uses the US7ASCII
character set, which does not support any accented letters. The load process
will convert characters and my lose accents or fail to convert some characters
(which get replaced with '?' signs).

So, if you perform the actual loading on a Unix platform, and your input data
does contain accented letters, then you need to explictly set the NLS_LANG
environment prior to running SQL*Loader so as to match the character set of
the input data. For instance:

  $ NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1
  $ export NLS_LANG


5.8 Reserved words

The shape file may contain columns whose names are reserved words in Oracle
such as ORDER, DATE or NUMBER. The shp2sdo program does not attempt to locate
or change those words. Therefore, you will need to modify the SQL scripts and
CTL file and replace those names with valid alternatives (such as ORDER_NO,
SHIP_DATE or PHONE_NUMBER).


5.9 Supported data types

The shp2sdo program supports the following datatypes for attributes found in
the DBF files

DBF Type    Definition and format                 SQL Datatype
--------    ---------------------------------     ------------
N           Decimal number                        NUMBER
D           Date in format DDDDMMYY               DATE
C           Character string (max N chars)        VARCHAR2(n)
F           Floating point number                 NUMBER
L           Boolean



6. Change History
-----------------

* Revision 4.7  20-Feb-2005 Albert Godfrind
*                         -- Implement support for datatype D (date) in DBF file
*                         -- Added documentation on supported datatypes
* Revision 4.6  07-Apr-2004 Albert Godfrind
*                         -- Implement support for datatype F in DBF file
* Revision 4.5  15-Mar-2004 Albert Godfrind
*                         -- Documentation changes only
*                         -- Added documentation on decimal separator
*                         -- Added documentation on character sets
*                         -- Added documentation on reserved words
* Revision 4.4  26-Oct-2003 Albert Godfrind
*                         -- Corrected handling of null (blank) numeric attributes
*                            (see dbfopen.c - DBFReadAttribute() )
*                         -- Added support for null geometries
*                         -- Added support for multi-points
* Revision 4.3  26-Jul-2003 Albert Godfrind
*                         -- Add name to primary key constraint on ID column
*                         -- Changed default database version to 9.2
* Revision 4.2   8-May-2003 Albert Godfrind
*                         -- Fix bug in DetermineRingOrientation
* Revision 4.1  14-Mar-2003 Albert Godfrind
*                         -- Identify outer and inner rings of polygons
*                         -- Orient inner and outer rings following the Oracle Spatial convention.
*                         -- Identify polygon with voids as single-element polygons (type 3)
*                         -- Code cleanup
* Revision 4.0  26-Feb-03 Albert Godfrind
*                         -- Removed support for relational model
*                         -- Generate index creation script
*                         -- Fix handling of long integer attributes
*                            (see dbfopen.c - DBFReadAttribute() )
* Revision 3.2  14-Dec-01 Albert Godfrind
*                         -- Add -t option to control tolerance
*                         -- Changed default database version to 9.0.1
* Revision 3.1  12-Dec-01 Albert Godfrind
*                         -- Output number generation: use %f instead of %g
* Revision 3.0  08-Aug-01 Albert Godfrind
*                         -- Implemented support for 9i
*                         -- Removed workaround for sql*loader bug when loading multi-record varray for 9.0.1
*                         -- Add -l option to control SQL Loader processing mode
*                            (INSERT, APPEND, REPLACE, or TRUNCATE)
* Revision 2.10 07-Aug-01 Albert Godfrind
*                         -- Corrected flag usage: -f for decimals instead of -d
*                         -- Do not print trailing 0 decimals
* Revision 2.9  06-Aug-01 Albert Godfrind
*                         -- Generate 4-digit GTYPES (200x)
*                         -- control precision of ordinates in output data file
* Revision 2.8  01-May-01 Dan Abugov / Albert Godfrind
*                         -- implement -s for srid field (both geom and user_sdo_geom_metadata)
*                         -- implement 8.1.6 support (metadata)
* Revision 2.7  01-Nov-99 Albert Godfrind
*                         -- implement 64K limit per physical record in control file
*                         -- compensate for sql*loader bug when loading multi-record varray
* Revision 2.6  26-Oct-99 Albert Godfrind
*                         -- corrected generation of point data in SDO_ORDINATES
* Revision 2.5  24-Oct-99 Albert Godfrind
*                         -- corrected uppercasing (table names only)
*                         -- added "TRAILING NULLCOLS" to all control files
* Revision 2.4  12-Oct-99 Albert Godfrind
*                         -- added 'verbose' and 'debug' options
*                         -- separate data from control files
*                         -- added option to control point storage for object format
*                         -- create files with geometry as last column
*                         -- automatic generation of ID columns
*                         -- rewrote argument parsing and prompting
*                         -- removed SQLPLUS-specifics from generated SQL scripts
* Revision 2.3  13-Jul-99 Albert Godfrind
*                         -- corrected generation of SDO_GTYPE for compound structures
* Revision 2.2  01-Jul-99 Albert Godfrind
*                         -- Uppercase output table and column name for object model
*                         -- Added prompting for parameters
*                         -- Allow overriding of dimension information
* Revision 2.1  04-May-99 Albert Godfrind
*                         -- Added multi-line output for object model
* Revision 2.0  01-May-99 Albert Godfrind
*                         -- Implemented support for Oracle8i object model
* Revision 1.9  03-Dec-98 Albert Godfrind
*                         -- Ported to NT and Digital OpenVMS
*                         -- Added tracing and debugging messages
*                         -- Added checks on malloc() and realloc()
* Revision 1.8  08-Jan-98 Dan Geringer
*                         -- Removed _ATT suffix from attribute table
* Revision 1.7  17-Dec-97 Dan Geringer
*                         -- Change C++ comment to C comment
*                         -- Removed all trailing blanks from VARCHAR attributes
* Revision 1.6  05-Dec-97 Dan Geringer
*                         -- Added starting GID
*                         -- Fixed geometry extraction and coordinate wrap
*                         -- Removed MAXCODE
*                         -- Integrated DBF file
*                         -- Added APPEND to control files
*                         -- Added NULLIF column_name = BLANKS to control files
*                         -- Added ability to store attributes in _SDOGEOM table
*                         -- .shp, .dbf and .dbx extensions can be lower or upper case
*                         -- Fix point coordinate extraction
* Revision 1.5  07-Aug-97 John F. Keaveney
*                         -- Wrote Version 1 of the utility
