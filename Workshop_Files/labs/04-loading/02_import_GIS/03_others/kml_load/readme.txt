This note explains the process for digitizing and loading the results into Oracle Spatial.

Digitizing the shapes is done using the web application available at http://www.daftlogic.com/projects-google-maps-area-calculator-tool.htm. Once a shape is digitized, you can download the resulting kml file onto your machine.

Once you are done, you need to copy the kml files into a directory on the database server. This is because we will read them from the database.

The "Data" directory contains a few kml files digitized using the above technique.

The "Scripts" directory contains the scripts you need to load the KML files into the database and extract the shapes into geometry types understandable by Oracle Spatial and Mapviewer.

Here are the steps to follow:

1) Create a directory
---------------------

This is required. Accessing external files from inside the database is subject to security and access limits. To make that possible, you need do to the following:

- create a directory object that points to an actual file system directory
- grant the proper access rights on that directory to the user who will do the load.

See script 01_CREATE_DIRECTORY.SQL

It creates a directory called KML_DATA_DIR, like this:

  SQL> create or replace directory kml_data_dir as '/media/sf_Data/Files/Partners/ZA/AdaptIT/area_capture/data';

Then it grants access to the user SCOTT:

  SQL> grant read, write on directory kml_data_dir to scott;

Modify the script to match your environment. 

IMPORTANT: run this script as SYS or SYSTEM.

2) Create a table to receive the results.
-----------------------------------------

See script 02_CREATE_TABLE_FIELDS.SQL. It creates a table called FIELDS with the following structure:

Name           Null?    Type
-------------- -------- -------------------
ID             NOT NULL NUMBER
FILE_NAME               VARCHAR2(40)
KML                     CLOB
GEOMETRY                PUBLIC.SDO_GEOMETRY


3) Setup the list of the files to load
--------------------------------------

See script 03_POPULATE_FIELDS.SQL. It shows how to initialize the FIELDS table:

SQL> insert into fields (id, file_name) values (1, '31072015-434j1a1.kml');
...
SQL> commit;


4) Load the KML files as CLOBs
------------------------------

For this we use SQL, specifically the DBMS_LOB.LoadCLOBFromFile() procedure. Note that this requires that you define a directory inside Oracle that points to the folder where you stored the KML files. You also need to give the proper rights to the user that

See script 04_LOAD_KML_FILES.SQL. It processes the FIELDS table and loads the content of each KML file into the KML column (a CLOB).


5) Convert the KML into geometries
----------------------------------

See script 05_CONVERT_KML_TO_GEOMETRIES.SQL.

For each row in the FIELDS table, the script extracts the geometry definition from the KML text, converts it into a geometry object, and loads that into the GEOMETRY column.

The update statement does the following:

* Casts the kml column (a string) into an XMLType: 
  xmltype(kml)
* Extracts the <Polygon> element from that XML:
  xmltype(kml).extract('//Polygon','xmlns="http://www.opengis.net/kml/2.2')
* Turns the result back into a string (that is what from_kmlgeometry() expects
  xmltype(kml).extract(...).getclobval()
* Converts that string into a geometry object
  sdo_util.from_kmlgeometry (...)
* Finally makes the result 2D (the input KML is 3D)
  sdo_cs.make_2d(...)

An additional update sets the coordinate system to the proper value (lat/long GPS).


6) Add the spatial index
------------------------

See script 06_ADD_SPATIAL_INDEX.SQL


7) Define a theme for Mapviewer
-------------------------------

This is needed in order to make the data available to OBIEE.

See script 07_DEFINE_THEME.SQL. It uses SQL to define a theme (FIELDS) by inserting a row in the themes table (USER_SDO_THEMES). The label is set to the content of the ID column.

The ID column can then be used to link each field with BI data.

