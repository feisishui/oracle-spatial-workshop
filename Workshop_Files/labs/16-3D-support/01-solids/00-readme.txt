==========================================================
3D Support - Solids
==========================================================

1) import building footprints

01-IMPORT-BUILDING-FOOTPRINTSS.BAT

This imports a set of some 500 building footprints into table BUILDING_FOOTPRINTS. 
The footprints are in the British National Grid projection (SRID 27700)

2) extrude the buildings to 3D solids. 

02-EXTRUDE-BUILDINGS.SQL

Use the height and ground height specified for each footprint.
The results go in table BUILDINGS_EXT.
The script also sets the SRID of the results to the proper 3D coordinate system (SRID 7405)

3) Enable XDB access

03-SETUP-XDB-ACCESS.SQL

4) Publish the extruded 3D buildings to KML in XDB

04-PUBLISH-EXTRUDED-BUILDINGS-TO-KML.SQL

Use Google Earth to access the KML file in the database via ftp (ftp://127.0.0.1/public/Buildings/buildings_ext.kml) or http (http://127.0.0.1:8080/public/Buildings/buildings_ext.kml)

Note that this script uses a function "SNAP_TO_GROUND()", created by the script, that corrects the elevationn of the buildings so that they appear on the ground in Google Earth.


5) Publish the extruded 3D buildings to CityGML in XDB

05-PUBLISH-EXTRUDED-BUILDINGS-TO-GML.SQL

Use Autodesk LandXplorer to view the resulting GML file via WebDAV

6) Load 3D buildings from a CityGML file

The cityGML file "CityGML_British_Ordnance_Survey.xml" is provided by the Ordnance Survey. You can download it, along with other sample data sets, from http://www.citygml.org.

It contains the original set of buildings used in the previous lab: we used their footprints to produce the extruded buildings.

06-LOAD-BUILDINGS-FROM-CITYGML.BAT

  This uses the CGMLToSDO program to parse the CityGML file and load the results into the tables.

7) Publish the 3D buildings to KML in XDB

04-PUBLISH-BUILDINGS-TO-KML.SQL

Use Google Earth to access the KML file in the database via ftp (ftp://127.0.0.1/public/Buildings/buildings.kml) or http (http://127.0.0.1:8080/public/Buildings/buildings.kml)

8) Setup spatial indexes

08-SETUP-SPATIAL-INDEXES.SQL

This creates indexes on the three tables processed:

Table                 Dim   SRID
BUILDING_FOOTPRINTS   2D    27700
BUILDING_EXT          3D    7405
BUILDINGS             3D    7405

9) Perform some 3D queries

09-SPATIAL_QUERIES.SQL


